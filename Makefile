install:
	dart pub get

lint:
	dart analyze

lint-fix:
	dart fix --apply

check-format:
	dart format --output=none --set-exit-if-changed --line-length 120 .

format:
	dart format --line-length 120 .

tests:
	dart test

build-wampproto:
	git clone https://github.com/xconnio/wampproto-cli.git
	cd wampproto-cli/ && make build && sudo cp ./wampproto /usr/local/bin/
