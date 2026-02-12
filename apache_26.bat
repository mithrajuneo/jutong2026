::https://github.com/mithrajuneo/jutong2026

@echo off
setlocal EnableDelayedExpansion
echo ###############################################################                 
echo #                 MSSQL Server CheckList                      #                                     
echo #    JeongJuneHyuck Copyright 2026. all rights reserved.      #                                        
echo ###############################################################

echo ============================================
echo Apache 프로세스 정보
echo ============================================
echo [참고] -d 옵션 뒤의 경로가 Apache 홈 디렉터리입니다
echo.

REM Apache 프로세스의 CommandLine 출력
for /f "skip=1 delims=" %%i in ('
    wmic process where "name='httpd.exe' or name='Apache.exe'" get CommandLine 2^>nul
') do (
    set "CMDLINE=%%i"
    echo !CMDLINE! | findstr /i "httpd" >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo !CMDLINE!
        echo.
    )
)

echo ============================================
echo.
set /p APACHE_HOME="Apache 홈 디렉터리 경로를 입력하세요: "

if not defined APACHE_HOME (
    echo [ERROR] 경로를 입력하지 않았습니다.
    goto :EOF
)

REM 따옴표 제거
set "APACHE_HOME=!APACHE_HOME:"=!"

REM 슬래시를 백슬래시로 변환
set "APACHE_HOME=!APACHE_HOME:/=\!"

REM 끝의 백슬래시 제거
if "!APACHE_HOME:~-1!"=="\" set "APACHE_HOME=!APACHE_HOME:~0,-1!"

REM httpd.conf 경로 설정
set "CONF_FILE=!APACHE_HOME!\conf\httpd.conf"

echo.
if exist "!CONF_FILE!" (
    echo [OK] Apache 홈: !APACHE_HOME!
    echo [OK] httpd.conf: !CONF_FILE!
) else (
    echo [ERROR] httpd.conf를 찾을 수 없습니다: !CONF_FILE!
    goto :EOF
)

REM ===========================================
REM 결과 파일명 생성
REM ===========================================
set RESULT_FILE=%COMPUTERNAME%_apache.txt

echo === config file start === > %RESULT_FILE%
type "!CONF_FILE!" >> %RESULT_FILE%
echo === config file end ===== >> %RESULT_FILE%
echo ===========================================================
echo        Apache Security Check - Windows Server              
echo =========================================================== 

echo.
echo [OK] 결과 파일 생성 완료: %RESULT_FILE%



echo =========================================================== >> %RESULT_FILE%
echo        Apache Security Check - Windows Server              >> %RESULT_FILE%
echo =========================================================== >> %RESULT_FILE%

:: ===========================================
:: WEB-01. Default 관리자 계정명 변경
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-01. Default 관리자 계정명 변경 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo Apache는 해당 사항 없음 >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-02. 취약한 비밀번호 사용 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-02. 취약한 비밀번호 사용 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo Apache는 해당 사항 없음 >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-03. 비밀번호 파일 권한 관리
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-03. 비밀번호 파일 권한 관리 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo Apache는 해당 사항 없음 >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-04. 웹 서비스 디렉터리 리스팅 방지 설정
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-04. 웹 서비스 디렉터리 리스팅 방지 설정 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 디렉터리 리스팅을 사용하지 않는 경우 >> %RESULT_FILE%

:: httpd.conf 파일 존재 여부 확인
if exist "!APACHE_HOME!\conf\httpd.conf" (
    echo [INFO] httpd.conf 파일 존재함 >> %RESULT_FILE%
    
    :: 먼저 Indexes 옵션을 찾는다
    set "FOUND="
    for /f "delims=" %%G in ('findstr /i /c:"Options" "!APACHE_HOME!\conf\httpd.conf" ^| findstr /i /c:"Indexes"') do (
        set "FOUND=%%G"
    )

    if defined FOUND (
        echo [WARN] Indexes 옵션 발견됨 - 디렉터리 리스팅 허용 가능성 있음 >> %RESULT_FILE%
        echo !FOUND! >> %RESULT_FILE%
    ) else (
        echo [OK] Indexes 옵션 설정 없음 (디렉터리 리스팅 미허용) >> %RESULT_FILE%
    )

) else (
    echo [WARN] httpd.conf 파일 없음 >> %RESULT_FILE%
)

echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-05. 지정하지 않은 CGI/ISAPI 실행 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-05. 지정하지 않은 CGI/ISAPI 실행 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : cgi 스크립트를 사용하지 않거나 CGI 스크립트 실행가능한 디렉터리를 제한한 경우 >> %RESULT_FILE%

findstr /I /R "^[^#].*ExecCGI" "!APACHE_HOME!\conf\httpd.conf" >nul
if !errorlevel! equ 0 (
    echo [WARN] CGI 실행 가능한 디렉터리 존재 >> %RESULT_FILE%
    findstr /I /R "^[^#].*ExecCGI" "!APACHE_HOME!\conf\httpd.conf" >> %RESULT_FILE%
) else (
    echo [OK] CGI 실행 가능 설정 없음 >> %RESULT_FILE%
)

echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-06. 웹 서비스 상위 디렉터리 접근 제한 설정
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-06. 웹 서비스 상위 디렉터리 접근 제한 설정 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 상위 디렉터리 접근 기능(AllowOverride)을 제거한 경우 >> %RESULT_FILE%

if exist "!APACHE_HOME!\conf\httpd.conf" (
    echo [INFO] AllowOverride 설정 확인 >> %RESULT_FILE%
    findstr /i "AllowOverride" "!APACHE_HOME!\conf\httpd.conf" >> %RESULT_FILE%
    if !errorlevel! equ 0 (
        echo [참고] 설정 확인 필요 >> %RESULT_FILE%
    ) else (
        echo [OK] AllowOverride 설정 없음 >> %RESULT_FILE%
    )
) else (
    echo [WARN] httpd.conf 파일 없음 >> %RESULT_FILE%
)
echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-07. 웹 서비스 경로 내 불필요한 파일 제거
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-07. 웹 서비스 경로 내 불필요한 파일 제거 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 기본으로 생성되는 불필요한 파일 및 디렉토리가 존재하지 않는 경우 >> %RESULT_FILE%

if exist "!APACHE_HOME!\htdocs\manual" (
    echo 1^) /htdocs/manual 디렉토리 존재 >> !RESULT_FILE!
    echo [/htdocs/manual 내 전체 목록] >> !RESULT_FILE!

    for %%F in ("!APACHE_HOME!\htdocs\manual\*") do (
        echo %%~fF >> !RESULT_FILE!
    )
) else (
    echo 1^) /htdocs/manual 디렉토리 존재하지 않음 >> !RESULT_FILE!
)
if exist "!APACHE_HOME!\manual" (
    echo 2^) manual 디렉토리 존재 >> !RESULT_FILE!
    echo [manual 디렉토리 내 전체 목록] >> !RESULT_FILE!

    for %%F in ("!APACHE_HOME!\manual\*") do (
        echo %%~fF >> !RESULT_FILE!
    )
) else (
    echo 2^) manual 디렉토리 존재하지 않음 >> !RESULT_FILE!
)
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-08. 웹 서비스 파일 업로드 및 다운로드 용량 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-08. 웹 서비스 파일 업로드 및 다운로드 용량 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : LimitRequestBody로 업로드/다운로드 용량을 제한하면 양호 >> %RESULT_FILE%

if exist "!APACHE_HOME!\conf\httpd.conf" (
    
    findstr /I "LimitRequestBody" "!APACHE_HOME!\conf\httpd.conf" > nul
    if !errorlevel! equ 0 (
        echo [OK] LimitRequestBody 설정 존재 >> %RESULT_FILE%
        findstr /I "LimitRequestBody" "!APACHE_HOME!\conf\httpd.conf" >> %RESULT_FILE%
    ) else (
        echo [WARN] LimitRequestBody 설정 없음 >> %RESULT_FILE%
    )
) else (
    echo [WARN] httpd.conf 파일 없음 >> %RESULT_FILE%
)
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-09. 웹 프로세스 권한 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-09. 웹 프로세스 권한 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : Apache 데몬이 관리자 권한(Administrator)으로 구동되지 않는 경우 >> %RESULT_FILE%

