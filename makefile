RUSTC ?= rustc
RUSTFLAGS = -O --out-dir=$(@D) -Lbuild -Lbuild/external
IRON_CRATE = src/iron.rs
IRON_LIB := build/libiron.so

DEMOS := \
	build/demo/header_dump

all:

test: RUSTFLAGS += --test

build/lib%.so: src/%.rs
	rm -f $(@D)/lib$*-*.so
	$(RUSTC) $(RUSTFLAGS) --lib $<
	ln -sf `basename $(@D)/lib$*-*.so` $@

build/external/lib%.so:
	rm -f $(@D)/lib$*-*.so
	$(RUSTC) $(RUSTFLAGS) --lib $<
	ln -sf `basename $(@D)/lib$*-*.so` $@

build/%: src/%.rs
	$(RUSTC) $(RUSTFLAGS) $<

clean:
	rm -rf build

# --- Directory creation ------------------------------------------------------

DIRS := \
	build/external \
	build/demo \

$(DIRS):
	mkdir -p $(DIRS)

# --- Dependency tracking -----------------------------------------------------

DEPS := \
	build/external/libzmq.so \
	build/external/libtnetstring.so \
	build/external/libmongrel2.so \

build/external/libzmq.so: external/rust-zmq/zmq.rc
build/external/libtnetstring.so: external/rust-tnetstring/tnetstring.rc
build/external/libmongrel2.so: external/rust-mongrel2/mongrel2.rc \
	build/external/libzmq.so \
	build/external/libtnetstring.so

$(IRON_LIB): $(DEPS)
$(DEMOS): $(IRON_LIB)
all $(IRON_LIB) $(DEMOS): | $(DIRS)
all: $(IRON_LIB) $(DEMOS)

$(IRON_LIB): \
	src/app.rs \
	src/env.rs \

# --- Mongrel2 specific stuff -------------------------------------------------

MONGREL2_CONFIG := mongrel2/example.conf
MONGREL2_CONFIG_DB := mongrel2/config.sqlite

$(MONGREL2_CONFIG_DB): $(MONGREL2_CONFIG)
	m2sh load --db $(MONGREL2_CONFIG_DB) --config $(MONGREL2_CONFIG)

.PHONY: mongrel2

mongrel2: $(MONGREL2_CONFIG_DB)
	m2sh start --db $(MONGREL2_CONFIG_DB) --host localhost
