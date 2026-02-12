REM https://github.com/mithrajuneo/jutong2026

@echo off
PUSHD %~dp0
:ADMIN_CHECK
bcdedit > nul || (ECHO Please, execute by Administrator & pause & exit)
CLS 2> NUL
TITLE Windows Server Check 2026
REM 주요정보통신기반시설 WINDOWS SERVER

REM ==================================================
REM ==================================================
:OS_TEST
wmic os get producttype /format:list 2>NUL | findstr "2 3" >NUL
IF NOT ERRORLEVEL 1 (
	GOTO :HANGUL_TEST
) ELSE (
	echo Please, execute in Server OS & pause & exit /b
)

REM ==================================================
REM ==================================================
:HANGUL_TEST
CHCP 949 >nul
SETLOCAL ENABLEDELAYEDEXPANSION
cls 2>NUL

REM ==================================================
REM ==================================================
:SYSTEM_BASIC_CONFIG
rem 맨앞글자가 숫자인지 비교를 해야함
FOR /f "tokens=1,2,3,* delims=-/ " %%i IN ('date /t') DO (
	SET START_DATE=%%i-%%j-%%k
	IF %%i leq 2100 (
		echo %START_DATE% 2>NUL | findstr /l \/ >NUL
		rem 일단 맨앞에 글자는 아님
		IF NOT ERRORLEVEL 1 (
			FOR /f "tokens=1,2,3,* delims=/ " %%i IN ('date /t') DO (
				SET START_DATE=%%i-%%j-%%k
			)
		)
    ) ELSE (
	rem 일단 맨앞에 글자가 있음
		IF NOT ERRORLEVEL 1 (
			FOR /f "tokens=2,3,4,* delims=/ " %%i IN ('date /t') DO (
				SET START_DATE=%%i-%%j-%%k
			)
		)
	)
)

echo %START_DATE% >> time.txt
rem 파일을 만들게 되면 공백이 추가가 된다. 이거를 염두해야함

rem 날짜 순서가 2018/12/31
rem 날짜 순서가 12/31/2018
rem 날짜순서가 잘못된거를 바로 잡아야 한다.
rem 일단은 차이점은 맨앞 글자가 1900를 비교해서 순서를 바꾸면 될듯

FOR /f "tokens=1,2,3,* delims=- " %%i IN (time.txt) DO (
	SET START_DATE=%%i-%%j-%%k
	IF %%i gtr 1900 (
		GOTO :normal_number
	) ELSE (
			GOTO :not_normal_number
		)
	)
)
:not_normal_number
set _year_=%START_DATE:~-4%
set _month_=%START_DATE:~0,2%
set _day_=%START_DATE:~3,2%
set START_DATE=%_year_%-%_month_%-%_day_%

:normal_number

IF EXIST time.txt (
	del time.txt
)


FOR /f "tokens=1,2*" %%i IN ('time /t') DO (SET START_TIME=%%i %%j)
SET SCRIPT_TIME=%START_DATE% %START_TIME%
FOR /f "tokens=4,5,6 delims=.[] " %%a IN ('ver') DO (SET OS_VER=%%a.%%b&SET OS_VER_1=%%a.%%b.%%c)
IF %OS_VER_1% EQU 10.0.26100 (SET OS_TYPE=WINDOWS[2025])
IF %OS_VER_1% EQU 10.0.20348 (SET OS_TYPE=WINDOWS[2022])
IF %OS_VER_1% EQU 10.0.17763 (SET OS_TYPE=WINDOWS[2019])
IF %OS_VER_1% EQU 10.0.18362 (SET OS_TYPE=WINDOWS[2019])
IF %OS_VER_1% EQU 10.0.18363 (SET OS_TYPE=WINDOWS[2019])
IF %OS_VER_1% EQU 10.0.19041 (SET OS_TYPE=WINDOWS[2019])
IF %OS_VER_1% EQU 10.0.19042 (SET OS_TYPE=WINDOWS[2019])
IF %OS_VER_1% EQU 10.0.14393 (SET OS_TYPE=WINDOWS[2016])
IF %OS_VER_1% EQU 10.0.16299 (SET OS_TYPE=WINDOWS[2016])
IF %OS_VER_1% EQU 10.0.17134 (SET OS_TYPE=WINDOWS[2016])
IF %OS_VER% EQU 6.3 (SET OS_TYPE=WINDOWS[2012R2])
IF %OS_VER% EQU 6.2 (SET OS_TYPE=WINDOWS[2012])
IF %OS_VER% EQU 6.1 (SET OS_TYPE=WINDOWS[2008R2])
IF %OS_VER% EQU 6.0 (SET OS_TYPE=WINDOWS[2008])
IF %OS_VER% EQU 5.2 (SET OS_TYPE=WINDOWS[2003])
IF %OS_VER% EQU 5.0 (SET OS_TYPE=WINDOWS[2000])
IF NOT DEFINED OS_TYPE (SET OS_TYPE=WINDOWS[UNKNOWN])


FOR /f "tokens=*" %%i IN ('wmic os get caption ^| findstr /i "microsoft"') DO (SET OS_NAME=%%i&SET OS_NAME=!OS_NAME:  =!)
REM 보안정책 파일 현재 디렉토리에 임시저장
SECEDIT /EXPORT /CFG secpol.inf 2>NUL >NUL
REM no_file 초기화 (1이면 파일 미생성 에러)
SET no_file=0
IF NOT EXIST secpol.inf (
	SET file_1=         - 보안정책 파일이 생성되지 않음.&SET file_1_no=1&SET no_file=1
) ELSE (
	SET file_1_no=0
)
REM 서비스 파일 현재 디렉토리에 임시저장

wmic service get displayname, startmode, state 2>NUL > services.inf

IF NOT EXIST services.inf (
	SET file_2=         - 서비스 파일이 생성되지 않음.&SET file_2_no=1&SET no_file=1
) ELSE (SET file_2_no=0)
REM 서비스 포트 및 호스트 정보 임시저장

netstat -ano | findstr /i /v "TIME_WAIT" | findstr ":20 :21 :23 :25 :53 :80 :161 :443 :465 :587 :993 :995" > netstat.inf

IF NOT EXIST netstat.inf (
    SET "file_3=         - 서비스 포트 파일이 생성되지 않음."
    SET file_3_no=1
    SET no_file=1
) ELSE (
    SET file_3_no=0
)
IF %no_file% EQU 1 (
	IF EXIST secpol.inf (del secpol.inf)
	IF EXIST services.inf (del services.inf)
	IF EXIST netstat.inf (del netstat.inf)
	CLS 2> NUL
	echo ---------------------[ Error ]---------------------
	echo.
	echo           시스템 설정파일 생성 오류입니다.
	echo           담당자에게 문의바랍니다.
	echo.
	IF %file_1_no% EQU 1 (echo %file_1%)
	IF %file_2_no% EQU 1 (echo %file_2%)
	IF %file_3_no% EQU 1 (echo %file_3%)
	echo.
	echo ---------------------------------------------------
	echo.
	EXIT /b
)
:IP_ADDR_CHECK
REM 첫 번째 IPv4 주소만 사용
FOR /f "tokens=2 delims=:" %%i IN ('ipconfig ^| findstr /i "IPv4"') DO (
	SET ipaddr=%%i
	SET ipaddr=!ipaddr: =!
	GOTO :IP_ADDR_CHECK_1
)
:IP_ADDR_CHECK_1

:LOGO
CLS 2> NUL
echo. > [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* [주요정보통신기반시설] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 해당 파일은 %COMPUTERNAME%의 스크립트 결과 파일 입니다. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 담당자에게 전달해주시기 바랍니다. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo --------[ Script Result - Windows SRV ]------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo         1.   OS version is "%OS_NAME%" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo         2.   Hostname is "%COMPUTERNAME%" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo         3.   Today is "%SCRIPT_TIME%" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------------------------------------------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo             JEONGJUNEHYUCK Copyright 2026, All right Reserved
echo.
echo  1. OS version is "%OS_NAME%"
echo.
echo  2. Hostname is "%COMPUTERNAME%"
echo.
echo  3. Today is "%SCRIPT_TIME%"
echo.
echo ----------------------------------------------------
echo.
cls 2> nul



REM ==================================================
REM ==================================================
:SCRIPT_START
echo ###############################################################                 
echo #               Windows Server CheckList                      #                                     
echo #    JeongJuneHyuck Copyright 2026. all rights reserved.      #                                        
echo ###############################################################
echo -------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo  1. 계정관리  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo -------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo.
echo 1. 계정관리
echo --------------

REM ==================================================
:01_START
echo [01.W-01] Administrator 계정 이름 변경 등 보안성 강화 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:01_ROUTINE
SET CMT_01=초기화&SET RESULT_01=인터뷰
SET SECPOL=%CD%\secpol.inf

type "%SECPOL%" | findstr /i "EnableAdminAccount" | findstr "= 1" >NUL
IF ERRORLEVEL 1 (
	SET CMT_01=Administrator 계정이 비활성화됨
	SET RESULT_01=양호
) ELSE (
	FOR /F "tokens=3 delims= " %%i IN ('type "%SECPOL%" ^| findstr /i "NewAdministratorName"') DO (
		echo %%~i | findstr /i "Administrator" >NUL
		IF ERRORLEVEL 1 (
			SET CMT_01=Administrator 계정이 존재하지 않음
			SET RESULT_01=양호
		) ELSE (
			SET CMT_01=Administrator 계정이 존재함
			SET RESULT_01=취약
		)
	)
)

:01_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_01% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : Administrator계정 이름 "변경" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_01% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "EnableAdminAccount" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "EnableAdminAccount" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "NewAdministratorName" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "NewAdministratorName" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) wmic useraccount get name ^| findstr /i administrator >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과값이 없을 시, administrator 계정 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wmic useraccount get name 2>NUL | findstr /i administrator >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
    echo     Administrator 계정이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

echo (CMD) wmic useraccount where disabled="true" get name ^| findstr /i administrator >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 계정이 존재하고 결과값이 없을 시, administrator 계정 활성화됨 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wmic useraccount where disabled="true" get name | findstr /i administrator >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) net localgroup "Administrators" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 계정 10개 이상일 경우, 10개를 제외한 나머지는 생략 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
SET count=0
FOR /f %%i IN ('net localgroup "Administrators" ^| findstr /i /v "^$ 별칭 Alias 명령 completed 설명 Comment 구성원 Members -"') DO (
	net user %%i 2>NUL | findstr /i "활성 active" | findstr /i "아니요 No" >NUL
	IF NOT ERRORLEVEL 1 (
		echo     ^(inactive^)%%i >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
	IF ERRORLEVEL 1 (
		echo     %%i >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
	SET /a count+=1
	IF !count! EQU 10 (
		echo     ... >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		GOTO :01_PRINT_1
	)
)
:01_PRINT_1
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [01.W-01] Administrator 계정 이름 바꾸기 [%RESULT_01%]
:01_END
SET CMT_01=
SET RESULT_01=

:01_ADD
REM [항목] Administrator 계정 이름 바꾸기
REM Administrators그룹에 Administrator이 존재하는지 확인(일반 사용자계정일 경우엔 양호)

REM ==================================================
:02_START
echo [02.W-02] Guest 계정 비활성화 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:02_ROUTINE
SET CMT_02=초기화&SET RESULT_02=인터뷰
type secpol.inf | findstr /i "EnableGuestAccount" | findstr "1" >NUL
IF ERRORLEVEL 1 (
	SET CMT_02=Guest 계정이 "비활성화"됨&SET RESULT_02=양호
) ELSE (
	SET CMT_02=Guest 계정이 "활성화"됨&SET RESULT_02=취약
)

:02_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_02% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : Guest 계정 "비활성화" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_02% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "EnableGuestAccount" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "EnableGuestAccount" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "NewGuestName" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "NewGuestName" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) wmic useraccount get name ^| findstr /i "Guest" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과값이 없을 시, Guest 계정 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wmic useraccount get name 2>NUL | findstr /i "Guest" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) wmic useraccount where disabled="true" get name ^| findstr /i "Guest" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 계정이 존재하고 결과값이 없을 시, Guest 계정 활성화됨 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wmic useraccount where disabled="true" get name 2>NUL | findstr /i "Guest" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
net user guest >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [02.W-02] Guest 계정 상태 [%RESULT_02%]
:02_END
SET CMT_02=
SET RESULT_02=

:02_ADD

REM ==================================================
:03_START
echo [03.W-03] 불필요한 계정 제거 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:03_ROUTINE
SET CMT_03=수동 점검&SET RESULT_03=인터뷰


:03_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_03% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 3개월 이상 로그인하지 않은 불필요한 계정 "제거" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_03% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) net user "활성 계정" ^| findstr "최근 마지막 last" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 계정 5개 이상일 경우, 5개를 제외한 나머지는 생략 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
SET count=0

wmic useraccount where Disabled=false get name | findstr /v /r "^$ Name" > users.txt
FOR /f "tokens=1 delims= " %%i IN (users.txt) DO (
	net user %%i >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo ==============================================  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
IF EXIST users.txt del users.txt

:03_PRINT_1
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [03.W-03] 불필요한 계정 제거 [%RESULT_03%]
:03_END
SET CMT_03=
SET RESULT_03=
SET count=
SET USER_date=
SET USER_year=
SET USER_month=
SET NOW_03_month=
SET NOW_03_year=

:03_ADD

REM ==================================================
:04_START
echo [04.W-04] 계정 잠금 임계값 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:04_ROUTINE

SET CMT_04=초기화&SET RESULT_04=양호
FOR /f "tokens=2 delims== " %%i IN ('type "%SECPOL%" ^| findstr /i "LockoutBadCount"') DO (
	IF %%i EQU 0 (
		SET CMT_04=계정 잠금 임계값이 "설정되지 않음"&SET RESULT_04=취약& GOTO :04_PRINT
	)
	IF %%i LEQ 5 (
		SET CMT_04=계정 잠금 임계값이 "5회 이하"로 설정됨&SET RESULT_04=양호
	) ELSE (
		SET CMT_04=계정 잠금 임계값이 "5회 초과"로 설정됨&SET RESULT_04=취약
	)
)

:04_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_04% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 계정 잠금 임계값을 "5회 이하"로 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_04% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "LockoutBadCount" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "LockoutBadCount" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo 설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [04.W-04] 계정 잠금 임계값 설정 [%RESULT_04%]
:04_END
SET CMT_04=

:04_ADD
REM [항목] 계정 잠금 임계값 설정
REM 해당 항목이 설정되어야 관련 설정항목들이 활성화됨 (08번)

REM ==================================================
:05_START
echo [05.W-05] 해독 가능한 암호화를 사용하여 암호 저장 해제 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:05_ROUTINE
SET CMT_05=초기화&SET RESULT_05=인터뷰
type secpol.inf | findstr "ClearTextPassword" | findstr "0" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_05=해독 가능한 암호화를 "사용하지 않음"&SET RESULT_05=양호& GOTO :05_PRINT
)
IF ERRORLEVEL 1 (
	SET CMT_05=해독 가능한 암호화를 "사용"함&SET RESULT_05=취약& GOTO :05_PRINT
)

:05_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_05% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 해독 가능한 암호화를 "사용하지 않음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_05% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr "ClearTextPassword" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr "ClearTextPassword" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [05.W-05] 해독 가능한 암호화를 사용하여 암호 저장 해제[%RESULT_05%]
:05_END
SET CMT_05=
SET RESULT_05=

:05_ADD
REM [설정] 보안정책 설정파일 위치
REM 1.  XP, 2003 : %windir%\repair\secsetup.inf
REM 2. vista, 7, 2008 : %windir%\inf\defltbase.inf
REM 3. 2012, 2016, 2019 ??(테스트 후 수정 예정)

REM ==================================================
:06_START
echo [06.W-06] 관리자 그룹에 최소한의 사용자 포함 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:06_ROUTINE
SET CMT_06=관리자 그룹에 최소한의 사용자가 "포함" 여부 확인&SET RESULT_06=인터뷰

:06_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_06% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 관리자 그룹에 최소한의 사용자가 "포함" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_06% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) net localgroup "Administrators" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 계정 10개 이상일 경우, 10개를 제외한 나머지는 생략 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
SET count=0
FOR /f %%i IN ('net localgroup "Administrators" ^| findstr /i /v "^$ 별칭 Alias 명령 completed 설명 Comment 구성원 Members -"') DO (
	net user %%i 2>NUL | findstr /i "활성 active" | findstr /i "아니요 No" >NUL
	IF NOT ERRORLEVEL 1 (
		echo     ^(inactive^)%%i >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
	IF ERRORLEVEL 1 (
		echo     %%i >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
	SET /a count+=1
	IF !count! EQU 10 (
		echo     ... >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		GOTO :06_PRINT_1
	)
)
:06_PRINT_1
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [06.W-06] 관리자 그룹에 최소한의 사용자 포함 [%RESULT_06%]
:06_END
SET CMT_06=
SET RESULT_06=
SET count=

:06_ADD

REM ==================================================
:07_START
echo [07.W-07] Everyone 사용 권한을 익명 사용자에게 적용 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:07_ROUTINE
SET CMT_07=초기화&SET RESULT_07=인터뷰
type secpol.inf | findstr /i "everyoneincludesanonymous" | findstr /i "4,0" >NUL
IF ERRORLEVEL 1 (
	SET CMT_07=Everyone 사용 권한을 익명 사용자에게 적용을 "사용"함&SET RESULT_07=취약
)
IF NOT ERRORLEVEL 1 (
	SET CMT_07=Everyone 사용 권한을 익명 사용자에게 적용을 "사용 안 함"&SET RESULT_07=양호
)

:07_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_07% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 네트워크 액세스:Everyone 사용 권한을 익명 사용자에게 적용 "사용 안 함" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_07% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr "everyoneincludesanonymous" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "everyoneincludesanonymous" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\System\CurrentControlSet\Control\Lsa" /v "EveryoneIncludesAnonymous" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\System\CurrentControlSet\Control\Lsa" /v "EveryoneIncludesAnonymous" 2>NUL | findstr /i "EveryoneIncludesAnonymous" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [07.W-07] Everyone 사용 권한을 익명 사용자에게 적용 [%RESULT_07%]
:07_END
SET CMT_07=
SET RESULT_07=

:07_ADD
REM [항목] Everyone 사용 권한을 익명 사용자에게 적용
REM 익명사용자의 네트워크 엑세스시 everyone 권한 자원에 대한 접근 허용 여부

REM ==================================================
:08_START
echo [08.W-08] 계정 잠금 기간 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:08_ROUTINE
SET CMT_08=초기화&SET RESULT_08=양호
IF "%RESULT_04%" == "양호" (
	type secpol.inf | findstr /i "LockoutDuration" >NUL
	FOR /f "tokens=3 delims= " %%i IN ('type "%SECPOL%" ^| findstr /i "LockoutDuration"') DO (
		IF %%i EQU -1 (
			SET CMT_08="관리자가 해제할 때까지" 계정 잠금으로 설정됨&SET RESULT_08=양호
		) ELSE (
			IF %%i GEQ 60 (
				SET CMT_08=계정 잠금 기간이 "60분 이상"으로 설정됨&SET RESULT_08=양호
			) ELSE (
				SET CMT_08=계정 잠금 기간이 "60분 미만"으로 설정됨&SET RESULT_08=취약
			)
		)
	)
) ELSE (
	SET CMT_08=계정잠금임계값이 "설정되지 않음"^(4번 항목 취약^)&SET RESULT_08=취약
)

:08_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_08% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 계정 잠금 임계값이 존재하고 잠금 기간 및 다음 시간 후 계정 잠금 수를 원래대로 설정이 60분 이상으로 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_08% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo 계정 잠금 임계값 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type "%SECPOL%" | findstr /i "LockoutBadCount" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo 계정 잠금 기간 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type "%SECPOL%" | findstr /i "LockoutDuration" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo 다음 시간 후 계정 잠금 수를 원래대로 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type "%SECPOL%" | findstr /i "LockoutDuration" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)


echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [08.W-08] 계정 잠금 기간 설정 [%RESULT_08%]
:08_END
SET CMT_08=
SET RESULT_08=


:08_ADD
REM [항목] 계정 잠금 기간 설정
REM 04번 항목의 계정잠금임계값이 설정되어야 해당 기능 설정가능
REM 아님 == 0분 설정

REM ==================================================
:09_START
echo [09.W-09] 비밀번호 관리 정책 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:09_ROUTINE
SET CMT_09=초기화&SET RESULT_09=인터뷰
type secpol.inf | findstr /i "PasswordComplexity" | findstr "1" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_09=패스워드 복잡성 정책이 "설정"됨&SET RESULT_09=양호
)
IF ERRORLEVEL 1 (
	SET CMT_09=패스워드 복잡성 정책이 "설정되지 않음"&SET RESULT_09=취약
	GOTO :END_09
)
FOR /f "tokens=2 delims== " %%i IN ('type "%SECPOL%" ^| findstr /i "MinimumPasswordLength"') DO (
	IF %%i LSS 8 (
		SET CMT_09=패스워드 최소 암호 길이 "8자리 미만" 설정됨&SET RESULT_09=취약
		GOTO :END_09
	) ELSE (
		SET CMT_09=패스워드 최소 암호 길이 "8자리 이상" 설정됨&SET RESULT_09=양호
	)
	IF %%i EQU 0 (
		SET CMT_09=패스워드 최소 암호 길이 정책이 "설정되지 않음"&SET RESULT_09=취약
		GOTO :END_09
	)
)
FOR /f "tokens=2 delims== " %%i IN ('type "%SECPOL%" ^| findstr /i "MaximumPasswordAge" ^| findstr /v "Netlogon"') DO (
	IF %%i EQU 0 (
		SET CMT_09=패스워드 사용 기간 "제한 없음",&SET RESULT_09=취약
		GOTO :END_09
	)
	IF %%i GTR 90 (
		SET CMT_09=패스워드 최대 사용 기간이 "90일 초과"로 설정됨,&SET RESULT_09=취약
		GOTO :END_09
	) ELSE (
		SET CMT_09=패스워드 최대 사용 기간이 "90일 이하"로 설정됨,&SET RESULT_09=양호
	)
)
FOR /f "tokens=2 delims= " %%i IN ('type "%SECPOL%" ^| findstr /i "MinimumPasswordAge"') DO (
	IF %%i GEQ 1 (
		SET CMT_09=패스워드 최소 사용 기간이 "1일 이상"으로 설정됨
	) ELSE (
		SET CMT_09=패스워드 최소 사용 기간이 "설정되지 않음"&SET RESULT_09=취약
		GOTO :END_09
	)
)
FOR /f "tokens=2 delims== " %%i IN ('type "%SECPOL%" ^| findstr /i "PasswordHistorySize"') DO (
	IF %%i GEQ 4 (
		SET CMT_09=최근 암호 기억 개수가 "4개 이상"으로 설정됨
	) ELSE (
		SET CMT_09=최근 암호 기억 개수가 "4개 미만"으로 설정됨&SET RESULT_09=취약
		GOTO :END_09
	)
	IF %%i EQU 0 (
		SET CMT_09=최근 암호 기억 정책이 "설정되지 않음"&SET RESULT_09=취약
	)
)

