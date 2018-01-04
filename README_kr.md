Android용 openssl(fips)을 빌드하는 방법

주 내용은 https://wiki.openssl.org/index.php/Android 를 참조하였습니다.

테스트 환경 : CentOS release 6.7

Openssl : openssl-1.0.2n, openssl-fips-ecp-2.0.16(특허 문제)

NDK : r13b

- 절차
1. home/user{XXX}/openssl 폴더를 만들고 이동
1. ndk download(https://developer.android.com/ndk/downloads/index.html?hl=ko)
2. openssl download(https://www.openssl.org/source/)
3. openssl-fips download(https://www.openssl.org/source/)
4. script download(build-all-arch.sh)
5. chmod a+x *.sh
6. build-all-arch.sh {yes|no} {/usr/local/ssl} 실행

- build-all-arch.sh 상세 옵션
1. fips mode : fips 지원 라이브러리를 만듬
2. 출력물 폴더 
3. openssl version(openssl-1.0.2n)
4. openssl-fips version(openssl-fips-ecp-2.0.16)

