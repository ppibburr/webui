/*
 * This file is part of the neutron project.
 * 
 * Copyright 2013 Richard Wiedenhöft <richard.wiedenhoeft@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using Neutron;
namespace WebUI {
	public string? data_dir() {
		var q = Environment.get_variable ("WEBUI_DATA_DIR");
		if (q == null) {
			return "./share/webui/data";
		}	
		return q;
    }
	
	public class App : GLib.Object {
		public Http.Server http {get; construct set;}
		public string route {get; construct set;}	
		private View[] views;
		public uint port {get; construct set;}
		
		public App(uint port, string route = "") {
		  Object(port:port, route:route);
		}
		
		construct {
			this.http = new Http.Server();
			http.select_entity.connect(on_select_entity);
			http.port = (uint16)port;
			
			this.views = new View[0];	
		}
		
		public void add_view(View view) {
			views += view;
		}
			
		static construct {
		  var tcontrol = new ThreadController(4);
		  tcontrol.push_default();
		}

		protected void on_select_entity(Http.Request request, Http.EntitySelectContainer container) {
			print(views.length.to_string());
			
			print(@"$(route)  :  %s", request.path);
			if (@"$(route)" == request.path) {
				container.set_entity(new Http.StaticEntity("text/html", render()));
			} else if (@"$(route)/socket" == request.path) {
				var entity = new Websocket.HttpUpgradeEntity();
				entity.incoming.connect(on_incoming_ws);
				container.set_entity(entity);
			} else if ( FileUtils.test(@"$(data_dir())/"+request.path, FileTest.EXISTS)) {
				string data = "";
				size_t len;
				string mime = "html";
				var f = request.path.split(".");
				
				if (f[f.length-1] == "css") {
					mime = "css";
				} else if (f[f.length-1] == "js") {
					mime = "javascript";
				}
				
				FileUtils.get_contents(@"$(data_dir())/"+request.path, out data, out len);
				container.set_entity(new Http.StaticEntity(@"text/%s".printf(mime), data));
			}
			
		}

		protected void on_incoming_ws(Websocket.Connection conn) {
			conn.ref();
			conn.on_message.connect(on_message);
			conn.on_error.connect(on_error);
			conn.on_close.connect(on_close);
			conn.start();
		}
		
		public Widget? find_widget(string id) {
			Widget? q = null;
			foreach (var view in views) {
	            q = view.find(id);
				if (q != null) {
					break; 
				}
			}
			return q;
		}
		
		
		protected void on_message(string message, Websocket.Connection conn) {
			var raw = message.split(",");
			if (raw[0] == "event") {
			  var wid = raw[1];
			  var type = raw[2];
			  var data = raw[3];
			  
			  var q = find_widget(wid);
			  
			  if (q != null) {
				  EventType et = EventType.BAD;
				  
				  if (type == "activate") {
					  et = EventType.ACTIVATE;
				  } else if (type == "down") {
					  et = EventType.DOWN;
				  } else if (type == "release") {
					  et = EventType.RELEASE;
				  } else if (type == "toggle") {
					  et = EventType.TOGGLE;
				  } else if (type == "click") {
					  et = EventType.CLICK;
				  } else if (type == "change") {
					  et = EventType.CHANGE;
				  }
				  
				  q.event(et, data);
			  }
			  
			  print("%s %s %s\n", wid, type, data);
		    }
			
		}
		protected void on_error(string msg, Websocket.Connection conn) {
			message(msg);
		}
		protected void on_close(Websocket.Connection conn) {
			conn.unref();
		}
		
		public string render() {
		  string template = "";
		  string initializers = "";
		  size_t len;
		  
		  FileUtils.get_contents(@"$(data_dir())/template.html", out template, out len);

          string content = "";
          foreach (var view in views) {
			content += view.render();
			initializers += view.oncreate();
   		  }
			
		
			
		  return template.printf(initializers, content);
		}
	}

	public enum EventType {
	  BAD = -1,
	  TOGGLE,
	  ACTIVATE,
	  CLICK,
	  DOWN,
	  RELEASE,
	  CHANGE
	}
	  
  public class View : Object {
	  public string initializers;
	  public string layout;
	  public string name {get; set;}
	  private Widget[] _children; 
	  
	  private int _id;
	  public string id() {
		    return "webui_view_%d".printf(_id);
	  }
	  
	  public signal void init();
	  public signal void activate();
	  
	  public View (string name) {
		  Object(name:name);
	  }
	  
	  private static int _nxt_id;
	  protected static int next_id() {
		  return _nxt_id += 1;
	  }
	  
	  static construct {
		 _nxt_id  = 0;
	  }
	  
	  construct {
		  _id = next_id(); 
		  initializers = "";
		  layout       = "";
	  }
	  
	  public void attach(Widget w) {
		  layout += w.render_html();
		  initializers += w.render_js();
		  _children += w;
	  }
	  
	  public Widget? find(string id) {
		  Widget? q = null;
		  foreach (var c in _children) {
			  if (c.id == id) {
				  q = c;
			  }
		  }
		  
		  return q;
	  }
	  
	  public string oncreate() {
		  return """
			$(document).on("pagecreate","#%s",function(){
               %s

			});		  
		  
		  """.printf(id(), initializers);
	  }
	  
	  
	  public string render() {
		  return """
		  <div data-role=page id=%s>
		    <div data-role=main class="ui-content">
		      %s
		    </div>
		  </div>	  
		  """.printf(id(), layout);
	  }
  }

	
  public class Widget : Object {
	public signal void event(EventType evt, string? data); 
	public signal void down();
	public signal void release();
	
	public string id {get; construct set;}
	
	protected static int nxt_id; 
	
	protected int next_id() {
		return nxt_id += 1;
	}
	
	static construct {
		nxt_id = 0;
	}
  
    construct {
	  this.id = @"webui_object_$(next_id())";
	  
	  event.connect((type) => {
		  if (type == EventType.DOWN) {
			  down();
		  } else if (type == EventType.RELEASE) {
			  release();
		  }
	  });	
	}
	
	public virtual string render_html() {
		return "";
	}
	
	public virtual string render_js() {
		return "\n$('#%s').bind('vclick', function() {\n\t;webui.event('%s', 'click');\n});".printf(id,id) +
		"\n$('#%s').bind('vmousedown', function() {\n\t;webui.event('%s', 'mousedown');\n});".printf(id,id) +
		"\n$('#%s').bind('vmouseup', function() {\n\t;webui.event('%s', 'mouseup');\n});".printf(id,id);
	}
	
    public virtual void attach_to(View view) {
  	  view.attach(this);  
	}
	
	public bool enabled {get; set;}
	public void show(bool val) {
		
	}
  }
  
  
  public class Button : Widget {
	  public signal void activate();
	  
	  public string label {get; construct set;}
	  
	  public Button (string label = "") {
		  Object(label:label);
	  }
	  
	  construct {
	    event.connect((event)=>{
		  if (event == EventType.CLICK || event == EventType.ACTIVATE) {
			  activate();
		  }		  		  
		});
	  }
	  
	  public override string render_js() {
		  return base.render_js();
	  }
	  
	  public override string render_html() {
		  return @"<button class=\"ui-btn ui-corner-all webui-object\" id=$id>$label</button>";
	  }  
  }
  
  
  public class Slider : Widget {
	  public signal void change(int data);
	  
	  public override string render_html() {
		  return @"<input id=$id type=\"range\" name=\"$id\" value=\"50\" min=\"0\" max=\"100\" data-popup-enabled=\"true\">";  
	  }
	  
	  public override string render_js() {
		  return "$( document ).bind('change', '#%s' , function(ele, ui) {;\nwebui.event_full('%s','change', $('#%s').val());\n});".printf(id,id,id) + base.render_js();
	  }
	  
	  construct {
	    event.connect((event, data)=>{
		  if (event == EventType.CHANGE) {
			  change(int.parse(data));
		  }		  		  
		});
	  }	  
  }
}



