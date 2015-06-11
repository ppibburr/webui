var webui = {};
webui.connect = function() {
	webui.socket = new WebSocket("ws://192.168.7.2:8048/test/socket");
	
	webui.socket.onopen = function() {
      opened = true;
	}
	webui.socket.onclose = function() {
		opened = false;
	}
	webui.socket.onerror = function() {
		//socket.close();
	}
	webui.socket.onmessage = function(msg) {
		alert(msg.data);
	}
}

webui.disconnect = function() {
	webui.socket.close();
}

webui.update = function(id, property, value) {
  	var obj = webui.object(id);
}

webui.event_full = function(id, type, data) {
	//alert(type);
	webui.socket.send("event,"+id+","+type+","+data);
}

webui.event = function(id,type) {
	if (event.handled == true) {
	  return;
    }
    event.handled = true;
	webui.event_full(id, type, "null");
}

webui.object = function(id) {
	return $("#"+id);
}

webui.connect();

