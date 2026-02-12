::20260109 1.1버전v 작성 완료 
::2026 주요정보통신기반시설 취약점 점검 항목으로 변경
::mithrajune22@ictis.kr
@echo off
setlocal enabledelayedexpansion

echo ============================================
echo Tomcat 프로세스 정보
echo ============================================

REM Tomcat 프로세스의 CommandLine 출력
for /f "skip=1 delims=" %%i in ('
    wmic process where "name='java.exe'" get CommandLine 2^>nul
') do (
    set "CMDLINE=%%i"
    echo !CMDLINE! | findstr /i "catalina" >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo !CMDLINE!
        echo.
    )
)

echo ============================================
echo.
set /p CATALINA_HOME="Tomcat catalina base 경로를 입력하세요: "

if not defined CATALINA_HOME (
    echo [ERROR] 경로를 입력하지 않았습니다.
    goto :EOF
)

REM 따옴표 제거
set "CATALINA_HOME=!CATALINA_HOME:"=!"

REM 끝의 백슬래시 제거
if "!CATALINA_HOME:~-1!"=="\" set "CATALINA_HOME=!CATALINA_HOME:~0,-1!"

REM server.xml 경로 설정
set "SERVER_XML=!CATALINA_HOME!\conf\server.xml"

echo.
if exist "!SERVER_XML!" (
    echo [OK] catalina.base : !CATALINA_HOME!
    echo [OK] server.xml: !SERVER_XML!
) else (
    echo [ERROR] server.xml을 찾을 수 없습니다: !SERVER_XML!
    goto :EOF
)

REM ===========================================
REM 결과 파일명 생성
REM ===========================================
set HOSTNAME=%COMPUTERNAME%
set RESULT_FILE=%HOSTNAME%_tomcat.txt

echo Tomcat 홈 디렉토리 > %RESULT_FILE%
echo !CATALINA_HOME! >> %RESULT_FILE%
echo === server.xml 출력 start === >> %RESULT_FILE%
type "!CATALINA_HOME!\conf\server.xml" >> %RESULT_FILE%
echo === server.xml 출력 end === >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo === web.xml 출력 start === >> %RESULT_FILE%
type "!CATALINA_HOME!\conf\web.xml" >> %RESULT_FILE%
echo === web.xml 출력 end === >> %RESULT_FILE%

echo.
echo [OK] 결과 파일 생성 완료: %RESULT_FILE%


:: ===========================================
:: 결과 파일명 생성
:: ===========================================

set HOSTNAME=%COMPUTERNAME%
set RESULT_FILE=%HOSTNAME%_tomcat.txt

echo Tomcat 홈 디렉토리 > %RESULT_FILE%
echo !CATALINA_HOME! >> %RESULT_FILE%

echo === server.xml 출력 start === >> %RESULT_FILE%
type !CATALINA_HOME!\conf\server.xml >> %RESULT_FILE%
echo === server.xml 출력 end === >> %RESULT_FILE%
echo . >> %RESULT_FILE%
echo === web.xml 출력 start === >> %RESULT_FILE%
type !CATALINA_HOME!\conf\web.xml >> %RESULT_FILE%
echo === web.xml 출력 end === >> %RESULT_FILE%

:: ===========================================
:: WEB-01. Default 관리자 계정명 변경 확인
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-01. Default 관리자 계정명 변경 확인 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 계정명이 system, admin, administrator로 되어있는 경우 취약 >> %RESULT_FILE%

if exist "!CATALINA_HOME!\conf\tomcat-users.xml" (
    
	echo ===tomcat-users.xml 출력 시작=== >> %RESULT_FILE%
	type !CATALINA_HOME!\conf\tomcat-users.xml >> %RESULT_FILE%
	echo ===tomcat-users.xml 출력 끝=== >> %RESULT_FILE%
	findstr /i /c:'username="admin"' "!CATALINA_HOME!\conf\tomcat-users.xml" > nul

) else (
    echo [INFO] tomcat-users.xml 파일 없음 >> %RESULT_FILE%
)
echo . >> %RESULT_FILE%
echo === 참고. webapps 디렉터리 출력 === >> %RESULT_FILE%
echo === manager, host-manager 디렉터리가 있다면 관리자 페이지는 활성화 상태 === >> %RESULT_FILE%
dir !CATALINA_HOME!\webapps\ >> %RESULT_FILE%


