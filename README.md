# webui
GLib/GObject library that allows system applications to have a Web-based UI without ever leaving Vala source

Example
===
```vala
using BBB;
using WebUI;

void main() {	
	var pwm = new PWM(3);
	pwm.duty_cycle = 55000;
	pwm.period = 8000;
	pwm.enabled = true; 
	
    var pin = new GPIO(7);
    pin.direction = GPIO.Direction.OUT;
	
	var app = new App(8048, "/test");
	var view = new View("main");	
	
	var b = new Button("Toggle");
	view.attach(b);	
	
	b.activate.connect(() => {
		pin.state = !pin.state;
	});	
		
	var slide = new Slider();
	slide.attach_to(view);
	
	slide.change.connect((data)=>{
		pwm.duty_cycle = data * 500;
	});
	
	new GLib.MainLoop().run();
}
```
