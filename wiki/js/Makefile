SRC = src
BUILD = build
CSS = $(SRC)/css
ASSETS = assets
BIN = node_modules/.bin/

all: build deploy clean

deploy:
	cp CNAME $(BUILD)/CNAME
	surge $(BUILD)

build: build-directory html css js favicon

build-directory:
	mkdir -p $(BUILD)

js: eslint babel uglify

eslint:
	$(BIN)/eslint $(SRC)/*.js

babel:
	$(BIN)/babel $(SRC)/*.js -o $(BUILD)/app.js

uglify:
	$(BIN)/uglifyjs $(BUILD)/app.js --compress --mangle \
		--output $(BUILD)/app.min.js
	mv $(BUILD)/app.min.js $(BUILD)/app.js

html:
	cp $(SRC)/index.html $(BUILD)/index.html

css:
	cat $(CSS)/*.css > \
		$(BUILD)/style.css

favicon:
	cp $(ASSETS)/favicon.ico $(BUILD)

setup:
	npm install

clean:
	rm -rf $(BUILD)
