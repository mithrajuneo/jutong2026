#!/usr/bin/env bash
# https://github.com/mithrajuneo/jutong2026

LANG=C
export LANG

HOSTNAME=`hostname`

echo "***************************************************************"
echo "*                                                             *"
echo "*   PostgreSQL Security 주요정보통신기반시설 Checklist           *"
echo "*                                                             *"
echo "***************************************************************"
echo "*                                                        		*"
echo "*    JEONGJUNEHYUCK Copyright 2026.  all rights reserved.     *"
echo "*                                                             *"
echo "***************************************************************"

# 1. 패키지 설치 경로 검색
find /var/lib/pgsql -maxdepth 3 -type f -name PG_VERSION 2>/dev/null | while read path
do
    datadir=$(dirname "$path")
    version=$(cat "$path")
    port=$(grep "^port" $datadir/postgresql.conf 2>/dev/null | awk '{print $3}' | tr -d "'")
    echo "[PostgreSQL $version - 팩키지 설치 경로 확인]"
    echo "Data Directory : $datadir"
    [ ! -z "$port" ] && echo "Port: $port"
    echo ""
done

# 2. 프로세스에서 실행 중인 PostgreSQL 확인
echo "현재 실행 중인 PostgreSQL 프로세스:"
ps -ef | grep "^postgres" | grep "\-D" | grep -v grep | while read line
do
    #echo "$line"
    # 데이터 디렉토리 추출
    datadir=$(echo "$line" | grep -o '\-D [^ ]*' | awk '{print $2}')
    if [ ! -z "$datadir" ] && [ -f "$datadir/PG_VERSION" ]; then
        version=$(cat "$datadir/PG_VERSION")
        port=$(grep "^port" $datadir/postgresql.conf 2>/dev/null | awk '{print $3}' | tr -d "'" | tr -d ' ')
        echo "프로세스에서 Data Directory 확인 : $datadir, Port: ${port:-5432}"
    fi
done
echo "******************************************************************************************"
echo "Data Directory 기준으로 인스턴스(Port 단위) 별로 스크립트 재점검하여 결과 파일 전달 요청드립니다."
echo "******************************************************************************************"


echo -n "PostgreSQL Data Directory 입력 : "
read postgresql_DATA
postgresql_DATA=${postgresql_DATA%/}

echo -n "PostgreSQL 포트번호 입력 (예: 5432) : "
read postgresql_PORT

echo -n "PostgreSQL 관리자 ID 입력 (예: postgres) : "
read postgresql_ID

echo -n "PostgreSQL 관리자 ID의 비밀번호 입력(없으면 enter) "
read postgresql_PASS

if [ "$postgresql_PORT" = "5432" ]; then
    HOST_OPTION=""
else
    HOST_OPTION="-h localhost"
fi


#su - $postgresql_ID -c "psql -p $postgresql_PORT -c '\du'"
echo ""

#echo -n "PostgreSQL 점검 DB명 입력  (예: postgres) : "
#read postgresql_DBname

