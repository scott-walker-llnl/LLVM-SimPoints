CLANG = clang -emit-llvm #-mllvm -simplifycfg-dup-ret
CXX = clang

countfunc:
	$(CLANG) -O3 -c -DINTERVAL=10000000 -o count.bc count_bb/count.cpp

ex: example.cpp countfunc
	@echo "Linking"
	$(CLANG) -c -o exl.bc example.cpp
	llvm-link exl.bc count.bc -o=ex_count.bc
	opt -load count_bb/build/countBB/libcountBB.so -countBB ex_count.bc -o ex_count_opt.bc
	llc -O0 ex_count_opt.bc 
	$(CXX) -O0 ex_count_opt.s -o ex.out

clean:
	rm -rf *.bc
	rm -rf *.out
	rm -rf *.ll
	rm -rf *.s
	rm -rf count.bb
