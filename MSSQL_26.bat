REM https://github.com/mithrajuneo/jutong2026
@echo off
chcp 949
setlocal enabledelayedexpansion
title SQL Server Script
echo ##################################################################################### > %COMPUTERNAME%_mssql.txt
echo #                                                                                   # >> %COMPUTERNAME%_mssql.txt
echo #                  MSSQL Server CheckList                                             # >> %COMPUTERNAME%_mssql.txt
echo #                                                                                   # >> %COMPUTERNAME%_mssql.txt
echo #        JeongJuneHyuck Copyright 2026.  all rights reserved.                       # >> %COMPUTERNAME%_mssql.txt
echo #                                                                                   # >> %COMPUTERNAME%_mssql.txt
echo ##################################################################################### >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo ###############################################################                 
echo #                 MSSQL Server CheckList                      #                                     
echo #    JeongJuneHyuck Copyright 2026. all rights reserved.      #                                        
echo ###############################################################

rem set /P INSTANCE="인스턴스명을 입력하세요 (ex.SQLEXPRESS) : "

rem set /P INSTANCE="인스턴스명을 입력하세요 (없으면 Enter) : "
rem if "%INSTANCE%"=="" (
rem    set SERVERNAME=%SERVER%
rem ) else (
rem set SERVERNAME=%SERVER%\%INSTANCE%
rem )
rem set SERVERNAME=%SERVER%
echo =============================================
echo [ SQL Server 접속 방식 선택 ]
echo =============================================
echo 1. 현재 로그인 된 Windows 계정으로 접속
echo 2. SQL 로그인 계정(ID/PW)으로 접속
echo =============================================
set /P MODE="번호를 선택하세요 (1 또는 2) : "

set /P SERVER="서버 주소를 입력하세요 (예: 127.0.0.1) : "
rem set /P INSTANCE="인스턴스명을 입력하세요 (비워두면 기본 인스턴스 사용) : "
set /P PORT="포트 번호를 입력하세요 (예: 1433) : "

if "%PORT%"=="" (
    set SERVERNAME=%SERVER%
) else (
    set SERVERNAME=%SERVER%,%PORT%
)

if "%MODE%"=="1" (
    echo [Windows 인증 방식으로 접속합니다...]
    set commonCMD=sqlcmd -S %SERVERNAME% -E   -W -w 999 -u
) else if "%MODE%"=="2" (
    set /P ID="SQL 로그인 ID를 입력하세요 (예: sa) : "
    set /P PASSWD="SQL 로그인 비밀번호를 입력하세요 : "
    echo [SQL 로그인 방식으로 접속합니다...]
    set commonCMD=sqlcmd -S %SERVERNAME% -U !ID! -P "!PASSWD!" -W -w 999 -u
    rem echo sqlcmd -S %SERVERNAME% -U %ID% -P
) else (
    echo 잘못된 선택입니다. 종료합니다.
    pause
    exit /b
)

echo ##################################################################################### >> %COMPUTERNAME%_mssql.txt

rem set commonCMD=sqlcmd -S %SERVERNAME%%INSTANCE% -w 65530 -U %ID% -P %PASSWD% -Q
rem set commonCMD=sqlcmd -S %SERVERNAME% -U %ID% -P %PASSWD% -Q

echo ########################## [[ 시스템 기본 정보 ]] ################################### >> %COMPUTERNAME%_mssql.txt
echo ##################################################################################### >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo --- Start Time ---------------------------------------------------------------------- >> %COMPUTERNAME%_mssql.txt
echo %date% %time% >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo ########################## 1. Account Management ################################# >> %COMPUTERNAME%_mssql.txt
echo ********************************************************************************** >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt
secedit /EXPORT /CFG local_security_policy.txt

