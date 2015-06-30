# webui
GLib/GObject library that allows system applications to have a Web-based UI without ever leaving Vala source

Example
===
```vala
using WebUI;

void main() {
	var srv = new Service(8080);

	srv.route("/foo", (conn) => {
	  var view = new View(conn, "view_1");
	  var s1   = new Slider(view);
	  
	  s1.changed.connect((data) => {
		print(@"$data\n");
	  }); 
	  
	  view.add(s1);
	});
	
	

	new MainLoop().run();
}

```
