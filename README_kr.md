Android용 openssl(fips)을 빌드하는 방법

주 내용은 https://wiki.openssl.org/index.php/Android 를 참조하였습니다.

테스트 환경 : CentOS
Openssl : openssl-1.0.2n, openssl-fips-2.0.16
NDK : r13b

- 절차
1. ndk download
2. openssl download
3. openssl-fips download
4. script download
5. chmod a+x *.sh
6. build-all-arch.sh 실행

- build-all-arch.sh 상세 옵션
1. fips mode : fips 지원 라이브러리를 만듬
2. 출력물 폴더 
3. openssl version
4. openssl-fips version

- 주의 
fips모드로 x86-64는 실패하였고 확인 중입니다.
