SRC = src
BUILD = build
MAIN = weather

all: build deploy clean

build: build-directory js html

build-directory:
	mkdir -p $(BUILD)

js:
	elm-make src/$(MAIN).elm --output $(BUILD)/app.js
	uglifyjs $(BUILD)/app.js --compress --mangle \
		--output $(BUILD)/app.min.js 2> /dev/null
	mv $(BUILD)/app.min.js $(BUILD)/app.js

html:
	cp $(SRC)/index.html $(BUILD)/index.html

deploy:
	cp CNAME $(BUILD)/CNAME
	surge $(BUILD)

clean:
	rm -rf $(BUILD)
