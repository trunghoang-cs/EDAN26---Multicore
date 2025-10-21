# lab 6

### Comparing the performance of mm.c using different commands. 


*clang -mcpu=power8 -O3 mm.c*

real	0m53.698s
user	0m53.684s
sys	    0m0.012s


*gcc -fexpensive-optimizations -mcpu=power8 -O3 mm.c*

real	0m14.687s
user	0m14.679s
sys	    0m0.008s


*gcc -ftree-parallelize-loops=80 -fexpensive-optimizations -mcpu=power8 -O3 mm.c*

real	0m2.078s
user	2m4.405s
sys	    0m0.612s

*pgcc -tp=pwr8 -O4 mm.c -Mconcur=allcores*

real	0m0.594s
user	0m42.897s
sys	    0m1.375s

*xlc -qarch=pwr8 -O5 -qsmp -qhot=level=2 mm.c*

real	0m0.281s
user	0m12.118s
sys	    0m5.810s

Explaination for these results: 

clang -- basic optimization, no parallelization. 

gcc 2 -- use more aggressive optimization, creates better result than clang. 

gcc 3 -- auto parallelization, give better result 

pgcc -- better compiler for parallelization 

xlc -- optimized for Power computer, give the best result. 

### Discussion question

1. Why is it more reasonable to use software transactional memory with
Clojure than with C, C++ or Java?

Because, in Clojure, data is immutable. When the data is modified, it creates a new data with the same structure with the old one. 
In case of a conflict, the newly created data would be removed, replaced with the old one. 

2. How does Power detect conflicts between hardware transactions? 

When the hardware transaction is active. The hardware keeps track of the read and write to a cache lines. 
If another core sends an invalidation request for a cache line, the current core has tracked due to a write or read. This conflict would be then detected. This relies on the cache coherence protocol. 

3. Why can we not use I/O in a transaction, and which instructions can be used on Power if we want to print something? 

It can depend on that I/O operation is not tracked by cache coherence.  
