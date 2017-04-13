# LLVM-SimPoints
### Intro
LLVM-SimPoints is an updated version of the original SimPoints project. The original project has not been updated since 2006. This consists of two components: a dynamic LLVM analysis pass that produces frequency vectors for basic blocks of a program, and the SimPoints analysis code which uses a k-means like algorithm to find the clusters of computation in a program. The SimPoints analysis code is relatively untouched, but has been updated so that it will compile on modern machines. I do not recommend using the original SimPoints source code.

### Building
There are three steps to building and LLVM-Simpoints. The first is compiling the LLVM dynamic analysis pass, the second is building your program with that pass and executing it. Finally, you feed the .bb file into the SimPoints analysis code to generate clusters and weights for the program. The following shows you how to run the simple example program:

`
mkdir bin
cd count_bb
mkdir build && cd build
cmake ..
make
cd ../..
make ex
./ex.out
cd SimPoints
make Simpoint
cd ..
Simpoints.2.3/bin/simpoint -maxK 30 -loadFVFile count.bb -saveSimpoints simpoints -saveSimpointWeights weights
`

The results of this program are not very interesting because the program is so small, but you should be able to verify how many times each basic block executes.

### Explanation of SimPoints
The main idea behind SimPoints is to reduce the amount of code you need to execute to simulate a program. SimPoints identifies the most important portions of a program so that instead of simulating the program in its entirety, you can get within 90-95% of the full program by just executing pieces of it. First, simpoints breaks up a program into intervals of assembly instructions. For any decent sized program, the value 10 million is recommended. You can change the interval used in LLVM-Simpoints by changing the INTERVAL macro in the count_bb/count.cpp file. This value will need to decrease significantly for small programs. SimPoints then uses k-means to find the clusters of execution in the program. These clusters tend to corrolate to areas of heavy computation and program phases.

The results in the "simpoints" file tell you which execution intervals are important and gives each execution interval a unique number. For example, here is how to inperpret the file:
`
14772 1
// For instructions 14772 * interval size to (14772 + 1) * interval size, that is an important interval and we assign it ID 1.
`

The results in the "weights" file tell you how much each interval contributes to the overall execution of the program. The weights should add up to 1. They use the same IDs as those in the simpoints file.
`
0.12443 1
// For interval with the ID 1, it contributes to 12.4% of the execution time of this program.
`

### Testing a Benchmark
You can test LLVM-SimPoints on any program. I have included an example for running it on LULESH.
`
# build the LLVM dynamic analysis pass first, see the first example for details
cd lulesh2.0.3
make all
cd ..
bin/lulesh2.0countbb
Simpoints.2.3/bin/simpoint -maxK 30 -loadFVFile count.bb -saveSimpoints simpoints -saveSimpointWeights weights
`