:: httpd.conf 파일 존재 여부
if exist "!APACHE_HOME!\conf\httpd.conf" (
    echo [INFO] httpd.conf 파일 존재함 >> %RESULT_FILE%

    rem User / Group 설정 내용 출력
    findstr /i /c:"User " "!APACHE_HOME!\conf\httpd.conf" >> %RESULT_FILE%
    findstr /i /c:"Group " "!APACHE_HOME!\conf\httpd.conf" >> %RESULT_FILE%
)

echo. >> %RESULT_FILE%

:: Apache 서비스 존재 여부 점검
echo [INFO] Apache 서비스 확인 >> %RESULT_FILE%
sc query Apache2.4 >> %RESULT_FILE% 2>&1
if !errorlevel! neq 0 (
    echo [INFO] Apache2.4 서비스 없음, Apache 서비스 확인 >> %RESULT_FILE%
    sc query Apache >> %RESULT_FILE% 2>&1
)

:: httpd.exe 프로세스 점검
tasklist /FI "IMAGENAME eq httpd.exe" | findstr /i "httpd.exe" > nul

if %ERRORLEVEL% equ 0 (
    echo [WARN] httpd.exe 프로세스 실행 중임 → 서비스 외 수동 실행일 가능성 있음 >> %RESULT_FILE%

    powershell -NoProfile -Command ^
        "Get-WmiObject Win32_Process -Filter 'Name=''httpd.exe''' | ForEach-Object { $o = $_.GetOwner(); Write-Output ('PID {0} - {1}\{2} - {3}' -f $_.ProcessId, $o.Domain, $o.User, $_.CommandLine) }" >> %RESULT_FILE%

) else (
    echo [OK] httpd.exe 프로세스 실행 중 아님 >> %RESULT_FILE%
)

echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-10. 불필요한 프록시 설정 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-10. 불필요한 프록시 설정 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 불필요한 Proxy 설정을 제한 한 경우 >> %RESULT_FILE%

if exist "!APACHE_HOME!\conf\httpd.conf" (
    
    findstr /I "proxy" "!APACHE_HOME!\conf\httpd.conf" > nul
    if !errorlevel! equ 0 (
        echo [OK] proxy 설정 존재 >> %RESULT_FILE%
        findstr /I "proxy" "!APACHE_HOME!\conf\httpd.conf" >> %RESULT_FILE%
    ) else (
        echo [WARN] proxy 설정 없음 >> %RESULT_FILE%
    )
) else (
    echo [WARN] httpd.conf 파일 없음 >> %RESULT_FILE%
)
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-11. 웹 서비스 경로 설정
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-11. 웹 서비스 경로 설정 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 웹 서버에 설정한 DocumentRoot 경로가 기본 경로가 분리되어있는지 확인 >> %RESULT_FILE%

:: httpd.conf 파일 경로 지정

type %CONF_FILE% | findstr /i /c:"Define SRVROOT" | findstr /v "#"  >> %RESULT_FILE%
type %CONF_FILE% | findstr /i "DocumentRoot" | findstr /v "#"  >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-12. 웹 서비스 링크 사용 금지
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-12. 웹 서비스 링크 사용 금지 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : FollowSymLinks 옵션 및 Alias 설정이 없으면 양호 >> %RESULT_FILE%


:: 1. FollowSymLinks 사용 여부
echo. >> %RESULT_FILE%
echo [INFO] FollowSymLinks 옵션 점검 >> %RESULT_FILE%

if exist "!CONF_FILE!" (
    findstr /i "FollowSymLinks" "!CONF_FILE !" >> %RESULT_FILE%
    if !errorlevel! equ 0 (
        echo [WARN] FollowSymLinks 옵션이 설정되어 있음 >> %RESULT_FILE%
    ) else (
        echo [OK] FollowSymLinks 옵션 미설정 >> %RESULT_FILE%
    )
) else (
    echo [WARN] httpd.conf 파일이 존재하지 않음 >> %RESULT_FILE%
)

