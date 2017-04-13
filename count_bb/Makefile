CLANG = clang -emit-llvm -O3

countfunc:
	$(CLANG) -c -o count.bc countLoads/count.cpp

exl: extraloads.cpp countfunc
	@echo "Linking"
	$(CLANG) -c -o exl.bc extraloads.cpp
	llvm-link exl.bc count.bc -o=ex_count.bc
	opt -load ../count_loads/build/countLoads/libcountLoads.so -countLoads lu_count.bc -o ex_count.bc
	llc ex_count.bc 
	$(CLANG) ex_count.s -o exl.out

