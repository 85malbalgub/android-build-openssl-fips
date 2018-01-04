android-openssl
===============

Android NDK openssl build script for original repository(https://www.openssl.org/)

modified version of setenv-android.sh and build script support all architectures in the android NDK

see details : http://wiki.openssl.org/index.php/Android

- openssl : openssl-1.0.2n.tar.gz

- openssl-fips : openssl-fips-ecp-2.0.16.tar.gz

- checkpoint

build-all-arch.sh

 usage (fips mode on/off, output file path, openssl archive, openssl-fips archive)
 
 > build-all-arch.sh {yes|no} {output path} {openssl} {openssl-fips}

- editing

 build-all-arch.sh
 
 arch
 
 32 archs=(armeabi arm64-v8a mips mips64 x86 x86_64)

- compile options

 79 xCFLAGS="-DSHARED_EXTENSION=.so -fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/ -O3 -fomit-frame-pointer -Wall"
 
 80 xCFLAGS_FIPS="-fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB -O3 -fomit-frame-pointer -Wall"

- openssl options

 29 OPENSSL_OPTION="no-ssl2 no-ssl3 no-comp no-hw no-engine no-idea no-mdc2 no-rc5 no-ec2m"


