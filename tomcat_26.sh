#!/usr/bin/env bash
# https://github.com/mithrajuneo/jutong2026

OS=`uname`

if [ $OS = Linux ]
	then
		#alias echo='echo -e'
		IP=`hostname -I | sed 's/ //g'`
		if [ -f /etc/os-release ]; then
		. /etc/os-release
		else
			echo "Cannot detect OS"
			exit 1
		fi
		echo $ID
fi

HOSTNAME=$(hostname)

echo "***************************************************************"
echo "*                                                        		*"
echo "*	Tomcat Security 주요정보통신기반시설 Checklist v1.0            *"
echo "*                                                       		*"
echo "***************************************************************"
echo "*                                                        		*"
echo "*    JEONGJUNEHYUCK Copyright 2026.  all rights reserved.     *"
echo "*                                                             *"
echo "***************************************************************"


TOMCAT_PROCESS=$(ps -ef | grep catalina | grep -v grep)

if [ -z "$TOMCAT_PROCESS" ]; then
    echo "[WARNING] Tomcat이 실행 중이 아닙니다."
    echo ""
    read -p "[INPUT] Tomcat 실행 디렉터리(catalina.base)를 입력해주세요 (예: /usr/share/tomcat): " CATALINA_BASE
else
    echo "[INFO] Tomcat 실행 중"
    
    # catalina.base 자동 추출
    DETECTED_HOME=$(echo "$TOMCAT_PROCESS" | grep -o 'Dcatalina.base=[^ ]*' | cut -d'=' -f2)
    echo "프로세스에서 확인한 인스턴스 디렉터리(catalina.base) :"
	echo "$DETECTED_HOME"
fi

# 사용자에게 Tomcat 홈 디렉토리 입력 받기
read -p "[INPUT] Tomcat 실행 디렉토리(catalina.base) 경로를 입력해주세요 (예: /usr/share/tomcat): " CATALINA_BASE

# 디렉토리 유효성 검사
if [ ! -d "$CATALINA_BASE" ]; then
    echo "[ERROR] 입력한 Tomcat 경로가 존재하지 않습니다: $CATALINA_BASE"
    exit 1
fi

