[settings]
os=Linux
arch=x86_64
compiler=gcc
compiler.version=11
compiler.libcxx=libstdc++11
compiler.cppstd=gnu17
build_type=Release

[options]
shared=True
fips=False

[conf]
tools.cmake.cmaketoolchain:generator=Unix Makefiles
tools.gnu:make_program=make
