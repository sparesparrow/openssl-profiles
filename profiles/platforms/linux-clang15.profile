[settings]
os=Linux
arch=x86_64
compiler=clang
compiler.version=15
compiler.libcxx=libstdc++11
compiler.cppstd=gnu17
build_type=Release

[options]
shared=True
fips=False

[conf]
tools.cmake.cmaketoolchain:generator=Ninja
tools.gnu:make_program=ninja
