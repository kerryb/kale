.PHONY: format credo test
default: format credo dialyzer test docs
format:
	mix format --check-formatted
credo:
	mix credo --strict
dialyzer:
	mix dialyzer --halt-exit-status
test:
	mix test
docs:
	mix docs