# 파일명용으로 / 를 _ 로 치환
CATALINA_BASE_SAFE=${CATALINA_BASE//\//_}

OUTPUT_FILE="./${HOSTNAME}_tomcat${CATALINA_BASE_SAFE}.txt"


echo
echo "[INFO] 최종 입력된 Tomcat 실행 디렉터리: $CATALINA_BASE" > $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
echo

TOMCAT_USERS="$CATALINA_BASE/conf/tomcat-users.xml"
WEBAPPS="$CATALINA_BASE/webapps"
WEBXML="$CATALINA_BASE/conf/web.xml"
SERVERXML="$CATALINA_BASE/conf/server.xml"
CONTEXT="$CATALINA_BASE/conf/context.xml"

LOGS="$CATALINA_BASE/logs"
TEMP="$CATALINA_BASE/temp"
WORK="$CATALINA_BASE/work"

TOMCAT_PROCESS2=$(ps -ef | grep $CATALINA_BASE | grep -v grep)

if [ -f "$SERVERXML" ];
	then
		# HTTP 포트 (Connector port)
		HTTP_PORT=$(grep -oP '(?<=<Connector port=")[0-9]+(?=")' $SERVERXML | head -1)

		# 개선(2026-02-06)
		HTTPS_PORT=$(grep 'SSLEnabled="true"' $SERVERXML | grep -o 'port="[0-9]*"' | head -1 | grep -o '[0-9]*')
	else
			echo "server.xml 파일  없음" >> $OUTPUT_FILE
fi


	echo "[WEB-01] Default 관리자 계정명 변경"
		echo "[WEB-01] Default 관리자 계정명 변경"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단 기준 : 계정명이 system, admin, administrator로 되어있는 경우 취약" >> $OUTPUT_FILE
		echo "참고 : 관리자 페이지가 디렉터리가 없거나 계정이 주석처리 되어있으면 양호" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		echo "1. 현황 : 관리자 페이지 디렉터리 확인 " >> $OUTPUT_FILE
		ls -alL "$WEBAPPS" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -f "$TOMCAT_USERS" ]; then
		  echo "2. 현황 : tomcat_users 파일 확인 " >> $OUTPUT_FILE
		  cat $TOMCAT_USERS  >> $OUTPUT_FILE
		  echo " " >> $OUTPUT_FILE
		else
		  echo "2. 현황 tomcat-users.xml 파일 없음" >> $OUTPUT_FILE
		  echo " " >> $OUTPUT_FILE
		fi
		echo "[END]" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE

	echo "[WEB-02] 취약한 비밀번호 사용 제한"
		echo "[WEB-02] 취약한 비밀번호 사용 제한"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단 기준 : 관리자 비밀번호가 암호화되어 있거나, 유추하기 어려운 비밀번호로 설정된 경우" >> $OUTPUT_FILE
		echo "참고 : 1번 점검항목 참고" >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
	echo "[WEB-03] 비밀번호 파일 권한 관리"
		echo "[WEB-03] 비밀번호 파일 권한 관리"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단 기준 : tomcat_users 파일 퍼미션이 600 이하로 설정된 경우" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -f "$TOMCAT_USERS" ]; then
		  echo "1. 현황 : tomcat_users 파일 확인 " >> $OUTPUT_FILE
		  ls -l $TOMCAT_USERS  >> $OUTPUT_FILE
		  echo " " >> $OUTPUT_FILE
		else
		  echo "1. 현황 tomcat-users.xml 파일 없음" >> $OUTPUT_FILE
		  echo " " >> $OUTPUT_FILE
		fi
		
		echo "[END]" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE

	echo "[WEB-04] 웹 서비스 디렉터리 리스팅 방지 설정"
		echo "[WEB-04] 웹 서비스 디렉터리 리스팅 방지 설정"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : 디렉터리 리스팅이 설정되지 않은 경우" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -f "$WEBXML" ];
		then
			echo "1. 현황 : web.xml 파일 내 디렉터리 리스팅  설정 확인" >> $OUTPUT_FILE	
			grep -n -C 7 '<param-name>listings' $WEBXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
			echo "web.xml 파일  없음" >> $OUTPUT_FILE
		fi
		
		echo "[END]" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE

	echo "[WEB-05] 지정하지 않은 CGI/ISAPI 실행 제한"
		echo "[WEB-05] 지정하지 않은 CGI/ISAPI 실행 제한"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : CGI 스크립트를 사용하지 않거나 CGI 스크립트가 실행 가능한 디렉터리를 제한한 경우" >> $OUTPUT_FILE
		echo "참고 : 주석처리 되어있는지 잘 확인하기" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -f "$SERVERXML" ];
		then
			echo "1. 현황 : server.xml 파일 내 CGI 스크립트 실행 제한 설정 확인" >> $OUTPUT_FILE	
			grep -n -C 9 '<servlet-name>cgi' $WEBXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
				echo "server.xml 파일  없음" >> $OUTPUT_FILE
		fi
		
		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE


	echo "[WEB-06] 웹 서비스 상위 디렉터리 접근 제한 설정"
		echo "[WEB-06] 웹 서비스 상위 디렉터리 접근 제한 설정"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : 상위 디렉터리 접근 기능을 제거한 경우" >> $OUTPUT_FILE
		echo "참고 : AllowOverride 지시자가 None으로 설정되어 있어 .htaccess 파일을 통한 설정 변경이 제한되어 있으며, 이는 서버 설정의 무단 변경을 방지하는 보안적으로 적절한 설정임"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -f "$SERVERXML" ];
		then
			echo "1. 현황 : server.xml 파일 내 상위 디렉터리 접근 제한 설정 확인" >> $OUTPUT_FILE	
			grep -n -C 7 'allowLinking' $SERVERXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
			echo "server.xml 파일  없음" >> $OUTPUT_FILE
		fi
		
		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE


	echo "[WEB-07] 웹 서비스 경로 내 불필요한 파일 제거"
		echo "[WEB-07] 웹 서비스 경로 내 불필요한 파일 제거"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : 기본으로 생성되는 불필요한 디렉터리 존재하지 않을 경우" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
				
		echo "1. 현황 : webapps 디렉터리 확인 " >> $OUTPUT_FILE
		ls -alL "$WEBAPPS" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -d "$WEBAPPS/sample" ];
		then
			echo "2. 현황 : webapps 디렉터리 내 불필요한 메뉴얼 디렉터리 확인(sample)" >> $OUTPUT_FILE	
			ls -alL "$WEBAPPS/sample" >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
			
			if [ ! -z "$HTTP_PORT" ]; then
				curl -I "localhost:$HTTP_PORT/sample" 2>&1 >> $OUTPUT_FILE
			else
				echo "HTTP 포트를 찾을 수 없음" >> $OUTPUT_FILE
			fi
			echo " " >> $OUTPUT_FILE

			if [ ! -z "$HTTPS_PORT" ]; then
				curl -I "localhost:$HTTPS_PORT/sample" 2>&1 >> $OUTPUT_FILE
			else
				echo "HTTPS 포트를 찾을 수 없음" >> $OUTPUT_FILE
			fi
			echo " " >> $OUTPUT_FILE
		else
			echo "2. 현황 : 메뉴얼 디렉터리 없음(sample)" >> $OUTPUT_FILE	
			echo " " >> $OUTPUT_FILE
		fi
		echo " " >> $OUTPUT_FILE
		
		
		if [ -d "$WEBAPPS/docs" ];
		then
			echo "3. 현황 : webapps 디렉터리 내 불필요한 메뉴얼 디렉터리 확인(docs)" >> $OUTPUT_FILE	
			ls -alL "$WEBAPPS/docs" >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
			if [ ! -z "$HTTP_PORT" ]; then
				curl -I "localhost:$HTTP_PORT/docs" 2>&1 >> $OUTPUT_FILE
			else
				echo "HTTP 포트를 찾을 수 없음" >> $OUTPUT_FILE
			fi
			echo " " >> $OUTPUT_FILE

			if [ ! -z "$HTTPS_PORT" ]; then
				curl -I "localhost:$HTTPS_PORT/docs" 2>&1 >> $OUTPUT_FILE
			else
				echo "HTTPS 포트를 찾을 수 없음" >> $OUTPUT_FILE
			fi
			echo " " >> $OUTPUT_FILE
		else
			echo "3. 현황 : 메뉴얼 디렉터리 없음(docs)" >> $OUTPUT_FILE	
			echo " " >> $OUTPUT_FILE
		fi
		echo " " >> $OUTPUT_FILE
		
		if [ -d "$WEBAPPS/examples" ];
		then
			echo "4. 현황 : webapps 디렉터리 내 불필요한 메뉴얼 디렉터리 확인(examples)" >> $OUTPUT_FILE	
			ls -alL "$WEBAPPS/examples" >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
			if [ ! -z "$HTTP_PORT" ]; then
				curl -I "localhost:$HTTP_PORT/examples" 2>&1 >> $OUTPUT_FILE
			else
				echo "HTTP 포트를 찾을 수 없음" >> $OUTPUT_FILE
			fi
			echo " " >> $OUTPUT_FILE

			if [ ! -z "$HTTPS_PORT" ]; then
				curl -I "localhost:$HTTPS_PORT/examples" 2>&1 >> $OUTPUT_FILE
			else
				echo "HTTPS 포트를 찾을 수 없음" >> $OUTPUT_FILE
			fi
			echo " " >> $OUTPUT_FILE
		else
			echo "4. 현황 : 메뉴얼 디렉터리 없음(examples)" >> $OUTPUT_FILE	
			echo " " >> $OUTPUT_FILE
		fi
	
		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE


	echo "[WEB-08] 웹 서비스 파일 업로드 및 다운로드 용량 제한"
		echo "[WEB-08] 웹 서비스 파일 업로드 및 다운로드 용량 제한"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : 파일 업로드 및 다운로드 용량을 제한한 경우 (용량 제한 없음)" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
				
		if [ -f "$SERVERXML" ];
		then
			echo "1. 현황 : server.xml 파일 내에 용량 제한 확인" >> $OUTPUT_FILE	
			grep -n -C 7 'maxPostSize' $SERVERXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
				echo "server.xml 파일  없음" >> $OUTPUT_FILE
		fi
		
		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE


	echo "[WEB-09] 웹 서비스 프로세스 권한 제한"
		echo "[WEB-09] 웹 서비스 프로세스 권한 제한"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : 웹 프로세스(웹 서비스)가 관리자 권한(root)이 부여된 계정이 아닌 경우" >> $OUTPUT_FILE
		echo "참고 : 웹 프로세스 권한이 root가 아니고 읽기 권한만 있는 경우 (디렉터리 소유자가 root 계정이면 양호함)" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -f "/usr/lib/systemd/system/tomcat.service" ];
		then
			echo "1. 현황 : tomcat.service 파일 내에 실행 계정 확인" >> $OUTPUT_FILE
			grep -n -C 3 'User' /usr/lib/systemd/system/tomcat.service >> $OUTPUT_FILE
			echo "" >> $OUTPUT_FILE
		else
			echo "1. 현황 : /usr/lib/systemd/system/tomcat.service 파일  없음" >> $OUTPUT_FILE
			echo "" >> $OUTPUT_FILE
		fi
		
		echo "2. 현황 : tomcat 디렉터리 권한 확인" >> $OUTPUT_FILE
		ls -alL "$CATALINA_BASE" >> $OUTPUT_FILE
		echo "" >> $OUTPUT_FILE

		echo "[END]" >> $OUTPUT_FILE

	echo "[WEB-10] 불필요한 프록시 설정 제한"
		echo "[WEB-10] 불필요한 프록시 설정 제한"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 :  불필요한 Proxy 설정을 제한한 경우" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
			
		if [ -f "$SERVERXML" ];
		then
			echo "1. 현황 : server.xml 파일 내 proxy 설정 확인" >> $OUTPUT_FILE
			grep -n -C 7 'proxy' $SERVERXML >> $OUTPUT_FILE
			echo "" >> $OUTPUT_FILE
		else
				echo "server.xml 파일  없음" >> $OUTPUT_FILE
		fi
		
		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE


	echo "[WEB-11] 웹 서비스 경로 설정"
		echo "[WEB-11] 웹 서비스 경로 설정"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 :  웹 서버 경로를 별도의 경로가 존재하지 않는 경우" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
			
		if [ -f "$SERVERXML" ];
		then
			echo "1. 현황 : server.xml 파일 내 docBase 경로 설정 확인" >> $OUTPUT_FILE
			grep -n -C 3 -E 'docBase|appBase' $SERVERXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
			echo "server.xml 파일  없음" >> $OUTPUT_FILE
		fi
		
		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE

	echo "[WEB-12] 웹 서비스 링크 사용 금지"
		echo "[WEB-12] 웹 서비스 링크 사용 금지"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : 심볼릭 링크, aliases, 바로가기 등의 링크 사용을 허용하지 않는 경우" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -f "$SERVERXML" ];
		then
			echo "1. 현황 : server.xml 파일 내 링크 설정 확인" >> $OUTPUT_FILE
			grep -n -C 6 -E 'allowLinking' $SERVERXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
			echo "server.xml 파일  없음" >> $OUTPUT_FILE
		fi
	
		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE

	echo "[WEB-13] 웹 서비스 설정 파일 노출 제한"
		echo "[WEB-13] 웹 서비스 설정 파일 노출 제한"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : 불필요한 DB 연결 리소스 설정 제거" >> $OUTPUT_FILE
		echo "참고(멘트) : UserDatabase 리소스는 Tomcat Manager/Host Manager의 인증을 위한 필수 리소스 " >> $OUTPUT_FILE
		
		if [ -f "$SERVERXML" ];
		then
			echo "1. 현황 : server.xml 파일 내 링크 설정 확인" >> $OUTPUT_FILE
			grep -n -C 6 -E 'GlobalNamingResources' $SERVERXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
			echo "1. 현황 : server.xml 파일  없음" >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		fi
		
		if [ -f "$CONTEXT" ];
		then
			echo "2. 현황 : context.xml 파일 내 Resource 설정 확인" >> $OUTPUT_FILE
			grep -n -C 3 -E 'resource' $CONTEXT >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
			echo "2. 현황 : context.xml 파일  없음" >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		fi
		
		echo "[END]" >> $OUTPUT_FILE	

	echo "[WEB-14] 웹 서비스 경로 내 파일의 접근 통제"
		echo "[WEB-14] 웹 서비스 경로 내 파일의 접근 통제"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : 홈 디렉터리 내  파일 퍼미션 검토" >> $OUTPUT_FILE
		echo "참고 : web.xml 및 server.xml		750" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		echo "1. 현황 : 홈 디렉터리 내  파일 설정 확인" >> $OUTPUT_FILE
		ls -alL $CATALINA_BASE"/conf" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		echo "[END]" >> $OUTPUT_FILE

	echo "[WEB-15] 웹 서비스의 불필요한 스크립트 매핑 제거"
		echo "[WEB-15] 웹 서비스의 불필요한 스크립트 매핑 제거"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 :  불필요한 스크립트 매핑이 존재하지 않는 경우" >> $OUTPUT_FILE
		
		if [ -f "$WEBXML" ];
		then
			echo "1. 현황 : web.xml 파일 내 스크립팅 매핑 설정 확인" >> $OUTPUT_FILE
			grep -n -C 5 '<servlet-mapping>' $WEBXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
			echo "web.xml 파일  없음" >> $OUTPUT_FILE
		fi
		echo " " >> $OUTPUT_FILE
		
		echo "[END]" >> $OUTPUT_FILE	

	echo "[WEB-16] 웹 서비스 헤더 정보 노출 제한"
		echo "[WEB-16] 웹 서비스 헤더 정보 노출 제한"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 :  HTTP 응답 헤더에서 웹 서버 정보가 노출되지 않는 경우" >> $OUTPUT_FILE
		
		if [ -n "$HTTP_PORT" ]; then
			echo "1. 현황 : HTTP 포트 확인 : $HTTP_PORT" >> $OUTPUT_FILE
			echo "1-1. 현황 : 서버 응답값 확인(curl)" >> $OUTPUT_FILE
			curl -I "localhost:$HTTP_PORT" >> $OUTPUT_FILE
			echo "" >> $OUTPUT_FILE
		else
			echo "1. 현황 : HTTP 포트 미설정" >> $OUTPUT_FILE
			echo "" >> $OUTPUT_FILE
		fi

		if [ -n "$HTTPS_PORT" ]; then
			echo "2. 현황 : HTTPS 포트 확인 : $HTTPS_PORT" >> $OUTPUT_FILE
			echo "2-1. 현황 : 서버 응답값 확인(curl)" >> $OUTPUT_FILE
			curl -I "localhost:$HTTPS_PORT" >> $OUTPUT_FILE
			echo "" >> $OUTPUT_FILE
		else
			echo "2. 현황 : HTTPS 포트 미설정" >> $OUTPUT_FILE
			echo "" >> $OUTPUT_FILE
		fi
	
		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE

	echo "[WEB-17] 웹 서비스 가상 디렉토리 삭제"
		echo "[WEB-17] 웹 서비스 가상 디렉토리 삭제"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : 불필요한 가상 디렉터리가 존재하지 않는 경우" >> $OUTPUT_FILE
		echo "참고 :  server.xml 파일 내 Context 블록 요소의 path 속성값 확인" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -f "$SERVERXML" ];
		then
			echo "1. 현황 : server.xml 파일 내 링크 설정 확인" >> $OUTPUT_FILE
			grep -n -C 6 -E 'Context path' $SERVERXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
			echo "1. 현황 : server.xml 파일  없음" >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		fi
		
		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE

	echo "[WEB-18] 웹 서비스 WebDAV 비활성화"
		echo "[WEB-18] 웹 서비스 WebDAV 비활성화"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "tomcat은 해당 사항 없음" >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE

	echo "[WEB-19] 웹 서비스 SSI(Server Side Includes) 사용 제한"
		echo "[WEB-19] 웹 서비스 SSI(Server Side Includes) 사용 제한"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 :  웹 서비스 SSI 사용 설정이 비활성화되어 있는 경우" >> $OUTPUT_FILE
		echo "참고 : web.xml 파일 내에 SSIServlet 또는 SSIFilter 사용 설정 확인" >> $OUTPUT_FILE
		
		if [ -f "$WEBXML" ];
		then
			echo "1. 현황 : web.xml 파일 내 SSIServlet 설정 확인" >> $OUTPUT_FILE
			grep -n -C 10 'SSIServlet' $WEBXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
			
			echo "2. 현황 : web.xml 파일 내 SSIFilter 설정 확인" >> $OUTPUT_FILE
			grep -n -C 10 'SSIFilter' $WEBXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
			echo "web.xml 파일  없음" >> $OUTPUT_FILE
		fi
		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE
		
	echo "[WEB-20] SSL/TLS 활성화"
		echo "[WEB-20] SSL/TLS 활성화"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "tomcat은 해당 사항 없음" >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE

	echo "[WEB-21] HTTP 리디렉션"
		echo "[WEB-21] HTTP 리디렉션"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "tomcat은 해당 사항 없음" >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
				
	echo "[WEB-22] 에러 페이지 관리"
		echo "[WEB-22] 에러 페이지 관리"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : 웹 서비스 에러 페이지가 별도로 지정된 경우" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -f "$WEBXML" ];
		then
			echo "1. 현황 : web.xml 파일 내 에러페이지 설정 확인" >> $OUTPUT_FILE
			grep -n -C 4 'error-page' $WEBXML >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		else
			echo "web.xml 파일  없음" >> $OUTPUT_FILE
		fi
		echo " " >> $OUTPUT_FILE
		
		echo "[END]" >> $OUTPUT_FILE

	echo "[WEB-23] LDAP 알고리즘 적절하게 구성"
		echo "[WEB-23] LDAP 알고리즘 적절하게 구성"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 :  LDAP 연결 인증( JNDIRealm) 설정 존재시 안전한 비밀번호 다이제스트 알고리즘을 사용하는 경우" >> $OUTPUT_FILE
		echo "참고 :  JNDIRealm 설정 존재시 암호화 알고리즘 sha-256 이상 설정시 양호" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -f "$SERVERXML" ];
		then
			echo "1. 현황: server.xml 파일 내 LDAP 설정 확인"  >> $OUTPUT_FILE
			grep -n -C 4 'JNDIRealm' $SERVERXML >> $OUTPUT_FILE
			echo "" >> $OUTPUT_FILE
		else
			echo "1. 현황 : server.xml 파일  없음" >> $OUTPUT_FILE
		fi
		
		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE

	echo "[WEB-24] 별도의 업로드 경로 사용 및 권한 설정"
		echo "[WEB-24] 별도의 업로드 경로 사용 및 권한 설정"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo "판단기준 : 별도의 업로드 경로를 사용하고 일반 사용자의 접근 권한이 부여되지 않은 경우" >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		
		if [ -f "$SERVERXML" ];
		then
			echo "1. 현황: server.xml 파일 내 업로드 경로 확인"  >> $OUTPUT_FILE
			grep -i "docBase\|uploadPath\|upload" $SERVERXML >> $OUTPUT_FILE
			echo "" >> $OUTPUT_FILE
		else
			echo "1. 현황 : server.xml 파일  없음" >> $OUTPUT_FILE
		fi
		echo " " >> $OUTPUT_FILE
		
		if [ -f "$CONTEXT" ];
		then
			echo "2. 현황: context.xml 파일 내 업로드 경로 확인"  >> $OUTPUT_FILE
			grep -i "docBase\|uploadPath\|upload" $CONTEXT >>$OUTPUT_FILE
			echo "" >> $OUTPUT_FILE
		else
			echo "2. 현황 : context.xml 파일  없음" >> $OUTPUT_FILE
		fi
		echo " " >> $OUTPUT_FILE

		echo "[END]" >> $OUTPUT_FILE


	echo "[WEB-25] 주기적 보안 패치 및 벤더 권고사항 적용"
		echo "[WEB-25] 주기적 보안 패치 및 벤더 권고사항 적용"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
	
			echo "1. 현황 : tomcat 버전 확인(팩키지 버전 확인)" >> $OUTPUT_FILE
			yum list installed | grep tomcat >> $OUTPUT_FILE
			#rpm -qa | grep tomcat
			#dnf list installed | grep tomcat
			echo " " >> $OUTPUT_FILE
			
			echo "2. 현황 : tomcat 버전 확인 (팩키지 버전 확인)" >> $OUTPUT_FILE
			rpm -qf $(which tomcat) >> $OUTPUT_FILE
			#rpm -qa | grep tomcat
			#dnf list installed | grep tomcat
			echo " " >> $OUTPUT_FILE

			case "$ID" in
				ubuntu | debian | kali)
				echo "2. 현황 : tomcat 버전 확인 (ubuntu)" >> $OUTPUT_FILE
				dpkg -l | grep tomcat  >> $OUTPUT_FILE
				echo " " >> $OUTPUT_FILE
				apt show tomcat9  >> $OUTPUT_FILE
				echo " " >> $OUTPUT_FILE
				;;
			esac


			if [ -f "/var/log/tomcat/catalina.out" ];
			then
				echo "3. 현황 : tomcat 버전 확인(팩키지 버전)" >> $OUTPUT_FILE
				grep -h "Apache Tomcat/" /var/log/tomcat/catalina.*.log | head -1 >> $OUTPUT_FILE
				grep -h "서버 버전 이름" /var/log/tomcat/catalina.*.log | head -1 >> $OUTPUT_FILE
			else
				echo "3. 현황 : catalina.out 파일 없음(팩키지 버전)" >> $OUTPUT_FILE
			fi
			echo " " >> $OUTPUT_FILE
			
			if [ -f "$CATALINA_BASE/logs/catalina.out" ];
			then
				echo "4. 현황 : tomcat 버전 확인(바이너리 버전)" >> $OUTPUT_FILE
				grep -h "Apache Tomcat/" $CATALINA_BASE/logs/catalina.*.log | head -1 >> $OUTPUT_FILE
				grep -h "Apache Tomcat/" $CATALINA_BASE/logs/catalina.out | head -1 >> $OUTPUT_FILE
				grep -h "서버 버전 이름" $CATALINA_BASE/logs/catalina.*.log | head -1 >> $OUTPUT_FILE
			else
				echo "4. 현황 : catalina.out 파일 없음(바이너리 버전)" >> $OUTPUT_FILE
			fi
			echo " " >> $OUTPUT_FILE
			
			
			if [ -d "$CATALINA_BASE" ];
			then
				echo "5. 현황: tomcat 버전 확인(version)"  >> $OUTPUT_FILE
				$CATALINA_BASE/bin/version.sh >> $OUTPUT_FILE
				echo "" >> $OUTPUT_FILE
			else
				echo "5. 현황 : version.sh 파일 없음(바이너리 버전)" >> $OUTPUT_FILE
			fi
			
			if [ -f "$CATALINA_BASE/RELEASE-NOTES" ];
			then
				echo "6. 현황: tomcat 버전 확인(RELEASE-NOTES)"  >> $OUTPUT_FILE
				cat "$CATALINA_BASE/RELEASE-NOTES" | grep "Apache Tomcat Version"  >> $OUTPUT_FILE
				echo "" >> $OUTPUT_FILE
			else
				echo "6. 현황 : RELEASE-NOTES 파일 없음(바이너리 버전)" >> $OUTPUT_FILE
			fi
			
			echo "7. 현황 : tomcat 홈 디렉터리 페이지" >> $OUTPUT_FILE
			if [ ! -z "$HTTP_PORT" ]; then
				curl "localhost:$HTTP_PORT" | grep "<title>" 2>&1 >> $OUTPUT_FILE
			else
				echo "HTTP 포트를 찾을 수 없음" >> $OUTPUT_FILE
			fi
			echo " " >> $OUTPUT_FILE

			if [ ! -z "$HTTPS_PORT" ]; then
				curl "localhost:$HTTPS_PORT" | grep "<title>" 2>&1 >> $OUTPUT_FILE
			else
				echo "HTTPS 포트를 찾을 수 없음" >> $OUTPUT_FILE
			fi
			

		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE	

	echo "[WEB-26] 로그 디렉터리 및 파일 권한 설정"
		echo "[WEB-26] 로그 디렉터리 및 파일 권한 설정"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "[START]"  >> $OUTPUT_FILE
		echo " " >> $OUTPUT_FILE
		echo "판단기준 :  로그 디렉터리 및 파일에 일반 사용자의 접근 권한이 없는 경우" >> $OUTPUT_FILE
		
		if [ -d $CATALINA_BASE/logs ]
		then
			echo "1. 현황 : logs 디렉터리 확인 " >> $OUTPUT_FILE
			ls -alLd $CATALINA_BASE/logs  >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
			echo "2. 현황 : logs 디렉터리 내 파일 확인" >> $OUTPUT_FILE
			ls -alL $CATALINA_BASE/logs >> $OUTPUT_FILE
		else
			echo "1. 현황 : $CATALINA_BASE/logs 디렉터리가 없습니다." >> $OUTPUT_FILE
			echo " " >> $OUTPUT_FILE
		fi

		echo " " >> $OUTPUT_FILE
		echo "[END]" >> $OUTPUT_FILE

