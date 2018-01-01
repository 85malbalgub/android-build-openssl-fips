android-openssl
===============

Android NDK openssl build script for original repository(https://www.openssl.org/)

modified version of setenv-android.sh and build script support all architectures in the android NDK

see details : http://wiki.openssl.org/index.php/Android

- checkpoint
build-all-arch.sh
 usage (fips mode on/off, output file path, openssl archive, openssl-fips archive)
 > build-all-arch.sh {yes|no} {output path} {openssl} {openssl-fips}

- editing
 build-all-arch.sh
 arch
 29 archs=(armeabi arm64-v8a mips mips64 x86 x86_64)

- compile options
 78 xCFLAGS="-DSHARED_EXTENSION=.so -fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/ -O3 -fomit-frame-pointer -Wall"
 79 xCFLAGS_FIPS="-fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB -O3 -fomit-frame-pointer -Wall"

- openssl options
 91 ./Configure no-ssl2 no-ssl3 no-comp no-hw no-engine no-idea no-mdc2 no-rc5 $configure_platform $xCFLAGS_FIPS --openssldir=$OUTPUT/out_fips/$ANDROID_API 
 115 ./Configure fips shared no-ssl2 no-ssl3 no-comp no-hw no-engine no-idea no-mdc2 no-rc5 --openssldir=$OUTPUT/out/$ANDROID_API --with-fipsdir=$OUTPUT/out_fips/$ANDROID_API --with-fipslibdir=$OUTPUT/out_fips/$ANDROID_API/lib/ $configure_platform $xCFLAGS
 117 ./Configure shared no-ssl2 no-ssl3 no-comp no-hw no-engine no-idea no-mdc2 no-rc5 --openssldir=/usr/local/ssl/$ANDROID_API/ $configure_platform $xCFLAGS
