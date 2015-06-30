namespace WebUI {
	// Single Page Application
	//
	// Multiple Views
	public class View : Object, HTML, EventTarget {
		public string? id {get; construct; default = @"webui_view_$(next_id())";}
		public Widget[] widgets {get; private set;}
		public Widget[] children {get; private set;}		
		
		// Pretty Important
		public Connection connection {get; construct set;}
		
		public View(Connection conn, string id) {
			Object(id:id,connection:conn);
		}
	
	    // ...	
		protected static int _nxt_id = 0;
		protected static int next_id() {
			return _nxt_id += 1;
		} 
		
		construct {
			this.widgets = new Widget[0];
			this.children = new Widget[0];			
			this.connection.views[id] = this;
		}
		
		// Widget-Tracker
		public void own(Widget w) {
			this._widgets += w;
		}
		
		// The HTML of the View
		public new string render() {
		  var content = "";
		  foreach (var w in children) {
			  print(w.render());
			  content += w.render();
		  }
		  return """
		    <div id=%s class=webui-view>
		      %s
		    </div>
		  """.printf(id, content);	
		}
		
		// Tell the client to initialize us
		public void initialize() {
			var code = "";
			foreach (var w in widgets) {
				code += w.jsui_code();
			}
		
		    code += ";\nwebui.n_views += 1;webui.send('status:n_views:'+webui.n_views.toString());";
			
			// DEBUG
			print(code);
			
			connection.exec(code);
		}

		// Get that Widget!
		public Widget? get_widget(string id) {
			foreach (var w in widgets) {
				if (w.id == id) {
					return w;
				}
			}
			return null;
		}
		
		// Has Widget of ID, +id+ ?
		public bool has_widget(string id) {
			if (get_widget(id) != null) {
				return true;
			}
			
			return false;
		}
		
		// Root level node
		public void add(Widget w) {
			this._children += w;
		}		
	}	
}