:: 2. Alias 설정 여부
echo. >> %RESULT_FILE%
echo [INFO] Alias 설정 점검 >> %RESULT_FILE%

if exist "!CONF_FILE!" (
    findstr /i /r "^Alias" "!CONF_FILE !" >> %RESULT_FILE%
    if !errorlevel! equ 0 (
        echo [WARN] Alias 설정 존재함 >> %RESULT_FILE%
    ) else (
        echo [OK] Alias 설정 없음 >> %RESULT_FILE%
    )
) else (
    echo [WARN] httpd.conf 파일이 존재하지 않음 >> %RESULT_FILE%
)

echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-13. 웹 서비스 설정 파일 노출 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-13. 웹 서비스 설정 파일 노출 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo Apache는 해당 사항 없음 >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-14. 웹 서비스 경로 내 파일의 접근 통제
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-14. 웹 서비스 경로 내 파일의 접근 통제 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : config 파일 내에 적절한 권한이 부여되어있는 경우  >> %RESULT_FILE%

echo config 파일 권한 확인  >> %RESULT_FILE%
icacls "!CONF_FILE!" >> %RESULT_FILE%

echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-15. 웹 서비스의 불필요한 스크립트 매핑 제거
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-15. 웹 서비스의 불필요한 스크립트 매핑 제거 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo Apache는 해당 사항 없음 >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-16. 웹 서비스 헤더 정보 노출 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-16. 웹 서비스 헤더 정보 노출 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 :  HTTP 응답 헤더에서 웹 서버 정보가 노출되지 않는 경우 >> %RESULT_FILE%

echo. >> %RESULT_FILE%
echo 웹 서버 정보 노출 점검 >> %RESULT_FILE%

if exist "!CONF_FILE!" (
    echo [INFO] ServerTokens 설정 확인 >> %RESULT_FILE%
    findstr /i /v "^#" "!CONF_FILE!" | findstr /i "ServerTokens" >> %RESULT_FILE%
    echo. >> %RESULT_FILE%
    echo [INFO] ServerSignature 설정 확인 >> %RESULT_FILE%
    findstr /i /v "^#" "!CONF_FILE!" | findstr /i "ServerSignature" >> %RESULT_FILE%
    echo. >> %RESULT_FILE%
    
    set "PORT_RAW="
    for /f "tokens=2" %%p in ('findstr /i /v "^#" "!CONF_FILE!" ^| findstr /i "^Listen" 2^>nul') do (
        if not defined PORT_RAW set "PORT_RAW=%%p"
    )
    
    if defined PORT_RAW (
        echo !PORT_RAW! | findstr ":" >nul
        if !ERRORLEVEL! EQU 0 (
            for /f "tokens=2 delims=:" %%a in ("!PORT_RAW!") do set "PORT=%%a"
        ) else (
            set "PORT=!PORT_RAW!"
        )
        
        echo [INFO] Apache 포트 !PORT! : 서버 응답 확인 >> %RESULT_FILE%
        powershell -Command "try { $response = Invoke-WebRequest -Uri http://localhost:!PORT! -Method Head -ErrorAction Stop; $response.Headers } catch { 'Connection failed: ' + $_.Exception.Message }" >> %RESULT_FILE%
        echo. >> %RESULT_FILE%
    ) else (
        echo [WARN] Listen 포트를 찾을 수 없음 >> %RESULT_FILE%
    )
    
) else (
    echo [WARN] httpd.conf 파일이 존재하지 않음 >> %RESULT_FILE%
)

echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-17. 웹 서비스 가상 디렉터리 삭제
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-17. 웹 서비스 가상 디렉터리 삭제 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 불필요한 가상 디렉터리가 존재하는 경우 >> %RESULT_FILE%

if exist "!CONF_FILE!" (
    findstr /i /r "^Alias" "!CONF_FILE !" >> %RESULT_FILE%
    if !errorlevel! equ 0 (
        echo [참고] Alias 옵션 확인 >> %RESULT_FILE%
    ) else (
        echo [양호] Alias 옵션 없음 >> %RESULT_FILE%
    )
) else (
    echo [WARN] httpd.conf 파일이 존재하지 않음 >> %RESULT_FILE%
)

echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-18. 웹 서비스 WebDAV 비활성화
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-18. 웹 서비스 WebDAV 비활성화 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 :  WebDAV 서비스가 비활성화 되어있는 경우 >> %RESULT_FILE%

echo. >> %RESULT_FILE%
echo WEBDAV 서비스 비활성화 점검 >> %RESULT_FILE%

if exist "!CONF_FILE!" (
    findstr /i "Dav" "!CONF_FILE!" >> %RESULT_FILE%
    if !errorlevel! equ 0 (
        echo [취약] WebDAV 서비스 활성화 >> %RESULT_FILE%
    ) else (
        echo [양호] WebDAV 옵션 없음 >> %RESULT_FILE%
    )
) else (
    echo [WARN] httpd.conf 파일이 존재하지 않음 >> %RESULT_FILE%
)
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-19. 웹 서비스 SSI 사용 제한
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-19. 웹 서비스 SSI 사용 제한 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 웹 서비스 SSI 사용 설정이 비활성화 된 경우 >> %RESULT_FILE%

echo. >> %RESULT_FILE%
echo SSI 사용 설정 점검 >> %RESULT_FILE%

if exist "!CONF_FILE!" (
    findstr /i "Includes" "!CONF_FILE!" >> %RESULT_FILE%
    if !errorlevel! equ 0 (
        echo [확인필요] 웹 서비스 SSI 사용 설정 활성화 >> %RESULT_FILE%
    ) else (
        echo [양호] SSI 옵션 없음 >> %RESULT_FILE%
    )
) else (
    echo [WARN] httpd.conf 파일이 존재하지 않음 >> %RESULT_FILE%
)
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-20. SSL/TLS 활성화
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-20. SSL/TLS 활성화 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : SSL/TLS 활성화 되어있는경우 >> %RESULT_FILE%

if exist "!APACHE_HOME!\bin\httpd.exe" (
    echo "ssl 모듈(mod_ssl) 활성화 확인" >> %RESULT_FILE%
    "!APACHE_HOME!\bin\httpd.exe" -M >> %RESULT_FILE%
) else (
    echo [WARN] httpd.exe 파일 못 찾음 >> %RESULT_FILE%
)
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-21. HTTP 리디렉션
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-21. HTTP 리디렉션 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : HTTP 접근시 HTTPS Redirection이 활성화 된 경우 >> %RESULT_FILE%

if exist "!CONF_FILE!" (
    findstr /i /R "Redirect|RewriteRule.*https|HTTPS.*off" "!CONF_FILE!" >> %RESULT_FILE%
    if !errorlevel! equ 0 (
        echo [양호] HTTP → HTTPS 리다이렉션 설정 존재 >> %RESULT_FILE%
    ) else (
        echo [취약] HTTP → HTTPS 리다이렉션 설정 없음 >> %RESULT_FILE%
    )
) else (
    echo [WARN] httpd.conf 파일이 존재하지 않음 >> %RESULT_FILE%
)

echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-22. 에러 페이지 관리
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-22. 에러 페이지 관리 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 웹 서비스 에러 페이지가 별도로 지정된 경우 >> %RESULT_FILE%

if exist "!CONF_FILE!" (
    findstr /i /S "ErrorDocument" "!CONF_FILE!" >> %RESULT_FILE%
    if !errorlevel! equ 0 (
		echo [양호] 에러 페이지 설정 존재함 >> %RESULT_FILE%
    ) else (
        echo [취약] 에러 페이지 설정 없음 >> %RESULT_FILE%
    )
) else (
    echo [WARN] httpd.conf 파일이 존재하지 않음 >> %RESULT_FILE%
)
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-23. LDAP 알고리즘 적절하게 구성
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-23. LDAP 알고리즘 적절하게 구성 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo Apache는 해당 사항 없음 >> %RESULT_FILE%
echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-24. 별도의 업로드 경로 사용 및 권한 설정
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-24. 별도의 업로드 경로 사용 및 권한 설정 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%												
echo 판단 기준 : DocumentRoot 디렉토리 내부에 업로드 디렉터리가 있을 경우 취약 >> %RESULT_FILE%
set "DOCROOT="

