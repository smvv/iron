RUSTC = rustc --opt-level=3
IRON_CRATE = src/iron.rc

all: iron

iron:
	mkdir -p build/lib
	rm -rf build/lib/*
	$(RUSTC) --out-dir=build/lib $(IRON_CRATE)

demo: iron
	mkdir -p build/demo
	rm -rf build/demo/*
	$(RUSTC) --out-dir=build/demo -L build/lib demo/header_dump/header_dump.rs

test:
	mkdir -p build/test
	rm -rf build/test/*
	$(RUSTC) --out-dir=build/test --test $(IRON_CRATE)

clean:
	rm -rf build
