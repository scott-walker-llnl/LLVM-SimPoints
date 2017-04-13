CLANG = clang -emit-llvm -mllvm -simplifycfg-dup-ret
CXX = clang -O3

countfunc:
	$(CLANG) -O3 -c -o count.bc count_bb/count.cpp

ex: example.cpp countfunc
	@echo "Linking"
	$(CLANG) -c -o exl.bc example.cpp
	llvm-link exl.bc count.bc -o=ex_count.bc
	opt -load count_bb/build/countBB/libcountBB.so -countBB ex_count.bc -o ex_count_opt.bc
	llc ex_count_opt.bc 
	$(CXX) -O3 ex_count_opt.s -o exl.out

clean:
	rm -rf *.bc
	rm -rf *.out
	rm -rf *.ll
	rm -rf *.s
	rm -rf count.bb
