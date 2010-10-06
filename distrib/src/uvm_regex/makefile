src = uvm_regex.cc
lib = uvm_regex

all:
	g++ -m32 \
	  -g \
	  -I$(MTI_HOME)/include ${src} \
	  -shared -o ${lib}.so

clean:
	rm -f transcript *.wlf core* *.log workingExclude.cov
	rm -f *.dll *.exp *.lib *.obj *.sl *.o *.so
	rm -f vsim_stacktrace.vstf *.h results.txt
	rm -rf work
	rm -f wlft*
