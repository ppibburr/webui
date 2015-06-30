namespace WebUI {
	public interface MouseEvents : Widget {
		public signal void mouse_down();
		public signal void mouse_up();
		
		public virtual void attach_mouse_events() {
			event.connect((type, data)=>{
				switch (type) {
					case EventType.MOUSE_DOWN:
					mouse_down();
					break;
					
					case EventType.MOUSE_UP:
					mouse_up();
					break;
				}
			});
		}
	}
	
	public class Button : Widget, MouseEvents {
		public signal void clicked();
		
		public Button(View view, string? id=null) {
			base(view, id);
		}
		
		construct {
		  attach_mouse_events();	
			
		  event.connect((type, data)=>{
			  switch (type) {
				  case EventType.CLICKED:
				  clicked();
				  break;
			  }
		  });	
		}
		
		
		public override string render() {
			return """
			<div id='%s' style="min-width:100%;">
            </div>			
			""".printf(id);
		}
		
		public override string jsui_code() {
			return """
            $('#%s').jqxButtons({ theme:'android'});
            $('#%s').on('click', function (event) {
                webui.event(event.target.id, 'clicked');
            });			
			""".printf(id,id);
		}		
	}	
	
	public class Slider : Widget {
		public signal void changed(int val);
		
		public Slider(View view, string? id=null) {
			base(view, id);
		}
		
		construct {
		  event.connect((type, data)=>{
			  switch (type) {
				  case EventType.CHANGED:
				  changed(int.parse(data));
				  break;
			  }
		  });	
		}
		
		
		public override string render() {
			return """
			<div id='%s' style="min-width:100%;">
            </div>			
			""".printf(id);
		}
		
		public override string jsui_code() {
			return """
            $('#%s').jqxSlider({ theme:'android', min: 0, max: 100, ticksFrequency: 5, value: 0, step: 1});
            $('#%s').on('change', function (event) {
                webui.event_full(event.target.id, 'changed' ,$(event.target).val());
            });			
			""".printf(id,id);
		}
	}	
	
	public class Switch : Widget {
	  public signal void changed(bool val);
	  
	  public Switch(View view, string? id = null) {
		  base(view, id);
	  }	
	  
	  construct {
		  event.connect((type, data)=>{
			  switch (type) {
				  case EventType.CHANGED:
				  var val = bool.parse(data);
				  
				  changed(val);
				  break;
		      }
		  });
	  }
	  
	  public override string render() {
		  return """
		  
		  """;
	  }
	  
	  public override string jsui_code() {
		  return """
		  
		  """;
	  }
	}
	
	//
	public class Range : Widget {
      public signal void changed(int min, int max);		
		
	  public Range(View view, string? id = null) {
		  base(view, id);
	  }	
	  
	  construct {
		  event.connect((type, data)=>{
			  switch (type) {
				  case EventType.CHANGED:
				  var range = data.split("..");
				  
				  var min = int.parse(range[0]);
				  var max = int.parse(range[1]);
				  
				  changed(min, max);
				  break;
		      }
		  });
	  }
	  
	  public override string render() {
		  return """
		  
		  """;
	  }
	  
	  public override string jsui_code() {
		  return """
		  
		  """;
	  }
	}
	
	//
	public class Graph : Widget {
	  public Graph(View view, string? id = null) {
		  base(view, id);
	  }	
	  
	  construct {
		  
	  }
	  
	  public override string render() {
		  return """
		  
		  """;
	  }
	  
	  public override string jsui_code() {
		  return """
		  
		  """;
	  }
	}			
	
}