:END_09


:09_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_09% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 패스워드 복잡성 정책 "설정", >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_09% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "PasswordComplexity" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "MinimumPasswordLength" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "MaximumPasswordAge" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "MinimumPasswordAge" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "PasswordHistorySize" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [09.W-09] 패스워드 복잡성 설정 [%RESULT_09%]
:09_END
SET CMT_09=
SET RESULT_09=

:09_ADD



REM ==================================================
:10_START
echo [10.W-10] 마지막 사용자 이름 표시 안함 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:10_ROUTINE
SET CMT_10=초기화&SET RESULT_10=인터뷰
type secpol.inf | findstr /i "DontDisplayLastUserName" | findstr /i "4,1" >NUL
IF ERRORLEVEL 1 (
	SET CMT_10=마지막 사용자 이름 표시 안함을 "사용 안 함"&SET RESULT_10=취약
)
IF NOT ERRORLEVEL 1 (
	SET CMT_10=마지막 사용자 이름 표시 안함을 "사용"함&SET RESULT_10=양호
)

:10_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_10% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 대화형 로그온:마지막 사용자 이름 표시 안함 "사용" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_10% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "DontDisplayLastUserName" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "DontDisplayLastUserName" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DontDisplayLastUserName" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DontDisplayLastUserName" 2>NUL | findstr /i "DontDisplayLastUserName" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [10.W-10] 마지막 사용자 이름 표시 안함 [%RESULT_10%]
:10_END
SET CMT_10=
SET RESULT_10=

:10_ADD
REM [항목] 마지막 사용자 이름 표시 안함
REM windows10의 경우, 기본 차단 >> users.txt

REM ==================================================
:11_START
echo [11.W-11] 로컬 로그온 허용 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:11_ROUTINE
SET CMT_11=초기화&SET RESULT_11=인터뷰
FOR /f "tokens=3 delims= " %%i IN ('type "%SECPOL%" ^| findstr /i "SeInteractiveLogonRight"') DO (
	SET NOW_11_group=%%i
	REM 관리자 그룹 S-1-5-32-544 (양호)
	echo !NOW_11_group! 2>NUL | findstr /i "S-1-5-32-544" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_11_group=!NOW_11_group:S-1-5-32-544=Administrators^(o^)!
	)

	REM IUSR_ 사용자 지정 그룹 (양호)
	echo !NOW_11_group! 2>NUL | findstr /i "IUSR S-1-5-17" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_11_group=!NOW_11_group:IUSR=사용자지정 IUSR^(o^)!
		SET NOW_11_group=!NOW_11_group:S-1-5-17=사용자지정 IUSR^(o^)!
	)

	REM 백업운영자그룹 S-1-5-32-551 (내부에 계정이 없을 경우 양호)
	echo !NOW_11_group! 2>NUL | findstr /i "S-1-5-32-551" >NUL
	IF NOT ERRORLEVEL 1 (
		FOR /f %%i IN ('net localgroup "Backup Operators" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET NOW_11_group=!NOW_11_group:S-1-5-32-551=Backup Operators^(x^)!
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 계정이 "존재"함
				SET CMT_11_1=!CMT_11_1! "Backup Operators"&SET RESULT_11=취약
			) ELSE (
				SET NOW_11_group=!NOW_11_group:S-1-5-32-551=Backup Operators^(o^)!
			)	
		)
	)

	REM 서버운영자그룹 S-1-5-32-549 (취약 그룹)
	echo !NOW_11_group! 2>NUL | findstr /i "S-1-5-32-549" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_11_group=!NOW_11_group:S-1-5-32-549=Server Operators^(x^)!
		FOR /f %%i IN ('net localgroup "Server Operators" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 계정이 "존재"함
				SET CMT_11_1=!CMT_11_1! "Server Operators"&SET RESULT_11=취약
			) ELSE (
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 그룹이 "존재"함
				SET CMT_11_2=!CMT_11_2! "Server Operators"&SET RESULT_11=취약
			)
		)
	)

	REM Guest (2번 항목 양호시 양호)
	echo !NOW_11_group! 2>NUL | findstr /i "Guest" >NUL
	IF NOT ERRORLEVEL 1 (
		IF "%RESULT_02%" EQU "취약" (
			SET NOW_11_group=!NOW_11_group:Guest=active Guest계정^(x^)!
			SET CMT_11=로컬 로그온 허용 계정에 불필요한 계정이 "존재"함
			SET CMT_11_1=!CMT_11_1! "Guest계정"&SET RESULT_11=취약
		) ELSE (
			SET NOW_11_group=!NOW_11_group:Guest=inactive Guest계정^(o^)!
		)
	)

	REM Guests 그룹 S-1-5-32-546 (취약 그룹)
	echo !NOW_11_group! 2>NUL | findstr /i "Guests" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_11_group=!NOW_11_group:S-1-5-32-546=Guests^(x^)!
		FOR /f %%i IN ('net localgroup "Guests" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 계정이 "존재"함
				SET CMT_11_1=!CMT_11_1! "Guests"&SET RESULT_11=취약
			) ELSE (
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 그룹이 "존재"함
				SET CMT_11_2=!CMT_11_2! "Guests"&SET RESULT_11=취약
			)
		)
	)

	REM 사용자그룹 (취약 그룹)
	echo !NOW_11_group! 2>NUL | findstr /i "S-1-5-32-545" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_11_group=!NOW_11_group:S-1-5-32-545=Users^(x^)!
		FOR /f %%i IN ('net localgroup "Users" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 계정이 "존재"함
				SET CMT_11_1=!CMT_11_1! "Users"&SET RESULT_11=취약
			) ELSE (
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 그룹이 "존재"함
				SET CMT_11_2=!CMT_11_2! "Users"&SET RESULT_11=취약
			)
		)
	)

	REM 도메인 관련 그룹 (취약 그룹)
	echo !NOW_11_group! 2>NUL | findstr /i "S-1-5-21" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_11_group=!NOW_11_group:S-1-5-21=Domain related^(x^)!
		SET CMT_11=로컬 로그온 허용 계정에 불필요한 계정/그룹이 "존재"함
		SET CMT_11_1=!CMT_11_1! "Domain related"&SET RESULT_11=취약
	)

	REM 계정 운영자 그룹 (내부에 계정이 없을 경우 양호)
	echo !NOW_11_group! 2>NUL | findstr /i "S-1-5-32-548" >NUL
	IF NOT ERRORLEVEL 1 (
		FOR /f %%i IN ('net localgroup "Account Operators" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET NOW_11_group=!NOW_11_group:S-1-5-32-548=Account Operators^(x^)!
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 계정이 "존재"함
				SET CMT_11_1=!CMT_11_1! "Domain controler:Account Operators"&SET RESULT_11=취약
			) ELSE (
				SET NOW_11_group=!NOW_11_group:S-1-5-32-548=Account Operators^(o^)!
			)
		)
	)

	REM 도메인 프린터 그룹 (취약 그룹)
	echo !NOW_11_group! 2>NUL | findstr /i "S-1-5-32-550" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_11_group=!NOW_11_group:S-1-5-32-550=Print Operators^(x^)!
		FOR /f %%i IN ('net localgroup "Print Operators" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 계정이 "존재"함
				SET CMT_11_1=!CMT_11_1! "Domain controler:Print Operators"&SET RESULT_11=취약
			) ELSE (
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 그룹이 "존재"함
				SET CMT_11_2=!CMT_11_2! "Domain controler:Print Operators"&SET RESULT_11=취약
			)
		)
	)

	REM vmware 사용자 그룹 (취약 그룹)
	echo !NOW_11_group! 2>NUL | findstr /i "__vmware__" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_11_group=!NOW_11_group:vmware=Vmare Users^(x^)!
		FOR /f %%i IN ('net localgroup "__vmware__" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 계정이 "존재"함
				SET CMT_11_1=!CMT_11_1! "Vmware Users"&SET RESULT_11=취약
			) ELSE (
				SET CMT_11=로컬 로그온 허용 계정에 불필요한 그룹이 "존재"함
				SET CMT_11_2=!CMT_11_2! "Vmware Users"&SET RESULT_11=취약
			)
		)
	)
)

:11_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_11% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 로컬 로그온 허용 계정에 administrators, IUSR 이외의 계정이 "존재하지 않음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_11% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo %CMT_11_1% 2>NUL | findstr /r "\"*\"" >NUL
IF ERRORLEVEL 1 (
	echo   불필요한 그룹 목록^(계정 o^) : 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) ELSE (
	echo   불필요한 그룹 목록^(계정 o^) : %CMT_11_1% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo %CMT_11_2% 2>NUL | findstr /r "\"*\"" >NUL
IF ERRORLEVEL 1 (
	echo   불필요한 그룹 목록^(계정 x^) : 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) ELSE (
	echo   불필요한 그룹 목록^(계정 x^) : %CMT_11_2% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "SeInteractiveLogonRight" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* o/x 표시가 없는 그룹의 경우, 인터뷰 필요 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo SeInteractiveLogonRight = "%NOW_11_group%" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [11.W-11] 로컬 로그온 허용 [%RESULT_11%]
:11_END
SET CMT_11=
SET CMT_11_1=
SET CMT_11_2=
SET RESULT_11=
SET NOW_11_group=

:11_ADD
REM [기준] 관리자그룹, 비활성 Guest를 제외한 그룹이 존재할 경우 그룹 내부 계정의 존재 유무에 따라 판단
REM (그룹이름으로 변환되지 않는 SID는 스크립트에 추가해야하므로 공지해주기)
REM
REM [설명] 기본 설정 그룹 (Users, Guest, Print Operators와 같은 취약그룹 외 나머지는 그룹내 계정존재여부에 따라 양호처리)
REM 워크스테이션 및 서버: Administrators, Backup Operators, Power Users, Users 및 Guest.
REM 도메인 컨트롤러: Account Operators, Administrators, Backup Operators 및 Print Operators.


REM ==================================================
:12_START
echo [12.W-12] 익명 SID/이름 변환 허용 해제 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:12_ROUTINE
SET CMT_12=초기화&SET RESULT_12=인터뷰
type secpol.inf | findstr /i "LSAAnonymousNameLookup" | findstr "0" >NUL
IF ERRORLEVEL 1 (
	SET CMT_12=익명 SID/이름 변환 허용 정책을 "사용"함&SET RESULT_12=취약
)
IF NOT ERRORLEVEL 1 (
	SET CMT_12=익명 SID/이름 변환 허용 정책을 "사용 안 함"&SET RESULT_12=양호
)

:12_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_12% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 익명 SID/이름 변환 허용 정책 "사용 안 함" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_12% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "LSAAnonymousNameLookup" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "LSAAnonymousNameLookup" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [12.W-12] 익명 SID/이름 변환 허용 해제[%RESULT_12%]
:12_END
SET CMT_12=
SET RESULT_12=

:12_ADD
REM [항목] 익명 SID/이름 변환 허용
REM 워크스테이션 및 구성원 서버의 기본값: 사용 안 함
REM Windows Server 2008 이상을 실행하는 도메인 컨트롤러의 기본값: 사용 안 함
REM Windows Server 2003 R2 이하를 실행하는 도메인 컨트롤러의 기본값: 사용


REM ==================================================
:13_START
echo [13.W-13] 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:13_ROUTINE
SET CMT_13=초기화&SET RESULT_13=인터뷰
type secpol.inf | findstr /i "LimitBlankPasswordUse" | findstr "4,1" >NUL
IF ERRORLEVEL 1 (
	SET CMT_13_1=콘솔 로그온 시 로컬 계정에서 빈 암호 사용이 "제한되지 않음"&SET RESULT_13=취약
) ELSE (
	SET CMT_13_1=콘솔 로그온 시 로컬 계정에서 빈 암호 사용이 "제한"됨&SET RESULT_13=양호
)
FOR /f %%i IN ('wmic useraccount where disabled^="false" get name ^| findstr /v /i "^$ Name"') DO (
	net user %%i | findstr /i "필요 required" | findstr /i "예 yes" >NUL
	IF NOT ERRORLEVEL 1 (
		net user %%i | findstr /i "설명 comment" | findstr /i "기본 built-in" >NUL
		IF ERRORLEVEL 1 (
			SET CMT_13=일부 계정의 비밀번호가 "설정되지 않음",&SET RESULT_13=취약& GOTO :13_PRINT
		) ELSE (
			SET CMT_13=모든 계정의 비밀번호가 "설정"됨,
		)
	) ELSE (
		SET CMT_13=모든 계정의 비밀번호가 "설정"됨,
	)
)

:13_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_13% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 콘솔 로그온 시 로컬 계정에서 빈 암호 사용이 "제한" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_13% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황2: %CMT_13_1% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) net user "활성 계정" ^| findstr "필요" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* Built-in 계정은 예외(접속 불가) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 계정 5개 이상일 경우, 5개를 제외한 나머지는 생략 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
SET count=0
FOR /f %%i IN ('wmic useraccount where disabled^="false" get name ^| findstr /v /i "^$ Name"') DO (
	echo - %%i - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	net user %%i | findstr /i "필요 required 설명 comment" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	SET /a count+=1
	IF !count! EQU 5 (
		echo ... >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		GOTO :13_PRINT_1
	)
)

:13_PRINT_1
echo (CMD) type secpol.inf ^| findstr /i "LimitBlankPasswordUse" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "LimitBlankPasswordUse" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "LimitBlankPasswordUse" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "LimitBlankPasswordUse" 2>NUL | findstr /i "LimitBlankPasswordUse" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [13.W-13] 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 [%RESULT_13%]

:13_END
SET CMT_13=
SET RESULT_13=
SET count=

:13_ADD

REM ==================================================
:14_START
echo [14.W-14] 원격터미널 접속 가능한 사용자 그룹 제한 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:14_ROUTINE
SET CMT_14=초기화&SET RESULT_14=인터뷰
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" 2>NUL |findstr /i "fDenyTSConnections" | findstr "0x1" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_14=원격데스크톱이 "비활성화"됨
	SET RESULT_14=양호
	GOTO :14_PRINT
)
SET CMT_14=로컬 로그온 허용 계정에 불필요한 계정이 "존재하지 않음"
SET RESULT_14=양호
FOR /f "tokens=3 delims= " %%i IN ('type "%SECPOL%" ^| findstr /i "SeRemoteInteractiveLogonRight"') DO (
	SET NOW_14_group=%%i

	REM 관리자 그룹 S-1-5-32-544 (양호)
	echo !NOW_14_group! 2>NUL | findstr /i "S-1-5-32-544" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_14_group=!NOW_14_group:S-1-5-32-544=Administrators^(o^)!
	)

	REM Remote 데스크톱 사용자 그룹 S-1-5-32-555 (양호)
	echo !NOW_14_group! 2>NUL | findstr /i "S-1-5-32-555" >NUL
	IF NOT ERRORLEVEL 1 (
		FOR /f %%i IN ('net localgroup "Remote Desktop Users" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET NOW_14_group=!NOW_14_group:S-1-5-32-555=Remote Desktop Users^(?^)!
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 계정이 존재 여부 확인
				SET RESULT_14=인터뷰
				SET CMT_14_1=!CMT_14_1! "Remote Desktop Users"
			) ELSE (
				SET NOW_14_group=!NOW_14_group:S-1-5-32-555=Remote Desktop Users^(o^)!
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 계정이 "존재하지 않음"
			)
		)
	)

	REM IUSR_ 사용자 지정 그룹(취약 그룹)
	echo !NOW_14_group! 2>NUL | findstr /i "IUSR S-1-5-17" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_14_group=!NOW_14_group:S-1-5-17=사용자지정 IUSR^(x^)!
		SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 그룹이 "존재"함
		SET CMT_14_1=!CMT_14_1! "IUSR"&SET RESULT_14=취약
	)

	REM 백업운영자그룹 S-1-5-32-551(취약 그룹)
	echo !NOW_14_group! 2>NUL | findstr /i "S-1-5-32-551" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_14_group=!NOW_14_group:S-1-5-32-551=Backup Operators^(x^)!
		FOR /f %%i IN ('net localgroup "Backup Operators" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 계정이 "존재"함
				SET CMT_14_1=!CMT_14_1! "Backup Operators"&SET RESULT_14=취약
			) ELSE (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 그룹이 "존재"함
				SET CMT_14_2=!CMT_14_2! "Backup Operators"&SET RESULT_14=취약
			)
		)
	)

	REM Guest (2번 항목 양호시 양호)
	echo !NOW_14_group! 2>NUL | findstr /i "Guest" >NUL
	IF NOT ERRORLEVEL 1 (
		IF "%RESULT_02%" EQU "취약" (
			SET NOW_14_group=!NOW_14_group:Guest=active Guest계정^(x^)!
			SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 계정이 "존재"함
			SET CMT_14_1=!CMT_18_1! "Guest계정"&SET RESULT_14=취약
		) ELSE (
			SET NOW_14_group=!NOW_14_group:Guest=inactive Guest계정^(o^)!
		)
	)

	REM Guests 그룹 S-1-5-32-546 (취약 그룹)
	echo !NOW_14_group! 2>NUL | findstr /i "Guests" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_14_group=!NOW_14_group:S-1-5-32-546=Guests^(x^)!
		FOR /f %%i IN ('net localgroup "Guests" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 계정이 "존재"함
				SET CMT_14_1=!CMT_14_1! "Guests"&SET RESULT_14=취약
			) ELSE (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 그룹이 "존재"함
				SET CMT_14_2=!CMT_14_2! "Guests"&SET RESULT_14=취약
			)
		)
	)

	REM 사용자그룹 (취약 그룹)
	echo !NOW_14_group! 2>NUL |findstr /i "S-1-5-32-545" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_14_group=!NOW_14_group:S-1-5-32-545=Users^(x^)!
		FOR /f %%i IN ('net localgroup "Users" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 계정이 "존재"함
				SET CMT_14_1=!CMT_14_1! "Users"&SET RESULT_14=취약
			) ELSE (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 그룹이 "존재"함
				SET CMT_14_2=!CMT_14_2! "Users"&SET RESULT_14=취약
			)
		)
	)

	REM 도메인그룹 (취약 그룹)
	echo !NOW_14_group! 2>NUL |findstr /i "S-1-5-21" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_14_group=!NOW_14_group:S-1-5-21=Domain related^(x^)!
		FOR /f %%i IN ('net localgroup "Server Operators" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 계정이 "존재"함
				SET CMT_14_1=!CMT_14_1! "Domain related"&SET RESULT_14=취약
			) ELSE (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 그룹이 "존재"함
				SET CMT_14_2=!CMT_14_2! "Domain related"&SET RESULT_14=취약
			)
		)
	)

	REM 계정 운영자 그룹 (취약 그룹)
	echo !NOW_14_group! 2>NUL |findstr /i "S-1-5-32-548" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_14_group=!NOW_14_group:S-1-5-32-548=Account Operators^(x^)!
		FOR /f %%i IN ('net localgroup "Server Operators" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 계정이 "존재"함
				SET CMT_14_1=!CMT_14_1! "Domain controler:Account Operators"&SET RESULT_14=취약
			) ELSE (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 그룹이 "존재"함
				SET CMT_14_2=!CMT_14_2! "Domain controler:Account Operators"&SET RESULT_14=취약
			)
		)
	)

	REM 도메인 프린터 그룹 (취약 그룹)
	echo !NOW_14_group! 2>NUL |findstr /i "S-1-5-32-550" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_14_group=!NOW_14_group:S-1-5-32-550=Print Operators^(x^)!
		FOR /f %%i IN ('net localgroup "Print Operators" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 계정이 "존재"함
				SET CMT_14_1=!CMT_14_1! "Print Operators"&SET RESULT_14=취약
			) ELSE (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 그룹이 "존재"함
				SET CMT_14_2=!CMT_14_2! "Print Operators"&SET RESULT_14=취약
			)
		)
	)

	REM vmware 사용자 그룹 (취약 그룹)
	echo !NOW_14_group! 2>NUL | findstr /i "__vmware__" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_14_group=!NOW_14_group:vmware=Vmware Users^(x^)!
		FOR /f %%i IN ('net localgroup "__vmware__" ^| findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" ^| find /c /v "^$"') DO (
			IF NOT %%i EQU 0 (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 그룹이 "존재"함
				SET CMT_14_1=!CMT_14_1! "Vmware Users"&SET RESULT_14=취약
			) ELSE (
				SET CMT_14=원격터미널 접속 가능한 사용자 그룹에 불필요한 계정이 "존재"함
				SET CMT_14_2=!CMT_14_2! "Vmware Users"&SET RESULT_14=취약
			)
		)
	)
)

