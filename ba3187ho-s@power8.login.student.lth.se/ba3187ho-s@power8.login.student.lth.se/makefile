main:
	gcc -o concurrent concurrent.c pthread_barrier.c -g -O3 -pthread
	time sh check-solution.sh ./concurrent
	@echo PASS all tests
