namespace WebUI {
using Neutron;
using Gee;
	public class Request {
		public int id;
		public string? result;
		public bool active;
		public delegate void finished_cb(string data); 
		public finished_cb func;
		
		public Request(int id, finished_cb fun) {
			this.id = id;
			active = true;
			this.func = fun;
		}
		
		public void complete(string res) {
			result = res;
			active = false;
			func(this.result);
		}
	}
	
	public class Connection : Object {
	    public Websocket.Connection? socket {get; construct;}
		public HashMap<string, View> views {get; private set;}
		public Gee.ArrayList<Request> requests {get; private set;}
		public string route {get; construct set;}
		protected View _view;
		public View view {get {return _view;} set {
			_view = value;
			exec(@"webui.set_view('$(_view.id)')");
		}}
		
		public int id {get; private set;}
		
		protected static int _nxt_id = 0;
		protected static int next_id() {
			return _nxt_id += 1;
		} 		
		
		public Connection(Websocket.Connection? conn, string route ) {
			Object(socket:conn, route:route);
		}
		
		construct {
			this.id = next_id();
			requests = new Gee.ArrayList<Request>();
			views = new HashMap<string, View>();
			
			socket.ref();

			socket.on_message.connect(on_message);
			// socket.on_error.connect(on_error);
			// socket.on_close.connect(on_close);
			socket.start();	
		}
		
		public void on_message(string message, Websocket.Connection conn) {
			var raw = message.split(":");
			var action = raw[0];
			switch (raw[0]) {
				case "response":
				var id = int.parse(raw[1]);
				
				string[] rest = {};
				
				for (int i = 0; i < raw.length; i++) {
					if (i > 1) {
						rest += raw[i];
					}
				}
				
				response(id, string.joinv(":", rest));
				break;
				case "initialize":
				var id = raw[1];
				foreach (var v in views.entries) {
					v.value.initialize();
				}
				break;
				
				case "event":
				if (raw.length == 3) {
					raw[3] = "";
				}
				foreach (var v in views.entries) {
					if (v.value.has_widget(raw[1])) {
						v.value.get_widget(raw[1]).emit(raw[2], raw[3]);
					    break;
					}
				}
				break;
			}
		}
		
		public void response(int id, string val) {
			foreach (var req in requests) {
				if (req.id == id) {
					req.complete(val);
				}
			}
		}
		
		public void exec(string code) {
			socket.send(@"exec:$code");
		}
		
		public void request(string what, Request.finished_cb fun) {
			var req = new Request(requests.size, fun);
			requests.add(req);
			
			socket.send(@"request:$(req.id):$what");
		}
	}	
}