echo [END] >> %RESULT_FILE%
:: ===========================================
:: WEB-02. 취약한 패스워드 사용 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-02. 취약한 패스워드 사용 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 패스워드 길이가 8자리 이하일 경우 취약 >> %RESULT_FILE%
echo 점검항목 1에서 tomcat-users.xml 참고하여 판단 >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%
:: ===========================================
:: WEB-03. 비밀번호 파일 권한 관리
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-03. 비밀번호 파일 권한 관리 >> !RESULT_FILE!
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 관리자만 tomcat-users.xml 파일 접근 가능시 양호 >> %RESULT_FILE%

echo 윈도우 서버 내 계정 리스트 출력 >> %RESULT_FILE%
powershell -Command "Get-LocalUser | Select-Object Name, Enabled, LastLogon" >> %RESULT_FILE%

if exist "!CATALINA_HOME!\conf\tomcat-users.xml" (
    echo [INFO] tomcat-users.xml 존재함 >> !RESULT_FILE!
    echo [INFO] 파일 권한 (icacls) >> !RESULT_FILE!
    icacls "!CATALINA_HOME!\conf\tomcat-users.xml" >> !RESULT_FILE!
) else (
    echo [INFO] tomcat-users.xml 파일 없음 >> !RESULT_FILE!
)
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-04. 웹 서비스 디렉터리 리스팅 방지 설정
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-04. 웹 서비스 디렉터리 리스팅 방지 설정 >> %RESULT_FILE%
echo [START] >> !RESULT_FILE!
echo 판단 기준 : 디렉토리 리스팅 설정이 되어있지 않은 경우 >> !RESULT_FILE!

powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\web.xml' -Pattern '<param-name>listings</param-name>' -Context 7,7" >> !RESULT_FILE!

if exist "!CATALINA_HOME!\conf\web.xml" (
    findstr /i /c:"<param-name>listings</param-name>" "!CATALINA_HOME!\conf\web.xml" > nul
    if !errorlevel! equ 0 (
        findstr /i /c:"<param-value>true</param-value>" "!CATALINA_HOME!\conf\web.xml" > nul
        if !errorlevel! equ 0 (
            echo [WARN] directory listing 활성화됨 >> %RESULT_FILE%
        ) else (
            echo [OK] directory listing 비활성화됨 >> %RESULT_FILE%
        )
    ) else (
        echo [OK] listings 설정 미존재 >> %RESULT_FILE%
    )
) else (
    echo [INFO] web.xml 파일 없음 >> %RESULT_FILE%
)
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-05. 지정하지 않은 CGI/ISAPI 실행 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-05. 지정하지 않은 CGI/ISAPI 실행 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : cgi 스크립트를 사용하지 않거나 CGI 스크립트 실행가능한 디렉터리를 제한한 경우 >> %RESULT_FILE%
echo 참고 : default 값으로 cgi 매핑이 주석처리 되어있음  >> %RESULT_FILE%

powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\web.xml' -Pattern '<servlet-name>cgi</servlet-name>' -Context 7,7" >> !RESULT_FILE!

echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-06. 웹 서비스 상위 디렉터리 접근 제한 설정 
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-06. 웹 서비스 상위 디렉터리 접근 제한 설정  >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 상위 디렉터리 접근 기능(allowLinking=true)을 제거한 경우 >> %RESULT_FILE%

powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\server.xml' -Pattern 'allowLinking' -Context 7,7" >> !RESULT_FILE!

echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-07. 웹 서비스 경로 내 불필요한 파일 제거
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-07. 웹 서비스 경로 내 불필요한 파일 제거 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : apache 기본으로 존재하는 /webapps/docs 디렉터리 내 에서 관리자용 문서 파일이 존재함으로 취약 >> %RESULT_FILE%