echo D-0. 로그인 가능한 계정 리스트 출력 >> %COMPUTERNAME%_mssql.txt
set "query_login=SELECT sp.name AS LoginName, sp.type_desc AS AuthType, sp.is_disabled AS IsDisabled, sp.create_date AS CreateDate, sp.default_database_name AS DefaultDB, CASE WHEN sp.is_disabled = 0 THEN 'Active' ELSE 'Disabled' END AS Status, CASE WHEN spm.role_principal_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS IsSysAdmin FROM sys.server_principals sp LEFT JOIN sys.server_role_members spm ON sp.principal_id = spm.member_principal_id AND spm.role_principal_id = (SELECT principal_id FROM sys.server_principals WHERE name = 'sysadmin') WHERE sp.type IN ('S','U','G') AND sp.is_disabled = 0 AND sp.name NOT LIKE '##%' ORDER BY sp.type_desc, sp.name;"
%commonCMD% -Q "%query_login%" >> %COMPUTERNAME%_mssql.txt

echo D-01. 기본 계정의 패스워드, 정책 등을 변경하여 사용 >> %COMPUTERNAME%_mssql.txt
echo 결과가 NULL이어도 변경 안한게 아님 변경 시간을 보는게 나을수도  >> %COMPUTERNAME%_mssql.txt
echo ----------------------------------------------------------------------------------------->> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
rem %commonCMD% "select * from syslogins" >> %COMPUTERNAME%_mssql.txt
echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
set "query1_1_1=SELECT * FROM sys.syslogins"
set "query1_1_2=SELECT *  from sys.sql_logins WHERE name = 'sa'"
rem sa 계정이 비활성화 되어있다면 윈도우 인증으로 로그인 한다는거임
echo --------------------- 구버전 --------------------- >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query1_1_1%" >> %COMPUTERNAME%_mssql.txt
echo --------------------- 신버전 (sa 로그인 정보) --------------------- >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query1_1_2%" >> %COMPUTERNAME%_mssql.txt
echo --------------------- 윈도우 계정의 비밀번호 변경 여부 확인 --------------------- >> %COMPUTERNAME%_mssql.txt
powershell -Command  "Get-LocalUser | Select-Object Name, PasswordLastSet, PasswordExpires" >> %COMPUTERNAME%_mssql.txt

rem is_locked_out = 1 → 로그인 잠김
rem is_disabled = 1 → 계정 사용 안 함
rem is_policy_checked = 1 → 보안 정책(잠금/복잡성 등)이 적용되는 계정

echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt

echo D-02. 데이터베이스의 불필요 계정을 제거하거나, 잠금 설정 후 사용 >> %COMPUTERNAME%_mssql.txt
echo 아래 결과를 종합적으로 분석을 해서 활성화된 계정에 대해서 인터뷰가 필요할수도.. >> %COMPUTERNAME%_mssql.txt
echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
set "query1_2_1=select name,status,denylogin,hasaccess from syslogins"
set "query1_2_2=SELECT name, type_desc, is_disabled, create_date, modify_date FROM sys.sql_logins ORDER BY name"
echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
echo --------------------- 구버전 --------------------- >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query1_2_1%" >> %COMPUTERNAME%_mssql.txt
echo --------------------- 신버전 --------------------- >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query1_2_2%" >> %COMPUTERNAME%_mssql.txt

echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-03 패스워드의 사용기간 및 복잡도 기관 정책에 맞도록 설정 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo 패스워드 복잡도 설정 확인(is_disabled가 1이고,type S(서버 인증)이고, is_expiration_checked(패스워드 만료기간) = 1, is_policy_checked(암호정책)이면 양호) >> %COMPUTERNAME%_mssql.txt
set "query1_3_1=select * from sys.sql_logins"
set "query1_3_2=SELECT name, is_expiration_checked AS password_expiration_enabled, is_policy_checked AS password_policy_enforced FROM sys.sql_logins ORDER BY name"
echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
echo --------------------- 구버전 --------------------- >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query1_3_1%" >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt
echo type이 U또는 G일때 아래 정책에 영향을 받음 >> %COMPUTERNAME%_mssql.txt
echo [PasswordComplexity]>> %COMPUTERNAME%_mssql.txt
type local_security_policy.txt | find "PasswordComplexity"  >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt
echo[Maximum password age]>> %COMPUTERNAME%_mssql.txt
type local_security_policy.txt | find "Maximum"  >> %COMPUTERNAME%_mssql.txt

