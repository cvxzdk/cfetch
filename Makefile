.PHONY: install test clean

install:
	chmod +x cfetch
	ln -sf $(PWD)/cfetch /usr/local/bin/cfetch

test:
	lua53 tests/run_tests.lua

clean:
	rm -f *.txt
	find . -name "*.pyc" -delete

