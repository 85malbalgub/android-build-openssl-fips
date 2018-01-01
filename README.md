android-openssl
===============

Android NDK openssl build script for original repository(https://www.openssl.org/)

modified version of setenv-android.sh and build script support all architectures in the android NDK

see details : http://wiki.openssl.org/index.php/Android

##H1 checkpoint
###H2 build-all-arch.sh
####H3 usage (fips mode on/off, output file path, openssl archive, openssl-fips archive)
####H3 > build-all-arch.sh {yes|no} {output path} {openssl} {openssl-fips}

##H1 editing
###H2 build-all-arch.sh
####H3 arch
####H3 29 archs=(armeabi arm64-v8a mips mips64 x86 x86_64)

##H1 compile options
###H2 78 xCFLAGS="-DSHARED_EXTENSION=.so -fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB -O3 -fomit-frame-pointer -Wall"
###H2 79 xCFLAGS_FIPS="-fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB -O3 -fomit-frame-pointer -Wall"

##H1 openssl options
###H2 91 ./Configure no-ssl2 no-ssl3 no-comp no-hw no-engine no-idea no-mdc2 no-rc5 $configure_platform $xCFLAGS_FIPS --openssldir=$OUTPUT/out_fips/$ANDROID_API 
###H2 115 ./Configure fips shared no-ssl2 no-ssl3 no-comp no-hw no-engine no-idea no-mdc2 no-rc5 --openssldir=$OUTPUT/out/$ANDROID_API --with-fipsdir=$OUTPUT/out_fips/$ANDROID_API --with-fipslibdir=$OUTPUT/out_fips/$ANDROID_API/lib/ $configure_platform $xCFLAGS
###H2 117 ./Configure shared no-ssl2 no-ssl3 no-comp no-hw no-engine no-idea no-mdc2 no-rc5 --openssldir=/usr/local/ssl/$ANDROID_API/ $configure_platform $xCFLAGS