echo --------------------- 신버전 --------------------- >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query1_3_2%" >> %COMPUTERNAME%_mssql.txt
rem password_expiration_enabled: 암호 만료 정책이 활성화되어 있는지를 나타냅니다. 1은 활성화, 0은 비활성화
rem password_policy_enforced: 암호 정책이 적용되고 있는지를 나타냅니다. 1은 적용됨, 0은 적용되지 않음

echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-04. 데이터베이스 관리자 권한을 꼭 필요한 계정 및 그룹에 대해서만 허용 >> %COMPUTERNAME%_mssql.txt
echo ----------------------------------------------------------------------------------------->> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
set "query1_4_1=select login_name = P.name, role_name = CASE R.role_principal_id WHEN 3 THEN 'sysadmin' WHEN 4 THEN 'securityadmin' WHEN 5 THEN 'serveradmin' WHEN 6 THEN 'setupadmin' WHEN 7 THEN 'processadmin' WHEN 8 THEN 'diskadmin' WHEN 9 THEN 'dbcreator' WHEN 10 THEN 'bulkadmin' END FROM sys.server_principals P INNER JOIN sys.server_role_members R ON P.principal_id = R.member_principal_id ORDER BY P.name"
set "query1_4_2=SELECT sp.name AS login_name, sp.type_desc AS login_type, sp.is_disabled, sl.create_date, sl.modify_date FROM sys.server_role_members rm JOIN sys.server_principals sp ON rm.member_principal_id = sp.principal_id JOIN sys.sql_logins sl ON sp.name = sl.name WHERE rm.role_principal_id = SUSER_ID('sysadmin') ORDER BY sp.name"
echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
echo --------------------- 구버전 --------------------- >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query1_4_1%" >> %COMPUTERNAME%_mssql.txt
echo --------------------- 신버전 --------------------- >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query1_4_2%" >> %COMPUTERNAME%_mssql.txt
rem sysadmin 서버 역할에 속한 로그인 계정들의 정보를 조회하는 쿼리
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-05. 패스워드 재사용에 대한 제약 >> %COMPUTERNAME%_mssql.txt
echo ----------------------------------------------------------------------------------------->> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo MSSQL은 패스워드 재사용에 대한 보안 설정이 존재하지 않으므로 해당사항 없음 >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-06. DB 사용자 계정 개별적 부여 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo 공용계정이 아닌 사용자별 계정을 사용하고 있는 경우(결과 값에 대한 인터뷰 진행).  >> %COMPUTERNAME%_mssql.txt
echo log.name AS [Name] : 로그인계정  >> %COMPUTERNAME%_mssql.txt
echo log.type_desc : 로그인타입  >> %COMPUTERNAME%_mssql.txt
echo log.is_disabled AS [IsDisabled] : 1이면사용할수없음  >> %COMPUTERNAME%_mssql.txt
echo log.create_date AS [CreateDate] : 생성일  >> %COMPUTERNAME%_mssql.txt

