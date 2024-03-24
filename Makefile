all: dialyzer test

dialyzer:
	@echo "\n==> STARTING DIALYZER TYPE CHECKING\n"
	@mix dialyzer

.PHONY: test
test:
	@echo "\n==> RUNNING PROJECT TESTS\n"
	@mix test
