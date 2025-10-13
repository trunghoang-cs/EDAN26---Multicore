main:
	gcc -o preflow preflow.c -g -O3 -pthread
	time sh check-solution.sh ./preflow
	@echo PASS all tests

para:
	gcc -o concurrent concurrent.c -g -O3 -pthread
	time sh check-solution.sh ./concurrent
	@echo PASS all tests
