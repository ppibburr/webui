namespace WebUI {
	public interface MouseEvents : Widget {
		// Mouse button down
		public signal void mouse_down();
		// "          " up
		public signal void mouse_up();
		
		// Attach all mouse events
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
	
	
	
	/*
	 * 
	 * 
	 * 
	 */
	public class Button : Widget, MouseEvents {
		// CLICK-ed
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
	
	
	
	/*
	 * 
	 * 
	 * 
	 */
	public class Slider : Widget {
		public signal void changed(int val);
		
		private int _step = 1;
		public int step {
			get {
				return _step;
			} set {
				_step = value;			
							
				if (!socket.ready) {
				  return;	
				}
				
				socket.exec("$('#%s').step(%d)".printf(id,value));
			}
		}
		
		private int _tick_interval = 5;
		public int tick_interval {
			get {
				return _tick_interval;
			} set {
				_tick_interval = value;			
							
				if (!socket.ready) {
				  return;	
				}
				
				socket.exec("$('#%s').ticksFrequency(%d)".printf(id,value));
			}
		}
		
		private int _value;
		public int @value {
			get {
				return _value;
			}
			set {
				_value = value;
				
			
				if (!socket.ready) {
				  return;	
				}
							
				socket.exec("$('#%s').val(%d)".printf(id, value));
			}
		}
		
		private int _max = 100;
		public int max { get {
			return _max;
		} set {
			_max = value;
			
			if (!socket.ready) {
			  return;	
			}
						
			socket.exec("$('#%s').max(%d)".printf( id, value));
		}}
		
		private int _min = 0;
		public int min { get {
			return _min;
		} set {
			_min = value;
			
			if (!socket.ready) {
			  return;	
			}
			
			socket.exec("$('#%s').min(%d)".printf(id, value));
		}}		
		
		public Slider(View view, string? id=null) {
			base(view, id);
		}
		
		construct {
		  event.connect((type, data)=>{
			  switch (type) {
				  case EventType.CHANGED:
				  this._value = int.parse(data);
				  changed(this.value);
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
            $('#%s').jqxSlider({ theme:'android', min: %d, max: %d, ticksFrequency: %d, value: %d, step: %d});
            $('#%s').on('change', function (event) {
                webui.event_full(event.target.id, 'changed' ,$(event.target).val());
            });			
			""".printf(id,min, max, tick_interval, this.value, step, id);
		}
	}	
	
	
	
	/*
	 * 
	 * 
	 * 
	 * 
	 * 
	 */
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
	
	
	
	/*
	 * 
	 * 
	 * 
	 * 
	 */
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
	
	
	
	/*
	 * 
	 * 
	 * 
	 * 
	 * 
	 */
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
