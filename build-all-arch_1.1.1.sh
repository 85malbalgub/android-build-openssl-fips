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
	FIPS_FILE=openssl-fips-ecp-2.0.16
fi
SHARED_OPTION=$5
if [ "$SHARED_OPTION" == "static" ]; then	
	SHARED_OPTION=
else
	SHARED_OPTION=shared
fi
SONAME=$6
if [ "$_ANDROID_NDK" == "" ]; then	
	_ANDROID_NDK="android-ndk-r13b"
fi

OLD_PWD=$(pwd)

set -e
rm -rf $OUTPUT
mkdir -p $OUTPUT

OPENSSL_OPTION="no-ssl2 no-ssl3 no-comp no-hw no-engine no-idea no-mdc2 no-rc5 no-ec2m"

#archs=(armeabi arm64-v8a mips mips64 x86 x86_64)
archs=(armeabi arm64-v8a x86 x86_64)

for arch in ${archs[@]}; do
    xLIB="/lib"
    case ${arch} in
        "armeabi")
            _ANDROID_TARGET_SELECT=arch-arm
            _ANDROID_ARCH=arch-arm
	    _ANDROID_API=android-19
            _ANDROID_EABI=arm-linux-androideabi-4.9
            configure_platform="android-arm" ;;
        "arm64-v8a")
            _ANDROID_TARGET_SELECT=arch-arm64-v8a
            _ANDROID_ARCH=arch-arm64
	    _ANDROID_API=android-21
            _ANDROID_EABI=aarch64-linux-android-4.9
            #no xLIB="/lib64"
            configure_platform="linux-generic64" ;;
        "mips")
            _ANDROID_TARGET_SELECT=arch-mips
            _ANDROID_ARCH=arch-mips
	    _ANDROID_API=android-19
            _ANDROID_EABI=mipsel-linux-android-4.9
            configure_platform="android -DB_ENDIAN" ;;
        "mips64")
            _ANDROID_TARGET_SELECT=arch-mips64
            _ANDROID_ARCH=arch-mips64
	    _ANDROID_API=android-21
            _ANDROID_EABI=mips64el-linux-android-4.9
            xLIB="/lib64"
            configure_platform="linux-generic64 -DB_ENDIAN" ;;
        "x86")
            _ANDROID_TARGET_SELECT=arch-x86
            _ANDROID_ARCH=arch-x86
	    _ANDROID_API=android-19
            _ANDROID_EABI=x86-4.9
            configure_platform="android-x86" ;;
        "x86_64")
            _ANDROID_TARGET_SELECT=arch-x86_64
            _ANDROID_ARCH=arch-x86_64
	    _ANDROID_API=android-21
            _ANDROID_EABI=x86_64-4.9
            xLIB="/lib64"
            configure_platform="linux-generic64" ;;
        *)
            configure_platform="linux-elf" ;;
    esac

    chmod a+x setenv-android-mod.sh
    . ./setenv-android-mod.sh

if [ "$ANDROID_NDK_HOME" == "" ]; then	
	export ANDROID_NDK_HOME="$ANDROID_NDK_ROOT"
fi
        echo "CROSS COMPILE ENV : $CROSS_COMPILE"

	xCFLAGS="-DSHARED_EXTENSION=.so -fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB -O3 -fomit-frame-pointer -Wall -DOPENSSL_API_COMPAT=0x10100000L"
	xCFLAGS_FIPS="-fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB -O3 -fomit-frame-pointer -Wall -DOPENSSL_API_COMPAT=0x10100000L"
	
	#Prepare the OpenSSL Sources
	# From the 'root' directory
	if [ "$FIPS" == "yes" ]; then	
		rm -rf $FIPS_FILE/
		tar xzf $FIPS_FILE.tar.gz

		#Build the FIPS Object Module	
		cd $FIPS_FILE/

		chmod 755 Configure
		./Configure $OPENSSL_OPTION $configure_platform $xCFLAGS_FIPS --openssldir=$OUTPUT/out_fips/$ANDROID_API 
		
		cp -f Makefile Makefile_org
		perl -pi -e 's/SHLIB_EXT=\.so\.\$\(SHLIB_MAJOR\)\.\$\(SHLIB_MINOR\)/SHLIB_EXT=\.so/g' Makefile
		perl -pi -e 's/SHLIB_EXT=\.so\.\$\(SHLIB_VERSION_NUMBER\)/SHLIB_EXT=\.so/g' Makefile
		perl -pi -e 's/SHARED_LIBS_LINK_EXTS=\.so\.\$\(SHLIB_MAJOR\) \.so//g' Makefile
		# quote injection for proper SONAME, fuck...
		perl -pi -e 's/SHLIB_MAJOR=1/SHLIB_MAJOR=`/g' Makefile
		perl -pi -e 's/SHLIB_MINOR=0.0/SHLIB_MINOR=`/g' Makefile	
		if [ "$SONAME" == "" ]; then	
		    perl -pi -e 's/soname=libcrypto/soname=lib\${SONAME}\crypto/g' Makefile
		fi
		
		make
		make install

		# Execute after install
