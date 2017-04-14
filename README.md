# LLVM-SimPoints
### Intro
LLVM-SimPoints is an updated version of the original SimPoints project which has not been updated since 2006. This project consists of two components: a dynamic LLVM analysis pass that produces execution frequency vectors for basic blocks of a program, and the SimPoints analysis code which uses a k-means like algorithm to find the clusters of computation in a program. The SimPoints analysis code is relatively untouched, but has been updated so that it will compile on modern machines. I do not recommend using the original SimPoints source code.

### Building
There are three steps to building and running LLVM-Simpoints. The first is compiling the LLVM dynamic analysis pass, the second is building your program with that pass and executing it. Finally, you feed the .bb file into the SimPoints analysis code to generate clusters and weights for the program. The following shows you how to run the simple example program:

```
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
```

The results of this program are not very interesting because the program is so small, but you should be able to verify how many times each basic block executes.

### Explanation of SimPoints
The main idea behind SimPoints is to reduce the amount of code you need to execute to simulate a program. SimPoints identifies the most important portions of a program so that instead of simulating the program in its entirety, you can get within 90-95% of the full program by just executing pieces of it. First, simpoints breaks up a program into intervals of assembly instructions. For any decent sized program, the value 10 million is recommended. You can change the interval used in LLVM-Simpoints by changing the INTERVAL macro in the count_bb/count.cpp file. This value will need to decrease significantly for small programs. Note that you do not need to build the LLVM analysis pass again after changing INTERVAL but you will need to re-build the benchmark. SimPoints then uses k-means to find the clusters of execution in the program. These clusters tend to correlate to areas of heavy computation and program phases.

The results in the "simpoints" file tell you which execution intervals are important and gives each execution interval a unique number. For example, here is how to interpret the file:
```
14772 1
// For instructions 14772 * interval size to (14772 + 1) * interval size, that is an important interval and we assign it ID 1.
```

The results in the "weights" file tell you how much each interval contributes to the overall execution of the program. The weights should add up to 1. They use the same IDs as those in the simpoints file.
```
0.12443 1
// For interval with the ID 1, it contributes to 12.4% of the execution time of this program.
```

### Testing a Benchmark
You can test LLVM-SimPoints on any program. I have included an example for running it on LULESH.
```
# build the LLVM dynamic analysis pass first, see the first example for details
cd lulesh2.0.3
make all
cd ..
bin/lulesh2.0countbb
Simpoints.2.3/bin/simpoint -maxK 30 -loadFVFile count.bb -saveSimpoints simpoints -saveSimpointWeights weights
```

### Connections
1. To get SimPoints to work, I needed to write a LLVM dynamic analysis pass like the countLoads pass from assignment 2. SimPoints uses frequency vectors, which indicate how many times each basic block of a program executed. SimPoints had links to tools which did this but 1 of the links was broken, and the others did not support x86-64 (one needed a processor which no longer exists and an outdated operating system, the other may have supported x86-64 but needed an outdaded operating system). My dynamic analysis code is more complex than countLoads. It uses a dynamically sized array to create a counter for each basic block. When the pass inserts the function call, it gives each function a constant unique ID value as the first parameter to the function. Finally, SimPoints needs each vector to correspond to a fixed number of instructions executed. To do this, I pass in the length of each LLVM-IR basic block as the second parameter to the function. The function uses an internal counter to detect the intervals based on the length of each basic block. The vectors are placed into a counts.bb output file.

2. My first attempt at the dynamic analysis pass placed the counting function call at the beginning of each basic block. This worked fine on simple programs, but when I switched to more complicated ones I received interesting error messages. The error messages were complaining that the PHI nodes were not the first instructions in those basic blocks. This error makes total sense since we know that PHI nodes must be placed immediately after paths converge. Placing my counting function call at the end of each basic block solved the problem.

3. Part of the SimPoints analysis is to find the important basic blocks from each phase of a program. I learned about program phases when I was an intern at Lawrence Livermore National Lab. When I was an intern there, I worked on a tool called Libmsr. This tool does a different sort of dynamic analysis, which uses data gathered from the processor during run-time. I later used this tool to do an interval analysis similar to SimPoints, which looked at data such as the number of instructions retired every N clock cycles. I created feature vectors using the change in each data item, and then used k-means to find the similarity between different program components.
