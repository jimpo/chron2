MOCHA_OPTS=--reporter nyan --compiler coffee:coffee-script
UNIT_TEST_FILES=$(shell find test/unit/ -name '*.coffee')
ACCEPTANCE_TEST_FILES=$(shell find test/acceptance/ -name '*.coffee')
TIMEOUT=20000


install:
	@npm install

test: test-unit test-acceptance

test-unit:
	@NODE_ENV=test NODE_PATH=. ./node_modules/.bin/mocha \
		$(MOCHA_OPTS) --require test/unit/common $(UNIT_TEST_FILES)

test-acceptance:
	@NODE_ENV=test NODE_PATH=. ./node_modules/.bin/mocha \
		$(MOCHA_OPTS) --require test/acceptance/common --timeout $(TIMEOUT) \
		$(ACCEPTANCE_TEST_FILES)

run:
	./node_modules/coffee-script/bin/coffee server.coffee

.PHONY: install test test-unit test-acceptance run