:14_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_14% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 원격데스크톱 "비활성화" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        또는 원격터미널 접속 가능한 사용자 그룹에 불필요한 계정이 "존재하지 않음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_14% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_14_1%  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_14_2%  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo - 원격 데스크톱 사용 여부 - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" 2>NUL | findstr /i "fDenyTSConnections" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) type secpol.inf ^| findstr /i "SeRemoteInteractiveLogonRight" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* o/x 표시가 없는 그룹의 경우, 인터뷰 필요 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo SeRemoteInteractiveLogonRight = "%NOW_14_group%" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo %NOW_14_group% 2>NUL | findstr /c:"Remote Desktop Users" >NUL
IF NOT ERRORLEVEL 1 (
	echo ^(CMD^) net localgroup "Remote Desktop Users" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo ^*^* 결과값 존재시, 3번 항목 계정 정보 비교 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	net localgroup "Remote Desktop Users" | findstr /i /v "^$ ^- 별칭 alias 설명 comment 구성원 members 명령 command" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [14.W-14] 원격터미널 접속 가능한 사용자 그룹 제한 [%RESULT_14%]
:14_END
SET CMT_14=
SET CMT_14_1=
SET CMT_14_2=
SET RESULT_14=
SET NOW_14_group=

:14_ADD
REM [항목] 원격터미널 접속 가능한 사용자 그룹 제한
REM 관리자 그룹과 원격데스크톱사용자 그룹을 제외한 나머지 그룹은 모두 취약
REM 원격데스크톱사용자 그룹의 사용자는 확인 필요




REM ==================================================
REM ==================================================
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ----------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo  2. 서비스관리  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ----------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo.
echo.
echo 2. 서비스관리
echo --------------

REM ==================================================
:15_START
echo [15.W-15] 사용자 개인키 사용 시 암호 입력 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:15_ROUTINE
SET CMT_15=Windows 버전 확인 중
SET RESULT_15=인터뷰

echo %OS_VER% 2>NUL | findstr "10.0" >NUL
IF NOT ERRORLEVEL 1 (
	REM Windows 2016 이상 (10.0) - 점검 대상
	type secpol.inf | findstr /i "ForceKeyProtection" | findstr "2" >NUL
	IF ERRORLEVEL 1 (
		SET CMT_15=취약한 옵션
		SET RESULT_15=취약
	) ELSE (
		SET CMT_15=키를 사용할 때마다 암호를 매번 입력해야함 설정
		SET RESULT_15=양호
	)
) ELSE (
	REM Windows 2012 R2 이하 (5.x, 6.0, 6.1, 6.2, 6.3) - 해당없음
	SET CMT_15=Windows 2016 이상만 점검대상임
	SET RESULT_15=양호
)


:15_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_15% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 사용자 개인 키를 사용할 때마다 암호 입력 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_15% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "ForceKeyProtection" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "ForceKeyProtection" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [15.W-15] 사용자 개인키 사용 시 암호 입력[%RESULT_15%]
:15_END
SET CMT_15=
SET RESULT_15=

:15_ADD



REM ==================================================
:16_START
echo [16.W-16] 공유 권한 및 사용자 그룹 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:16_ROUTINE
SET CMT_16=초기화
SET RESULT_16=인터뷰

FOR /f "tokens=*" %%i IN ('wmic share get caption ^| findstr /v /i "^$ 기본 원격 Default remote caption" ^| find /c /v "^$"') DO (
	IF %%i EQU 0 (
		SET CMT_16=일반 공유가 존재하지 않음
		SET RESULT_16=양호
		GOTO :16_PRINT
	) ELSE (
		SET CMT_16=공유폴더에 Everyone 권한이 존재하지 않음
		SET RESULT_16=양호
	)
)

FOR /f "tokens=1,2,* skip=1 delims= " %%i IN ('wmic share get caption^, path ^| findstr /v /i "^$ 기본 원격 Default remote"') DO (
	echo %%j | findstr ":" >NUL
	IF ERRORLEVEL 1 (
		SET CMT_16=확인필요
		SET RESULT_16=인터뷰
		GOTO :16_PRINT
	) ELSE (
		net share %%i 2>NUL | findstr /i "Everyone" >NUL
		IF NOT ERRORLEVEL 1 (
			SET CMT_16=공유폴더에 Everyone 권한이 존재함
			SET RESULT_16=취약
		)
	)
)

:16_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_16% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 기본공유를 제외한 일반공유 디렉터리 접근 권한에 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        Everyone 권한이 "존재하지 않음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_16% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) net share "일반 공유 디렉토리" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
FOR /f "tokens=1,2,* skip=1 delims= " %%i IN ('wmic share get caption^, path ^| findstr /v /i "^$ 기본 원격 Default remote"') DO (
	echo - %%i - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo %%j | findstr ":" >NUL
	IF ERRORLEVEL 1 (
		echo     이름에 공백이 포함된 공유폴더로 수동 진단 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
	net share %%i 2>NUL | findstr /v "^$ 이름 name 경로 path 설명 description 사용자 user 캐싱 cache 명령 completed" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
net share >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [16.W-16] 공유 권한 및 사용자 그룹 설정 [%RESULT_16%]
:16_END
SET CMT_16=
SET RESULT_16=

:16_ADD

REM ==================================================
:17_START
echo [17.W-17] 하드디스크 기본 공유 제거 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:17_ROUTINE
SET CMT_17=초기화&SET RESULT_17=인터뷰
wmic share list brief | findstr /i "원격 remote 기본 Default" | findstr /v /i "IPC" > NUL 2> NUL
IF NOT ERRORLEVEL 1 (SET CMT_17=기본 공유가 "존재"함,&SET RESULT_17=취약)

REG QUERY "HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" /v "AutoShareServer" 2>NUL | findstr "AutoShareServer" >NUL
IF ERRORLEVEL 1 (
	SET CMT_17_1=AutoShareServer값이 존재하지 않음&SET RESULT_17=취약
) ELSE (
	FOR /f "tokens=3 delims= " %%i IN ('REG QUERY "HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" /v "AutoShareServer" ^| findstr /i "AutoShareServer"') DO (
		IF "%%i" == "0x0" (
			SET CMT_17_1=AutoShareServer값이 "0x0"로 설정됨
		) ELSE (
			SET CMT_17_1=AutoShareServer값이 "%%i"로 설정됨&SET RESULT_17=취약
		)
	)
)

:17_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_17% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 불필요한 공유 폴더(기본공유 등) "제거"하고 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        AutoShareServer값이 "0x0"로 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_17% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황2: %CMT_17_1% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) wmic share list brief >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wmic share list brief > wmic.inf
type wmic.inf >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" /v "AutoShareServer" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
REG QUERY "HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" /v "AutoShareServer" 2>NUL | findstr /i "AutoShareServer" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [17.W-17] 하드디스크 기본 공유 제거 [%RESULT_17%]
:17_END
SET CMT_17=
SET CMT_17_1=
SET RESULT_17=

:17_ADD

REM ==================================================
:18_START
echo [18.W-18] 불필요한 서비스 제거 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:18_ROUTINE
SET CMT_18=초기화
SET RESULT_18=양호

REM 주통기반 항목
type services.inf | findstr /i /c:"Alerter" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo 불필요한 "Alerter" 서비스가 실행 중 >> service_now.txt&SET RESULT_18=취약
)
type services.inf | findstr /i /c:"Clipbook" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo 불필요한 "Clipbook" 서비스가 실행 중 >> service_now.txt&SET RESULT_18=취약
)
type services.inf | findstr /i /c:"Messenger" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo 불필요한 "Messenger" 서비스가 실행 중 >> service_now.txt&SET RESULT_18=취약
)
type services.inf | findstr /i /c:"Simple TCP/IP Services" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo 불필요한 "Simple TCP/IP Services" 서비스가 실행 중 >> service_now.txt&SET RESULT_18=취약
)

REM 그외 추가 항목
type services.inf | findstr /i /c:"Automatic Updates" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo "Automatic Updates" : PMS 및 수동 업데이트 여부 확인 필요 >> service_now.txt
)
type services.inf | findstr /i /c:"Computer Browser" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo "Computer Browser" : 독립 PC 여부 확인 필요 >> service_now.txt
)
REM type services.inf | findstr /i /c:"Cryptographic Services" | findstr /i "Running" >> service_cmd.txt
REM IF NOT ERRORLEVEL 1 (echo 불필요한 "Cryptographic Services" 서비스가 실행 중 >> service_now.txt&SET RESULT_21=취약)
type services.inf | findstr /i /c:"DHCP Client" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo "DHCP Client" : 모뎀 또는 DSL 사용 및 동적 IP 사용 여부 확인 >> service_now.txt
)
type services.inf | findstr /i /c:"Distributed Link Tracking Client" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo "Distributed Link Tracking Client" : 서버간 파일공유 등 서비스 사용 여부 확인 >> service_now.txt
)
type services.inf | findstr /i /c:"Distributed Link Tracking Server" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo "Distributed Link Tracking Server" : 서버간 파일공유 등 서비스 사용 여부 확인 >> service_now.txt
)
type services.inf | findstr /i /c:"DNS Client" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo "DNS Client" : IPSEC 서비스 사용 여부 확인 >> service_now.txt
)
type services.inf | findstr /i /c:"Error reporting Service" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo 불필요한 "Error reporting Service" 서비스가 실행 중 >> service_now.txt&SET RESULT_18=취약
)
type services.inf | findstr /i /c:"Human Interface Device Access" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo 불필요한 "Human Interface Device Access" 서비스가 실행 중 >> service_now.txt&SET RESULT_18=취약
)
type services.inf | findstr /i /c:"IMAPI CD-Burning COM Service" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo "IMAPI CD-Burning COM Service" : CD굽기 사용 여부 확인  >> service_now.txt&SET RESULT_18=취약
)
type services.inf | findstr /i /c:"NetMeeting Remote Desktop Sharing" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo 불필요한 "NetMeeting Remote Desktop Sharing" 서비스가 실행 중 >> service_now.txt&SET RESULT_18=취약
)
type services.inf | findstr /i /c:"Portable Media Serial Number" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo 불필요한 "Portable Media Serial Number" 서비스가 실행 중 >> service_now.txt&SET RESULT_18=취약
)
type services.inf | findstr /i /c:"Print spooler" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo "Print spooler" : 프린터 사용 여부 확인 >> service_now.txt&SET RESULT_18=취약
)
type services.inf | findstr /i /c:"Remote Registry Service" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo 불필요한 "Remote Registry Service" 서비스가 실행 중 >> service_now.txt&SET RESULT_18=취약
)
type services.inf | findstr /i /c:"Wireless Zero Configuration" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo 불필요한 "Wireless Zero Configuration" 서비스가 실행 중 >> service_now.txt&SET RESULT_18=취약
)
type services.inf | findstr /i /c:"bluetooth" | findstr /i "Running" >> service_cmd.txt
IF NOT ERRORLEVEL 1 (
	echo 불필요한 "bluetooth" 서비스가 실행 중 >> service_now.txt&SET RESULT_18=취약
)

IF "%RESULT_18%" == "양호" (
	FOR /f %%i in ('type service_now.txt ^|findstr /r /v "^$" ^| find /c /v ""') DO (
		IF %%i GTR 0 (
			SET RESULT_18=인터뷰
			SET CMT_18=불필요한 서비스가 있음
		) ELSE (
			SET CMT_18=불필요한 서비스가 없음
		)
	)
) ELSE (
	SET RESULT_18=취약
	SET CMT_18=불필요한 서비스가 있음
)

:18_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_18% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 불필요한 서비스 "제거" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_18% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type service_now.txt >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type services.inf ^| findstr /i "불필요한 서비스명" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type service_cmd.txt >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [18.W-18] 불필요한 서비스 제거 [%RESULT_18%]
:18_END
SET CMT_18=
SET RESULT_18=
del service_cmd.txt
del service_now.txt

:18_ADD
REM [기준] 확실한 불필요는 취약, 그외 인터뷰 (주석처리된 서비스는 사용자 편의성 고려해 제외)
REM
REM [주통기반 항목]
REM Alerter : 관리용 경고메세지 전송, PC는 서버 역할하지 않으므로 불필요
REM Clipbook : 다른 PC와 공유가능한 클립보드(일반 클립보드와 별도 서비스), 보안상 불필요
REM Messenger : PC간 경고메시지 전달에 사용(MSN과는 무관)하므로 불필요
REM Simple TCP/IP Services : 윈도우 기본 설치되지 않음, 오래된 UNIX 서비스로 불필요
REM
REM [그외 추가 항목]
REM Automatic Updates : 윈도우즈 사이트에 접속해 자동 다운 및 업데이트, PMS사용 또는 수동 업데이트시 불필요
REM Computer Browser : 네트워크 PC 목록 업데이트 및 관리 또는 파일 공유 이용시 필요, 독립 PC에는 불필요
REM Cryptographic Services : 윈도우 파일 서명 확인 카탈로그 DB 서비스, 윈도우 프로그램 설치시 "인증되지 않은 드라이버" 메세지만 뜸, 수동 업데이트 또는 MS 베포 프로그램 설치시 서비스 사용해야함
REM DHCP Client : 케이블 모뎀이나 ADSL, VDSL 서비스 사용시 필요, 그외 고정 IP 사용시 불필요
REM Distributed Link Tracking Client : NTFS 공유 드라이브 사용시 파일 주고받는 서비스(파일공유 등), 네트워크 미사용 PC는 불필요
REM DNS Client : IPSEC을 사용하는 경우를 제외하고 일반적인 TCP/IP를 쓰는 PC는 불필요
REM Error reporting Service : 각종 에러를 MS에 보고하는 서비스로 불필요
REM Human Interface Device Access : 볼륨조절 등의 기능이 추가된 키보드의 버튼 제어 등의 기능제공 서비스
REM IMAPI CD-Burning COM Service : XP는 CD굽기 기본값, CD굽기 프로그램을 별도로 사용 또는 CD굽기 미사용시 불필요
REM NetMeeting Remote Desktop Sharing : 취약한 원격 관리 도구 서비스로 불필요
REM Portable Media Serial Number : PC에 연결된 음약재생기 등록정보 확인 서비스로 불필요
REM Print spooler : 프린터 미사용시 불필요
REM Remote Registry Service : 취약한 원격 레지스트리 설정 변경 서비스로 불필요
REM Wireless Zero Configuration : 무선 LAN 미사용시 불필요
REM bluetooth : bluetooth관련 서비스로 보통 불필요

REM ==================================================
:19_START
echo [19.W-19] 불필요한 IIS 서비스 구동 점검 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:19_ROUTINE
SET CMT_19=초기화&SET RESULT_19=인터뷰
SET NETSTAT=%CD%\netstat.inf

SET IIS_FOUND=0
FOR /f "tokens=2 delims= " %%i IN (netstat.inf) DO (
	echo %%i | findstr ":80$" >NUL
	IF NOT ERRORLEVEL 1 SET IIS_FOUND=1
	echo %%i | findstr ":443$" >NUL
	IF NOT ERRORLEVEL 1 SET IIS_FOUND=1
)

IF !IIS_FOUND! EQU 0 (
	REM IIS 서비스 실제 상태 확인
	sc query W3SVC 2>NUL | findstr "RUNNING" >NUL
	IF NOT ERRORLEVEL 1 (
		SET CMT_19=IIS 서비스가 활성화되어 있고 포트가 열림
		SET RESULT_19=인터뷰
	) ELSE (
		SET CMT_19=IIS 포트가 열려있으나 서비스는 비활성화 됨
		SET RESULT_19=양호
	)
) ELSE (
	SET CMT_19=IIS 서비스 포트가 닫힘
	SET RESULT_19=양호
)


