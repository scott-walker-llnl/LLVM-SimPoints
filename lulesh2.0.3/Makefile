# Makefile.llvm
# Will build an executables called lulesh2.0noopt and lulesh2.0opt using llvm's opt program.

.SUFFIXES: .cc .s

BINDIR = ../bin/
LULESH_EXEC_COUNTBB = lulesh2.0countbb

CLANG = clang -emit-llvm -O0 -DUSE_MPI=0 -DUSE_OMP=0
LLVMOPT = opt 
SERCXX = g++ -DUSE_MPI=0
CXX = $(SERCXX)

OPTFLAG = -O3
NOOPTFLAG = -O0

SOURCES2.0 = \
	lulesh.cc \
	lulesh-comm.cc \
	lulesh-viz.cc \
	lulesh-util.cc \
	lulesh-init.cc
ASSEMS2.0 = $(SOURCES2.0:.cc=.no.s)
ASSEMSrm2.0 = $(SOURCES2.0:.cc=.rm.s)
ASSEMSOPT2.0 = $(SOURCES2.0:.cc=.opt.s)

#Default build suggestions with OpenMP for g++
CXXFLAGS = -g -O3 -fopenmp -I. -Wall
//LDFLAGS = -g -O3 -fopenmp
LDFLAGS = -g -O3 -fopenmp -lm

#For each source file create unoptimized and optimized llvm bitcode.
%.rm.s: %.cc lulesh.h
	@echo "Building $<"
	$(CLANG) -c -o $*.no.bc $<
	$(LLVMOPT) $(RMLOADFLAG) $*.no.bc -o $*.rm.bc
	llc $*.rm.bc

%.no.s: %.cc lulesh.h
	@echo "Building $<"
	$(CLANG) -c -o $*.no.bc $<
	llc $*.no.bc

%.opt.s: %.cc lulesh.h
	$(CLANG) -c -o $*.bc $<
	$(LLVMOPT) $(OPTFLAG) $*.bc -o $*.opt.bc
	llc $*.opt.bc

all: $(LULESH_EXEC_COUNTBB)

countfunc:
	$(CLANG) -c -DINTERVAL=10000000 -o count.bc ../count_bb/count.cpp

$(LULESH_EXEC_COUNTBB): $(ASSEMSOPT2.0) countfunc
	@echo "Linking"
	llvm-link *.opt.bc count.bc -o=lu_count.bc
	opt -load ../count_bb/build/countBB/libcountBB.so -countBB lu_count.bc -o lu_count_opt.bc
	llc lu_count_opt.bc 
	$(CXX) lu_count_opt.s $(LDFLAGS) -lm -o $(BINDIR)$@

clean:
	/bin/rm -f *.o *~ $(OBJECTS)
	/bin/rm -f $(BINDIR)$(LULESH_EXEC_COUNTBB)

	/bin/rm -rf *.dSYM
	/bin/rm -f *.bc
	/bin/rm -f *.s