#echo "현재 BASE" $CATALINA_BASE
#echo "현재 HOME" $CATALINA_HOME 

echo "======== Check list FINISH  =========" >> $OUTPUT_FILE

#TOMCAT home directory file list
echo "======== TOMCAT HOME File List =========" >> $OUTPUT_FILE
	if [ -d "$CATALINA_BASE" ];
		then
			ls -alL $CATALINA_BASE >> $OUTPUT_FILE
		else
			echo "base 디렉터리 없음" >> $OUTPUT_FILE
	fi
echo "" >> $OUTPUT_FILE
echo "==================================================" >> $OUTPUT_FILE

#TOMCAT conf directory file list
echo "======== TOMCAT conf File List =========" >> $OUTPUT_FILE
	if [ -d "$CATALINA_BASE/conf" ];
		then
			ls -alL $CATALINA_BASE/conf >> $OUTPUT_FILE
		else
			echo "conf 디렉터리 없음" >> $OUTPUT_FILE
	fi
echo "" >> $OUTPUT_FILE
echo "==================================================" >> $OUTPUT_FILE

#TOMCAT bin directory file list
echo "======== TOMCAT bin File List =========" >> $OUTPUT_FILE
	if [ -d "$CATALINA_BASE/bin" ];
		then
			ls -alL $CATALINA_BASE/bin >> $OUTPUT_FILE
		else
			echo "bin 디렉터리 없음" >> $OUTPUT_FILE
	fi