:19_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_19! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 불필요한 IIS 웹서비스 "비활성화" 및 "사용 안 함", >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        불필요한 IIS 웹서비스 포트 "닫힘" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_19! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type services.inf ^| findstr /i /c:"World Wide Web Publishing" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 서비스 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type services.inf | findstr /i /c:"World Wide Web Publishing" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type netstat.inf >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 열린 포트 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
FOR /f "tokens=1,2,* delims= " %%i IN ('type "%NETSTAT%"') DO (
	echo %%j. | findstr /l ":80. :443." >NUL
	IF NOT ERRORLEVEL 1 (
		echo %%i  %%j  %%k >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
)
echo (CMD) appcmd list sites >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF EXIST %SystemRoot%\System32\inetsrv\appcmd.exe (
	%SystemRoot%\System32\inetsrv\appcmd list sites >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) ELSE (
	echo     appcmd.exe 파일이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [19.W-19] IIS 서비스 구동 점검 [!RESULT_19!]
:19_END
SET CMT_19_1=
SET RESULT_19=

:19_ADD
REM [현황] IIS 서비스 구동 점검
REM IIS 관리 서비스 활성화 여부에 따라 양호/취약 판단
REM IIS 웹 서비스는 양호/취약 정도만 파악 후 다음 항목들 판단에 사용


REM ==================================================
:20_START
echo [20.W-20] NetBIOS 바인딩 서비스 구동 점검 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:20_ROUTINE
SET CMT_20=초기화&SET RESULT_20=인터뷰
ipconfig /all 2>NUL | findstr /i "NetBIOS" | findstr /i /r "사용$ Enabled" >NUL

IF %ERRORLEVEL% EQU 0 (
	SET CMT_20=NetBIOS 바인딩 서비스가 "활성화"안됨&SET RESULT_20=취약
) ELSE (
	SET CMT_20=NetBIOS 바인딩 서비스가 "활성화"됨&SET RESULT_20=양호
)

:20_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_20% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : NetBIOS 바인딩 서비스가 "활성화" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_20% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) ipconfig /all ^| findstr /i "NetBIOS" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* "DHCP", "네트워크 파일공유 서비스"를 사용하는 경우 인터뷰 필요 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 세부 IP 정보는 결과파일 하단의 "IP 정보" 확인 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
ipconfig /all | findstr /i "adapter 어댑터 netbios" | findstr /i /v "설명 Description" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [20.W-20] NetBIOS 바인딩 서비스 구동 점검 [%RESULT_20%]
:20_END
SET CMT_20=
SET RESULT_20=

:20_ADD

REM ==================================================
:21_START
echo [21.W-21] 암호화되지 않는 FTP 서비스 비활성화 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:21_ROUTINE
SET CMT_21=초기화&SET RESULT_21=인터뷰

SET FTP_FOUND=0
type netstat.inf | findstr ":20 :21" >NUL
IF NOT ERRORLEVEL 1 (
	SET FTP_FOUND=1
	SET CMT_21=FTP 서비스 포트가 "열림"
	SET RESULT_21=취약
) ELSE (
	SET FTP_FOUND=0
	SET CMT_21=FTP 서비스 포트가 "닫힘"
	SET RESULT_21=양호
)

:21_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_21! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : FTP 서비스 비활성화 및 SecureFTP 사용, >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_21! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo type services.inf ^| findstr /i /c:"FTP Publishing Service" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 서비스 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo type services.inf ^| findstr /i /c:"Microsoft FTP Service" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 서비스 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type services.inf | findstr /i "FTP" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type netstat.inf >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 열린 포트 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
FOR /f "tokens=1,2,* delims= " %%i IN ('type "%NETSTAT%"') DO (
	echo %%j. | findstr /l ":20. :21." >NUL
	IF NOT ERRORLEVEL 1 (
		echo %%i  %%j  %%k  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
)
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [21.W-21] 암호화되지 않는 FTP 서비스 비활성화 [!RESULT_21!]
:21_END
SET CMT_21_1=
SET RESULT_21=

:21_ADD


:22_START
echo [22.W-22] FTP 디렉토리 접근권한 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:22_ROUTINE
REM 2008
SET CMT_22=초기화&SET RESULT_22=양호

IF !FTP_FOUND! EQU 1 (
	reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\InetStp" /v "VersionString" 2>NUL | findstr /i "VersionString" | findstr "5. 6.0" >NUL
	IF ERRORLEVEL 1 (
		IF EXIST %SystemRoot%\System32\inetsrv\appcmd.exe (
			FOR /f "tokens=2 delims= " %%i IN ('%SystemRoot%\System32\inetsrv\appcmd list sites ^| findstr /i ":21"') DO (
				FOR /f %%a IN ('%SystemRoot%\System32\inetsrv\appcmd list vdirs /app.name:%%i/ /text:physicalPath') DO (
					cacls %%a | findstr /i "Everyone" >NUL
					IF NOT ERRORLEVEL 1 (
						SET CMT_22=FTP 홈 디렉터리에 불필요한 권한이 "존재"함 ^(Everyone^)&SET RESULT_22=취약
					) ELSE (
						SET CMT_22=FTP 홈 디렉터리에 불필요한 권한이 "존재하지 않음" ^(Everyone 외 수동 진단^)&SET RESULT_22=양호
					)
				)
			) 
		) ELSE (
			SET CMT_22=FTP 홈 디렉터리 존재하지 않음&SET RESULT_22=양호
		)
	) ELSE (
		FOR /f "tokens=2 delims==" %%i IN ('type C:\WINDOWS\system32\inetsrv\MetaBase.xml 2^>NUL ^| findstr /i "\<Path= ServerBindings" ^| findstr /i "path"') DO (
			cacls %%i | findstr /i "Everyone" >NUL
			IF NOT ERRORLEVEL 1 (
				SET CMT_22=FTP 홈 디렉터리에 불필요한 권한이 "존재"함 ^(Everyone^)&SET RESULT_22=취약
			) ELSE (
				SET CMT_22=FTP 홈 디렉터리에 불필요한 권한이 "존재하지 않음" ^(Everyone 외 수동 진단^)&SET RESULT_22=양호
			)
		)
	) 
) ELSE (
	SET CMT_22=FTP 서비스 포트가 "닫힘"
	SET RESULT_22=양호
)


:22_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_22! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : FTP 홈 디렉터리에 불필요한 권한 "존재하지 않음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_22! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type "IIS 설정파일" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

IF EXIST C:\WINDOWS\system32\inetsrv\MetaBase.xml (
	FOR /f "tokens=2 delims==" %%i IN ('type C:\WINDOWS\system32\inetsrv\MetaBase.xml 2^>NUL ^| findstr /i "\<Path= ServerBindings" ^| findstr /i "path"') DO (
		cacls %%i >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
) ELSE (
	echo     MetaBase.xml 파일이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

echo (CMD) cacls "FTP 홈 디렉터리" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF EXIST %SystemRoot%\System32\inetsrv\appcmd.exe (
	FOR /f "tokens=2 delims= " %%i IN ('%SystemRoot%\System32\inetsrv\appcmd list sites ^| findstr /i ":21"') DO (
		%SystemRoot%\System32\inetsrv\appcmd list sites | findstr /i ":21" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		FOR /f %%a IN ('%SystemRoot%\System32\inetsrv\appcmd list vdirs /app.name:%%i/ /text:physicalPath') DO (
			cacls %%a >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		)
	)
) ELSE (
	echo     appcmd.exe 파일이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [22.W-22] FTP 디렉토리 접근권한 설정 [!RESULT_22!]
:22_END
SET CMT_22=
SET RESULT_22=

:22_ADD

REM ==================================================
:23_START
echo [23.W-23] 공유 서비스에 대한 익명 접근 제한 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:23_ROUTINE
SET CMT_23=초기화&SET RESULT_23=인터뷰

IF !FTP_FOUND! EQU 1 (
    type %systemroot%\system32\inetsrv\config\applicationHost.config | findstr /i "anonymousAuthentication" | findstr /i "enabled" | findstr /i "true" >nul
	IF ERRORLEVEL 0 (
		SET CMT_23=익명 인증 사용 설정
		SET RESULT_23=취약
	) ELSE (
		SET CMT_23=익명 인증 사용 안함
		SET RESULT_23=양호
	)
) ELSE (   
	SET CMT_23=FTP 서비스 포트 닫혀있음
    SET RESULT_23=양호
)

:23_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_23% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : anonymousAuthentication enabled="false" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_23% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type %systemroot%\system32\inetsrv\config\applicationHost.config ^| findstr /i "anonymousAuthentication" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF EXIST %systemroot%\system32\inetsrv\config\applicationHost.config (
    type %systemroot%\system32\inetsrv\config\applicationHost.config | findstr /N "ftpServer anonymous authentication" | findstr /v "sec system" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) ELSE (
    echo applicationHost.config 설정파일이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [23.W-23] Anonymous FTP 금지 [%RESULT_23%]
:23_END
SET CMT_23=
SET RESULT_23=
SET FTP_IP=

:23_ADD
REM [기준] anonymous 인증 취약 기준 -> 해당 방식이 적용되지 않는 일부 OS 때문에 직접 접속하는 방식으로 변경
REM IIS 6.0 이하: AllowAnonymous=True 여부 확인 (metabase.xml) - WINDOWS 2008 이하
REM IIS 7.0 이상: anonymousAuthentication enabled="true" 여부 확인 (applicationHost.config)

REM ==================================================
REM ==================================================
:24_START
echo [24.W-24] FTP 접근 제어 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:24_ROUTINE
SET CMT_24=초기화&SET RESULT_24=인터뷰

IF !FTP_FOUND! EQU 1 (
	REM IIS 버전 확인 (6.0 이하: MetaBase.xml, 7.0 이상: appcmd)
	reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\InetStp" /v "VersionString" 2>NUL | findstr /i "VersionString" | findstr "5\. 6\." >NUL
	IF NOT ERRORLEVEL 1 (
		REM ===== IIS 6.0 이하 (Windows Server 2003 이하) - MetaBase.xml 사용 =====
		IF EXIST %systemroot%\system32\inetsrv\MetaBase.xml (
			type %systemroot%\system32\inetsrv\MetaBase.xml 2>NUL | find /i "IPSecurity" | findstr /r [0-9] >NUL
			IF ERRORLEVEL 1 (
				REM IPSecurity 설정이 없는 경우 = ALL ALLOW
				SET CMT_24="ALL ALLOW" 접근제어 설정 적용됨&SET RESULT_24=취약
			) ELSE (
				REM IPSecurity 설정이 있는 경우
				type %systemroot%\system32\inetsrv\MetaBase.xml 2>NUL | find /i "IPSecurity" > ftp_ipsec.tmp
				
				REM 18000080200000803c 패턴 확인 (접근 제어 설정 존재)
				type ftp_ipsec.tmp | findstr "18000080200000803c" >NUL
				IF ERRORLEVEL 1 (
					REM 접근 제어 설정이 없거나 다른 형식
					SET CMT_24="ALL ALLOW" 접근제어 설정 적용됨^(일부 IP 접근 불가^)&SET RESULT_24=취약
				) ELSE (
					REM ffffffff00000000 패턴 확인 (모든 IP 차단)
					type ftp_ipsec.tmp | findstr "ffffffff00000000" >NUL
					IF NOT ERRORLEVEL 1 (
						SET CMT_24="ALL DENY" 접근제어 설정 적용됨^(모든 IP 접근 불가^)&SET RESULT_24=인터뷰
					) ELSE (
						REM 특정 IP만 허용 (화이트리스트)
						SET CMT_24="특정 IP 주소에서만^(ALL DENY^)" 접근제어 설정 적용됨&SET RESULT_24=양호
					)
				)
				del ftp_ipsec.tmp 2>NUL
			)
		) ELSE (
			SET CMT_24=MetaBase.xml 파일이 "존재하지 않음"&SET RESULT_24=양호
		)
	) ELSE (
		REM ===== IIS 7.0 이상 (Windows Server 2008 이상) - appcmd 사용 =====
		IF EXIST %SystemRoot%\System32\inetsrv\appcmd.exe (
			REM FTP 사이트가 있는지 확인 (포트 21 사용)
			%SystemRoot%\System32\inetsrv\appcmd list sites 2>NUL | findstr /i ":21" >NUL
			IF ERRORLEVEL 1 (
				REM FTP 사이트 없음
				SET CMT_24=FTP 서비스가 "존재하지 않음"&SET RESULT_24=양호
			) ELSE (
				REM FTP 사이트가 존재하는 경우
				SET FTP_FOUND=0
				FOR /f "tokens=2 delims= " %%i IN ('%SystemRoot%\System32\inetsrv\appcmd list sites 2^>NUL ^| findstr /i ":21"') DO (
					SET FTP_FOUND=1
					REM allowUnlisted="false" 확인 (특정 IP만 허용)
					%SystemRoot%\System32\inetsrv\appcmd list config %%i /section:system.ftpServer/security/ipsecurity 2>NUL | findstr /i "allowUnlisted" | findstr /i "false" >NUL
					IF NOT ERRORLEVEL 1 (
						SET CMT_24=지정되지 않은 클라이언트에 대해서 엑세스 거부 설정 적용&SET RESULT_24=양호
					) ELSE (
						REM allowUnlisted="true" 또는 설정 없음 = ALL ALLOW
						SET CMT_24=지정되지 않은 클라이언트에 대해서 엑세스 허용 설정 적용&SET RESULT_24=취약
					)
				)
				IF !FTP_FOUND! EQU 0 (
					SET CMT_24=FTP 서비스가 "존재하지 않음"&SET RESULT_24=양호
				)
			)
		) ELSE (
			REM appcmd.exe가 없는 경우 (IIS 미설치)
			SET CMT_24=IIS가 설치되지 않음&SET RESULT_24=양호
		)
	)
) ELSE (
	SET CMT_24=FTP 서비스 포트가 "닫힘"
	SET RESULT_24=양호
)



:24_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_24% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : "특정 IP 주소에서만" FTP 서버에 접속하도록 접근제어 설정 적용 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_24% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

REM IIS 버전에 따른 설정 정보 출력
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\InetStp" /v "VersionString" 2>NUL | findstr /i "VersionString" | findstr "5\. 6\." >NUL
IF NOT ERRORLEVEL 1 (
	echo ^(CMD^) type %systemroot%^\system32^\inetsrv^\MetaBase.xml ^| find /i "IPSecurity" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo ^*^*^*^*^* IIS 6.0 이하 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo ^*^* IPSecurity="" : ALL ALLOW (취약) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo ^*^* ffffffff00000000 포함 : ALL DENY (인터뷰) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo ^*^* 특정 IP 포함 : 특정 IP만 허용 (양호) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	IF EXIST %systemroot%\system32\inetsrv\MetaBase.xml (
		type %systemroot%\system32\inetsrv\MetaBase.xml 2>NUL | find /i "IPSecurity" | findstr /v "^$" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		IF ERRORLEVEL 1 (
			echo     IPSecurity 설정 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		)
	) ELSE (
		echo     MetaBase.xml 파일이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
) ELSE (
	echo ^(CMD^) appcmd list config "FTP사이트" /section:system.ftpServer/security/ipsecurity >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo ^*^*^*^*^* IIS 7.0 이상 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo ^*^* allowUnlisted="false" : 지정되지 않은 클라이언트 엑세스 거부 (양호) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo ^*^* allowed="true" : 특정 IP 허용 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt	
	echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	IF EXIST %SystemRoot%\System32\inetsrv\appcmd.exe (
		%SystemRoot%\System32\inetsrv\appcmd list sites 2>NUL | findstr /i ":21" >NUL
		IF NOT ERRORLEVEL 1 (
			FOR /f "tokens=2 delims= " %%i IN ('%SystemRoot%\System32\inetsrv\appcmd list sites 2^>NUL ^| findstr /i ":21"') DO (
				echo - FTP 사이트: %%i - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
				%SystemRoot%\System32\inetsrv\appcmd list config %%i /section:system.ftpServer/security/ipsecurity 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
			)
		) ELSE (
			echo     FTP 사이트가 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		)
	) ELSE (
		echo     appcmd.exe 파일이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
)

echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [24.W-24] FTP 접근 제어 설정 [%RESULT_24%]

:24_END
SET CMT_24=
SET RESULT_24=
SET FTP_FOUND=

:24_ADD
REM [기준] FTP 접근 제어 설정
REM 
REM [IIS 6.0 이하 - MetaBase.xml]
REM - ALL ALLOW (IP 미포함) : IPSecurity="" (취약)
REM - ALL ALLOW (IP 포함) : IPSecurity="18000080340000803c..." (취약)
REM - ALL DENY (IP 미포함) : IPSecurity="18000080200000803c...ffffffff00000000" (인터뷰)
REM - ALL DENY (IP 포함) : IPSecurity="18000080200000803c...ffffffffc0a8ab01c0a8ab02" (양호)
REM   * ffffffff(netmask) c0a8ab01(Long IP) c0a8ab02(Long IP)
REM   * 4294967295, 3232279297, 3232279298
REM   * 255.255.255.255, 192.168.171.1, 192.168.171.2
REM
REM [IIS 7.0 이상 - appcmd]
REM - allowUnlisted="true" 또는 설정 없음 : ALL ALLOW (취약)
REM - allowUnlisted="false" + IP 목록 : 특정 IP만 허용 (양호)

REM ==================================================

:25_START
echo [25.W-25] DNS Zone Transfer 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

rem 레지스트리가 있어도 값(value not set)이 없을수도 있음
:25_ROUTINE
SET CMT_25=초기화&SET RESULT_25=인터뷰

SET DNS_FOUND=0

type netstat.inf ^
 | findstr /I "TCP" ^
 | findstr ":53" ^
 | findstr /I "LISTENING" >NUL

IF NOT ERRORLEVEL 1 (
    SET DNS_FOUND=1
)

IF !DNS_FOUND! EQU 1 (
    SET CMT_25=DNS 서비스 포트 LISTENING
    SET RESULT_25=인터뷰
) ELSE (
    SET CMT_25=DNS 서비스 포트 닫혀있음
    SET RESULT_25=양호
)


:25_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_25! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : Zone Transfer "제한" 또는 허용 시 특정 서버로 "설정" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_25! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /v "SecureSecondaries" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^* 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* [ SecureSecondaries ] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 0 : 영역 전송 허용(아무 서버로) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 1 : 영역 전송 허용(이름 서버 택에 나열됨 서버로만) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 2 : 영역 전송 허용(다음 서버로만) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 3 : 영역 전송 제한 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s 2>NUL | findstr /i "\Zones SecureSecondaries" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [25.W-25] DNS Zone Transfer 설정 [!RESULT_25!]
:25_END
SET CMT_25=
SET RESULT_25=

:25_ADD
REM SecureSecondaries
REM 0 : 영역 전송 허용(아무 서버로)
REM 1 : 영역 전송 허용(이름 서버 택에 나열됨 서버로만)
REM 2 : 영역 전송 허용(다음 서버로만)
REM 3 : 영역 전송 제한


REM ==================================================

:26_START
echo [26.W-26] RDS(RemoteDataServices)제거 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:26_ROUTINE
SET CMT_26=초기화&SET RESULT_26=인터뷰
echo %OS_VER% 2>NUL | findstr "6.0 6.1 6.2 6.3 10.0" >NUL
IF ERRORLEVEL 1 (
	REM Windows 2003 이하 (5.0)
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\ADCLaunch" 2>NUL >NUL
	IF NOT ERRORLEVEL 1 (
		SET CMT_26=불필요한 RDS 서비스가 "제거되지 않음"&SET RESULT_26=취약
	) ELSE (
		SET CMT_26=불필요한 RDS 서비스가 "제거"됨&SET RESULT_26=양호
	)
) ELSE (
	REM Windows 2008 이상 (6.0, 6.1, 6.2, 6.3, 10.0)
	SET CMT_26=Windows 2008 이상 버전은 "해당없음"&SET RESULT_26=양호
)

:26_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_26% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 불필요한 RDS 서비스 "제거" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_26% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\ADCLaunch" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\ADCLaunch" 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [26.W-26] RDS(RemoteDataServices)제거 [%RESULT_26%]
:26_END
SET CMT_26=
SET RESULT_26=

:26_ADD


REM ==================================================
:27_START
echo [27.W-27] 최신 Windows OS Build 버전 적용 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:27_ROUTINE
SET CMT_27=수동점검&SET RESULT_27=인터뷰

:27_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_27% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 최신 빌드 설치 된 경우(25년 2월 릴리즈까지 양호) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 참고 : Windows Server 2012 이하는 EOS 되었으므로 취약 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 참고 : 2016 : 14393.7785 ~ 14393.8692 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 참고 : 2019 : 17763.6893 ~ 17763.8148 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 참고 : 2022 : 20348.3207 ~ 20348.4529 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 참고 : 2025 : 26100.3194 ~ 26100.7462 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_27% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) ver >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
ver | findstr /v "^$" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo UBR이 마이너버전(16진수) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v UBR  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

FOR /f "tokens=3 delims= " %%i IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v UBR 2^>NUL ^| findstr /i "UBR"') DO (
    SET UBR_HEX=%%i
    REM 0x 제거
    SET UBR_HEX=!UBR_HEX:0x=!
    SET UBR_HEX=!UBR_HEX:0X=!
    
    REM 16진수를 10진수로 변환 (PowerShell 사용)
    FOR /f %%a IN ('powershell -Command "[Convert]::ToInt32('!UBR_HEX!', 16)"') DO (
        SET UBR_DEC=%%a
    )
    
    echo UBR: 10진수 계산 : ^(!UBR_DEC!^) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [27.W-27] 최신 서비스팩 적용 [%RESULT_27%]
:27_END
SET CMT_27=
SET RESULT_27=

:27_ADD

REM ==================================================
:28_START
echo [28.W-28] 터미널 서비스 암호화 수준 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:28_ROUTINE
SET CMT_28=초기화&SET RESULT_28=인터뷰
type services.inf 2>NUL | findstr /i /c:"Remote Desktop Services" | findstr /i "Running" >NUL
IF ERRORLEVEL 1 (
	SET CMT_28=원격 터미널 서비스를 "사용하지 않음"&SET RESULT_28=양호
)
IF NOT ERRORLEVEL 1 (
	reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MinEncryptionLevel 2>NUL | findstr /i "MinEncryptionLevel" >NUL
	IF ERRORLEVEL 1 (
		SET CMT_28=레지스트리 키 또는 값이 존재하지 않음&SET RESULT_28=인터뷰
	)
	IF NOT ERRORLEVEL 1 (
		reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MinEncryptionLevel 2>NUL | findstr /i "MinEncryptionLevel" >NUL | findstr /i "MinEncryptionLevel" | findstr "0x1"
		IF ERRORLEVEL 1 (
			SET CMT_28=원격 터미널 서비스를 "사용"하고 암호화 수준이 "클라이언트와 호환 가능^(중간^) 이상"으로 설정됨&SET RESULT_28=양호
		)
		IF NOT ERRORLEVEL 1 (
			SET CMT_28=원격 터미널 서비스를 "사용"하고 암호화 수준이 "낮은 수준"으로 설정됨&SET RESULT_28=취약
		)
	)
)

:28_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_28% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 원격 터미널 서비스 "사용하지 않음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        또는 사용 시 암호화 수준 "클라이언트와 호환 가능(중간) 이상" 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_28% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type services.inf ^| findstr /i /c:"Remote Desktop Services" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 서비스 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type services.inf | findstr /i /c:"Remote Desktop Services" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^* 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 낮은 수준 (취약)           : 0x01 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 클라이언트 호환 가능 (양호) : 0x02 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 높은 수준 (양호)           : 0x03 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo (CMD) 그룹 정책 확인 (최우선)>> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MinEncryptionLevel 2>NUL | findstr /i "MinEncryptionLevel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo (CMD) 로컬 설정 확인 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "MinEncryptionLevel" 2>NUL | findstr /i "MinEncryptionLevel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [28.W-28] 터미널 서비스 암호화 수준 설정 [%RESULT_28%]
:28_END
SET CMT_28=
SET RESULT_28=

:28_ADD
REM [기준] MinEncryptionLevel 값이 1이면 낮은 수준(취약), 2이면 클라이언트 호환 가능(양호), 3이면 높은 수준(양호)

REM ==================================================
:29_START
echo [29.W-29] 불필요한 SNMP 서비스 구동 점검 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
SET CMT_29=초기화&SET RESULT_29=인터뷰
SET CMT_29_1=

:29_ROUTINE
SET SNMP_FOUND=0
FOR /f "tokens=2 delims= " %%i IN (netstat.inf) DO (
	echo %%i | findstr ":161" >NUL
	IF NOT ERRORLEVEL 1 SET SNMP_FOUND=1
)
IF !SNMP_FOUND! EQU 1 (
	SET CMT_29=SNMP 포트가 "열림"
	SET RESULT_29=취약
) ELSE (
	SET CMT_29=SNMP 포트가 "닫힘"
	SET RESULT_29=양호
)

:29_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_29! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 불필요한 SNMP 서비스 "비활성화" 및 "사용 안 함", >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        불필요한 SNMP 서비스 포트 "닫힘" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_29! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo type services.inf ^| findstr /i "snmp" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 없음 ^= 서비스 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type services.inf | findstr /i "snmp" | findstr /i /v "trap 트랩" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo type netstat.inf >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 없음 ^= 열린 포트 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
FOR /f "tokens=1,2,* delims= " %%i IN (netstat.inf) DO (
	echo %%j | findstr /c:":161" >NUL
	IF NOT ERRORLEVEL 1 (
		echo %%i  %%j  %%k  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
)
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [29.W-29] 불필요한 SNMP 서비스 구동 점검 [!RESULT_29!]
:29_END
SET CMT_29_1=
SET RESULT_29=
:29_ADD

REM ==================================================

:30_START
echo [30.W-30] SNMP Community String 복잡성 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:30_ROUTINE
SET CMT_30=초기화&SET RESULT_30=인터뷰

IF !SNMP_FOUND! EQU 1 (
	reg query "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" | findstr "public private" >NUL 2>NUL
	IF ERRORLEVEL 1 (
		SET CMT_30=community string 값이 public 또는 private가 아닌값으로 설정
		SET RESULT_30=양호
	) ELSE (
		SET CMT_30=community string 값이 public 또는 private로 설정
		SET RESULT_30=취약
	)
) ELSE (
	SET CMT_30=SNMP 포트가 "닫힘"
	SET RESULT_30=양호
)


:30_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_30! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : "유추불가"한 SNMP Community string 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        영문+숫자 10자리 이상, 영문+숫자+특수 8자리 이상>> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        엑세스 권한 "RO ReadOnly 설정" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_30! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo reg query "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^* 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* [Access 권한] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* NONE        : 0x0001 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* NOTIFY      : 0x0002 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* READ ONLY   : 0x0004 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* READ/WRITE  : 0x0008 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* READ/CREATE : 0x0010 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 다음의 특수문자 외 다른 특수문자 포함 시, 수동진단 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" >NUL 2>NUL
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) ELSE (
	reg query "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" 2>NUL | findstr /i /v "ValidCommunities" | findstr /v "^$ localhost 검색" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [30.W-30] SNMP 서비스 커뮤니티스트링의 복잡성 설정 [!RESULT_30!]
:30_END
SET CMT_30=
SET CMT_30_1=
SET CMT_30_2=
SET RESULT_30=
SET NOW_30=
SET C_30=

:30_ADD
REM [기준] 영문+숫자 10자 이상 또는 영문+숫자+특수 8자 이상 (2021.01 기준 변경)
REM [설명] Windows 2016까지 SNMP v3 미지원, 원할 시 별도 솔루션을 사용해야 함
REM SNMP v3의 경우 별도 인증 기능을 사용하고, 해당 비밀번호가 복잡도를 만족할 경우 "양호"로 판단
REM [설명] 유효 커뮤니티 (ValidCommunities) : snmp 커뮤니티 및 권한
REM [설명] 트랩구성 (TrapConfiguration\커뮤니티명) : trap 전송 목록
REM [설명] Access 권한
REM     NONE ? 0x0001
REM     NOTIFY ? 0x0002
REM     READ ONLY ? 0x0004
REM     READ/WRITE ? 0x0008
REM     READ/CREATE ? 0x0010

REM ==================================================
:31_START
echo [31.W-31] SNMP Access control 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
:31_ROUTINE
SET CMT_31=초기화
SET RESULT_31=인터뷰

IF !SNMP_FOUND! EQU 1 (
	REM 레지스트리 값 확인 (숫자로 된 항목이 있는지)
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" 2>NUL | findstr /i /v "PermittedManagers HKEY" | findstr /r "REG_SZ" >NUL 2>NUL
	IF ERRORLEVEL 1 (
		SET CMT_31="모든 호스트"로부터 SNMP 패킷을 받아들임
		SET RESULT_31=취약
	) ELSE (
		SET CMT_31="특정 호스트"로부터만 SNMP 패킷을 받아들임
		SET RESULT_31=양호
	)
) ELSE (
	SET CMT_31=SNMP 포트가 "닫힘"
	SET RESULT_31=양호
)

:31_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_31! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : "특정 호스트"로부터만 SNMP 패킷을 받아들임 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 참고 : 레지스트리 값이 없을때는 취약임 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_31! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" >NUL 2>NUL
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) ELSE (
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [31.W-31] SNMP Access control 설정 [!RESULT_31!]
:31_END
SET CMT_31=
SET RESULT_31=

:31_ADD


REM ==================================================
:32_START
echo [32.W-32] DNS 서비스 구동 점검 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:32_ROUTINE
SET CMT_32=초기화&SET RESULT_32=인터뷰

IF !DNS_FOUND! EQU 1 (
	dnscmd /ExportSettings 2>NUL >NUL
	IF EXIST %systemroot%\system32\dns\DnsSettings.txt (
		type %systemroot%\system32\dns\DnsSettings.txt 2>NUL | findstr /i "AllowUpdate" | findstr /i /v "DWORD" | findstr /i "=1" >NUL
		IF ERRORLEVEL 1 (
			SET CMT_32=동적 업데이트 기능이 비활성화됨&SET RESULT_32=양호
		) ELSE (
			SET CMT_32=동적 업데이트 기능이 활성화됨&SET RESULT_32=취약
		)
	) ELSE (
		SET CMT_32=DNS 설정파일이 존재하지 않음&SET RESULT_32=인터뷰
	)

) ELSE (
	SET CMT_32=DNS 서비스 포트가 닫힘
	SET RESULT_32=양호
)



:32_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_32! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 불필요한 DNS 서비스 "비활성화" 및 "사용 안 함", >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        불필요한 DNS 서비스 포트 "닫힘" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        또는 동적 업데이트 "사용 안 함" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_32! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type services.inf ^| findstr /i "dns" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 서비스 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type services.inf 2>NUL | findstr /i "dns" | findstr /i /v /c:"DNS Client" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type netstat.inf >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 열린 포트 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

FOR /f "tokens=1,2,* delims= " %%i IN (netstat.inf) DO (
	echo %%j | findstr ":53" | findstr "LISTENING">NUL
	IF NOT ERRORLEVEL 1 (
		echo %%i  %%j  %%k  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
)
echo (CMD) type %systemroot%\system32\dns\DnsSettings.txt >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

type %systemroot%\system32\dns\DnsSettings.txt 2>NUL | findstr /i "AllowUpdate [" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     DNS 설정파일이 "존재하지 않음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [32.W-32] DNS 서비스 구동 점검 [!RESULT_32!]
:32_END
SET CMT_32_1=
SET CMT_32_2=
SET RESULT_32=

:32_ADD

REM ==================================================
:33_START
echo [33.W-33] HTTP/FTP/SMTP 배너 차단 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:33_ROUTINE
SET CMT_33=초기화&SET RESULT_33=인터뷰
SET CMT_33_1=
SET CMT_33_2=

REM ===== HTTP 배너 체크 =====

type services.inf 2>NUL | findstr /i /c:"World Wide Web Publishing" | findstr /i "Running" >NUL
IF ERRORLEVEL 1 (
    SET CMT_33=HTTP 서비스가 "비활성화"됨
) ELSE (
    FOR /f "tokens=2 delims= " %%i IN (netstat.inf) DO (
        echo %%i. | findstr /l ":80." >NUL
        IF NOT ERRORLEVEL 1 (
            SET CMT_33=HTTP 배너에 노출되는 정보 존재 여부 수동 진단
            SET RESULT_33=인터뷰
            curl -s -D curl_http.txt 127.0.0.1 -o nul >NUL 2>NUL
            type curl_http.txt 2>NUL | findstr /i "x- server" >NUL
            IF ERRORLEVEL 1 (
                SET CMT_33=HTTP 배너에 노출되는 정보 "없음"
            )
            GOTO :33_CHECK_FTP
        )
    )
    SET CMT_33=HTTP 배너에 노출되는 정보 존재 여부 수동 진단^(포트 변경됨^)
    SET RESULT_33=인터뷰
)

:33_CHECK_FTP
REM ===== FTP 배너 체크 =====
rem del ftp_result.txt 2>NUL

type services.inf 2>NUL | findstr /i /c:"FTP Publishing Service" /c:"Microsoft FTP Service" | findstr /i "Running" >NUL
IF ERRORLEVEL 1 (
    SET CMT_33_1=FTP 서비스가 "비활성화"됨
) ELSE (
    FOR /f "tokens=2 delims= " %%i IN (netstat.inf) DO (
        echo %%i. | findstr /l ":21. :20." >NUL
        IF NOT ERRORLEVEL 1 (
            SET CMT_33_1=FTP 배너에 노출되는 정보 존재 여부 수동 진단
            SET RESULT_33=인터뷰
            FOR /f "tokens=2 delims=:^(" %%a IN ('ipconfig /all ^| findstr /i "ipv4"') DO (
                SET FTP_IP=%%a
                SET FTP_IP=!FTP_IP: =!
                ftp /i /s:ftp.txt !FTP_IP! 2>NUL > ftp_result.txt
                type ftp_result.txt 2>NUL | findstr "220" | findstr /i "ftp" >NUL
                IF NOT ERRORLEVEL 1 (
                    SET CMT_33_1=FTP 배너에 노출되는 정보 "있음"
                    SET RESULT_33=취약
                    GOTO :33_CHECK_SMTP
                )
            )
            GOTO :33_CHECK_SMTP
        )
    )
)

:33_CHECK_SMTP
REM ===== SMTP 배너 체크 =====
type services.inf 2>NUL | findstr /i /c:"Simple Mail Transfer Protocol" | findstr /i "Running" >NUL
IF ERRORLEVEL 1 (
    SET CMT_33_2=SMTP 서비스가 "비활성화"됨
) ELSE (
    FOR /f "tokens=2 delims= " %%i IN (netstat.inf) DO (
        echo %%i. | findstr /l ":25." >NUL
        IF NOT ERRORLEVEL 1 (
            SET CMT_33_2=SMTP 배너에 노출되는 정보 존재 여부 수동 진단
            SET RESULT_33=인터뷰
            curl -v -D curl_smtp.txt smtp://127.0.0.1 -o nul >NUL 2>NUL
            type curl_smtp.txt 2>NUL | findstr /i "220" | findstr /i "SMTP Mail Version" >NUL
            IF ERRORLEVEL 1 (
                SET CMT_33_2=SMTP 배너에 노출되는 정보 "없음"
            )
            GOTO :33_PRINT
        )
    )
    SET CMT_33_2=SMTP 배너에 노출되는 정보 존재 여부 수동 진단^(포트 변경됨^)
    SET RESULT_33=인터뷰
)

:33_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_33! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 불필요한 서비스 "비활성화" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        또는 각 서비스별 배너에 노출되는 정보 "없음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_33! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황2: !CMT_33_1! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황3: !CMT_33_2! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type curl_http.txt >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo **결과 없음 = 노출 정보 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF EXIST curl_http.txt (
	type curl_http.txt | findstr /v "^$" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	IF ERRORLEVEL 1 (
		echo     연결되지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	) 
) ELSE (
	echo     curl_http.txt 파일이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo (CMD) ftp -A 127.0.0.1 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF EXIST ftp_result.txt (
	type ftp_result.txt | findstr /v "^$" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	IF ERRORLEVEL 1 (
		echo     연결되지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	) 
) ELSE (
	echo     ftp_result.txt 파일이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo (CMD) type curl_http.txt >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF EXIST curl_smtp.txt (
	type curl_smtp.txt | findstr /v "^$" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	IF ERRORLEVEL 1 (
		echo     연결되지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	) 
) ELSE (
	echo     curl_smtp.txt 파일이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo (CMD) type services.inf ^| findstr /i /c:"Simple Mail Transfer Protocol" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 서비스 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type services.inf | findstr /i /c:"Simple Mail Transfer Protocol" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type netstat.inf ^| findstr ":25" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 관련 포트 목록 : 25(일반 SMTP),465(SMTPS),587(MSA SMTP),993(IMAP),995(POP3) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 열린 포트 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
FOR /f "tokens=1,2,* delims= " %%i IN (netstat.inf) DO (
	echo %%j. | findstr /l ":25. :465. :587. :993. :995." >NUL
	IF NOT ERRORLEVEL 1 (
		echo %%i  %%j  %%k  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
)
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [33.W-33] HTTP/FTP/SMTP 배너 차단 [!RESULT_33!]
:33_END
SET CMT_33_1=
SET CMT_33_2=
SET RESULT_33=

:33_ADD
REM [설정] IIS 7.0 이상 버전 rewrite 룰을 적용해 헤더정보 필터링
REM IIS 10.0 이상 버전 removeServerHeader 옵션이 true로 설정

REM ==================================================
:34_START
echo [34.W-34] Telnet 비활성화 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:34_ROUTINE
SET CMT_34=초기화&SET RESULT_34=인터뷰
SET CMT_34_1=초기화
SET CMT_34_2=초기화

echo %OS_VER% 2>NUL | findstr "10.0" >NUL
IF ERRORLEVEL 1 (
	REM Windows 2012 이하
	FOR /f "tokens=2 delims= " %%i IN (netstat.inf) DO (
		echo %%i. | findstr /l ":23." >NUL
		IF NOT ERRORLEVEL 1 (
			SET CMT_34_1=Telnet 서비스 포트가 "열림"
			echo !CMT_34! 2>NUL | findstr "비활성화" >NUL
			IF NOT ERRORLEVEL 1 (
				SET CMT_34_1=불필요한 포트가 "열림"&SET RESULT_34=인터뷰
			)
		) ELSE (
			SET CMT_34_1=Telnet 서비스 포트가 "닫힘"
			echo !CMT_34! 2>NUL | findstr "활성화" | findstr /v "비활성화" >NUL
			IF NOT ERRORLEVEL 1 (
				SET CMT_34_1=디폴트 포트가 아닌 "임의의 포트"를 사용함
			)
		)
	)
	echo !CMT_34! 2>NUL | findstr /i "비활성화" >NUL
	IF NOT ERRORLEVEL 1 (
		SET CMT_34_2=.&GOTO :34_PRINT
	)
	reg query "HKLM\Software\Microsoft\TelnetServer\1.0" /v "SecurityMechanism" 2>NUL | findstr /i "SecurityMechanism" >NUL
	IF ERRORLEVEL 1 (
		SET CMT_34_2=설정값이 존재하지 않음&SET RESULT_34=인터뷰& GOTO :34_PRINT
	)
	reg query "HKLM\Software\Microsoft\TelnetServer\1.0" /v "SecurityMechanism" 2>NUL | findstr /i "SecurityMechanism" | findstr "2" >NUL
	IF NOT ERRORLEVEL 1 (
		SET CMT_34_2=passwd 인증방식을 제외한 "NTLM 인증방식만" 사용함&SET RESULT_34=양호
	)
	IF ERRORLEVEL 1 (
		SET CMT_34_2=취약한 "passwd 인증방식"을 사용함&SET RESULT_34=취약
	)
) ELSE (
	REM Windows 2016 이상 (10.0)
	SET CMT_34=Windows 2016 이상 버전은 "해당없음"&SET RESULT_34=양호
)

:34_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_34! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 불필요한 Telnet 서비스 비활성화 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        또는 활성화 시 passwd 인증방식을 제외한 "NTLM 인증방식만" 사용 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_34! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황2: !CMT_34_1! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황3: !CMT_34_2! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type services.inf ^| findstr /i "Telnet" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 서비스 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type services.inf | findstr /i "Telnet" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type netstat.inf >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 결과 없음 ^= 열린 포트 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
FOR /f "tokens=1,2,* delims= " %%i IN (netstat.inf) DO (
	echo %%j. | findstr /l ":23." >NUL
	IF NOT ERRORLEVEL 1 (
		echo %%i  %%j  %%k  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
)
echo (CMD) tlntadmn config >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
where tlntadmn 2>NUL >NUL
IF NOT ERRORLEVEL 1 (
	tlntadmn config 2>NUL | findstr /i "Authentication 인증" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) ELSE (
	echo     해당 명령이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo (CMD) reg query "HKLM\Software\Microsoft\TelnetServer\1.0" /v "SecurityMechanism" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^* 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 0x2 (양호) : NTLM 방식 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 0x4 (취약) : passwd 방식 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 0x6 (취약) : NTLM, passwd 방식>> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\Software\Microsoft\TelnetServer\1.0" /v "SecurityMechanism" 2>NUL | findstr /i "SecurityMechanism" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [34.W-34] Telnet 서비스 비활성화 [!RESULT_34!]
:34_END
SET CMT_34_1=
SET CMT_34_2=
SET RESULT_34=

:34_ADD
REM [설정] telnet 인증방식
REM echo SecurityMechanism = TELNET 서비스 인증방식설정
REM echo SecurityMechanism = 6 둘다
REM echo SecurityMechanism = 4 passwd 인증방식
REM echo SecurityMechanism = 2 (passwd 인증 방식을 제외하고 NTLM 인증방식 만 사용)
REM
REM [보안설정] CMD : tlntadmn config sec = +NTLM-passwd

REM ==================================================
:35_START
echo [35.W-35] 불필요한 ODBC/OLE-DB 데이터 소스와 드라이브 제거 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:35_ROUTINE
SET CMT_35=초기화&SET RESULT_35=인터뷰

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\ODBC Data Sources" 2>NUL | findstr /i "REG_SZ" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_35=불필요한 ODBC Data Sources 존재&SET RESULT_35=취약
)
reg query "HKLM\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources" 2>NUL | findstr /i "REG_SZ" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_35=불필요한 ODBC Data Sources 존재&SET RESULT_35=취약
)

:35_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_35% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 불필요한 ODBC Data Sources "존재하지 않음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_35% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "데이터소스" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo - 32bit - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\ODBC Data Sources" 2>NUL | findstr /i "REG_SZ" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo - 64bit - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources" 2>NUL | findstr /i "REG_SZ" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [35.W-35] 불필요한 ODBC/OLE-DB 데이터 소스와 드라이브 제거 [%RESULT_35%]
:32_END
SET CMT_35=
SET RESULT_35=

:35_ADD

REM ==================================================
batch:36_START
echo [36.W-36] 원격 터미널 접속 타임아웃 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
:36_ROUTINE
SET CMT_36=초기화
SET RESULT_36=인터뷰

REM 1. RDP 서비스 활성화 여부 확인
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections 2>NUL | findstr "0x0" >NUL
IF ERRORLEVEL 1 (
	SET CMT_36=원격 데스크톱이 "비활성화"됨
	SET RESULT_36=양호
	GOTO :36_PRINT
)

REM 2. 타임아웃 설정 확인 (그룹 정책 우선)
SET TIMEOUT_SET=0

REM 2-1. 그룹 정책 확인 (우선순위 높음)
FOR /f "tokens=3 delims= " %%i IN ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" 2^>NUL ^| findstr /i "MaxIdleTime"') DO (
	IF NOT "%%i" EQU "0x0" (
		SET TIMEOUT_SET=1
	)
)

REM 2-2. 그룹 정책에 없으면 로컬 레지스트리 확인
IF !TIMEOUT_SET! EQU 0 (
	FOR /f "tokens=3 delims= " %%i IN ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" 2^>NUL ^| findstr /i "MaxIdleTime" ^| findstr /v "fInherit"') DO (
		IF NOT "%%i" EQU "0x0" (
			SET TIMEOUT_SET=1
		)
	)
)

IF !TIMEOUT_SET! EQU 1 (
	SET CMT_36=원격 데스크톱이 활성화되어 있고 타임아웃 "설정"됨
	SET RESULT_36=양호
) ELSE (
	SET CMT_36=원격 데스크톱이 활성화되어 있으나 타임아웃 "미설정"
	SET RESULT_36=취약
)

:36_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_36! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 원격 터미널 사용 시 타임아웃 "설정" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_36! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^* 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* MaxIdleTime : 1800000(ms) = 0x1b7740 = 30분 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* MaxIdleTime : 900000(ms) = 0xdbba0 = 15분 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo (CMD) reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 0x0 = 허용, 0x1 = 거부 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ** 그룹 정책 설정 (우선순위 높음) ** >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxIdleTime >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo - 유휴 세션 제한 (그룹 정책) - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxIdleTime 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     그룹 정책 미설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ** 로컬 레지스트리 설정 ** >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo - 유휴 세션 제한 (로컬) - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" 2>NUL | findstr /i "MaxIdleTime" | findstr /v "fInherit" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     로컬 설정 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [36.W-36] 원격터미널 접속 타임아웃 설정 [!RESULT_36!]

:36_END
SET CMT_36=
SET RESULT_36=
SET TIMEOUT_SET=

:36_ADD
REM [기준] 별도 정해진 기준은 없음 (숫자 설정시 양호)
REM 시간값 1분 = 60000  10분 = 600000  15분 = 900000  1시간 = 3600000
REM 사용 안함(0x0), 1분(0xea60), 5분(0x493e0), 10분(0x927c0), 15분(0xdbba0), 30분(0x1b7740), 1시간(0x36ee80), 2시간(0x6ddd00)
REM MaxDisconnectionTime = 연결 끊킨 세션 끝내기(연결이 끊어진 사용자는 세션은 붙어있으나 이 시간이 지나면 세션을 끊어짐)
REM MaxConnectionTime = 활성 세션 제한(접속한 사용자는 어떤 업무를 하던간에 이 시간이 지나면 연결이 끊어짐)
REM MaxIdleTime = 유휴 세션 제한(서버에 연결해서 아무런 행동을 하지 않을 시 값을 초과하는 경우 끊어짐)
REM
REM [설명] AZURE VM 원격 데스크톱 -> fInherit포함

REM ==================================================
:37_START
echo [37.W-37] 예약된 작업에 의심스러운 명령이 등록되어 있는지 점검 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:37_ROUTINE
SET CMT_37=수동점검&SET RESULT_37=인터뷰

:37_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_37% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 불필요한 예약 작업 "존재하지 않음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_37% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) schtasks >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
schtasks /query | findstr /i /v "^$ N/A = status 상태 Folder 폴더 INFO: 정보" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [37.W-37] 예약된 작업에 의심스러운 명령이 등록되어 있는지 점검 [%RESULT_37%]
:37_END
SET CMT_37=
SET RESULT_37=

:37_ADD

REM ==================================================

REM ==================================================
REM ==================================================
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ----------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo  3. 패치관리  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ----------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo.
echo.
echo 3. 패치관리
echo --------------

REM ==================================================
:38_START
echo [38.W-38] 주기적인 보안 패치 및 벤더 권고사항 적용 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:38_ROUTINE
SET CMT_38=수동 점검&SET RESULT_38=인터뷰

wmic qfe get installedon > wmic.inf
type wmic.inf | findstr /l \/ >NUL

:38_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_38% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 주기적으로 보안패치 적용 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_38% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) wmic qfe get hotfixid, installedon >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ** 설치 날짜가 일반 날짜 형식이 아닌 경우, 제어판 ^> 보안 ^> Windows Update ^> 업데이트 보기 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wmic qfe get hotfixid, installedon > wmic.inf
type wmic.inf >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [38.W-38] 주기적인 보안 패치 및 벤더 권고사항 적용 [%RESULT_38%]
:38_END
SET CMT_38=
SET RESULT_38=
SET NOW_38_year=
SET NOW_38_month=

:38_ADD

REM ==================================================
REM ==================================================
:39_START
echo [39.W-39] 백신 프로그램 업데이트 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:39_ROUTINE
SET CMT_39=초기화
SET CMT_39_1=
SET RESULT_39=인터뷰
SET AV_FOUND=0
SET AV_NAMES=

REM ========================================
REM 방법 1: SecurityCenter2 확인 (Windows 클라이언트용)
REM ========================================
wmic /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get displayName >NUL 2>NUL
IF NOT ERRORLEVEL 1 (
	FOR /f "skip=1 tokens=*" %%i IN ('wmic /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get displayName 2^>NUL ^| findstr /r /v "^$"') DO (
		SET AV_FOUND=1
		SET AV_NAMES=!AV_NAMES!%%i,
	)
)

REM ========================================
REM 방법 2: 주요 백신 서비스 확인 (Windows Server용)
REM ========================================
FOR %%s IN (
	"AVP:Kaspersky" 
	"ekrn"
	"ekrn:ESET" 
	"McAfeeFramework:McAfee" 
	"McShield:McAfee"
	"MsMpSvc:Defender"
	"TMBMSRV:TrendMicro"
	"ntrtscan:TrendMicro"
	"ofcservice:TrendMicro"
	"V3:AhnLab"
	"AYAgent:AhnLab"
	"SavService:Sophos"
	"SAVAdminService:Sophos"
	"WRSVC:Webroot"
	"avgwd:AVG"
	"avast:Avast"
) DO (
	FOR /f "tokens=1,2 delims=:" %%a IN ("%%s") DO (
		sc query %%a 2>NUL | findstr "RUNNING" >NUL
		IF NOT ERRORLEVEL 1 (
			SET AV_FOUND=1
			echo !AV_NAMES! | findstr "%%b" >NUL
			IF ERRORLEVEL 1 (
				SET AV_NAMES=!AV_NAMES!%%b,
			)
		)
	)
)

REM ========================================
REM 방법 3: 백신 프로세스 확인
REM ========================================

tasklist 2>NUL | findstr /i "v3l v3medic alyac mcshield avp ekrn tmlisten ntrtscan pccntmon avasvc avgui" >NUL
IF NOT ERRORLEVEL 1 (
	SET AV_FOUND=1
	SET CMT_39=백신 프로그램 프로세스 확인
	SET RESULT_39=양호
)

REM ========================================
REM 백신 설치 여부 판정
REM ========================================
IF !AV_FOUND! EQU 0 (
	SET CMT_39=백신 프로그램 "설치 안 됨"
	SET CMT_39_1=
	SET RESULT_39=취약
	GOTO :39_PRINT
)

REM ========================================
REM SecurityCenter2로 상세 상태 확인 (가능한 경우)
REM ========================================
wmic /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get productState >NUL 2>NUL
IF ERRORLEVEL 1 (
	REM SecurityCenter2 접근 불가 (Windows Server 등)
	SET CMT_39=백신 프로그램 "설치"됨 - 수동으로 업데이트 상태 확인 필요
	SET CMT_39_1=SecurityCenter2 미지원 환경 (설치된 백신: !AV_NAMES!)
)

REM productState 개수 확인
FOR /f "skip=1" %%i IN ('wmic /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get productState 2^>NUL ^| findstr /r /v "^$" ^| find /c /v ""') DO (
	IF %%i LEQ 0 (
		SET CMT_39=백신 프로그램 "설치 안 됨"
	)
)

REM ========================================
REM productState 값으로 백신 상태 분석
REM ========================================
SET RESULT_39=양호
SET STATE_INFO=
FOR /f "tokens=1 skip=1" %%i IN ('wmic /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get productState 2^>NUL ^|findstr /r /v "^$"') DO (
	SET STATE=%%i
	SET /A ENABLED=%%i %% 16
	SET /A OUTDATED=^(%%i / 256^) %% 16
	
	REM 백신 비활성화 체크
	IF !ENABLED! EQU 0 (
		SET CMT_39=!CMT_39![%%i]백신 "설치"됨 하지만 "비활성화"됨
		SET RESULT_39=취약
		SET STATE_INFO=!STATE_INFO![%%i:비활성]
	) ELSE (
		REM 업데이트 상태 체크
		IF !OUTDATED! GEQ 1 (
			SET CMT_39=!CMT_39![%%i]백신 "활성화" 및 "업데이트 미진행"
			SET RESULT_39=취약
			SET STATE_INFO=!STATE_INFO![%%i:업데이트필요]
		) ELSE (
			SET CMT_39=!CMT_39![%%i]백신 "활성화" 및 "업데이트 최신"
			SET STATE_INFO=!STATE_INFO![%%i:정상]
		)
	)
)

REM 신규 ProductState 값 수집 (디버깅용)
:39_PRINT_1
SET CMT_39_1=** ProductState 값:
FOR /f "tokens=1 skip=1" %%i IN ('wmic /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get productState 2^>NUL ^|findstr /r /v "^$"') DO (
	REM 알려진 값 목록 (활성화 + 최신)
	echo %%i | findstr "262144 266240 327680 331776 393216 397312 393472 397568 458752 462848" >NUL
	IF NOT ERRORLEVEL 1 GOTO :39_KNOWN
	
	REM 알려진 값 목록 (활성화 + 오래됨)
	echo %%i | findstr "262160 266256 331792 327696 393232 397328 397584 393488 462864 458768" >NUL
	IF NOT ERRORLEVEL 1 GOTO :39_KNOWN
	
	REM 알려진 값 목록 (비활성화)
	echo %%i | findstr "262128 327664 393200 458736 262112 327648 393184 458720" >NUL
	IF NOT ERRORLEVEL 1 GOTO :39_KNOWN
	
	REM 신규 값 발견
	SET CMT_39_1=!CMT_39_1! "%%i"(신규)
	SET RESULT_39=인터뷰
	
:39_KNOWN
)
IF "%CMT_39_1%" == "** ProductState 값:" (SET CMT_39_1=** ProductState 값: 모두 알려진 값)

REM ========================================
REM 결과 출력
REM ========================================
:39_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_39! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 백신 프로그램 설치 및 최신 업데이트 유지 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 참고 : 윈도우 기본 백신프로그램인 Windows Defender(MsMpEng.exe)만 존재할 경우 취약 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_39! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황2 : !CMT_39_1! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

REM SecurityCenter2 백신 목록
echo (1) SecurityCenter2 등록 백신: >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wmic /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get displayName 2>NUL | findstr /r /v "^$ displayName" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt 2>NUL
IF ERRORLEVEL 1 (
	echo     SecurityCenter2 미지원 환경 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

REM SecurityCenter2 ProductState
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (2) SecurityCenter2 ProductState: >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
FOR /f "skip=1 tokens=*" %%i IN ('wmic /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get displayName^, productState 2^>NUL ^| findstr /r /v "^$"') DO (
	echo     %%i >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
IF ERRORLEVEL 1 (
	echo     SecurityCenter2 미지원 환경 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

REM 백신 서비스 목록
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (3) 실행 중인 백신 서비스: >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
sc query state= all 2>NUL | findstr /i "SERVICE_NAME RUNNING" | findstr /i /b "SERVICE_NAME" > temp_svc.txt
FOR /f "tokens=2 delims=: " %%i IN (temp_svc.txt) DO (
	echo %%i | findstr /i "avp ekrn mcafee trend eset avg avast ahnlab v3 windefend sophos webroot msmpeng" >NUL
	IF NOT ERRORLEVEL 1 (
		sc query %%i 2>NUL | findstr "SERVICE_NAME STATE" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
)
IF EXIST temp_svc.txt del temp_svc.txt

REM 백신 프로세스 목록
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (4) 백신 프로세스: >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
tasklist 2>NUL | findstr /i "v3l v3medic alyac mcshield avp ekrn tmlisten ntrtscan pccntmon avasvc avgui msmpeng" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     백신 프로세스 미발견 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

REM ProductState 설명
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ** ProductState 값 설명: >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo    - 마지막 자리 0 = 비활성화, 마지막 자리 0이 아님 = 활성화 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo    - 중간 자리 0 = 업데이트 최신, 중간 자리 1 = 업데이트 오래됨 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo    - 예시: 397312(0x061000) = 정상/최신/활성화 (양호) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo    - 예시: 397328(0x061010) = 정상/오래됨/활성화 (취약) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo    - 예시: 393200(0x060000) = 정상/최신/비활성화 (취약) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [39.W-39] 백신 프로그램 업데이트 [!RESULT_39!]

:39_END
SET CMT_39=
SET CMT_39_1=
SET RESULT_39=
SET STATE_INFO=
SET STATE=
SET ENABLED=
SET OUTDATED=

:39_ADD

REM ==================================================

REM ==================================================
REM ==================================================
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ----------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo  4. 로그관리  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ----------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo.
echo.
echo 4. 로그관리
echo --------------

REM ==================================================
:40_START
echo [40.W-40] 정책에 따른 시스템 로깅 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:40_ROUTINE
SET CMT_40=초기화&SET RESULT_40=인터뷰
type secpol.inf | findstr /i "AuditAccountManage" | findstr "2 3" >NUL
IF ERRORLEVEL 1 (
	SET CMT_40=보안 감사 설정이 적절하게 "적용되지 않음"&SET RESULT_40=취약& GOTO :40_PRINT
)
type secpol.inf | findstr /i "AuditLogonEvents" | findstr "3" >NUL
IF ERRORLEVEL 1 (
	SET CMT_40=보안 감사 설정이 적절하게 "적용되지 않음"&SET RESULT_40=취약& GOTO :40_PRINT
)
type secpol.inf | findstr /i "AuditPrivilegeUse" | findstr "3" >NUL
IF ERRORLEVEL 1 (
	SET CMT_40=보안 감사 설정이 적절하게 "적용되지 않음"&SET RESULT_40=취약& GOTO :40_PRINT
)
type secpol.inf | findstr /i "AuditDSAccess" | findstr "2 3" >NUL
IF ERRORLEVEL 1 (
	SET CMT_40=보안 감사 설정이 적절하게 "적용되지 않음"&SET RESULT_40=취약& GOTO :40_PRINT
)
type secpol.inf | findstr /i "AuditAccountLogon" | findstr "3" >NUL
IF ERRORLEVEL 1 (
	SET CMT_40=보안 감사 설정이 적절하게 "적용되지 않음"&SET RESULT_40=취약& GOTO :40_PRINT
)
type secpol.inf | findstr /i "AuditPolicyChange" | findstr "3" >NUL
IF ERRORLEVEL 1 (
	SET CMT_40=보안 감사 설정이 적절하게 "적용되지 않음"&SET RESULT_40=취약& GOTO :40_PRINT
)
SET CMT_40=보안 감사 설정이 적절함&SET RESULT_40=양호

:40_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_40% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 보안 감사 설정 적절하게 "적용" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_40% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^* 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* AuditAccountManage        = 계정 관리 감사(실패) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* AuditLogonEvents          = 계정 로그온 이벤트 감사(성공/실패) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* AuditPrivilegeUse         = 권한 사용 감사(실패) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* AuditDSAccess             = 디렉터리 서비스 액세스 감사(실패) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* AuditAccountLogon         = 로그온, 이벤트 감사(성공/실패) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* AuditPolicyChange         = 정책 변경 감사(성공/실패) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo (CMD) type secpol.inf | findstr /i "감사명" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "^Audit" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [40.W-40] 정책에 따른 시스템 로깅 설정 [%RESULT_40%]
:40_END
SET CMT_40=
SET RESULT_40=

:40_ADD
REM 0 : 감사 안 함
REM 1 : 성공만 기록
REM 2 : 실패만 기록
REM 3 : 성공과 실패 모두 기록

REM ==================================================

REM ==================================================
:41_START
echo [41.W-41] NTP 및 시각 동기화 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:41_ROUTINE
SET CMT_41=수동검사&SET RESULT_41=인터뷰

:41_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_41% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : NTP 서버와 동기화 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 참고 : Type이 NoSync 이면 취약 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_41% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) sc query w32time >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
sc query w32time >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) w32tm /query /configuration >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
w32tm /query /configuration  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [41.W-41] NTP 및 시각 동기화 설정 [%RESULT_41%]
:41_END
SET CMT_41=
SET RESULT_41=
:41_ADD


REM ==================================================
:42_START
echo [42.W-42] 이벤트 로그 관리 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:42_ROUTINE
SET RESULT_42=양호
SET CMT_42=로그 파일 크기 제한이 적절하게 "설정"됨,
SET CMT_42_1=필요한 경우 덮어쓰기 "설정"됨

REM 로그 파일 크기 체크 (10MB = 10485760 bytes = 10240KB)
FOR /f "tokens=2 delims= " %%i IN ('wevtutil gl "application" ^| findstr /i "maxSize"') DO (
	IF %%i LSS 10485760 (
		SET CMT_42=로그 파일 크기 제한이 적절하게 "설정되지 않음"^(10MB 이상 권장^),
		SET RESULT_42=취약
	)
)

REM 필요한 경우 덮어쓰기 설정 체크
REM retention: false = 로그 가득 차면 오래된 것부터 덮어씀 (양호)
REM retention: true = 덮어쓰지 않음 (취약 - 로그 가득 차면 새 이벤트 기록 안됨)
wevtutil gl "application" 2>NUL | findstr /i "retention" | findstr /i "true" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_42_1=필요한 경우 덮어쓰기 "설정되지 않음"^(retention: true^)
	SET RESULT_42=취약
) ELSE (
	wevtutil gl "application" 2>NUL | findstr /i "retention" | findstr /i "false" >NUL
	IF NOT ERRORLEVEL 1 (
		SET CMT_42_1=필요한 경우 덮어쓰기 "설정"됨^(retention: false^)
	) ELSE (
		SET CMT_42_1=retention 설정값 확인 필요
		SET RESULT_42=인터뷰
	)
)

:42_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_42% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 로그 파일 크기 제한이 적절하게 "설정" 및 이벤트 엎어쓰지 않음 "설정" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_42% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황2: %CMT_42_1% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) wevtutil gl "로그명" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^* 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 최대 로그파일 크기 (MaxSize)             ^> 10240KB("10485760") >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* retention: "true", autobackup: "true"   = 이벤트 덮어쓰지 않음, 로그 보관 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* retention: "true", autobackup: "false"  = 이벤트 덮어쓰지 않음, 수동 로그 지우기 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* retention: "false", autobackup: "false" = 이벤트 덮어씀, 수동 로그 지우기 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wevtutil gl "application" 2>NUL | findstr /i "name retention autoBackup maxSize" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wevtutil gl "Security" 2>NUL | findstr /i "name retention autoBackup maxSize" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wevtutil gl "System" 2>NUL | findstr /i "name retention autoBackup maxSize" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [42.W-42] 이벤트 로그 관리 설정 [%RESULT_42%]
:42_END
SET CMT_42=
SET CMT_42_1=
SET RESULT_42=

:42_ADD

REM ==================================================
:43_START
echo [43.W-43] 이벤트 로그 파일 접근 통제 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:43_ROUTINE
SET CMT_43=초기화&SET RESULT_43=인터뷰

cacls "%systemroot%\system32\logfiles" 2>NUL | findstr /i "everyone" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_43=이벤트 파일에 대한 Everyone 권한이 "존재"함&SET RESULT_43=취약&goto :43_PRINT
)
cacls "%systemroot%\system32\config" 2>NUL | findstr /i "everyone" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_43=이벤트 파일에 대한 Everyone 권한이 "존재"함&SET RESULT_43=취약&goto :43_PRINT
)
cacls "%SystemRoot%\System32\Winevt\Logs" 2>NUL | findstr /i "everyone" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_43=이벤트 파일에 대한 Everyone 권한이 "존재"함&SET RESULT_43=취약&goto :43_PRINT
)
SET CMT_43=이벤트 파일에 대한 Everyone 권한 없음&SET RESULT_43=양호

:43_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_43% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 로그 디렉터리에 대한 Everyone 권한 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_43% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) cacls "로그파일 디렉터리" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
cacls "%systemroot%\system32\logfiles" 2>NUL | findstr /r /v "^$" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
cacls "%systemroot%\system32\config" 2>NUL | findstr /r /v "^$" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
cacls "%SystemRoot%\System32\Winevt\Logs" 2>NUL | findstr /r /v "^$" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [43.W-43] 이벤트 로그 파일 접근 통제 설정 [%RESULT_43%]
:43_END
SET CMT_43=
SET RESULT_43=

:43_ADD

REM ==================================================
REM ==================================================
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ----------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo  5. 보안관리  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ----------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo.
echo.
echo 5. 보안관리
echo --------------
REM ==================================================
:44_START
echo [44.W-44] 원격으로 액세스할 수 있는 레지스트리 경로 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:44_ROUTINE
SET CMT_44=초기화
SET RESULT_44=인터뷰

REM ========================================
REM Remote Registry 서비스 상태 확인
REM ========================================

REM 1. 서비스가 실행 중인지 확인
type services.inf | findstr /i /c:"Remote Registry" | findstr /i "Running" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_44=원격 레지스트리 서비스가 "실행 중"
	SET RESULT_44=취약
	GOTO :44_PRINT
)

REM 2. 서비스가 중지되어 있는 경우 - 시작 유형 확인
type services.inf | findstr /i /c:"Remote Registry" | findstr /i "Disabled" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_44=원격 레지스트리 서비스가 "사용 안 함" 및 "중지됨" 
	SET RESULT_44=양호
	GOTO :44_PRINT
)

REM 3. 서비스가 중지되어 있지만 시작 유형이 수동 또는 자동
type services.inf | findstr /i /c:"Remote Registry" | findstr /i "Stopped" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_44=원격 레지스트리 서비스가 "중지됨"
	SET RESULT_44=양호
	GOTO :44_PRINT
)

REM 4. 서비스 정보를 찾을 수 없는 경우
SET CMT_44=원격 레지스트리 서비스 정보 확인 필요
SET RESULT_44=인터뷰

:44_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : !RESULT_44! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : Remote Registry Service "사용 안 함" 및 "중지" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : !CMT_44! >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

REM Remote Registry 서비스 상태 출력
echo (CMD) type services.inf ^| findstr /i /c:"Remote Registry" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type services.inf | findstr /i /c:"Remote Registry" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     Remote Registry 서비스 정보 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

REM sc query로 현재 상태 확인
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) sc query "RemoteRegistry" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
sc query "RemoteRegistry" 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     서비스를 찾을 수 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

REM sc qc로 시작 유형 확인
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) sc qc "RemoteRegistry" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
sc qc "RemoteRegistry" 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     서비스를 찾을 수 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [44.W-44] 원격으로 액세스할 수 있는 레지스트리 경로 [!RESULT_44!]

