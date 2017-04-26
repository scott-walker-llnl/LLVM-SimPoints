#!/bin/bash
# Build all prerequisites and then run LLVM-SIMPOINTS on the example
TOP=$(pwd)

if [ "$#" -ne 1 ]
then
	echo -e "Useage:\n\t$0 maxK"
	exit
fi

# Build Dynamic Analysis Pass
if [ -e "count_bb/build/countBB/libcountBB.so" ]
then
	cd $TOP
else
	echo "Building Dynamic Analysis Pass: countBB"
	cd count_bb
	mkdir build && cd build
	cmake ..
	make
fi

# Build  SimPoints
if [ -e "SimPoint.3.2/bin/simpoint" ]
then
	cd $TOP
else
	echo "Building SimPoint"
	cd $TOP
	cd SimPoint.3.2
	mkdir bin
	make Simpoint
fi

# Build Example File
if [ -e "ex.out" ]
then
	cd $TOP
else
	echo "Building Example"
	cd $TOP
	make ex
	./ex.out
fi
 
# Run SimPoints on Example
# maxK indicates the maximum centers for kmeans. In other words, the maximum number of program phases.
SimPoint.3.2/bin/simpoint -maxK $1 -loadFVFile count.bb -saveSimpoints simpoints -saveSimpointWeights weights