if exist "!CATALINA_HOME!\webapps\docs" (
    echo 1^) /webapps/docs 디렉토리 존재 >> !RESULT_FILE!
    echo [/webapps/docs 내 전체 목록] >> !RESULT_FILE!

    for %%F in ("!CATALINA_HOME!\webapps\docs\*") do (
        echo %%~fF >> !RESULT_FILE!
    )
) else (
    echo 1^) /webapps/docs 디렉토리 존재하지 않음 >> !RESULT_FILE!
)
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-08. 웹 서비스 파일 업로드 및 다운로드 용량 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-08. 웹 서비스 파일 업로드 및 다운로드 용량 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 파일 업로드 및 다운로드 용량을 제한(max-file-size, max-request-size)한 경우 >> %RESULT_FILE%

echo web.xml 파일 내 파일 업로드 제한(multipart/form-data)  >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\web.xml' -Pattern 'multipart-config' -Context 7,7" >> !RESULT_FILE!
echo . >> %RESULT_FILE%
echo 참고. server.xml 파일 내 Post 요청 크기 제한  >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\server.xml' -Pattern 'maxPostSize' -Context 7,7" >> !RESULT_FILE!
echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-09. 웹 서비스 프로세스 권한 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-09. 웹 서비스 프로세스 권한 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 웹 프로세스(서비스)가 관리자 권한이 부여된 계정이 아닌 최소한의 별도의 계정으로 구동되고 있는 경우 >> %RESULT_FILE%


echo tomcat 9버전 서비스 확인 >> %RESULT_FILE%
sc qc Tomcat9 >> %RESULT_FILE%
echo tomcat 8버전 서비스 확인 >> %RESULT_FILE%
sc qc Tomcat8 >> %RESULT_FILE%
echo tomcat 7버전 서비스 확인 >> %RESULT_FILE%
sc qc Tomcat7 >> %RESULT_FILE%

echo 서비스가 아닌 startup.bat로 실행된 tomcat 서비스일 경우 실행된 터미널 권한 확인 >> %RESULT_FILE%


REM 1. Tomcat 프로세스 존재 여부 먼저 확인
tasklist /FI "IMAGENAME eq java.exe" /FO CSV /V | findstr /I "Tomcat" >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    REM 프로세스가 존재하는 경우에만 로그 저장
    tasklist /FI "IMAGENAME eq java.exe" /FO CSV /V | findstr /I "Tomcat" >> %RESULT_FILE%
    
    REM PID 추출
    for /f "tokens=2 delims=," %%i in ('
        tasklist /FI "IMAGENAME eq java.exe" /FO CSV /V ^| findstr /I "Tomcat"
    ') do (
        set "PID_RAW=%%i"
        set "PID=!PID_RAW:"=!"
    )
) else (
    REM 프로세스가 없는 경우
    echo [!] Tomcat java process not found. >> %RESULT_FILE%
)


echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-10. 불필요한 프록시 설정 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-10. 불필요한 프록시 설정 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 불필요한 Proxy 설정을 제한 한 경우 >> %RESULT_FILE%

echo server.xml 파일 내 프록시 설정 확인  >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\server.xml' -Pattern 'proxyName' -Context 7,7" >> !RESULT_FILE!
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-11. 웹 서비스 경로 설정
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-11. 웹 서비스 경로 설정 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 웹 서버에 설정한 DocumentRoot 경로가 기본 경로가 분리되어있는지 확인 >> %RESULT_FILE%

echo server.xml 파일 내 docBase 경로를 별도로 설정되어있는지 확인 >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\server.xml' -Pattern 'Host name' -Context 7,7" >> !RESULT_FILE!
echo . >> %RESULT_FILE%
echo context.xml 파일 내 docBase 경로를 변도로 설정되어있는지 확인 >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\context.xml' -Pattern 'docBase' -Context 7,7" >> !RESULT_FILE!
echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-12. 웹 서비스 링크 사용 금지
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-12. 웹 서비스 링크 사용 금지 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 링크 옵션(allowLinking)이 비활성화 또는 주석처리 된 경우 양호 >> %RESULT_FILE%
echo server.xml 파일 내 allowLinking=false  확인 >> %RESULT_FILE%

powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\server.xml' -Pattern 'allowLinking' -Context 7,7" >> !RESULT_FILE!
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-13. 웹 서비스 링크 사용 금지
:: ===========================================
echo. >> %RESULT_FILE%
echo  WEB-13. 웹 서비스 링크 사용 금지 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : server.xml 파일 내 불필요한 DB 리소스가 존재하는 경우 취약 >> %RESULT_FILE%
echo 참고 default로 존재하는 UserDatabase는 내부 사용자 관리를 위한 메모리 기반 리소스로 DB연결이 아니므로 점검 대상이 아님 >> %RESULT_FILE%

echo server.xml 파일 내 리소스 확인 >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\server.xml' -Pattern 'Resource name' -Context 7,7" >> !RESULT_FILE!
echo . >> %RESULT_FILE%
echo context.xml 파일 내 리소스 확인 >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\context.xml' -Pattern 'Resource name' -Context 7,7" >> !RESULT_FILE!
echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-14. 웹 서비스 경로 내 파일의 접근 통제
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-14. 웹 서비스 경로 내 파일의 접근 통제 >> %RESULT_FILE%
echo "[START]" >> %RESULT_FILE%
echo "판단 기준 : web.xml 파일 내에 적절한 권한이 부여되어있는 경우"  >> %RESULT_FILE%


echo "web.xml 파일 권한 확인"  >> %RESULT_FILE%
icacls "!CATALINA_HOME!\conf\web.xml" >> %RESULT_FILE%

rem echo "tomcat 홈 디렉터리 확인"  >> %RESULT_FILE%
rem icacls !CATALINA_HOME! >> %RESULT_FILE%
rem echo "bin 디렉터리 확인"  >> %RESULT_FILE%
rem icacls !CATALINA_HOME!\bin >> %RESULT_FILE%
rem echo "conf 디렉터리 확인"  >> %RESULT_FILE%
rem icacls !CATALINA_HOME!\conf  >> %RESULT_FILE%
rem echo "logs디렉터리 확인"  >> %RESULT_FILE%
rem icacls !CATALINA_HOME!\logs  >> %RESULT_FILE%
rem echo "webapps 디렉터리 확인"  >> %RESULT_FILE%
rem icacls !CATALINA_HOME!\webapps  >> %RESULT_FILE%

echo "[END]" >> %RESULT_FILE%


:: ===========================================
:: WEB-15. 웹 서비스의 불필요한 스크립트 매핑 제거
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-15. 웹 서비스의 불필요한 스크립트 매핑 제거 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 불필요한 스크립트 매핑이 존재하지 않는 경우 >> %RESULT_FILE%
echo 참고 : 테스트용 서블릿 매핑(default servlet)은 정상 >> %RESULT_FILE%
echo 참고 : 업무에 사용되는 서블릿 매핑(jsp, jspx)은 정상 >> %RESULT_FILE%
echo 참고 : 테스트용 서블릿 매핑(example, test)이 존재하면 취약 >> %RESULT_FILE%
echo 참고 : invoker servlet이 있으면 취약 >> %RESULT_FILE%
echo . >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\web.xml' -Pattern 'servlet' -Context 7,7" >> !RESULT_FILE!

echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-16. 웹 서비스 헤더 정보 노출 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-16. 웹 서비스 헤더 정보 노출 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : server.xml 파일 내 server 값을 임의의 정보로 변경 여부 확인 >> %RESULT_FILE%

echo 참고 : 서버 응답 값 내 server 정보가 노출되는 경우 취약 >> %RESULT_FILE%