:44_END
SET CMT_44=
SET RESULT_44=

:44_ADD


REM ==================================================
:45_START
SET CMT_45=초기화
SET RESULT_45=인터뷰

IF !AV_FOUND! EQU 0 (
	SET CMT_45=상용 백신 프로그램 없음
	SET RESULT_45=취약
) ELSE (
	SET CMT_45=상용 백신 프로그램,프로세스 존재함(!AV_NAMES!)
	SET RESULT_45=양호
)

:45_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_45% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 백신 프로그램 "설치" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_45% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 참고 : w-39 참고 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [45.W-45] 백신 프로그램 설치 [%RESULT_45%]
:45_END
SET CMT_45=
SET CMT_45_1=
SET RESULT_45=

:45_ADD
REM [항목] 바이러스 백신 프로그램 설치 및 주기적 업데이트
REM Windows Defender를 제외한 백신 설치시 양호
REM
REM [진단] ProductState를 2진수로 변환 후 기준에 따라 판단
REM enable(바이너리 오른쪽에서 19번째)
REM active(바이너리 오른쪽에서 13번째)
REM uptodate(바이너리 오른쪽에서 5번째)
REM
REM [업데이트]
REM 신규 ProductState 발견시 수동진단 및 스크립트 업데이트하기

REM ==================================================

