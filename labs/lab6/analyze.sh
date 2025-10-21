# Compile sequential and concurrent files.
gcc -o3 mm.c -o mm_sequential

gcc -fopenmp -O3 mm_openmp.c -o mm_openmp

# Run/record execution time for sequential and concurrent versions.

#Sequential 
start_seq=$(date +%s)
./mm_sequential
end_seq=$(date +%s)
diff_seq=$(($end_seq - $start_seq))

echo "Sequential version runtime: $diff_seq s"

# Concurrent
start_con=$(date +%s)
./mm_openmp
end_con=$(date +%s)
diff_con=$(($end_con - $start_con))

echo "Concurrent version runtime: $diff_con s"

#Calculate speedup
speedup=$(($diff_seq/$diff_con))
echo "Speedup: $speedup x"