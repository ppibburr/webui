// Uber Object
//
// Utilities to bridge to Connection of Service
var webui = {
	// how many views have been initialized 
	// 		(used to tell the application when a Connection is 'ready')
	n_views: 0
};

webui.connect = function(proto, route) {
		// Kinda important
		webui.socket = new WebSocket(proto+"://"+route+"/socket");
		
		this.socket.onopen = function() {

		}

		this.socket.onclose = function() {

		}
		
		this.socket.onerror = function() {
				webui.socket.close();
		}
		
		this.socket.onmessage = function(msg) {
           raw = msg.data.split(":");
          
           if (raw[0] == "exec") {
			   // Execute code send from Application
			   
			   raw.shift();
			   new Function(raw.join(":"))();
			   
		   } else if (raw[0] == "request") {
			   // Send data to the Application
			   
			   raw.shift();
			   id = raw[0];
			   raw.shift();
			   code = raw.join(":");
			   res = new Function("return "+code)();
			   res = "tree";
			   webui.socket.send("response:"+id+":"+res);
		   }
		}
}

webui.send = function(val) {
		webui.socket.send(val);
}

// Sends an Event with data
webui.event_full = function(id, type, val) {
	webui.send("event:"+id.toString()+":"+type+":"+val.toString());
}

// Sends an event without data
webui.event = function(id,type) {
	webui.event_full(id, type);
}

webui.disconnect = function() {
		webui.socket.close();
}

// BwaHaHa
webui.fetch = function(url, succ)
{

  xmlhttp=new XMLHttpRequest();
  xmlhttp.onreadystatechange=function() {
  
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
    {
		console.log(xmlhttp.responseText);
        succ.call(this,xmlhttp.responseText);
    }
  }
  
  xmlhttp.open("GET",url,true);
  xmlhttp.send();
}

// Loads the UI
webui.load_content = function(route,id) {
	webui.fetch(route+"/connection/"+id, function(res) {
		document.body.innerHTML = res;
		webui.send("initialize"); // tells the application to send us View initializers 
	});
}
