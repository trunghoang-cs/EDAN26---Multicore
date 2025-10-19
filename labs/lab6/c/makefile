main:
	gcc -o concurrent concurrent.c pthread_barrier.c -g -O3 -pthread -fgnu-tm
	time sh check-solution.sh ./concurrent
	@echo PASS all tests