echo 웹 서버 정보 노출 점검 (Tomcat) >> %RESULT_FILE%
if exist "!CATALINA_HOME!\conf\server.xml" (
    echo [CHECK 1] server.xml 설정 >> %RESULT_FILE%
    findstr /i "server=" "!CATALINA_HOME!\conf\server.xml" 2>nul | findstr /v "<!--" >> %RESULT_FILE%
    echo. >> %RESULT_FILE%

    echo [CHECK 2] HTTP 응답 헤더 확인 >> %RESULT_FILE%

    REM PowerShell로 server.xml에서 HTTP Connector의 port를 추출
    for /f "tokens=*" %%p in ('powershell -Command "([xml](Get-Content '!CATALINA_HOME!\conf\server.xml')).Server.Service.Connector | Where-Object { $_.protocol -match 'HTTP' -or (-not $_.protocol) } | ForEach-Object { $_.port }"') do (
        set "port=%%p"
        echo --- Port !port! --- >> %RESULT_FILE%
        powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:!port!/' -Method Head -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop; $r.Headers | Format-List } catch { $_.Exception.Message }" >> %RESULT_FILE% 2>nul
        echo. >> %RESULT_FILE%
    )
) else (
    echo [ERROR] server.xml 없음 >> %RESULT_FILE%
)

echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-17. 웹 서비스 가상 디렉로리 삭제
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-17. 웹 서비스 가상 디렉터리 삭제 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 불필요한 가상 디렉터리가 존재하는 경우 >> %RESULT_FILE%

powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\server.xml' -Pattern 'Context path=' -Context 7,7" >> !RESULT_FILE!

echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-18. 웹 서비스 WebDAV 비활성화
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-18. 웹 서비스 WebDAV 비활성화 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo tomcat은 해당 사항 없음 >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-19. 웹 서비스 SSI 사용 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-19. 웹 서비스 SSI 사용 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo "판단 기준 : 웹 서비스 SSI 사용 설정이 비활성화 된 경우" >> %RESULT_FILE%

echo 1. SSI 서블릿 확인 >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\web.xml' -Pattern 'SSIServlet' -Context 7,7" >> !RESULT_FILE!
echo. >> %RESULT_FILE%
echo 2. SSI 필터 확인 >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\web.xml' -Pattern 'SSIFilter' -Context 7,7" >> !RESULT_FILE!
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-20. SSL/TLS 활성화
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-20. SSL/TLS 활성화 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo tomcat은 해당 사항 없음 >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-21. HTTP 리디렉션
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-21. HTTP 리디렉션 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo tomcat은 해당 사항 없음 >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-22. 에러 페이지 관리
:: ===========================================
echo WEB-22. 에러 페이지 관리 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 웹 서비스 에러 페이지가 별도로 지정된 경우 >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\web.xml' -Pattern 'error-code' -Context 7,7" >> !RESULT_FILE!
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-23. LDAP 알고리즘 적절하게 구성
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-23. LDAP 알고리즘 적절하게 구성 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : LDAP 연결 인증시 안전한 알고리즘을 사용하는 경우 >> %RESULT_FILE%

echo 점검 기준 : 1. LDAP 연결 사용 여부 확인 >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\server.xml' -Pattern 'ldap' -Context 7,7" >> !RESULT_FILE!
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\server.xml' -Pattern 'JNDIRealm' -Context 7,7" >> !RESULT_FILE!
echo . >> %RESULT_FILE%
echo 점검 기준 : 2. LDAP 연결시에만 비밀번호 알고리즘 점검 >> %RESULT_FILE%
powershell -Command "Select-String -Path '!CATALINA_HOME!\conf\server.xml' -Pattern 'digest' -Context 7,7" >> !RESULT_FILE!
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-24. 별도의 업로드 경로 사용 및 권한 설정
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-24. 별도의 업로드 경로 사용 및 권한 설정 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : documentRoot 디렉터리 내부에 파일 업로드 경로가 있을 경우 취약 >> %RESULT_FILE%

echo [Tomcat appBase 점검] >> "%RESULT_FILE%"
echo. >> "%RESULT_FILE%"

