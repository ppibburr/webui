namespace WebUI {
	using Gee;
	using Neutron;
	
	public class DumbStruct {
		public Service.connection_func func;
		
		public DumbStruct(Service.connection_func fun) {
			this.func = fun;
		}
	}
	
	public class Service : Object {
		public uint port {get; construct;}
		[CCode (has_target = false)]
		public delegate void connection_func (Connection conn);
		public HashMap<string, DumbStruct> routes {get; private set;}
		public string data_dir {get; construct;}
		public Http.Server server {get; private set;}
		public HashMap<int, Connection> connections {get; private set;}
	
	    public Connection get_connection(int id) {
			return connections[id];
		}
	
		public Service(uint port, string? data_dir = null) {
		   	if (data_dir == null) {
				data_dir = Environment.get_variable ("WEBUI_DATA_DIR");
			}
			
		   	if (data_dir == null) {
				data_dir = "/usr/share/webui/data";
			}			
			
			if (FileUtils.test(data_dir, GLib.FileTest.EXISTS) == false) {
				print(@"WEBUI: WEBUI_DATA_DIR - $(data_dir) WARN NO_EXIST\n");
				
			    data_dir = "share/webui/data";
				
				if (FileUtils.test(data_dir, GLib.FileTest.EXISTS) == false) {
				  print("WEBUI: Error - No data directory found. Try `export WEBUI_DATA_DIR=/path/to/webui/data`\n");
				  assert(FileUtils.test(data_dir, GLib.FileTest.EXISTS));
				}			
			}		
			
			print(@"WEBUI: data directory is - $(data_dir)\n");	
			
			Object(port:port, data_dir:data_dir);
		}
		
		static construct {
			var tcontrol = new ThreadController(4);
			tcontrol.push_default();			
		}
		
		construct {
			this.routes = new HashMap<string, DumbStruct>();
			this.connections = new HashMap<int, Connection>();
			server = new Http.Server();
			server.port = (uint16)this.port;
			server.select_entity.connect(handle);			
		}
		
		public string get_mime_type(string ext) {
			switch (ext) {
				case "js":
				return "text/javascript";
				case "html":
				return "text/html";
				case "css":
				return "text/css";
				case "png":
				return "image/png";
				case "mp3":
				return "audio/mpeg3";
				case "mpg":
				return "video/mpeg";
				default:
				return "text/plain";
			}
		}
		
		public string[]? serve(owned string path) {
			print(@"PATH: $path\n");
			if (path in routes.keys) {
				return {render_libwebui(path), "text/html"};
			}
			
			
            foreach (var route in routes.keys) {
				Regex regex = new Regex ("%s/connection/[0-9]+$".printf(route));
				if (regex.match (path)){
					var split = path.split("/");
					var id = int.parse(split[split.length-1]);
					
					var buff = "";
					
					foreach (var view in get_connection(id).views.entries) {
						buff += view.value.render();
					}
					
					return {buff, "text/html"};
				}
			}
			
			path = "%s%s".printf(data_dir, path);
			
			var q = path.split(".");
			var ext = q[q.length-1];
						
			// A reference to our file
			var file = File.new_for_path (path);

			if (!file.query_exists ()) {
				stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
				return null;
			}			
			
			string buff = "";
			string mime = get_mime_type(ext);
			
			FileUtils.get_contents(path, out buff, null);
	
			return {buff, mime};
		}
		
		public void handle (Http.Request request, Http.EntitySelectContainer container) {
			print("%s\n", request.path);
			foreach (var apath in routes.keys) {				
				if (request.path == @"$apath/socket") {
					on_socket(apath, container);
					return;
				}
			}			
			
			var res = serve(request.path);
		    
		    if (res != null) {
				container.set_entity(new Http.StaticEntity(res[1], res[0]));
			}

		}
		
		public string render_libwebui(string route) {
			string buff = "";
			FileUtils.get_contents(data_dir+"/template.html",out buff, null);
			return buff.printf("ws", "127.0.0.1:8080%s".printf(route));
		}
		
		public void route(string path, connection_func fun) {
		  routes[path] = new DumbStruct(fun);
		}
		
		protected void on_socket(string route, Http.EntitySelectContainer container) {
			var entity = new Websocket.HttpUpgradeEntity();
			entity.incoming.connect((conn) => {
				var c = new Connection(conn, route);
				connections[c.id] = c;
				routes[route].func(c);
				c.exec(@"webui.load_content('$route', '$(c.id)');");
			});
			container.set_entity(entity);
		}
	}
}
