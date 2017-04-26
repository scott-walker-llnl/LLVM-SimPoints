# Build the prerequisites and run LLVM-SimPoints on LULESH
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


if [ -e "$TOP/bin" ]
then
	cd $TOP
else
	mkdir bin
fi 

cd lulesh2.0.3
make all
cd $TOP
bin/lulesh2.0countbb
SimPoint.3.2/bin/simpoint -maxK $1 -loadFVFile count.bb -saveSimpoints simpoints -saveSimpointWeights weights
