all:
	valac --pkg neutron --library=WebUI --vapi=webui.vapi -H webui.h src/*.vala -X -fPIC -X -shared -o libwebui.so
    

clean:
	rm -rf libwebui.so webui.vapi webui.h

install:
	cp -f libwebui.so /usr/lib/
	cp -f webui.vapi /usr/share/vala/vapi/
	cp -f webui.h /usr/include/
	cp -f webui.pc /usr/lib/pkgconfig/
	cp -rf share/webui /usr/share/
	
uninstall:
	rm -rf /usr/lib/libwebui.so
	rm -rf /usr/share/vala/webui.vapi
	rm -rf /usr/include/webui.h    
	rm -rf /usr/lib/pkgconfig/webui.pc
	rm -rf /usr/share/webui	