:46_START
echo [46.W-46] SAM 파일 접근통제 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:46_ROUTINE
SET CMT_46=초기화&SET RESULT_46=인터뷰

cacls %systemroot%\system32\config\SAM 2>NUL | findstr /i /v " ^$ SYSTEM Administrators" >NUL
IF ERRORLEVEL 1 (
	SET CMT_46=SAM 파일 접근 권한이 Administrator, System 그룹에게만 "부여"됨&SET RESULT_46=양호
)
IF NOT ERRORLEVEL 1 (
	SET CMT_46=SAM 파일 접근 권한이 Administrator, System 그룹에게만 "부여되지 않음"&SET RESULT_46=인터뷰
)

:46_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_46% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : SAM 파일 접근 권한을 Administrator, System 그룹에게만 "부여" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo : %CMT_46% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) cacls %systemroot%\system32\config\SAM >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
cacls %systemroot%\system32\config\SAM | findstr /v "^$" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) net localgroup "Administrators" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 관리자 그룹 내부 계정이 존재하면 제외 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 계정 10개 이상일 경우, 10개를 제외한 나머지는 생략 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
SET count=0
FOR /f %%i IN ('net localgroup "Administrators" ^| findstr /i /v "^$ 별칭 Alias 명령 completed 설명 Comment 구성원 Members -"') DO (
	net user %%i 2>NUL | findstr /i "활성 active" | findstr /i "아니요 No" >NUL
	IF NOT ERRORLEVEL 1 (
		echo     ^(inactive^)%%i >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
	IF ERRORLEVEL 1 (
		echo     %%i >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	)
	SET /a count+=1
	IF !count! EQU 10 (
		echo     ... >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		GOTO :46_PRINT_1
	)
)
:46_PRINT_1
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [46.W-46] SAM 파일 접근통제 [%RESULT_46%]
:46_END
SET CMT_46=
SET RESULT_46=
SET count=

:46_ADD
REM APPLICATION PACKAGE AUTHORITY : Windows sandboxing packages

REM ==================================================
:47_START
echo [47.W-47] 화면보호기 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:47_ROUTINE
SET CMT_47=초기화&SET RESULT_47=인터뷰

reg query "HKCU\Control Panel\Desktop" 2>NUL | findstr /i "ScreenSaveActive" | findstr "1" >NUL
IF ERRORLEVEL 1 (
	SET CMT_47=화면보호기를 "사용하지 않음"&SET RESULT_47=취약& GOTO :47_PRINT
)
reg query "HKCU\Control Panel\Desktop" 2>NUL | findstr /i "ScreenSaverIsSecure" | findstr "1" >NUL
IF ERRORLEVEL 1 (
	SET CMT_47=화면보호기를  "사용"하지만 "자동 시작되지 않음"&SET RESULT_47=취약& GOTO :47_PRINT
)
FOR /f "tokens=3 delims= " %%i IN ('reg query "HKCU\Control Panel\Desktop" ^| findstr /i "ScreenSaveTimeOut"') DO (
	IF %%i GTR 600 (
		SET CMT_47=화면보호기를 "사용" 및 "자동시작", 대기시간 10분^(600^) 이하 "설정되지 않음"&SET RESULT_47=취약
	) ELSE (
		SET CMT_47=화면보호기를 "사용" 및 "자동시작", 대기시간 10분^(600^) 이하 "설정"&SET RESULT_47=양호
	)
)

:47_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_47% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 화면보호기 "사용", "자동 시작", 암호 "설정" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        및 대기시간 "10분 이하" 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo : %CMT_47% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "HKCU\Control Panel\Desktop" /v "ScreenSave" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^* 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* ScreenSaveActive    : 사용 여부 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* ScreenSaverIsSecure : 자동 시작 여부 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* ScreenSaveTimeOut   : 대기 시간(초) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKCU\Control Panel\Desktop" 2>NUL | findstr /i "ScreenSave" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [47.W-47] 화면보호기 설정 [%RESULT_47%]
:47_END
SET CMT_47=
SET RESULT_47=

:47_ADD


REM ==================================================
:48_START
echo [48.W-48] 로그온하지 않고 시스템 종료 허용 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:48_ROUTINE
SET CMT_48=초기화&SET RESULT_48=인터뷰

type secpol.inf | findstr /i "ShutdownWithoutLogon" | findstr /i "4,1" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_48=로그온하지 않고 시스템 종료 허용을 "사용"함&SET RESULT_48=취약&goto :48_PRINT
)

