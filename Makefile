.PHONY: format credo test
default: format credo test docs
format:
	mix format --check-formatted
credo:
	mix credo --strict
test:
	mix test
docs:
	mix docs