set "query1_6_1= select log.name AS [Name], log.type_desc, log.is_disabled AS [IsDisabled],log.create_date AS [CreateDate] FROM sys.server_principals AS log WHERE (log.type in ('U', 'G', 'S', 'C', 'K') AND log.principal_id not between 101 and 255 AND log.name <> N'##MS_AgentSigningCertificate##') ORDER BY [Name] ASC"
set "query1_6_2= SELECT   loginname, starttime, hostname AS clienthostname, applicationname, servername FROM sys.fn_trace_gettable(CONVERT(VARCHAR(150), (SELECT TOP 1 value FROM sys.fn_trace_getinfo(NULL) WHERE property = 2)), DEFAULT) WHERE EventClass = 14 -- 로그인 성공 ORDER BY starttime DESC"
echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
echo --------------------- 구버전 ---------------------  >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query1_6_1%" >> %COMPUTERNAME%_mssql.txt
echo --------------------- 신버전 ---------------------  >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query1_6_2%" >> %COMPUTERNAME%_mssql.txt
rem 감사쿼리이며, 같은 계정으로 다른 hostname에서 로그인했는지 확인 하면 됨
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-07. root 권한으로 서비스 구동 제한 >> %COMPUTERNAME%_mssql.txt
echo ----------------------------------------------------------------------------------------->> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo MSSQL은 해당사항 없음 >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-08. 안전한 암호화 알고리즘 사용 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo mssql 2012 이상에서는 SHA-512 해쉬 알고리즘 사용 >> %COMPUTERNAME%_mssql.txt
set "query3_3_1= select name, password_hash from sys.sql_logins;"
set "query3_3_2= SELECT name AS login_name, is_policy_checked, is_expiration_checked FROM sys.sql_logins;"
echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
echo --------------------- 구버전 ---------------------  >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query3_3_1%" >> %COMPUTERNAME%_mssql.txt
echo --------------------- 신버전 ---------------------  >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query3_3_2%" >> %COMPUTERNAME%_mssql.txt
echo --------------------- 신버전(윈도우 OS 인증 일경우 패스워드 복잡도 정책 확인 ---------------------  >> %COMPUTERNAME%_mssql.txt
echo PasswordComplexity =1 이면 양호 >> %COMPUTERNAME%_mssql.txt
echo MaximumPasswordAge=90 이면 양호 >> %COMPUTERNAME%_mssql.txt
echo MinimumPasswordLength=8 이상이면 양호 >> %COMPUTERNAME%_mssql.txt
secedit /export /cfg password_policy.cfg
type password_policy.cfg | findstr PasswordComplexity  >> %COMPUTERNAME%_mssql.txt
type password_policy.cfg | findstr Maximum  >> %COMPUTERNAME%_mssql.txt
type password_policy.cfg | findstr Minimum  >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-09 일정 횟수의 로그인 실패 시 잠금 정책 설정 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo MSSQL은 해당사항 없음 >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-10. 원격에서 DB 서버로의 접속 제한 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo [추가인터뷰필요]  >> %COMPUTERNAME%_mssql.txt
echo 참고 : mssql 포트가 아닌 mstsc 원격 접속 포트임  >> %COMPUTERNAME%_mssql.txt
echo config_value = 0 (로컬연결), config_value = 1 (원격 연결), 특정 IP에서만 접속 가능하도록 방화벽 또는 DB접근제어 솔루션 확인  >> %COMPUTERNAME%_mssql.txt
echo ----------------------------------------------------------------------------------------->> %COMPUTERNAME%_mssql.txt
set "query2_1_1= sp_configure 'remote admin connections'"
echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
echo --------------------- 구버전 ---------------------  >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query2_1_1%" >> %COMPUTERNAME%_mssql.txt
echo --------------------- 신버전 (방화벽 정책 확인)---------------------  >> %COMPUTERNAME%_mssql.txt
for /f "tokens=3" %%A in ('
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber ^| find "PortNumber" 
') do set HEX_PORT=%%A

REM 16진수 → 10진수 변환
set /a RDP_PORT=%HEX_PORT%
echo RDP Port (Decimal) = %RDP_PORT% >> %COMPUTERNAME%_mssql.txt

powershell -Command "Get-NetFirewallRule -Enabled True -Direction Inbound | Where-Object { ($_ | Get-NetFirewallPortFilter).LocalPort -contains '%RDP_PORT%' }" >> %COMPUTERNAME%_mssql.txt
echo ----------------------------------------------------------------------------------------->> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-11. DBA 이외의 인가되지 않은 사용자가 시스템 테이블에 접근할 수 없도록 설정 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo 아래 쿼리에서 결과가 나오면 취약 (설명_sys.database_principals이 public 이면서 sys.all_objects가 System이면 취약)  >> %COMPUTERNAME%_mssql.txt
echo ----------------------------------------------------------------------------------------->> %COMPUTERNAME%_mssql.txt
set "query2_2_1= select su.name as principal_name, dp.type_desc as principal_type_desc, ao.type_desc, ao.name as object_name, p.permission_name, p.state_desc as permission_state_desc from sys.database_permissions p, sys.database_principals dp, sys.all_objects ao, sys.sysusers su where ao.object_id=p.major_id and p.grantee_principal_id=dp.principal_id and p.grantee_principal_id=su.uid and dp.name='public' and ao.type='S'"
set "query2_2_2=SELECT OBJECT_NAME(major_id) AS TableName, USER_NAME(grantee_principal_id) AS UserName, permission_name AS Permission FROM master.sys.database_permissions WHERE class = 1 AND major_id IN (SELECT object_id FROM master.sys.objects WHERE type = 'S') AND USER_NAME(grantee_principal_id) IN ('public', 'guest');"
echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
echo --------------------- 구버전 ---------------------  >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query2_2_1%" >> %COMPUTERNAME%_mssql.txt
echo --------------------- 신버전 ---------------------  >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query2_2_2%" >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-12. 안전한 리스너 비밀번호 설정 및 사용 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo MSSQL은 해당사항 없음 >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-13. 불필요한 ODBC/OLE-DB 데이터 소스와 드라이브를 제거하여 사용 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo 해당 점검 항목은 윈도우 서버 점검 항목으로 점검이 되고 있으므로 예외처리함 >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-14. 데이터베이스의 주요 설정 파일, 비밀번호 파일 등과 주요 파일들의 접근 권한이 적절하게 설정 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo Unix 점검항목으로 해당사항 없음   >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-15. 관리자 이외의 사용자가 오라클 리스너의 접속을 통해 리스너 로그 및 trace 파일에 대한 변경 제한 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo MSSQL은 해당사항 없음   >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-16. Windows 인증 모드 사용 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo sa 계정 비활성화 및 Windows 인증 모드 사용하는 경우 양호 >> %COMPUTERNAME%_mssql.txt
echo sa 계정 활성화시 강력한 암호 정책 되어있는 경우 양호 >> %COMPUTERNAME%_mssql.txt
set "query16= SELECT SERVERPROPERTY('IsIntegratedSecurityOnly') AS WindowsAuthOnly;"
set "query16_2=SELECT *  from sys.sql_logins WHERE name = 'sa';"
%commonCMD% -Q "%query16%" >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query16_2%" >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-17. Audit Table은 데이터베이스 관리자 계정으로 접근하도록 제한 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo MSSQL은 해당사항 없음   >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-18. 응용프로그램 또는 DBA 계정의 Role이 Public으로 설정되지 않도록 조정 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo MSSQL은 해당사항 없음   >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-19. OS_ROLES, REMOTE_OS_AUTHENTICATION, REMOTE_OS_ROLES를 FALSE로 설정 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo MSSQL은 해당사항 없음   >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-20. 인가되지 않은 Object Owner의 제한 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo MSSQL은 해당사항 없음   >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-21. 인가되지 않은 GRANT OPTION 사용 제한 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo MSSQL은 해당사항 없음   >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-22. 데이터베이스의 자원 제한 기능을 TRUE로 설정 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo MSSQL은 해당사항 없음   >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-23. xp_cmdshell 사용 제한 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
set "query23= SELECT name, value_in_use FROM sys.configurations WHERE name = 'xp_cmdshell';"
%commonCMD% -Q "%query23%" >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo D-24. Registry Procedure 권한 제한 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
set "query24=SELECT OBJECT_NAME(major_id) AS ProcedureName, USER_NAME(grantee_principal_id) AS UserName, permission_name AS Permission, state_desc AS State FROM sys.database_permissions WHERE OBJECT_NAME(major_id) IN ('xp_regaddmultistring','xp_regdeletekey','xp_regdeletevalue','xp_regenumvalues','xp_regread','xp_regremovemultistring','xp_regwrite') AND USER_NAME(grantee_principal_id)='public' AND class=1 ORDER BY OBJECT_NAME(major_id);"
%commonCMD% -Q "%query24%" >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo  D-25. 주기적 보안 패치 및 벤더 권고 사항 적용 >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo ----------------------------------------------------------------------------------------->> %COMPUTERNAME%_mssql.txt
echo 참고 server 2019(cu32) : 15.0.4430.1, KB5054833 >> %COMPUTERNAME%_mssql.txt
echo 참고 server 2019(cu32+GDR) : 15.0.4455.2, KB5068404 >> %COMPUTERNAME%_mssql.txt
echo 참고 server 2022(cu23) : 16.0.4235.2, KB5074819 >> %COMPUTERNAME%_mssql.txt
echo 참고 server 2022(cu22+GDR) : 16.0.4230.2, KB5072936 >> %COMPUTERNAME%_mssql.txt
echo 참고 server 2025(cu1) : 17.0.4005.7, KB5074901 >> %COMPUTERNAME%_mssql.txt
echo 참고 server 2025(cu1+GDR) : 17.0.1050.2	, KB5073177 >> %COMPUTERNAME%_mssql.txt
echo ----------------------------------------------------------------------------------------->> %COMPUTERNAME%_mssql.txt
set "query4_1_1= select @@version"
set "query4_1_2= SELECT SERVERPROPERTY('ProductVersion') AS ProductVersion, SERVERPROPERTY('ProductUpdateLevel') AS ProductUpdateLevel, SERVERPROPERTY('ProductUpdateReference') AS KB;"
echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
echo --------------------- 구버전 ---------------------  >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query4_1_1%" >> %COMPUTERNAME%_mssql.txt
echo --------------------- 신버전 ---------------------  >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query4_1_2%" >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo  D-26 데이터베이스의 접근, 변경, 삭제 등의 감사기록이 기관의 감사기록 정책에 적합하도록 설정  >> %COMPUTERNAME%_mssql.txt
echo [START] >> %COMPUTERNAME%_mssql.txt
echo AuditLevel 값이 0 아닐경우 양호 >> %COMPUTERNAME%_mssql.txt
echo 없음 = 0  >> %COMPUTERNAME%_mssql.txt
echo 실패한 로그인만 = 2  >> %COMPUTERNAME%_mssql.txt
echo 성공한 로그인만 = 1  >> %COMPUTERNAME%_mssql.txt
echo 실패한 로그인과 성공한 로그인 모두 = 3  >> %COMPUTERNAME%_mssql.txt
echo ----------------------------------------------------------------------------------------->> %COMPUTERNAME%_mssql.txt
set "query4_2_1= DECLARE @AuditLevel int EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'AuditLevel', @AuditLevel OUTPUT SELECT CASE WHEN @AuditLevel = 0 THEN 'None' WHEN @AuditLevel = 1 THEN 'Successful logins only' WHEN @AuditLevel = 2 THEN 'Failed logins only' WHEN @AuditLevel = 3 THEN 'Both failed and successful logins' END AS [AuditLevel]"
set "query4_2_2_1= SELECT name, is_state_enabled FROM sys.server_audits"
set "query4_2_2_2= SELECT * FROM sys.dm_exec_sessions WHERE is_user_process = 1"
echo ------------------------------------------------------>> %COMPUTERNAME%_mssql.txt
echo --------------------- 구버전 ---------------------  >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query4_2_1%" >> %COMPUTERNAME%_mssql.txt
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server" /s | find "AuditLevel" >> %COMPUTERNAME%_mssql.txt
echo --------------------- 신버전 ---------------------  >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query4_2_2_1%" >> %COMPUTERNAME%_mssql.txt
%commonCMD% -Q "%query4_2_2_2%" >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt
echo [END] >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo --- End Time ---------------------------------------------------------------------- >> %COMPUTERNAME%_mssql.txt
type local_security_policy.txt >> %COMPUTERNAME%_mssql.txt
del local_security_policy.txt 2>nul
del password_policy.cfg 2>nul
date /t >> %COMPUTERNAME%_mssql.txt
time /t >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo 잠금 임계값, 잠금 기간 설정 >> %COMPUTERNAME%_mssql.txt
net accounts  >> %COMPUTERNAME%_mssql.txt
echo. >> %COMPUTERNAME%_mssql.txt

echo ---------------------------------------------------- >> %COMPUTERNAME%_mssql.txt
echo            스크립트가 정상 종료되었습니다. >> %COMPUTERNAME%_mssql.txt
echo ---------------------------------------------------- >> %COMPUTERNAME%_mssql.txt
echo.
echo ----------------------------------------------------
echo            스크립트가 정상 종료되었습니다.
echo ----------------------------------------------------
echo.
REM ==================================================
REM ==================================================
