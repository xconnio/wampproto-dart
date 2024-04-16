install:
	dart pub get

lint:
	dart analyze

lint-fix:
	dart fix --apply

format:
	dart format --output=none --set-exit-if-changed . --line-length 120

test:
	dart test
