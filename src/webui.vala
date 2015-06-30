
namespace WebUI {	
	public const string VERSION = "0.1.0";
	
	public interface HTML {
		public virtual string render() {
			return "";
		}
	}
	
	
	public interface Container : Widget {
		public virtual void add(Widget w) {
			// this._children += w; 
		}
	} 
	
	public enum EventType {
		UNSUPPORTED,
		CLICKED,
		MOUSE_UP,
		MOUSE_DOWN,
		ACTIVATE,
		CHANGED;
		
		public static EventType from_string(string name) {
			var type = EventType.UNSUPPORTED;
			switch (name) {
				case "changed":
				type = (EventType.CHANGED);
				break;
			}
			return type;
		}
	}
	
	public interface EventTarget : Object {
		public virtual void emit(string evt, string? data=null) {
			var type = EventType.from_string(evt);
			event(type, data);
		}
		public signal void event(EventType event, string? data = null);	  
	}
}
	

	