postgres_DATA_SAFE=${postgresql_DATA//\//_}

OUTPUT_FILE="./${HOSTNAME}_psql${postgres_DATA_SAFE}.txt"

echo "☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆" > $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

echo "관리자 ID" >> $OUTPUT_FILE
echo $postgresql_ID >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo "입력한 Port" >> $OUTPUT_FILE
echo $postgresql_PORT >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo "입력한 Data Directory" >> $OUTPUT_FILE
echo $postgresql_DATA >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

#echo "" >> $OUTPUT_FILE
#echo "입력한 DBname" >> $OUTPUT_FILE
#echo $postgresql_DBname >> $OUTPUT_FILE
#echo "" >> $OUTPUT_FILE


echo "DB 접속 테스트(DATABASE LIST 출력)" >> $OUTPUT_FILE
if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'SELECT * FROM pg_database'" >> $OUTPUT_FILE
else
	su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'SELECT * FROM pg_database'" >> $OUTPUT_FILE
fi

echo " " >> $OUTPUT_FILE
echo "☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

# D-01
echo "D-01 기본 계정의 패스워드, 정책 등을 변경하여 사용"
echo "D-01 기본 계정의 패스워드, 정책 등을 변경하여 사용" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "판단 기준 : 초기 비밀번호를 변경하지 않고(패스워드가 null) 사용하고 있는 경우 취약으로 판단" >> $OUTPUT_FILE
echo "판단 방법 : DB 기본 계정의 디폴트 비밀번호 사용 여부를 점검" >> $OUTPUT_FILE
echo "인터뷰 필요" >> $OUTPUT_FILE
echo "-----------------------------------------------------------------------------------------" >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c 'select * from pg_shadow'" >> $OUTPUT_FILE

if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select * from pg_shadow'"  >> $OUTPUT_FILE
else
	su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select * from pg_shadow'"  >> $OUTPUT_FILE
fi

echo "[END]" >> $OUTPUT_FILE

# D-02
echo "D-02 데이터베이스의 불필요 계정을 제거하거나, 잠금설정 후 사용"
echo "D-02 데이터베이스의 불필요 계정을 제거하거나, 잠금설정 후 사용" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "판단 기준 : 기본 계정 외에 용도가 불분명한 계정이 존재하는 경우 취약으로 판단" >> $OUTPUT_FILE
echo "판단 방법 : DB관리나 운용에 사용하지 않는 불필요한 계정이 존재하는지 여부를 점검" >> $OUTPUT_FILE
echo "인터뷰 필요" >> $OUTPUT_FILE
echo "-----------------------------------------------------------------------------------------" >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c 'select * from pg_shadow'" >> $OUTPUT_FILE

if [ -z "$postgresql_PASS" ]; then
	su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select * from pg_shadow'"  >> $OUTPUT_FILE
else
    su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select * from pg_shadow'"  >> $OUTPUT_FILE
fi

echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

# D-03
echo "D-03 패스워드의 사용기간 및 복잡도를 기관 정책에 맞도록 설정"
echo "D-03 패스워드의 사용기간 및 복잡도를 기관 정책에 맞도록 설정" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "판단 기준 : 사용자 계정에 대한 비밀번호를 주기적(분기별 1회 이상)으로 변경하고 있지 않을 경우 취약으로 판단" >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c 'select rolname, rolvaliduntil from pg_authid'" >> $OUTPUT_FILE

if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select rolname, rolvaliduntil from pg_authid'"  >> $OUTPUT_FILE
else
    su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select rolname, rolvaliduntil from pg_authid'"  >> $OUTPUT_FILE
fi

echo "-----------------------------------------------------------------------------------------" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

# D-04
echo "D-04 데이터베이스의 관리자 권한을 꼭 필요한 계정 및 그룹에 허용"
echo "D-04 데이터베이스의 관리자 권한을 꼭 필요한 계정 및 그룹에 허용" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "판단 기준 : DBA권한이 불필요한 계정에게 설정되어 있는 경우 취약으로 판단" >> $OUTPUT_FILE
echo "판단 방법 : 관리자 권한이 필요한 계정 및 그룹에만 관리자 권한을 부여하였는지 여부를 점검" >> $OUTPUT_FILE
echo "-----------------------------------------------------------------------------------------" >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c '\du'" >> $OUTPUT_FILE
echo "1. 계정 리스트 출력(du)"  >> $OUTPUT_FILE
if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c '\du'"  >> $OUTPUT_FILE
else
	su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c '\du'"  >> $OUTPUT_FILE
fi

echo "2. 계정 권한 확인(pg_roles)"  >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c 'select * from pg_roles'" >> $OUTPUT_FILE
if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select * from pg_roles'"  >> $OUTPUT_FILE
else
	su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select * from pg_roles'"  >> $OUTPUT_FILE
fi

echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#D-05
echo "D-05 비밀번호 재사용에 대한 제약 설정"
echo "D-05 비밀번호 재사용에 대한 제약 설정" >> $OUTPUT_FILE
echo "-----------------------------------------------------------------------------------------" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#D-06
echo "D-06 DB 사용자 계정을 개별적으로 부여하여 사용"
echo "D-06 DB 사용자 계정을 개별적으로 부여하여 사용" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "판단 기준 : 공용 계정을 사용하고 있는 경우 취약으로 판단" >> $OUTPUT_FILE
echo "판단 방법 : DB 접근 시 사용자 별로 서로 다른 계정을 사용하여 접근하는지 여부를 점검" >> $OUTPUT_FILE
echo "1. 접속 현황 점검"  >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c 'select usename, client_addr, datname, application_name from pg_stat_activity'" >> $OUTPUT_FILE
if [ -z "$postgresql_PASS" ]; then
	su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select usename, client_addr, datname, application_name from pg_stat_activity'"  >> $OUTPUT_FILE
else
    su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select usename, client_addr, datname, application_name from pg_stat_activity'"  >> $OUTPUT_FILE
fi

echo "2. 계정 목록 점검"  >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c 'select rolname, rolsuper, rolcanlogin from pg_roles where rolcanlogin = true'" >> $OUTPUT_FILE
if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select rolname, rolsuper, rolcanlogin from pg_roles where rolcanlogin = true'"  >> $OUTPUT_FILE
else
	su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select rolname, rolsuper, rolcanlogin from pg_roles where rolcanlogin = true'"  >> $OUTPUT_FILE
fi


echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#D-07
echo "D-07 root 권한으로 서비스 구동 제한"
echo "D-07 root 권한으로 서비스 구동 제한" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "판단 기준 : DBMS가 root 계정 또는 root 권한으로 구동되고 있는 경우 취약으로 판단" >> $OUTPUT_FILE
echo "1. postgres 서비스 구동 계정 확인"  >> $OUTPUT_FILE
ps -ef | grep postgres | grep -v grep >> $OUTPUT_FILE
echo [END] >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#D-08
echo "D-08 안전한 암호화 알고리즘 사용"
echo "D-08 안전한 암호화 알고리즘 사용" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "판단 기준 : SHA-256 미만의 암호화 알고리즘 사용하는 경우 취약으로 판단" >> $OUTPUT_FILE
echo "참고 : default 설정으로 SCRAM-SHA-256 암호화 알고리즘 적용 되어있음" >> $OUTPUT_FILE
echo "-----------------------------------------------------------------------------------------" >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c 'select * from pg_shadow'" >> $OUTPUT_FILE

if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select * from pg_shadow'"  >> $OUTPUT_FILE
else

	su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'select * from pg_shadow'"  >> $OUTPUT_FILE
fi

echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#D-09
echo "D-09 일정 횟수의 로그인 실패 시에 이에 대한 잠금정책 설정"
echo "D-09 일정 횟수의 로그인 실패 시에 이에 대한 잠금정책 설정" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음"  >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#D-10
echo "D-10 원격에서 DB 서버로의 접속 제한"
echo "D-10 원격에서 DB 서버로의 접속 제한" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE

if [ -f $postgresql_DATA/postgresql.conf ]; then
	echo "1. 현황 : postgresql.conf 파일 내 DB 접속 제한 설정 확인" >> $OUTPUT_FILE
    grep -n -C 7 'listen_addresses' $postgresql_DATA/postgresql.conf >> $OUTPUT_FILE
else
    echo "$postgresql_DATA/postgresql.conf 파일 없음" >> $OUTPUT_FILE
fi

echo " " >> $OUTPUT_FILE

if [ -f $postgresql_DATA/pg_hba.conf ]; then
	echo "2. 현황 : pg_hba.conf 파일 내 DB 접속 제한 설정 확인" >> $OUTPUT_FILE
    cat $postgresql_DATA/pg_hba.conf >> $OUTPUT_FILE
else
    echo "$postgresql_DATA/pg_hba.conf 파일 없음" >> $OUTPUT_FILE
fi
echo " " >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#11
echo "D-11 DBA 이외의 인가되지 않은 사용자가 시스템 테이블에 접근할 수 없도록 설정" 
echo "D-11 DBA 이외의 인가되지 않은 사용자가 시스템 테이블에 접근할 수 없도록 설정" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "판단 기준 : DBA만 접근 가능한 테이블에 일반 사용자 접근이 가능한 경우 취약으로 판단" >> $OUTPUT_FILE
echo "판단 방법 : 시스템 테이블에 일반 사용자 계정 접근 가능 여부를 점검" >> $OUTPUT_FILE
echo "액세스 권한부분을 확인해서 아무것도 없다면 일반 사용자(superuser가 아닌 사용자)는 접근이 불가함"  >> $OUTPUT_FILE
echo "액세스 권한부분을 확인해서 불필요한 정책이 있는지 확인 필요" >> $OUTPUT_FILE
echo "---- *참고* 테이블 권한 ----" >> $OUTPUT_FILE
echo "SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
echo "-----------------------------------------------------------------------------------------" >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c '\dp'" >> $OUTPUT_FILE

if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c '\dp'"  >> $OUTPUT_FILE
else
	su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c '\dp'"  >> $OUTPUT_FILE
fi


echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#12
echo "D-12 안전한 리스너 비밀번호 설정 및 사용"
echo "D-12 안전한 리스너 비밀번호 설정 및 사용" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE 
echo " " >> $OUTPUT_FILE

#13
echo "D-13 불필요한 ODBC/OLE-DB 데이터 소스와 드라이브를 제거하여 사용"
echo "D-13 불필요한 ODBC/OLE-DB 데이터 소스와 드라이브를 제거하여 사용" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#14
echo "D-14 데이터베이스의 주요 설정 파일, 비밀번호 파일 등과 같은 주요 파일들의 접근 권한이 적절하게 설정"
echo "D-14 데이터베이스의 주요 설정 파일, 비밀번호 파일 등과 같은 주요 파일들의 접근 권한이 적절하게 설정" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "참고 : postgresql.conf, pg_hba.conf, pg_ident.conf, log파일 640 " >> $OUTPUT_FILE
echo "참고 : psql_history 600 " >> $OUTPUT_FILE
ls -alL "$postgresql_DATA" | grep postgresql.conf >> $OUTPUT_FILE
ls -alL "$postgresql_DATA" | grep pg_hba.conf >> $OUTPUT_FILE
ls -alL "$postgresql_DATA" | grep pg_ident.conf >> $OUTPUT_FILE
ls -alL "$postgresql_DATA/log" | grep log >> $OUTPUT_FILE

if [ -f /var/lib/pgsql/.psql_history ]; then
    ls -alL /var/lib/pgsql/.psql_history | grep psql_history >> $OUTPUT_FILE
else
    echo "/var/lib/pgsql/.psql_history 파일 없음" >> $OUTPUT_FILE
fi

echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#15
echo "D-15 관리자 이외의 사용자가 오라클 리스너의 접속을 통해 리스너 로그 및 trace 파일에 대한 변경 제한"
echo "D-15 관리자 이외의 사용자가 오라클 리스너의 접속을 통해 리스너 로그 및 trace 파일에 대한 변경 제한" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#16
echo "D-16 Windows 인증 모드 사용"
echo "D-16 Windows 인증 모드 사용" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#17
echo "D-17 Audit Table은 데이터베이스 관리자 계정으로 접근하도록 제한"
echo "D-17 Audit Table은 데이터베이스 관리자 계정으로 접근하도록 제한" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#18
echo "D-18 응용프로그램 또는 DBA 계정의 Role이 Public으로 설정되지 않도록 설정"
echo "D-18 응용프로그램 또는 DBA 계정의 Role이 Public으로 설정되지 않도록 설정" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE 
echo " " >> $OUTPUT_FILE

#19
echo "D-19 OS_ROLES, REMOTE_OS AUTHENTICATION, REMOTE_OS_ROLES를 False로 설정"
echo "D-19 OS_ROLES, REMOTE_OS AUTHENTICATION, REMOTE_OS_ROLES를 False로 설정" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE 
echo " " >> $OUTPUT_FILE

#20
echo "D-20 인가되지 않은 Object Owner의 제한"
echo "D-20 인가되지 않은 Object Owner의 제한" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "판단 기준 : 권한 없는 유저가 오브젝트(테이블 등)을 가지고 있으면 취약"  >> $OUTPUT_FILE
echo "chatgpt 버전"  >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c 'select c.relname, r.rolname FROM pg_class c JOIN pg_roles r ON c.relowner = r.oid where r.rolsuper = false'" >> $OUTPUT_FILE

if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c \"select c.relname, r.rolname FROM pg_class c JOIN pg_roles r ON c.relowner = r.oid where r.rolsuper = false\""  >> $OUTPUT_FILE
else
    su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c \"select c.relname, r.rolname FROM pg_class c JOIN pg_roles r ON c.relowner = r.oid where r.rolsuper = false\""  >> $OUTPUT_FILE
fi

echo "claude code 버전"  >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c \"SELECT c.relname AS object_name, CASE c.relkind WHEN 'r' THEN 'TABLE' WHEN 'i' THEN 'INDEX' WHEN 'S' THEN 'SEQUENCE' WHEN 'v' THEN 'VIEW' WHEN 'm' THEN 'MATERIALIZED VIEW' WHEN 'f' THEN 'FOREIGN TABLE' WHEN 'p' THEN 'PARTITIONED TABLE' ELSE c.relkind::text END AS object_type, r.rolname AS owner, n.nspname AS schema FROM pg_class c JOIN pg_roles r ON c.relowner = r.oid JOIN pg_namespace n ON c.relnamespace = n.oid WHERE r.rolsuper = false AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast') AND c.relkind IN ('r', 'v', 'm', 'S', 'f', 'p') ORDER BY schema, object_type, object_name;\"" >> $OUTPUT_FILE

if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c \"SELECT c.relname AS object_name, CASE c.relkind WHEN 'r' THEN 'TABLE' WHEN 'i' THEN 'INDEX' WHEN 'S' THEN 'SEQUENCE' WHEN 'v' THEN 'VIEW' WHEN 'm' THEN 'MATERIALIZED VIEW' WHEN 'f' THEN 'FOREIGN TABLE' WHEN 'p' THEN 'PARTITIONED TABLE' ELSE c.relkind::text END AS object_type, r.rolname AS owner, n.nspname AS schema FROM pg_class c JOIN pg_roles r ON c.relowner = r.oid JOIN pg_namespace n ON c.relnamespace = n.oid WHERE r.rolsuper = false AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast') AND c.relkind IN ('r', 'v', 'm', 'S', 'f', 'p') ORDER BY schema, object_type, object_name;\""  >> $OUTPUT_FILE
else
	su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c \"SELECT c.relname AS object_name, CASE c.relkind WHEN 'r' THEN 'TABLE' WHEN 'i' THEN 'INDEX' WHEN 'S' THEN 'SEQUENCE' WHEN 'v' THEN 'VIEW' WHEN 'm' THEN 'MATERIALIZED VIEW' WHEN 'f' THEN 'FOREIGN TABLE' WHEN 'p' THEN 'PARTITIONED TABLE' ELSE c.relkind::text END AS object_type, r.rolname AS owner, n.nspname AS schema FROM pg_class c JOIN pg_roles r ON c.relowner = r.oid JOIN pg_namespace n ON c.relnamespace = n.oid WHERE r.rolsuper = false AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast') AND c.relkind IN ('r', 'v', 'm', 'S', 'f', 'p') ORDER BY schema, object_type, object_name;\""  >> $OUTPUT_FILE
fi

echo "[END]" >> $OUTPUT_FILE 
echo " " >> $OUTPUT_FILE

#21
echo "D-21 인가되지 않은 GRANT OPTION 사용제한"
echo "D-21 인가되지 않은 GRANT OPTION 사용제한" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#22
echo "D-22 데이터베이스의 자원 제한 기능을 TRUE로 설정"
echo "D-22 데이터베이스의 자원 제한 기능을 TRUE로 설정" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#23
echo "D-23 xp_cmdshell 사용 제한"
echo "D-23 xp_cmdshell 사용 제한" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#24
echo "D-24 Registry Procedure 권한 제한"
echo "D-24 Registry Procedure 권한 제한" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "postgreSQL 해당사항 없음" >> $OUTPUT_FILE
echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#25
echo "D-25 데이터베이스에 대해 최신 보안패치와 벤더 권고사항을 모두 적용"
echo "D-25 데이터베이스에 대해 최신 보안패치와 벤더 권고사항을 모두 적용" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "판단 기준 : 보안 패치가 적용된 버전을 사용하는 경우" >> $OUTPUT_FILE
echo "----------------------------------------------------" >> $OUTPUT_FILE
echo "PostgreSQL 18.1		2025-11-13" >> $OUTPUT_FILE
echo "PostgreSQL 17.2		2025-11-13" >> $OUTPUT_FILE
echo "PostgreSQL 16.11	2025-11-13" >> $OUTPUT_FILE
echo "PostgreSQL 15.15	2025-11-13" >> $OUTPUT_FILE
echo "PostgreSQL 14.20	2025-11-13" >> $OUTPUT_FILE
echo "PostgreSQL 14.10	2023-11-09" >> $OUTPUT_FILE
echo "PostgreSQL 13 이하버전 EOS" >> $OUTPUT_FILE
echo "----------------------------------------------------" >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -c 'SHOW server_version'" >> $OUTPUT_FILE

if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'SHOW server_version'"  >> $OUTPUT_FILE
else
	su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'SHOW server_version'"  >> $OUTPUT_FILE
fi


echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#26
echo "D-26 데이터베이스의 접근, 변경, 삭제 등의 감사 기록이 기관의 감사 기록 정책에 적합하도록 설정"
echo "D-26 데이터베이스의 접근, 변경, 삭제 등의 감사 기록이 기관의 감사 기록 정책에 적합하도록 설정" >> $OUTPUT_FILE
echo "[START]" >> $OUTPUT_FILE
echo "판단 기준 : 기본 감사 기능이 미실행 중이거나, 감사로그에 대한 백업을 실시하지 않을 경우 취약으로 판단" >> $OUTPUT_FILE
echo "판단 방법 : 감사기록 정책 설정이 적합하게 설정되어 있는지 여부를 점검" >> $OUTPUT_FILE
echo "1. 현황 : logging_collector가 on으로 되어있으면 양호" >> $OUTPUT_FILE
#su - $postgresql_ID -c "psql -h localhost -p $postgresql_PORT -d \"$postgresql_DBname\" -c 'show logging_collector'" >> $OUTPUT_FILE

if [ -z "$postgresql_PASS" ]; then
    su - "$postgresql_ID" -c "psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'SHOW logging_collector'"  >> $OUTPUT_FILE
else
	su - "$postgresql_ID" -c "PGPASSWORD='$postgresql_PASS' psql ${HOST_OPTION} -p ${postgresql_PORT} -c 'SHOW logging_collector'"  >> $OUTPUT_FILE
fi

echo " " >> $OUTPUT_FILE

if [ -f $postgresql_DATA/postgresql.conf ]; then
	echo "2. 현황 : postgresql.conf 파일 내 로깅 설정 확인" >> $OUTPUT_FILE
    cat $postgresql_DATA/postgresql.conf | grep 'logging_collector =' >> $OUTPUT_FILE
else
    echo "$postgresql_DATA/postgresql.conf 파일 없음" >> $OUTPUT_FILE
fi

echo "[END]" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

#홈 디렉터리 내 파일 조회
echo "======== home directory  =========" >> $OUTPUT_FILE
ls -alL $postgresql_DATA >> $OUTPUT_FILE
echo "==================================================" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

#postgresql.conf 조회(메인 설정 파일)
echo "======== postgresql.sql 파일 =========" >> $OUTPUT_FILE
cat $postgresql_DATA/postgresql.conf >> $OUTPUT_FILE
echo "==================================================" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
# END 메시지
echo "==============================================================="
echo "PostgreSQL Security Check END"
echo ""
echo "PostgreSQL 스크립트 작업이 완료되었습니다."
echo ""
echo "스크립트 결과 파일을 보안담당자에게 전달 바랍니다."
echo ""
echo "감사합니다."