powershell -NoProfile -Command ^
    "$xml = [xml](Get-Content '%CATALINA_HOME%\conf\server.xml'); " ^
    "$appBase = $xml.Server.Service.Engine.Host.appBase; " ^
    "if ($appBase) { Write-Output $appBase } else { Write-Output 'webapps' }" > "%TEMP%\appbase.tmp"

set /p APPBASE=<"%TEMP%\appbase.tmp"
del "%TEMP%\appbase.tmp" >nul 2>&1

echo [*] appBase value: %APPBASE% >> "%RESULT_FILE%"

:: 상대경로면 CATALINA_HOME 기준, 절대경로면 그대로 사용
echo %APPBASE% | findstr /R "^[A-Za-z]:" >nul
if errorlevel 1 (
    set "WEB_ROOT=%CATALINA_HOME%\%APPBASE%"
) else (
    set "WEB_ROOT=%APPBASE%"
)

echo [*] DocumentRoot: %WEB_ROOT% >> "%RESULT_FILE%"
echo. >> "%RESULT_FILE%"

:: 디렉터리 존재 확인
if not exist "%WEB_ROOT%" (
    echo [ERROR] appBase 디렉터리가 존재하지 않습니다: %WEB_ROOT% >> "%RESULT_FILE%"
    goto END
)
echo ======================================== >> "%RESULT_FILE%"
echo appbase 디렉터리 점검 >> "%RESULT_FILE%"
echo ======================================== >> "%RESULT_FILE%"
dir "%WEB_ROOT%" /AD /B >> "%RESULT_FILE%" 2>&1
echo. >> "%RESULT_FILE%"

:END 

echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-25. 주기적 보안 패치 및 벤더 권고사항 적용
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-25. 주기적 보안 패치 및 벤더 권고사항 적용 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : Tomcat 최신 보안 패치가 적용되어 있으며, 주기적인 패치를 하는 경우 >> %RESULT_FILE%
echo 참고 : Tomcat 11 버전은 11.0.3  보다 낮으면 취약(1년 이상 지나면 취약) >> %RESULT_FILE%
echo 참고 : Tomcat 10 버전은 10.1.35 보다 낮으면 취약(1년 이상 지나면 취약) >> %RESULT_FILE%
echo 참고 : Tomcat 9 버전은 9.0.100  보다 낮으면 취약(1년 이상 지나면 취약) >> %RESULT_FILE%
echo 참고 : Tomcat 7,8 버전은 EOS 되었으므로 취약 >> %RESULT_FILE%

echo 1.tomcat 버전 확인 >> %RESULT_FILE%
rem type !CATALINA_HOME!\RELEASE-NOTES | findstr "Apache Tomcat Version" >> %RESULT_FILE%
for /f "delims=" %%L in ('findstr /i /c:"Apache Tomcat Version" "!CATALINA_HOME!\RELEASE-NOTES"') do (
    echo %%L >> %RESULT_FILE%
    goto :FOUND
)
:FOUND
echo . >> %RESULT_FILE%
echo 2.tomcat 버전 확인 >> %RESULT_FILE%
call "!CATALINA_HOME!\bin\version.bat" >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%


echo.

:: ===========================================
:: WEB-26. 로그 디렉터리 및 파일 권한 설정
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-26. 로그 디렉터리 및 파일 권한 설정 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 로그 디렉터리 및 파일에 일반 사용자의 접근 권한이 없는 경우  >> %RESULT_FILE%

echo 1. log 디렉터리 권한 확인  >> %RESULT_FILE%
icacls %CATALINA_HOME%\logs >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo 2. log 디렉터리 내 파일 권한 확인  >> %RESULT_FILE%
icacls %CATALINA_HOME%\logs\*.log >> %RESULT_FILE%

echo [END] >> %RESULT_FILE%
echo.  >> %RESULT_FILE%
echo === tomcat 취약점 점검 종료 === >> %RESULT_FILE%

echo.
echo === tomcat 취약점 점검 종료 ===
echo tomcat 스크립트 작업이 완료되었습니다.
echo 스크립트 결과 파일을 보안담당자에게 전달 바랍니다.
echo 감사합니다.
echo =============================