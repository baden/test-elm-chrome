.PHONY: all app

DIST := ./dist
DIST_JS := $(DIST)/js/main.js

MAIN := src/Main.elm
SRCS := $(shell find src/ -type f -name '*.elm')
APP_SRC := $(shell find app/ -type f -name '*')

# TODO: Add /app folder as dependency

all: $(DIST_JS)

$(DIST_JS): $(SRCS) $(APP_SRC) $(NATIVES) Makefile
	@mkdir -p $(dir $@)
	@elm make $(MAIN) --output=$@
	cp -R ./app/* $(DIST)

app: $(DIST_JS)
	npm i
	node build.js
