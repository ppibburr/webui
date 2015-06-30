namespace WebUI {
	public class Widget : Object, HTML, EventTarget {
		public string id {get; construct;}
		public Connection? socket {get; construct;}
		public View view {get; construct;}
		public Container? parent {get; private set;}
		
		protected void set_container(Container container) {
			parent = container;
		}
		
		public void read_property(string prop) {
          socket.request("$('%s').%s()".printf(id, prop), (data)=>{
			  print("fin");
		  });			
		}

		
		public void write_string_property(string prop, string val) {
			
		}	
		
		public Widget(View view, string? id=null) {
			if (id == null) {
				id = "foo";
			}
			
			Object(view:view, id:id, socket:view.connection);
		}
		
		construct {
		    this.view.own(this);
		}
		
		public string get_style_property(string name) {
			return "";
		}
		
		public void set_style_property(string name, string val) {
			
		}
		
		public string style(string name, owned string? val=null) {
			if (val == null) {
				val = get_style_property(name);
			} else {
				set_style_property(name, val);
			}
			
			return val;
		}
		
		public virtual string render() {
			return "";
		}
		
		public virtual string jsui_code() {
			return "// no widget base initializer thus far\n";
		}
	}
}