SET CMT_48=로그온하지 않고 시스템 종료 허용을 사용 안 함&SET RESULT_48=양호

:48_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_48% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 로그온하지 않고 시스템 종료 허용 "사용 안 함" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo : %CMT_48% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "ShutdownWithoutLogon" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "ShutdownWithoutLogon" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "ShutdownWithoutLogon" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "ShutdownWithoutLogon" 2>NUL | findstr /i "ShutdownWithoutLogon" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [48.W-48] 로그온하지 않고 시스템 종료 허용 [%RESULT_48%]
:48_END
SET CMT_48=
SET RESULT_48=

:48_ADD


REM ==================================================
:49_START
echo [49.W-49] 원격 시스템에서 강제로 시스템 종료 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:49_ROUTINE
SET CMT_49=초기화&SET RESULT_49=인터뷰
SET CMT_49_1=
SET NOW_49_group=

FOR /f "tokens=3 delims= " %%i IN ('type "%SECPOL%" ^| findstr /i "SeRemoteShutdownPrivilege"') DO (
	SET NOW_49_group=%%i

	REM 모든사용자 S-1-1-0 (취약)
	echo !NOW_49_group! 2>NUL | findstr /i "S-1-1-0" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_49_group=!NOW_49_group:S-1-1-0=Everyone!
		SET CMT_49=원격 시스템에서 강제 시스템종료를 Administrators만 "설정되지 않음"&SET RESULT_49=취약
		SET CMT_49_1=!CMT_49_1! "Everyone"
		goto :49_PRINT
	)

	REM 관리자 그룹 S-1-5-32-544 (양호)
	echo !NOW_49_group! 2>NUL | findstr /i "S-1-5-32-544" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_49_group=!NOW_49_group:S-1-5-32-544=Administrators!
	)

	REM IUSR_ 사용자 지정 그룹 (취약)
	echo !NOW_49_group! 2>NUL | findstr /i "IUSR S-1-5-17" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_49_group=!NOW_49_group:IUSR=사용자지정 IUSR!
		SET NOW_49_group=!NOW_49_group:S-1-5-17=사용자지정 IUSR!
		SET CMT_49=원격 시스템에서 강제 시스템종료를 Administrators만 "설정되지 않음"&SET RESULT_49=취약
		SET CMT_49_1=!CMT_49_1! "사용자지정 IUSR"
		goto :49_PRINT
	)

	REM 백업운영자그룹 S-1-5-32-551 (취약)
	echo !NOW_49_group! 2>NUL | findstr /i "S-1-5-32-551" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_49_group=!NOW_49_group:S-1-5-32-551=Backup Operators!
		SET CMT_49=원격 시스템에서 강제 시스템종료를 Administrators만 "설정되지 않음"&SET RESULT_49=취약
		SET CMT_49_1=!CMT_49_1! "Backup Operators"
		goto :49_PRINT
	)

  REM 서버운영자그룹 S-1-5-32-549 (취약)
	echo !NOW_49_group! 2>NUL | findstr /i "S-1-5-32-549" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_49_group=!NOW_49_group:S-1-5-32-549=Server Operators!
		SET CMT_49=원격 시스템에서 강제 시스템종료를 Administrators만 "설정되지 않음"&SET RESULT_49=취약
		SET CMT_49_1=!CMT_49_1! "Server Operators"
		goto :49_PRINT
	)

  REM Guest (취약)
	echo !NOW_49_group! 2>NUL |findstr /i "Guest" >NUL
	IF NOT ERRORLEVEL 1 (
		SET CMT_49=원격 시스템에서 강제 시스템종료를 Administrators만 "설정되지 않음"&SET RESULT_49=취약
		SET CMT_49_1=!CMT_49_1! "Guest"
		goto :49_PRINT
	)

	REM 사용자그룹 S-1-5-32-545 (취약)
	echo !NOW_49_group! 2>NUL |findstr /i "S-1-5-32-545" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_49_group=!NOW_49_group:S-1-5-32-545=Users!
		SET CMT_49=원격 시스템에서 강제 시스템종료를 Administrators만 "설정되지 않음"&SET RESULT_49=취약
		SET CMT_49_1=!CMT_49_1! "Users"
		goto :49_PRINT
	)

	REM 도메인그룹 (취약)
	echo !NOW_49_group! 2>NUL |findstr /i "S-1-5-21" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_49_group=!NOW_49_group:S-1-5-21=Domain !
		SET CMT_49=원격 시스템에서 강제 시스템종료를 Administrators만 "설정되지 않음"&SET RESULT_49=취약
		SET CMT_49_1=!CMT_49_1! "Domain"
		goto :49_PRINT
	)

	REM 도메인 컨트롤러 그룹 (취약)
	echo !NOW_49_group! 2>NUL |findstr /i "S-1-5-32-548" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_49_group=!NOW_49_group:S-1-5-32-548=Account Operators!
		SET CMT_49=원격 시스템에서 강제 시스템종료를 Administrators만 "설정되지 않음"&SET RESULT_49=취약
		SET CMT_49_1=!CMT_49_1! "Account Operators"
		goto :49_PRINT
	)

	REM 프린터 그룹 (취약)
	echo !NOW_49_group! 2>NUL |findstr /i "S-1-5-32-550" >NUL
	IF NOT ERRORLEVEL 1 (
		SET NOW_49_group=!NOW_49_group:S-1-5-32-550=Print Operators!
		SET CMT_49=원격 시스템에서 강제 시스템종료를 Administrators만 "설정되지 않음"&SET RESULT_49=취약
		SET CMT_49_1=!CMT_49_1! "Print Operators"
		goto :49_PRINT
	)
)
SET CMT_49=원격 시스템에서 강제 종료를 Administrators만 "설정"&SET RESULT_49=양호

:49_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_49% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 원격 시스템에서 강제 종료 Administrators만 "설정" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_49% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_49_1% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

IF ERRORLEVEL 1 (
	echo     취약 그룹 목록 : 없음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) ELSE (
	echo     취약 그룹 목록 : %CMT_49_1% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "SeRemoteShutdownPrivilege" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* SID가 그대로 노출되는 항목이 존재할 경우 인터뷰 필요 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo SeRemoteShutdownPrivilege = "%NOW_49_group%" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [49.W-49] 원격 시스템에서 강제로 시스템 종료 [%RESULT_49%]
:49_END
SET CMT_49=
SET CMT_49_1=
SET RESULT_49=
SET NOW_49_group=

:49_ADD

REM ==================================================
:50_START
echo [50.W-50] 보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:50_ROUTINE
SET CMT_50=초기화&SET RESULT_50=인터뷰

type secpol.inf | findstr /i "crashonauditfail" | findstr "4,0" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_50=보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 "사용 안 함"
	SET RESULT_50=양호
) ELSE (
	SET CMT_50=보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 "사용"
	SET RESULT_50=취약
)

:50_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_50% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 감사: 보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 "사용 안 함" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo : %CMT_50% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "crashonauditfail" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "crashonauditfail" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v "crashonauditfail" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v "crashonauditfail" 2>NUL | findstr /i "crashonauditfail" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [50.W-50] 보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 [%RESULT_50%]
:50_END
SET CMT_50=
SET RESULT_50=

:50_ADD

REM ==================================================
:51_START
echo [51.W-51] SAM 계정과 공유의 익명 열거 허용 안 함 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:51_ROUTINE
SET CMT_51=설정 되어있음&SET RESULT_51=양호
SET CMT_51_1=설정 되어있음

type secpol.inf | findstr /i "restrictanonymous=" | findstr "4,1 4,2" >NUL
IF ERRORLEVEL 1 (
	SET CMT_51=네트워크 액세스: SAM 계정과 공유의 익명 열거 허용 안 함 "사용 안 함"&SET RESULT_51=취약
)
type secpol.inf | findstr /i "restrictanonymousSAM" | findstr "4,1">NUL
IF ERRORLEVEL 1 (
	SET CMT_51_1=네트워크 액세스: SAM 계정의 익명 열거 허용 안 함 "사용 안 함"&SET RESULT_51=취약
)

:51_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_51% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 네트워크 액세스: SAM 계정과 공유의 익명 열거 허용 안 함 "사용", >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        네트워크 액세스: SAM 계정의 익명 열거 허용 안 함  "사용" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_51% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_51_1% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^* 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* restrictanonymous    : SAM 계정과 공유의 익명 열거 허용 안 함 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* restrictanonymousSAM : SAM 계정의 익명 열거 허용 안 함 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "restrictanonymous" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "restrictanonymous" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\System\CurrentControlSet\Control\Lsa" ^| findstr /i "restrictanonymous" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\System\CurrentControlSet\Control\Lsa" 2>NUL | findstr /i "restrictanonymous" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [51.W-51] SAM 계정과 공유의 익명 열거 허용 안 함 [%RESULT_51%]
:51_END
SET CMT_51=
SET CMT_51_1=
SET RESULT_51=

:51_ADD
REM [기준] RestrictAnonymous값
REM 1. Windows 2000
REM HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\LSA\RestrictAnonymous값이 (DWORD: 2)가 아닐 경우
REM 2. Windows 2003 이상
REM HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\LSA\RestrictAnonymous값이 (DWORD: 1)이 아닐 경우
REM ==================================================


:52_START
echo [52.W-52] AutoLogon 기능 제어 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:52_ROUTINE
SET CMT_52=초기화&SET RESULT_52=인터뷰

reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" 2>NUL | findstr /i "AutoAdminLogon" >NUL
IF ERRORLEVEL 1 (
	SET CMT_52=Autologon 기능 "비활성화"됨&SET RESULT_52=양호
)
IF NOT ERRORLEVEL 1 (
	reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" 2>NUL | findstr /i "AutoAdminLogon" | findstr 1 >NUL
	IF ERRORLEVEL 1 (
		SET CMT_52=Autologon 기능 "비활성화"됨&SET RESULT_52=양호
	)
	IF NOT ERRORLEVEL 1 (
		SET CMT_52=Autologon 기능 "활성화"됨&SET RESULT_52=취약
	)
)

:52_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_52% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : Autologon 기능 "비활성화" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_52% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" 2>NUL | findstr /i "AutoAdminLogon" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (echo     레지스트리 키 또는 값이 존재하지 않음^(비활성화^)) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF "%RESULT_52%" == "취약" (
	echo ^(CMD^) reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Default*" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Default*" 2>NUL | findstr /i "Default*" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	IF ERRORLEVEL 1 (
		echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	) 
)
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [52.W-52] AutoLogon 기능 제어 [%RESULT_52%]
:52_END
SET CMT_52=
SET RESULT_52=

:52_ADD


REM ==================================================
:53_START
echo [53.W-53] 이동식 미디어 포맷 및 꺼내기 허용 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:53_ROUTINE
SET CMT_53=초기화&SET RESULT_53=인터뷰

type secpol.inf | findstr /i "AllocateDASD" >NUL
IF ERRORLEVEL 1 (
	SET CMT_53="Administrators그룹"만 허용됨&SET RESULT_53=양호
) ELSE (
	SET CMT_53="Administrators 및 Power Users 그룹"이 허용됨&SET RESULT_53=취약
	type secpol.inf | findstr /i "AllocateDASD" | findstr "0" >NUL
	IF NOT ERRORLEVEL 1 (
		SET CMT_53="Administrators그룹"만 허용됨&SET RESULT_53=양호
	)
	type secpol.inf | findstr /i "AllocateDASD" | findstr "2" >NUL
	IF NOT ERRORLEVEL 1 (
		SET CMT_53="Administrators 및 Interactive Users 그룹"이 허용됨&SET RESULT_53=취약
	)
)

:53_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_53% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 장치: 이동식 미디어 포맷 및 꺼내기 허용 "Administrators 그룹" 설정  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo : %CMT_53% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "AllocateDASD" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "AllocateDASD" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음^(Administrators그룹만 허용^) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AllocateDASD" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AllocateDASD" 2>NUL | findstr /i "AllocateDASD" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음^(Administrators그룹만 허용^) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [53.W-53] 이동식 미디어 포맷 및 꺼내기 허용 [%RESULT_53%]
:53_END
SET CMT_53=
SET RESULT_53=

:53_ADD


REM ==================================================
:54_START
echo [54.W-54] Dos공격 방어 레지스트리 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:54_ROUTINE
SET CMT_54=수동점검
SET RESULT_54=인터뷰
SET CHECK_PASS=0

:54_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_54% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : DoS 방어 레지스트리 "설정" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_54% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "SynAttackProtect EnableDeadGWDetect KeepAliveTime NoNameReleaseOnDemand" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^* 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* SynAttackProtect = REG_DWORD 1 or 2 (기본 활성화) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* EnableDeadGWDetect = REG_DWORD 0 (비활성화) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* KeepAliveTime = REG_DWORD 300,000 (5분) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* NoNameReleaseOnDemand = REG_DWORD 1 (활성화) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "SynAttackProtect" 2>NUL | findstr /i "SynAttackProtect" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음^(기본 활성화됨^) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableDeadGWDetect" 2>NUL | findstr /i "EnableDeadGWDetect" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "KeepAliveTime" 2>NUL | findstr /i "KeepAliveTime" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NoNameReleaseOnDemand" 2>NUL | findstr /i "NoNameReleaseOnDemand" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [54.W-54] Dos공격 방어 레지스트리 설정 [%RESULT_54%]

:54_END
SET CMT_54=
SET RESULT_54=

:54_ADD
REM [기준] 레지스트리 설정
REM SynAttackProtect = REG_DWORD 1 or 2
REM EnableDeadGWDetect = REG_DWORD 0
REM KeepAliveTime = REG_DWORD 300,000(5분)
REM NoNameReleaseOnDemand = REG_DWORD 1
REM
REM [참고]
REM 1. "syn attack protection" : mechanism was configurable via various registry keys (like SynAttackProtect, TcpMaxHalfOpen, TcpMaxHalfOpenRetried, TcpMaxPortsExhausted), Syn attack protection has been in place since Windows 2000 and is enabled by default since Windows 2003/SP1
REM 2. "KeepAliveTime" : Default: 7,200,000 (two hours)


REM ==================================================
:55_START
echo [55.W-55] 사용자가 프린터 드라이버를 설치할 수 없게 함 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:55_ROUTINE
SET CMT_55=초기화&SET RESULT_55=인터뷰

type secpol.inf | findstr /i "AddPrinterDrivers" | findstr "4,1" >NUL
IF ERRORLEVEL 1 (
    SET CMT_55=일반사용자가 프린터 드라이버를 설치할 수 없게 함 "사용 안 함"
    SET RESULT_55=취약
) ELSE (
    SET CMT_55=일반사용자가 프린터 드라이버를 설치할 수 없게 함 "사용"함
    SET RESULT_55=양호
)

REM 레지스트리 확인
reg query "HKLM\System\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" /v "AddPrinterDrivers" 2>NUL >NUL
IF ERRORLEVEL 1 (
    SET CMT_55=일반사용자가 프린터 드라이버 설치 설정 여부 수동 진단
    SET RESULT_55=인터뷰
)

:55_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_55% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 장치: 공유 프린터에 연결할 때 사용자가 프린터 드라이버를 설치할 수 없게 함 "사용" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_55% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "AddPrinterDrivers" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "AddPrinterDrivers" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\System\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" /v "AddPrinterDrivers" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\System\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" /v "AddPrinterDrivers" 2>NUL | findstr /i "AddPrinterDrivers" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	SET CMT_55=레지스트리 키 또는 값이 존재하지 않음&SET RESULT_55=인터뷰
)
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [55.W-55] 사용자가 프린터 드라이버를 설치할 수 없게 함 [%RESULT_55%]
:55_END
SET CMT_55=
SET RESULT_55=

:55_ADD
REM [기준] 장치: 공유 프린터에 연결할 때 사용자가 프린터 드라이버를 설치할 수 없게 함 정책 기본값
REM 서버의 기본값: 사용
REM 워크스테이션의 기본값: 사용 안 함

REM ==================================================

REM ==================================================
:56_START
echo [56.W-56] SMB 세션 중단 관리 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:56_ROUTINE
SET CMT_56=초기화&SET RESULT_56=인터뷰

type secpol.inf | findstr /i "EnableForcedLogOff" | findstr "4,1" >NUL
IF NOT ERRORLEVEL 1 (
	SET CMT_56=로그온 시간이 만료되면 클라이언트 연결 끊기 "설정"&SET RESULT_56=양호
)
IF ERRORLEVEL 1 (
	SET CMT_56=로그온 시간이 만료되면 클라이언트 연결 끊기 "설정되지 않음"&SET RESULT_56=취약
)
type "%SECPOL%" | findstr /i "autodisconnect" >NUL
IF ERRORLEVEL 1 (
	SET CMT_56_1=세션 연결을 중단하기 전에 필요한 유휴 시간 15분 이하 "설정"됨^(기본값 15분^)
)
IF NOT ERRORLEVEL 1 (
	SET CMT_56_1=세션 연결을 중단하기 전에 필요한 유휴 시간 15분 이하 "설정"됨
	FOR /f "tokens=2 delims=," %%i IN ('type "%SECPOL%" ^| findstr /i "autodisconnect"') DO (
		IF %%i GTR 15 (
			SET CMT_56_1=세션 연결을 중단하기 전에 필요한 유휴 시간 15분 이하 "설정되지 않음"^(15분 이상^)&SET RESULT_56=취약
		)
		IF %%i EQU 0 (
			SET CMT_56_1=세션 연결을 중단하기 전에 필요한 유휴 시간 15분 이하 "설정되지 않음"^(제한 없음^)&SET RESULT_56=취약
		)
		IF %%i EQU 7494967295 (
			SET CMT_56_1=세션 연결을 중단하기 전에 필요한 유휴 시간 15분 이하 "설정되지 않음"^(제한 없음^)&SET RESULT_56=취약
		)
	)
)

:56_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_56% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : Microsoft 네트워크 서버: 로그온 시간이 만료되면 클라이언트 연결 끊기 "설정", >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo        Microsoft 네트워크 서버: 세션 연결을 중단하기 전에 필요한 유휴 시간 15분 이하 "설정" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_56% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_56_1% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "EnableForcedLogOff" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "EnableForcedLogOff" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v "EnableForcedLogOff" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v "EnableForcedLogOff" 2>NUL | findstr /i "EnableForcedLogOff" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) type secpol.inf ^| findstr /i "autodisconnect" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type "%SECPOL%" | findstr /i "autodisconnect" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음^(15분 설정됨^) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v "AutoDisconnect" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v "AutoDisconnect" 2>NUL | findstr /i "AutoDisconnect" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음^(15분 설정됨^) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [56.W-56] SMB 세션 중단 관리 설정 [%RESULT_56%]
:56_END
SET CMT_56=
SET RESULT_56=

:56_ADD
REM [설명] SMB(Server Message Block) 시스템 간\ 데이터 송수신 프로토콜
REM
REM [항목] Microsoft 네트워크 서버: 로그온 시간이 만료되면 클라이언트 연결 끊기
REM 이 정책을 사용하면 클라이언트의 로그온 시간이 만료될 때 SMB 서비스의 클라이언트 세션 연결이 강제로 끊어짐
REM
REM [항목] Microsoft 네트워크 서버: 세션 연결을 중단하기 전에 필요한 유휴 시간
REM 컴퓨터에서 비활성 SMB 세션을 중단시키는 시간을 제어 (설정 안 함이 기본값으로 서버는 15분으로 인식)


REM ==================================================
:57_START
echo [57.W-57] 로그온 시 경고 메시지 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:57_ROUTINE
SET CMT_57=초기화&SET RESULT_57=인터뷰

SET count=0
FOR /f "tokens=2 delims=," %%i IN ('type "%SECPOL%" ^| findstr /i "LegalNoticeCaption LegalNoticeText"') DO (
	SET /a count+=1
)
IF !count! EQU 1 (SET CMT_57=로그온 시도하는 사용자에 대한 메시지 제목, 텍스트가 "설정되지 않음"&SET RESULT_57=취약)&goto :57_PRINT

SET CMT_57=제목 및 텍스트 설정&SET RESULT_57=양호
:57_PRINT

echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_57% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 대화형 로그온: 로그온 시도하는 사용자에 대한 메시지 제목, 텍스트 "설정" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo : %CMT_57% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "LegalNoticeCaption LegalNoticeText" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
FOR /f "tokens=2 delims=," %%i IN ('type "%SECPOL%" ^| findstr /i "LegalNoticeCaption"') DO (
	echo - 제목 - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo : %%i >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
FOR /f "tokens=2 delims=," %%i IN ('type "%SECPOL%" ^| findstr /i "LegalNoticeText"') DO (
	echo - 내용 - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
	echo : %%i >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)
echo (CMD) reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "LegalNoticeCaption LegalNoticeText" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "LegalNoticeCaption" 2>NUL | findstr /i "LegalNoticeCaption" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "LegalNoticeText" 2>NUL | findstr /i "LegalNoticeText" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [57.W-57] 로그온 시 경고 메시지 설정 [%RESULT_57%]
:57_END
SET CMT_57=
SET RESULT_57=
SET count=

:57_ADD


REM ==================================================
:58_START
echo [58.W-58] 사용자별 홈 디렉터리 권한 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:58_ROUTINE
SET CMT_58=초기화&SET RESULT_58=인터뷰

IF "%OS_VER%" EQU "5." (
	FOR /f "tokens=*" %%i IN ('dir /b "C:\Documents and Settings" ^| findstr /i /v "public default"') DO (
		cacls "C:\Documents and Settings\%%i" 2>NUL | findstr /i "Everyone" >NUL
		IF NOT ERRORLEVEL 1 (
			SET CMT_58=사용자 홈 디렉터리에 Everyone 권한이 "존재"함&SET RESULT_58=취약& GOTO 58_PRINT
		)
	)
) ELSE (
	FOR /f "tokens=*" %%i IN ('dir /b "C:\Users" ^| findstr /i /v "public default"') DO (
		cacls "C:\Users\%%i" 2>NUL | findstr /i "Everyone" >NUL
		IF NOT ERRORLEVEL 1 (
			SET CMT_58=사용자 홈 디렉터리에 Everyone 권한이 "존재"함&SET RESULT_58=취약& GOTO :58_PRINT
		)
	)
)

SET CMT_58=사용자 홈 디렉터리에 Everyone 권한 없음&SET RESULT_58=양호

:58_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_58% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 사용자 홈 디렉터리에 Everyone 권한 "존재하지 않음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo : %CMT_58% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) cacls "사용자 홈 디렉터리" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 디렉터리 5개 이상일 경우, 5개를 제외한 나머지는 생략 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
SET count=0
IF "%OS_VER%" EQU "5." (
	FOR /f "tokens=*" %%i IN ('dir /b "C:\Documents and Settings" ^| findstr /i /v "public default"') DO (
		echo - %%i - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		cacls "C:\Documents and Settings\%%i" | findstr /v "^$" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		SET /a count+=1
		IF !count! EQU 5 (
			echo ... >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
			GOTO :58_PRINT_1
		)
	)
) ELSE (
	FOR /f "tokens=*" %%i IN ('dir /b "C:\Users" ^| findstr /i /v "public default"') DO (
		echo - %%i - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		cacls "C:\Users\%%i" | findstr /v "^$" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
		SET /a count+=1
		IF !count! EQU 5 (
			echo ... >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
			GOTO :58_PRINT_1
		)
	)
)
:58_PRINT_1
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [58.W-58] 사용자별 홈 디렉터리 권한 설정 [%RESULT_58%]
:58_END
SET CMT_58=
SET RESULT_58=
SET count=

:58_ADD


REM ==================================================
:59_START
echo [59.W-59] LAN Manager 인증 수준 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:59_ROUTINE
SET CMT_59=초기화&SET RESULT_59=인터뷰

type secpol.inf | findstr /i "Lmcompatibilitylevel" >NUL
IF ERRORLEVEL 1 (
	echo %OS_VER% 2>NUL | findstr "6.0 6.1 6.2 6.3 10.0" >NUL
	IF NOT ERRORLEVEL 1 (
		SET CMT_59=NTLMv2 응답만 보냄으로 "설정"됨^(Default^)&SET RESULT_59=양호
	)
	IF ERRORLEVEL 1 (
		SET CMT_59=NTLMv2 응답만 보냄으로 "설정되지 않음"^(Default^)&SET RESULT_59=취약
	)
) ELSE (
	type secpol.inf | findstr /i "Lmcompatibilitylevel" | findstr "4,3 4,4 4,5" >NUL
	IF NOT ERRORLEVEL 1 (
		SET CMT_59=NTLMv2 응답만 보냄으로 "설정"됨&SET RESULT_59=양호
	)
	IF ERRORLEVEL 1 (
		SET CMT_59=NTLMv2 응답만 보냄으로 "설정되지 않음"&SET RESULT_59=취약
	)
)

:59_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_59% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : NTLMv2 응답만 보냄 "설정" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_59% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^* 설정 ^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* [lmcompatibilitylevel] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 0 (취약) : (LM and NTLM 응답 보냄) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 1 (취약) : (LM and NTLM - NTLMv2 세션 보안 사용(협상된 경우)) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 2 (취약) : (NTLM 응답 보냄) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 3 (양호) : (NTLMv2 응답만 보냄) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 4 (양호) : (NTLMv2 응답만 보냄\LM 거부) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^* 5 (양호) : (NTLMv2 응답만 보냄\LM and NTLM 거부) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^* >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "Lmcompatibilitylevel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "Lmcompatibilitylevel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\System\CurrentControlSet\Control\Lsa" /v "LmCompatibilityLevel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\System\CurrentControlSet\Control\Lsa" /v "LmCompatibilityLevel" 2>NUL | findstr /i "LmCompatibilityLevel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [59.W-59] LAN Manager 인증 수준 [%RESULT_59%]
:59_END
SET CMT_59=
SET RESULT_59=

:59_ADD
REM [기준] LAN Manager 인증 수준 (3이상 양호 미만은 취약)
REM **Windows 2008 이상은 키가 없어도 양호, 2003 이하는 키 없으면 취약
REM lmcompatibilitylevel  =  0 (LM and NTLM 응답 보냄)
REM lmcompatibilitylevel  =  1 (LM and NTLM - NTLMv2 세션 보안 사용(협상된 경우))
REM lmcompatibilitylevel  =  2 (NTLM 응답 보냄)
REM lmcompatibilitylevel  =  3 (NTLMv2 응답만 보냄)
REM lmcompatibilitylevel  =  4 (NTLMv2 응답만 보냄\LM 거부)
REM lmcompatibilitylevel  =  5 (NTLMv2 응답만 보냄\LM and NTLM 거부)

REM ==================================================
:60_START
echo [60.W-60] 보안 채널 데이터 디지털 암호화 또는 서명 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:60_ROUTINE
SET CMT_60=&SET RESULT_60=인터뷰
SET CMT_60_1=
SET CMT_60_2=

type secpol.inf | findstr /i "signsecurechannel" | findstr "4,1" >NUL
IF ERRORLEVEL 1 (
	SET CMT_60=도메인 구성원: 보안 채널 데이터를 디지털 서명^(가능한 경우^) "사용 안 함"&SET RESULT_60=취약&goto :60_PRINT
)
type secpol.inf | findstr /i "requiresignorseal" | findstr "4,1" >NUL
IF ERRORLEVEL 1 (
	SET CMT_60_1=도메인 구성원: 보안 채널 데이터를 디지털 암호화 또는 서명^(항상^) "사용 안 함"&SET RESULT_60=취약&goto :60_PRINT
)
type secpol.inf | findstr /i "sealsecurechannel" | findstr "4,1" >NUL
IF ERRORLEVEL 1 (
	SET CMT_60_2=도메인 구성원: 보안 채널 데이터를 디지털 암호화^(가능한 경우^) "사용 안 함"&SET RESULT_60=취약&goto :60_PRINT
)
SET CMT_60=사용 설정&SET CMT_60_1=사용 설정&SET CMT_60_2=사용 설정&SET RESULT_60=양호

:60_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_60% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 도메인 구성원: 보안 채널 데이터를 디지털 서명(가능한 경우) "사용" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo       도메인 구성원: 보안 채널 데이터를 디지털 암호화 또는 서명(항상) "사용" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo       도메인 구성원: 보안 채널 데이터를 디지털 암호화(가능한 경우) "사용" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_60% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_60_1% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_60_2% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) type secpol.inf ^| findstr /i "signsecurechannel requiresignorseal sealsecurechannel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf | findstr /i "signsecurechannel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
type secpol.inf | findstr /i "requiresignorseal" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
type secpol.inf | findstr /i "sealsecurechannel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     설정값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\System\CurrentControlSet\Services\Netlogon\Parameters" /v "SignSecureChannel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\System\CurrentControlSet\Services\Netlogon\Parameters" /v "SignSecureChannel" 2>NUL | findstr /i "SignSecureChannel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\System\CurrentControlSet\Services\Netlogon\Parameters" /v "RequireSignOrSeal" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\System\CurrentControlSet\Services\Netlogon\Parameters" /v "RequireSignOrSeal" 2>NUL | findstr /i "RequireSignOrSeal" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) reg query "HKLM\System\CurrentControlSet\Services\Netlogon\Parameters" /v "SealSecureChannel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\System\CurrentControlSet\Services\Netlogon\Parameters" /v "SealSecureChannel" 2>NUL | findstr /i "SealSecureChannel" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [60.W-60] 보안 채널 데이터 디지털 암호화 또는 서명 [%RESULT_60%]
:60_END
SET CMT_60=
SET CMT_60_1=
SET CMT_60_2=
SET RESULT_60=

:60_ADD


REM ==================================================
:61_START
echo [61.W-61] 파일 및 디렉토리 보호 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:61_ROUTINE
SET CMT_61=초기화&SET RESULT_61=인터뷰

FOR /f %%i IN ('wmic logicaldisk get description^, filesystem ^| findstr /i "고정 fixed" ^| find /c /v "NTFS"') DO (
	IF %%i EQU 0 (
		SET CMT_61=모든 디스크 볼륨의 파일시스템이 "NTFS"로 설정됨&SET RESULT_61=양호
	) ELSE (
		SET CMT_61=파일시스템이 "NTFS가 아닌" 디스크 볼륨이 존재함&SET RESULT_61=취약
	)
)

:61_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_61% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 모든 디스크 볼륨의 파일시스템 "NTFS" 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_61% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) wmic logicaldisk get description, filesystem, name >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wmic logicaldisk get description, filesystem, name > wmic.inf
type wmic.inf >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [61.W-61] 파일 및 디렉토리 보호 [%RESULT_61%]
:61_END
SET CMT_61=
SET RESULT_61=

:61_ADD


REM ==================================================
:62_START
echo [62.W-62] 시작프로그램 목록 분석 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:62_ROUTINE
SET CMT_62=수동점검&SET RESULT_62=인터뷰

reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" 2>NUL >NUL
IF NOT ERRORLEVEL 1 (
    SET RESULT_62=인터뷰
    SET CMT_62=불필요한 시작프로그램 존재 여부 확인
)
reg query "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" 2>NUL >NUL
IF NOT ERRORLEVEL 1 (
    SET RESULT_62=인터뷰
    SET CMT_62=불필요한 시작프로그램 존재 여부 확인
)
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" 2>NUL >NUL
IF NOT ERRORLEVEL 1 (
    SET RESULT_62=인터뷰
    SET CMT_62=불필요한 시작프로그램 존재 여부 확인
)
reg query "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" 2>NUL >NUL
IF NOT ERRORLEVEL 1 (
    SET RESULT_62=인터뷰
    SET CMT_62=불필요한 시작프로그램 존재 여부 확인
)
dir /b /a "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" 2>NUL | findstr /i /v "desktop.ini" >NUL
IF NOT ERRORLEVEL 1 (
    SET RESULT_62=인터뷰
    SET CMT_62=불필요한 시작프로그램 존재 여부 확인
)
:62_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_62% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 불필요한 시작프로그램 "존재하지 않음" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_62% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) reg query "시작프로그램" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo - HKLM\Software\Microsoft\Windows\CurrentVersion\Run - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" 2>NUL | findstr /v "^$ HKEY_LOCAL_MACHINE" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo - HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" 2>NUL | findstr /v "^$ HKEY_LOCAL_MACHINE" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo - HKCU\Software\Microsoft\Windows\CurrentVersion\Run - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" 2>NUL | findstr /v "^$ HKEY_CURRENT_USER" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo - HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run - >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" 2>NUL | findstr /v "^$ HKEY_CURRENT_USER" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo (CMD) dir /b /a "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
dir /b /a "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" 2>NUL | findstr /v "^$" | findstr /i /v "desktop.ini" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     파일이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [62.W-62] 시작프로그램 목록 분석 [%RESULT_62%]
:62_END
SET CMT_62=
SET RESULT_62=


:63_START
echo [63.W-63] 도메인 컨트롤러-사용자의 시간 동기화 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:63_ROUTINE
SET CMT_63=수동 점검&SET RESULT_63=인터뷰

echo %OS_VER% 2>NUL | findstr "6.2 6.3 10.0" >NUL
IF ERRORLEVEL 1 (
	REM Windows 2008 이하
	SET CMT_63=Windows 2008 이하 버전은 "해당없음"&SET RESULT_63=양호
) ELSE (
	REM Windows 2012 이상 (6.2 6.3 10.0)
	SET CMT_63=수동 점검&SET RESULT_63=인터뷰
)

:63_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_63% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 컴퓨터 시계 동기화 최대 허용 오차값 5분 이하로 설정  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_63% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 1. 도메인 가입 여부 점검 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) wmic computersystem get Name,Domain,PartOfDomain >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
wmic computersystem get Name,Domain,PartOfDomain > temp_wmic.txt
type temp_wmic.txt >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
del temp_wmic.txt

echo 2. kerberos 시간 오차 점검 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters" /v MaxClockSkew 2>NUL
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) ELSE (
	reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters" /v MaxClockSkew 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)


echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [63.W-63] 도메인 컨트롤러-사용자의 시간 동기화 [%RESULT_63%]
:63_END
SET CMT_63=
SET RESULT_63=

:63_ADD


REM ==================================================
:64_START
echo [64.W-64] 윈도우 방화벽 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:64_ROUTINE
SET CMT_64=수동 점검&SET RESULT_64=인터뷰

echo %OS_VER% 2>NUL | findstr "5.0 5.2 6.0 6.1 6.2 6.3 10.0" >NUL
IF ERRORLEVEL 1 (
	REM Windows NT
	SET CMT_64=Windows NT 버전은 해당없음&SET RESULT_64=양호
) ELSE (
	REM Windows 200 이상 (6.2 6.3 10.0)
	SET CMT_64=수동 점검&SET RESULT_64=인터뷰
)

:64_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_64% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 윈도우 방화벽 사용으로 설정  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 : %CMT_64% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 윈도우 방화벽 설정 확인 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) netsh advfirewall show allprofiles >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
netsh advfirewall show allprofiles >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [64.W-64] 윈도우 방화벽 설정 [%RESULT_64%]
:64_END
SET CMT_64=
SET RESULT_64=

:64_ADD


echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ----------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo  추가 진단  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ----------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo.
echo.
echo 추가 진단
echo --------------
:83_ADD
REM 추가 진단1

:83_START
echo [추가진단 1] 관리자 권한의 사용자 외에 CMD 파일에 대한 실행 권한 제거 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:83_ROUTINE
cacls %systemroot%\system32\cmd.exe 2>NUL | findstr /i "APPLICATION" >NUL

IF ERRORLEVEL 1 (
	SET CMT_83=CMD 파일의 실행 권한이 SYSTEM, Administrator, TrustedInstaller 그룹에게만 부여&SET RESULT_83=양호
)
IF NOT ERRORLEVEL 1 (
	SET CMT_83=CMD 파일의 실행 권한이 SYSTEM, Administrator, TrustedInstaller 그룹에게만 부여되지않음&SET RESULT_83=취약& GOTO :83_PRINT
)

cacls %systemroot%\system32\cmd.exe 2>NUL | findstr /i "BUILTIN\Users" >NUL

IF ERRORLEVEL 1 (
	SET CMT_83=CMD 파일의 실행 권한이 SYSTEM, Administrator, TrustedInstaller 그룹에게만 부여&SET RESULT_83=양호
)
IF NOT ERRORLEVEL 1 (
	SET CMT_83=CMD 파일의 실행 권한이 SYSTEM, Administrator, TrustedInstaller 그룹에게만 부여되지않음&SET RESULT_83=취약& GOTO :83_PRINT
)


:83_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_83% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : CMD 파일 접근 권한을 SYSTEM, Administrator, TrustedInstaller 그룹에게만 "부여" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo : %CMT_83% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo (CMD) cacls %systemroot%\system32\cmd.exe >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
cacls %systemroot%\system32\cmd.exe >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:83_PRINT_1
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [추가진단 1] 관리자 권한의 사용자 외에 CMD 파일에 대한 실행 권한 제거 [%RESULT_83%]
:83_END
SET CMT_83=
SET RESULT_83=
SET count=

:84_ADD
REM 추가 진단1

:84_START
echo [추가진단 2] 윈도우 방화벽 설정을 통하여 허가받지 않은 포트 사용 금지 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:84_ROUTINE
SET cmt_84=수동점검&SET RESULT_84=인터뷰

:84_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_84% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : 비인가된 포트 사용이 없는 경우 양호 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo : %cmt_84% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 데이터를 엑셀로 옮겨서 보면 분석 쉬움, 텍스트 나누기 - 구분 기호로 분리됨 - 기타 (^|) >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

echo 방화벽 인바운드 포트 점검 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" | findstr Dir=In | findstr Active=TRUE >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 방화벽 아웃바운드 포트 점검 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" | findstr Dir=Out | findstr Active=TRUE >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:84_PRINT_1
echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [추가진단 2] 윈도우 방화벽 설정을 통하여 허가받지 않은 포트 사용 금지 [%RESULT_84%]
:84_END
SET cmt_84=
SET RESULT_84=
SET count=

:84_ADD
REM APPLICATION PACKAGE AUTHORITY : Windows sandboxing packages

:85_ADD
REM 추가 진단3


:85_START
echo [추가진단 3] Kerberos 프로토콜에 대한 재전송 공격방지를 위한 NTP 서버 사용 설정 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt

:85_ROUTINE
type services.inf 2>NUL | findstr /i "Time" | findstr /i "Windows" >NUL
IF ERRORLEVEL 1 (
	SET RESULT_85=취약&SET CMT_85=Windows Time 서비스가 존재하지 않음& GOTO :85_PRINT
)

type services.inf 2>NUL | findstr /i "Time" | findstr /i "Windows" | findstr /i "Running" >NUL
IF ERRORLEVEL 1 (
	SET RESULT_85=취약&SET CMT_85=Windows Time 서비스가 비활성화 되어있음& GOTO :85_PRINT
)
IF NOT ERRORLEVEL 1 (
	SET RESULT_85=양호&SET CMT_85=Windows Time 서비스가 활성화 되어있음
)

:85_PRINT
echo [START] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 결과 : %RESULT_85% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 권고 : Windows Time 서비스를 활성화 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 현황 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo : %cmt_85% >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo type services.inf 2>NUL | findstr /i "Time" | findstr /i "Windows" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type services.inf 2>NUL | findstr /i "Time" | findstr /i "Windows" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo 연동된 시간 서버 확인 : >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /s /v "SpecialPollTimeRemaining" | findstr SpecialPollTimeRemaining >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
IF ERRORLEVEL 1 (
	echo     레지스트리 키 또는 값이 존재하지 않음 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
) 

echo [END] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo [추가진단 3] Kerberos 프로토콜에 대한 재전송 공격방지를 위한 NTP 서버 사용 설정 [%RESULT_85%]
:85_END
SET cmt_85=
SET RESULT_85=
SET count=

:85_ADD
REM APPLICATION PACKAGE AUTHORITY : Windows sandboxing packages


:SCRIPT_END
IF EXIST wmic.inf (del wmic.inf)
IF EXIST ftp.txt (
  del ftp.txt
)
IF EXIST ftp_result.txt (
  del ftp_result.txt
)
IF EXIST curl_http.txt (
  del curl_http.txt
)
IF EXIST curl_smtp.txt (
  del curl_smtp.txt
)
IF EXIST netstat.inf (
  del netstat.inf
)

REM ==================================================
REM ==================================================
:SYSTEM_DETAILS
REM type system_information.txt >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo.
echo. ^*^* 시스템 정보를 수집 중 입니다.
echo ---------------------------------------------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo                      SYSTEM Detail >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------------------------------------------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo                 [시스템 정보] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
systeminfo 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo                 [IP 정보] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
ipconfig /all 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo                 [OPEN PORT 정보] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
netstat -abno | findstr 0.0.0.0 2>NUL | findstr /i "LISTENING" | findstr /v 127.0.0.1 >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo                 [포트 스캔용 PORT 정보] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
netstat -abno 2>NUL  >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo                 [프로세스 정보] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
tasklist /svc >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo                 [프로세스 정보-powershell] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
powershell -Command "Get-Process | Sort-Object Id | Select-Object Id, Name, Description, Path" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo                 [방화벽 인바운드 정책 차단] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
powershell -Command "Get-NetFirewallRule -Direction Inbound | Where-Object { $_.Enabled -eq 'True' -and $_.Action -eq 'BLOCK'} | ForEach-Object { $r=$_;$pf=Get-NetFirewallPortFilter -AssociatedNetFirewallRule $r; $af=Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $r; [pscustomobject]@{Name=$r.DisplayName; Protocol=$pf.Protocol; LocalPort=$pf.LocalPort; RemotePort=$pf.RemotePort; RemoteAddress=$af.RemoteAddress;} } | Format-Table -AutoSize" >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo                 [서비스 정보] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type services.inf 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
del services.inf 2>NUL
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt






echo                 [환경변수 정보] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
set 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo                 [보안정책 정보] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
type secpol.inf 2>NUL >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
del secpol.inf 2>NUL
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo                 [설치프로그램 정보] >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
FOR /f "tokens=3,* delims= " %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /v "DisplayName" ^| findstr /v "HKEY_LOCAL" ^| findstr DisplayName') DO (
	echo %%i%%j >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
)

REM ==================================================
REM ==================================================
:QUIT
echo ---------------------------------------------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo            스크립트가 정상 종료되었습니다. >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo ---------------------------------------------------- >> [RESULT]%COMPUTERNAME%_%OS_TYPE%_%ipaddr%_%START_DATE%.txt
echo.
echo ----------------------------------------------------
echo            스크립트가 정상 종료되었습니다.
echo ----------------------------------------------------
echo.
REM ==================================================
REM ==================================================
