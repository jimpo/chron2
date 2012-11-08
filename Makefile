MOCHA_OPTS=--reporter nyan --compiler coffee:coffee-script
MOCHA_PHANTOM_OPTS=--reporter spec
UNIT_TEST_FILES=$(shell find test/unit/ -name '*.coffee')
ACCEPTANCE_TEST_FILES=$(shell find test/acceptance/ -name '*.coffee')
BROWSER_TEST_FILES=$(shell find test/browser/ -name '*.html')
TIMEOUT=20000


install-modules:
	@npm install

install-components:
	@./node_modules/.bin/bower install

test/acceptance/%:
	@NODE_ENV=test NODE_PATH=. ./node_modules/.bin/mocha $(MOCHA_OPTS) \
		--require test/acceptance/common --timeout $(TIMEOUT) $(addsuffix .coffee, $@)

test/unit/%:
	@NODE_ENV=test NODE_PATH=. ./node_modules/.bin/mocha $(MOCHA_OPTS) \
		--require test/unit/common $(addsuffix .coffee, $@)

test/browser/%:
	@./node_modules/.bin/mocha-phantomjs $(MOCHA_PHANTOM_OPTS) \
		$(addsuffix .html, $@)

test: test-unit test-acceptance test-browser

test-unit:
	@NODE_ENV=test NODE_PATH=. ./node_modules/.bin/mocha \
		$(MOCHA_OPTS) --require test/unit/common $(UNIT_TEST_FILES)

test-acceptance:
	@NODE_ENV=test NODE_PATH=. ./node_modules/.bin/mocha \
		$(MOCHA_OPTS) --require test/acceptance/common --timeout $(TIMEOUT) \
		$(ACCEPTANCE_TEST_FILES)

test-browser:
	@./node_modules/.bin/mocha-phantomjs $(MOCHA_PHANTOM_OPTS) \
		$(BROWSER_TEST_FILES)

run:
	./node_modules/coffee-script/bin/coffee server.coffee

monitor:
	./node_modules/nodemon/nodemon.js --legacy-watch --exec './node_modules/coffee-script/bin/coffee' 'server.coffee'

.PHONY: install-modules install-components test test-unit test-acceptance test-browser run test/acceptance/% test/unit/%