:: PowerShell로 정확하게 파싱
powershell -NoProfile -Command ^
    "$line = Select-String -Path '%APACHE_HOME%\conf\httpd.conf' -Pattern '^DocumentRoot' | Select-Object -First 1; " ^
    "if ($line) { $path = $line.Line -replace '.*DocumentRoot\s+\""?([^\""]+)\""?.*', '$1'; Write-Output $path | Out-File -FilePath '%TEMP%\docroot.tmp' -Encoding ASCII }"

set /p DOCROOT=<"%TEMP%\docroot.tmp"
del "%TEMP%\docroot.tmp" >nul 2>&1

:: 2. 따옴표 제거
set "DOCROOT=%DOCROOT:"=%"

:: 3. ${SRVROOT} 제거 → 실제 하위 경로만 남김
set "DOCROOT=%DOCROOT:${SRVROOT}/=%"

:: 4. 최종 웹 루트 경로 생성
set "WEB_ROOT=%APACHE_HOME%\%DOCROOT%"

echo [INFO] DocumentRoot 파싱 결과 >> %RESULT_FILE%
echo %WEB_ROOT% >> %RESULT_FILE%

:: 5. 디렉터리 존재 여부 확인
if exist "%WEB_ROOT%" (
    echo [INFO] 웹 루트 디렉터리 권한 확인 >> %RESULT_FILE%
    icacls "%WEB_ROOT%" >> %RESULT_FILE%
) else (
    echo [WARN] 웹 루트 디렉터리가 존재하지 않음 >> %RESULT_FILE%
)
echo [END] >> %RESULT_FILE%

:: ===========================================
:: WEB-25. 주기적 보안 패치 및 벤더 권고사항 적용
:: ===========================================
:: WEB-25. 주기적 보안 패치 및 벤더 권고사항 적용
echo. >> %RESULT_FILE%
echo WEB-25. 주기적 보안 패치 및 벤더 권고사항 적용 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : Apache 버전정보가 2.4.62 버전 이하는 릴리즈 된지 1년 이상 지났으므로 취약  >> %RESULT_FILE%
%APACHE_HOME%\bin\httpd.exe -v >> %RESULT_FILE%

echo [END] >> %RESULT_FILE%


:: ===========================================
:: WEB-26. 로그 디렉터리 및 파일 권한 설정
:: ===========================================
echo. >> %RESULT_FILE%
echo WEB-26. 로그 디렉터리 및 파일 권한 설정 >> %RESULT_FILE%
echo [START] >> %RESULT_FILE%
echo 판단 기준 : 로그 디렉터리 및 파일에 일반 사용자의 접근 권한이 없는 경우  >> %RESULT_FILE%

echo 1. log 디렉터리 권한 확인  >> %RESULT_FILE%
icacls %APACHE_HOME%\logs >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo 2. log 디렉터리 내 파일 권한 확인  >> %RESULT_FILE%
icacls %APACHE_HOME%\logs\*.log >> %RESULT_FILE%

:: 참고 로그 설정 확인
echo. >> %RESULT_FILE%
echo [INFO] 로그 설정 점검 >> %RESULT_FILE%

if exist "!CONF_FILE!" (
    findstr /i "ErrorLog CustomLog" "!CONF_FILE!" >> %RESULT_FILE%
    if !errorlevel! equ 0 (
        echo [참고] Log 설정 존재함 >> %RESULT_FILE%
    ) else (
        echo [참고] Log 설정 없음 >> %RESULT_FILE%
    )
) else (
    echo [WARN] httpd.conf 파일이 존재하지 않음 >> %RESULT_FILE%
)
echo [END] >> %RESULT_FILE%
echo.  >> %RESULT_FILE%
echo === Apache 취약점 점검 종료 === >> %RESULT_FILE%

echo.
echo === Apache 취약점 점검 종료 ===
echo Apache 스크립트 작업이 완료되었습니다.
echo 스크립트 결과 파일을 보안담당자에게 전달 바랍니다.
echo 감사합니다.
echo =============================
