#!/bin/bash
#
# http://wiki.openssl.org/index.php/Android
#
# check fips mode
FIPS=$1
if [ "$FIPS" == "" ]; then	
	FIPS=no
fi
OUTPUT=$2
if [ "$OUTPUT" == "" ]; then	
	OUTPUT=/usr/local/ssl
fi
OPENSSL_FILE=$3
if [ "$OPENSSL_FILE" == "" ]; then	
	OPENSSL_FILE=openssl-1.0.2n
fi
FIPS_FILE=$4
if [ "$FIPS_FILE" == "" ]; then	
	FIPS_FILE=openssl-fips-2.0.16
fi

OLD_PWD=$(pwd)

set -e
rm -rf prebuilt
mkdir prebuilt

#archs=(armeabi arm64-v8a mips mips64 x86 x86_64)
archs=(armeabi)

for arch in ${archs[@]}; do
    xLIB="/lib"
    case ${arch} in
        "armeabi")
            _ANDROID_TARGET_SELECT=arch-arm
            _ANDROID_ARCH=arch-arm
            _ANDROID_EABI=arm-linux-androideabi-4.9
            configure_platform="android-armv7" ;;
        "arm64-v8a")
            _ANDROID_TARGET_SELECT=arch-arm64-v8a
            _ANDROID_ARCH=arch-arm64
            _ANDROID_EABI=aarch64-linux-android-4.9
            #no xLIB="/lib64"
            configure_platform="linux-generic64 -DB_ENDIAN" ;;
        "mips")
            _ANDROID_TARGET_SELECT=arch-mips
            _ANDROID_ARCH=arch-mips
            _ANDROID_EABI=mipsel-linux-android-4.9
            configure_platform="android -DB_ENDIAN" ;;
        "mips64")
            _ANDROID_TARGET_SELECT=arch-mips64
            _ANDROID_ARCH=arch-mips64
            _ANDROID_EABI=mips64el-linux-android-4.9
            xLIB="/lib64"
            configure_platform="linux-generic64 -DB_ENDIAN" ;;
        "x86")
            _ANDROID_TARGET_SELECT=arch-x86
            _ANDROID_ARCH=arch-x86
            _ANDROID_EABI=x86-4.9
            configure_platform="android-x86" ;;
        "x86_64")
            _ANDROID_TARGET_SELECT=arch-x86_64
            _ANDROID_ARCH=arch-x86_64
            _ANDROID_EABI=x86_64-4.9
            xLIB="/lib64"
            configure_platform="linux-generic64" ;;
        *)
            configure_platform="linux-elf" ;;
    esac

    mkdir prebuilt/${arch}

    chmod a+x setenv-android-mod.sh
    . ./setenv-android-mod.sh

    echo "CROSS COMPILE ENV : $CROSS_COMPILE"
	
	xCFLAGS="-DSHARED_EXTENSION=.so -fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB -O3 -fomit-frame-pointer -Wall"
	xCFLAGS_FIPS="-fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB -O3 -fomit-frame-pointer -Wall"
	
	#Prepare the OpenSSL Sources
	# From the 'root' directory
	if [ "$FIPS" == "yes" ]; then	
		rm -rf $FIPS_FILE/
		tar xzf $FIPS_FILE.tar.gz

		#Build the FIPS Object Module	
		cd $FIPS_FILE/

		chmod 755 Configure
		./Configure no-ssl2 no-ssl3 no-comp no-hw no-engine no-idea no-mdc2 no-rc5 $configure_platform $xCFLAGS_FIPS --openssldir=$OUTPUT/out_fips/$ANDROID_API 
		
		perl -pi -e 's/SHLIB_EXT=\.so\.\$\(SHLIB_MAJOR\)\.\$\(SHLIB_MINOR\)/SHLIB_EXT=\.so/g' Makefile
		perl -pi -e 's/SHARED_LIBS_LINK_EXTS=\.so\.\$\(SHLIB_MAJOR\) \.so//g' Makefile
		# quote injection for proper SONAME, fuck...
		perl -pi -e 's/SHLIB_MAJOR=1/SHLIB_MAJOR=`/g' Makefile
		perl -pi -e 's/SHLIB_MINOR=0.0/SHLIB_MINOR=`/g' Makefile		
		
		make
		make install

		# Execute after install
#		cp $FIPS_SIG /usr/local/ssl/fips-2.0/bin
#		mv /usr/local/ssl/fips-2.0/ /usr/local/ssl/$ANDROID_API

		cd $OLD_PWD
	fi
	
	rm -rf $OPENSSL_FILE/
	tar xzf $OPENSSL_FILE.tar.gz
    cd $OPENSSL_FILE/

    perl -pi -e 's/install: all install_docs install_sw/install: install_docs install_sw/g' Makefile.org
    if [ "$FIPS" == "yes" ]; then
		./Configure fips shared no-ssl2 no-ssl3 no-comp no-hw no-engine no-idea no-mdc2 no-rc5 --openssldir=$OUTPUT/out/$ANDROID_API --with-fipsdir=$OUTPUT/out_fips/$ANDROID_API --with-fipslibdir=$OUTPUT/out_fips/$ANDROID_API/lib/ $configure_platform $xCFLAGS
    else
    	./Configure shared no-ssl2 no-ssl3 no-comp no-hw no-engine no-idea no-mdc2 no-rc5 --openssldir=$OUTPUT/out/$ANDROID_API/ $configure_platform $xCFLAGS
    fi

    # patch SONAME

    perl -pi -e 's/SHLIB_EXT=\.so\.\$\(SHLIB_MAJOR\)\.\$\(SHLIB_MINOR\)/SHLIB_EXT=\.so/g' Makefile
    perl -pi -e 's/SHARED_LIBS_LINK_EXTS=\.so\.\$\(SHLIB_MAJOR\) \.so//g' Makefile
    # quote injection for proper SONAME, fuck...
    perl -pi -e 's/SHLIB_MAJOR=1/SHLIB_MAJOR=`/g' Makefile
    perl -pi -e 's/SHLIB_MINOR=0.0/SHLIB_MINOR=`/g' Makefile
	
    make clean
    make depend
    make all

    file libcrypto.so
    file libssl.so
#    cp libcrypto.so ../prebuilt/${arch}/libcrypto.so
#    cp libssl.so ../prebuilt/${arch}/libssl.so
    cd ..
done
exit 0