#		cp $FIPS_SIG $OUTPUT/out_fips/$ANDROID_API/fips-2.0/bin
#		mv /usr/local/ssl/fips-2.0/ $OUTPUT/$ANDROID_API

		perl -pi -e 's/\"\${FIPS_SIG}\" \"\${TARGET}\"/\"\${FIPS_SIG}\" -exe \"\${TARGET}\"/g' $OUTPUT/out_fips/$ANDROID_API/bin/fipsld
		
		cd $OLD_PWD
	fi
	
	rm -rf $OPENSSL_FILE/
	tar xzf $OPENSSL_FILE.tar.gz
    cd $OPENSSL_FILE/

#    perl -pi -e 's/install: all install_docs install_sw/install: install_docs install_sw/g' Makefile.org
    if [ "$FIPS" == "yes" ]; then		
		./Configure fips $SHARED_OPTION $OPENSSL_OPTION --prefix=$OUTPUT/out/$ANDROID_API/libs --openssldir=$OUTPUT/out/$ANDROID_API/SSL --with-fipsdir=$OUTPUT/out_fips/$ANDROID_API --with-fipslibdir=$OUTPUT/out_fips/$ANDROID_API/lib/ $configure_platform $xCFLAGS
    else
    	./Configure $SHARED_OPTION $OPENSSL_OPTION --prefix=$OUTPUT/out/$ANDROID_API/libs/ --openssldir=$OUTPUT/out/$ANDROID_API/SSL/ $configure_platform $xCFLAGS
    fi

    # patch SONAME

    cp -f Makefile Makefile_org
    perl -pi -e 's/SHLIB_EXT=\.so\.\$\(SHLIB_MAJOR\)\.\$\(SHLIB_MINOR\)/SHLIB_EXT=\.so/g' Makefile
    perl -pi -e 's/SHLIB_EXT=\.so\.\$\(SHLIB_VERSION_NUMBER\)/SHLIB_EXT=\.so/g' Makefile
    perl -pi -e 's/SHARED_LIBS_LINK_EXTS=\.so\.\$\(SHLIB_MAJOR\) \.so//g' Makefile
    # quote injection for proper SONAME, fuck...
    perl -pi -e 's/SHLIB_MAJOR=1/SHLIB_MAJOR=`/g' Makefile
    perl -pi -e 's/SHLIB_MINOR=0.0/SHLIB_MINOR=`/g' Makefile
    if [ "$SONAME" == "" ]; then	
	perl -pi -e 's/soname=libcrypto/soname=lib\${SONAME}\crypto/g' Makefile
    fi
	
    #modify secure coding
    cp -f crypto/mem.c crypto/mem_old.c
    cat crypto/mem.c | sed 's/strcpy(ret, str);/memset(ret, 0, strlen(str) + 1);\
    \#ifdef _WIN32\
    strcpy_s(ret, str, strlen(str));\
    \#else	\
    strncpy(ret, str, strlen(str));\
    \#endif/g' > mem_new.c	
    cp -f mem_new.c crypto/mem.c

    #modify sk_free
    cp -f include/openssl/stack.h include/openssl/stack_old.h
    cat include/openssl/stack.h | sed 's/if /if 0\n/'> stack_new.h
    cp -f stack_new.h include/openssl/stack.h

    make clean
    make depend
    make all

    DEST_PATH=$OUTPUT/${arch}
    mkdir -p ${DEST_PATH}
    if [ "$FIPS" == "yes" ]; then	
        DEST_PATH=${DEST_PATH}/FIPS
        mkdir -p ${DEST_PATH}
    fi    	
    cp -f libcrypto.* ${DEST_PATH}/
    cp -f libssl.* ${DEST_PATH}/
    cp -rfl include/ ${DEST_PATH}/
	if [ "$SHARED_OPTION" == "shared" ]; then	
		${ANDROID_TOOLCHAIN}/${CROSS_COMPILE}strip ${DEST_PATH}/libcrypto.so
		${ANDROID_TOOLCHAIN}/${CROSS_COMPILE}strip ${DEST_PATH}/libssl.so
		file ${DEST_PATH}/libcrypto.so
		file ${DEST_PATH}/libssl.so
	else
		file ${DEST_PATH}/libcrypto.a
		file ${DEST_PATH}/libssl.a
	fi
    cd ..
done
exit 0