echo "" >> $OUTPUT_FILE
echo "==================================================" >> $OUTPUT_FILE

#TOMCAT webapps/manager file list
echo "======== TOMCAT webapps manager File List =========" >> $OUTPUT_FILE
	if [ -d "$CATALINA_BASE/webapps/manager" ];
		then
			ls -alL $CATALINA_BASE/webapps/manager >> $OUTPUT_FILE
		else
			echo "/webapps/manager 디렉터리 없음" >> $OUTPUT_FILE
	fi
echo "" >> $OUTPUT_FILE
echo "==================================================" >> $OUTPUT_FILE

#TOMCAT webapps/ROOT file list
echo "======== TOMCAT webapps ROOT File List =========" >> $OUTPUT_FILE
	if [ -d "$CATALINA_BASE/webapps/ROOT" ];
		then
			ls -alL $CATALINA_BASE/webapps/ROOT >> $OUTPUT_FILE
		else
			echo "/webapps/ROOT 디렉터리 없음" >> $OUTPUT_FILE
	fi
echo "" >> $OUTPUT_FILE
echo "==================================================" >> $OUTPUT_FILE


#TOMCAT server.xml
echo "======== TOMCAT server.xml  =========" >> $OUTPUT_FILE
	if [ -f "$CATALINA_BASE/conf/server.xml" ];
		then
			ls -alL $CATALINA_BASE/conf/server.xml >> $OUTPUT_FILE
		else
			echo "/conf/server.xml 파일 없음" >> $OUTPUT_FILE
	fi
echo "" >> $OUTPUT_FILE
echo "==================================================" >> $OUTPUT_FILE
#TOMCAT web.xml
echo "======== TOMCAT web.xml  =========" >> $OUTPUT_FILE
	if [ -f "$CATALINA_BASE/conf/web.xml" ];
		then
			ls -alL $CATALINA_BASE/conf/web.xml >> $OUTPUT_FILE
		else
			echo "/conf/web.xml 파일 없음" >> $OUTPUT_FILE
	fi
echo "" >> $OUTPUT_FILE
echo "==================================================" >> $OUTPUT_FILE

echo "=== Tomcat 보안 점검 종료 ==="
echo "Tomcat 스크립트 작업이 완료되었습니다."
echo " "
echo "스크립트 결과 파일을 보안담당자에게 전달 바랍니다."
echo " "
echo "감사합니다."
