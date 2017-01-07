.PHONY: all

DIST := ./dist
DIST_JS := $(DIST)/js/main.js

MAIN := src/Main.elm
SRCS := $(shell find src/ -type f -name '*.elm')
APP_SRC := $(shell find app/ -type f -name '*')

# TODO: Add /app folder as dependency

all: $(DIST_JS)

$(DIST_JS): $(SRCS) $(APP_SRC) Makefile
	@mkdir -p $(dir $@)
	@elm-make $(MAIN) --warn --output=$@
	cp -R ./app/* $(DIST)
