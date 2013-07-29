RUSTC ?= rustc
RUSTDOC ?= rustdoc
RUSTFLAGS = -O --out-dir=$(@D) -Lbuild -Lbuild/external
IRON_CRATE = src/iron.rs
IRON_LIB := build/libiron.so

DEMOS := \
	build/demo/header_dump

DOCS := \
	build/doc/iron

all:

test: RUSTFLAGS += --test

doc: $(DOCS)

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

build/doc/%: src/%.rs
	$(RUSTDOC) --output-dir $(@D) $<

# --- Directory creation ------------------------------------------------------

DIRS := \
	build/external \
	build/demo \
	build/doc \

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
all doc $(IRON_LIB) $(DEMOS): | $(DIRS)
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
