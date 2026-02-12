#!/usr/bin/env bash
# https://github.com/mithrajuneo/jutong2026

OS=`uname`

echo "***************************************************************"
echo "*                                                             *"
echo "*   Unix/Linux + Apache Security 주요정보통신기반시설 Checklist  *"
echo "*                                                             *"
echo "***************************************************************"
echo "*                                                        		*"
echo "*    JEONGJUNEHYUCK Copyright 2026.  all rights reserved.     *"
echo "*                                                             *"
echo "***************************************************************"

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



if [ $OS = SunOS ]
	then
		IP=`ifconfig -a | grep broadcast | cut -f 2 -d ' '`
fi

if [ $OS = HP-UX ]
	then
		IP=`ifconfig lan0 | grep broadcast | cut -f 2 -d ' '`
fi

LANG=C
export LANG

alias ls=ls

CREATE_FILE=`hostname`"_"$OS"_"`date +%y%m%d%H%M`.txt
CHECK_FILE=`ls ./"$CREATE_FILE" 2>/dev/null | wc -l`

perm_check() {
    unset FUNC_FILE
    unset PERM
    unset NUM
    unset PERM_CHECK
    unset OWNER_FUNC_RESULT
    unset PERM_FUNC_RESULT
    unset VALUE

    FUNC_FILE=$1
    PERM=`ls -al $FUNC_FILE | awk '{print $1}'`
    OWNER_FUNC_RESULT=`ls -al $FUNC_FILE | awk '{print $3}'`
    PERM=`expr "$PERM" : '.\(.*\)' | sed -e "s/-/A/g"`;

    while :
    do
        NUM=`echo $PERM | awk '{print length($0)}'`

        if [ $NUM -eq 0 ]
            then
                break
        fi

        PERM_CHECK=`expr "$PERM" : '\(...\).*'`
        PERM=`expr "$PERM" : '...\(.*\)'`

        if [ "$PERM_CHECK" = "rwx" -o "$PERM_CHECK" = "rws" -o "$PERM_CHECK" = "rwS" ]
            then
                VALUE="7"
        fi

        if [ "$PERM_CHECK" = "rwA" ]
            then
                VALUE="6"
        fi

        if [ "$PERM_CHECK" = "rAx" -o "$PERM_CHECK" = "rAs" -o "$PERM_CHECK" = "rAS" ]
            then
                VALUE="5"
        fi

        if [ "$PERM_CHECK" = "rAA" ]
            then
                VALUE="4"
        fi

        if [ "$PERM_CHECK" = "Awx" -o "$PERM_CHECK" = "Aws" -o "$PERM_CHECK" = "AwS" ]
            then
                VALUE="3"
        fi

        if [ "$PERM_CHECK" = "AwA" ]
            then
                VALUE="2"
        fi

        if [ "$PERM_CHECK" = "AAx" -o "$PERM_CHECK" = "AAs" -o "$PERM_CHECK" = "AAS" ]
            then
                VALUE="1"
        fi

        if [ "$PERM_CHECK" = "AAA" ]
            then
                VALUE="0"
        fi

        PERM_FUNC_RESULT=$PERM_FUNC_RESULT" "$VALUE
    done

    PERM_FUNC_RESULT=$PERM_FUNC_RESULT" "$OWNER_FUNC_RESULT

    return
}

perm_check_dir() {
    unset FUNC_FILE
    unset PERM
    unset OWNER_FUNC_RESULT
    unset NUM
    unset PERM_CHECK
    unset PERM_FUNC_RESULT
    unset VALUE

    FUNC_FILE=$1

    PERM=`ls -alLd $FUNC_FILE | awk '{print $1}'`
    OWNER_FUNC_RESULT=`ls -alLd $FUNC_FILE | awk '{print $3}'`
    PERM=`expr "$PERM" : '.\(.*\)' | sed -e "s/-/A/g"`

    while :
    do
        NUM=`echo $PERM | awk '{print length($0)}'`

        if [ $NUM -eq 0 ]
            then
                break
        fi

        PERM_CHECK=`expr "$PERM" : '\(...\).*'`
        PERM=`expr "$PERM" : '...\(.*\)'`

        if [ "$PERM_CHECK" = "rwx" -o "$PERM_CHECK" = "rws" -o "$PERM_CHECK" = "rwS" ]
            then
                VALUE="7"
        fi

        if [ "$PERM_CHECK" = "rwA" ]
            then
                VALUE="6"
        fi

        if [ "$PERM_CHECK" = "rAx" -o "$PERM_CHECK" = "rAs" -o "$PERM_CHECK" = "rAS" ]
            then
                VALUE="5"
        fi

        if [ "$PERM_CHECK" = "rAA" ]
            then
                VALUE="4"
        fi

        if [ "$PERM_CHECK" = "Awx" -o "$PERM_CHECK" = "Aws" -o "$PERM_CHECK" = "AwS" ]
            then
                VALUE="3"
        fi

        if [ "$PERM_CHECK" = "AwA" ]
            then
                VALUE="2"
        fi

        if [ "$PERM_CHECK" = "AAx" -o "$PERM_CHECK" = "AAs" -o "$PERM_CHECK" = "AAS" ]
            then
                VALUE="1"
        fi

        if [ "$PERM_CHECK" = "AAA" ]
            then
                VALUE="0"
        fi

        PERM_FUNC_RESULT=$PERM_FUNC_RESULT" "$VALUE
    done

    PERM_FUNC_RESULT=$PERM_FUNC_RESULT" "$OWNER_FUNC_RESULT

    return
}
echo " "
echo " "
echo > $CREATE_FILE 2>&1
echo "                              Copyright 2026, JEONGJUNEHYUCK All right Reserved"
#echo "                              Copyright 2026, JEONGJUNEHYUCK All right Reserved" >> $CREATE_FILE 2>&1

echo " "
echo "----------------------------------------------------------------------------------------------------"
echo "---------------------------------------   진단 전 주의사항    --------------------------------------"
echo "---------------------------   반드시 Super 유저 권한에서 진단을 시작해야 합니다!   -----------------"
echo "----------------------------------------------------------------------------------------------------"
echo " "
echo " "
echo " "
echo "                      ==========================================================="
echo "                      ==============   UNIX/Linux Security Check   =============="
echo "                      ==========================================================="
echo " "
echo " "
echo "==========================" >> $CREATE_FILE 2>&1
echo "UNIX/Linux Security Check" >> $CREATE_FILE 2>&1
echo "==========================" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "****************************************************************************************************"
echo "****************************************   INFO_CHKSTART   *****************************************"
echo "****************************************************************************************************"
echo " "
echo " "

#echo " " >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1
#echo "****************************************************************************************************" >> $CREATE_FILE 2>&1
#echo "****************************************   INFO_CHKSTART   *****************************************" >> $CREATE_FILE 2>&1
#echo "****************************************************************************************************" >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1

echo "------------------------------------------   Start Time   ------------------------------------------"
echo " "
date
echo " "
echo "----------------------------------------------------------------------------------------------------"
echo " "
echo " "
echo " "

echo "------------------------------------------   Start Time   ------------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
date >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
echo "----------------------------------------------------------------------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "                      ==========================================================="
echo "                      ===========   System Information Query Start   ============"
echo "                      ==========================================================="
echo " "
echo " "
echo " "

#echo "                      ===========================================================" >> $CREATE_FILE 2>&1
#echo "                      ===========   System Information Query Start   ===========" >> $CREATE_FILE 2>&1
#echo "                      ===========================================================" >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1

echo "--------------------------------------   Kernel Information   --------------------------------------"
echo " "
KERNEL=`uname -a` >> $CREATE_FILE 2>&1
echo $KERNEL >> $CREATE_FILE 2>&1
echo " "
echo "----------------------------------------------------------------------------------------------------"
echo " "

echo "----------------------------------------   IP Information   ----------------------------------------"
echo " "
IFCONFIG=`ifconfig -a` >> $CREATE_FILE 2>&1
echo $IFCONFIG >> $CREATE_FILE 2>&1
echo " "
echo "----------------------------------------------------------------------------------------------------"
echo "-------------------------------------   Network Status   ----------------------------------------"
echo " "
NETSTAT=`netstat -an | egrep -i "LISTEN|ESTABLISHED"` >> $CREATE_FILE 2>&1
echo $NETSTAT >> $CREATE_FILE 2>&1
echo " "
echo "----------------------------------------------------------------------------------------------------"
echo " "

echo "-------------------------------------   Routing Information   --------------------------------------"
echo " "
NETSTATR=`netstat -rn` >> $CREATE_FILE 2>&1
echo $NETSTATR >> $CREATE_FILE 2>&1
echo " "
echo "----------------------------------------------------------------------------------------------------"
echo " "

echo "---------------------------------------   Process Status   -----------------------------------------"
echo " "
PS=`ps -ef` >> $CREATE_FILE 2>&1
echo $PS >> $CREATE_FILE 2>&1
echo " "
echo "----------------------------------------------------------------------------------------------------"
echo " "

echo "------------------------------------------   User Env   --------------------------------------------"
echo " "
UE=`env`
echo $UE
echo " "
echo "----------------------------------------------------------------------------------------------------"
echo " "
echo " "
echo " "

#echo "------------------------------------------   User Env   --------------------------------------------" >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1
#env >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1
#echo "----------------------------------------------------------------------------------------------------" >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1


echo "                    ==========================================================="
echo "                    ============   System Information Query End   ============="
echo "                    ==========================================================="
echo " "
echo " "

#echo "                    ===========================================================" >> $CREATE_FILE 2>&1
#echo "                    ============   System Information Query End   =============" >> $CREATE_FILE 2>&1
#echo "                    ===========================================================" >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1

echo "****************************************************************************************************"
echo "*****************************************   INFO_CHKEND   ******************************************"
echo "****************************************************************************************************"
echo " "
echo " "

#echo "****************************************************************************************************" >> $CREATE_FILE 2>&1
#echo "*****************************************   INFO_CHKEND   ******************************************" >> $CREATE_FILE 2>&1
#echo "****************************************************************************************************" >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo " "
echo " "
#echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> $CREATE_FILE 2>&1
#echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<" >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1
#echo " " >> $CREATE_FILE 2>&1

echo "                    ==========================================================="
echo "                    ================   Security Check START   ================="
echo "                    ==========================================================="
echo " "
echo " "

echo "====================" >> $CREATE_FILE 2>&1
echo "Security Check START" >> $CREATE_FILE 2>&1
echo "====================" >> $CREATE_FILE 2>&1
echo >> $CREATE_FILE 2>&1
echo >> $CREATE_FILE 2>&1

#echo "===========================================================" >> $CREATE_FILE 2>&1
#echo "===========================================================" >> $CREATE_FILE 2>&1
#echo >> $CREATE_FILE 2>&1


echo "[U-01] root 계정 원격 접속 제한"
	echo "[U-01] root 계정 원격 접속 제한"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : 원격터미널 서비스(telnet,ssh)를 사용하지 않거나, 사용시 Root 직접 접속 차단 설정" >> $CREATE_FILE 2>&1

	case $OS in
		SunOS)
			echo "1. 현황 : ps -ef | grep telnet " >> $CREATE_FILE 2>&1
			ps -ef | grep 'telnet' | grep -v 'grep' >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : /etc/default/login 파일의 CONSOLE=/dev/console 확인(주석되어있으면 취약)" >> $CREATE_FILE 2>&1
			cat /etc/default/login | grep CONSOLE | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : ps -ef | grep ssh " >> $CREATE_FILE 2>&1
			ps -ef | grep 'ssh' | grep -v 'grep' >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4. 현황 : /etc/ssh/sshd_config 파일 내 PermitRootLogin 값 확인" >> $CREATE_FILE 2>&1
			cat /etc/ssh/sshd_config | grep PermitRootLogin | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux) ##############################수정.순서변경
			echo "판단기준 참고 : auth required pam_securetty.so (pam_faillock.so) 설정 및 pts/x 미설정시 양호" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1. 현황 : ps -ef | grep telnet " >> $CREATE_FILE 2>&1
			ps -ef | grep 'telnet' | grep -v 'grep' >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. pam_securetty.so 설정 및 pts/x 설정 확인" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-1. grep -E "pam_securetty" /etc/pam.d/login" >> $CREATE_FILE 2>&1
			grep -E "pam_securetty" /etc/pam.d/login >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			if [ -f /etc/securetty  ]
			then
				echo "2-2. grep -E "pts" /etc/securetty" >> $CREATE_FILE 2>&1
				grep -E "pts" /etc/securetty | grep -v '^#' >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "2-2. 현황 : /etc/securetty 파일 없음" >> $CREATE_FILE 2>&1
			fi
			
			echo "3. 현황 : /etc/pam.d/login 상세 내용" >> $CREATE_FILE 2>&1
			cat /etc/pam.d/login >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4. 현황 : /etc/securetty 상세 내용"  >> $CREATE_FILE 2>&1
			cat /etc/securetty >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "5. 현황 : ps -ef | grep ssh " >> $CREATE_FILE 2>&1
			ps -ef | grep 'ssh' | grep -v 'grep' >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "6. 현황 : /etc/ssh/sshd_config 상세 내용"  >> $CREATE_FILE 2>&1
			grep -E "PermitRootLogin" /etc/ssh/sshd_config  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			echo "1. 현황 : ps -ef | grep telnet " >> $CREATE_FILE 2>&1
			ps -ef | grep 'telnet' | grep -v 'grep' >> $CREATE_FILE 2>&1
			echo "2. 현황 : cat /etc/security/user 파일의 rlogin = false일때 양호" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			cat /etc/security/user >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : ps -ef | grep ssh " >> $CREATE_FILE 2>&1
			ps -ef | grep 'ssh' | grep -v 'grep' >> $CREATE_FILE 2>&1
			echo "4. 현황 : cat /etc/ssh/sshd_config 파일의 PerminitRootLogin 값 확인" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			cat /etc/ssh/sshd_config | grep 'PermitRootLogin' >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "1. 현황 : ps -ef | grep telnet " >> $CREATE_FILE 2>&1
			ps -ef | grep 'telnet' | grep -v 'grep' >> $CREATE_FILE 2>&1
			echo "2. 현황 : /etc/securetty 파일의 console 주석 미처리시 양호" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			cat /etc/securetty >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : ps -ef | grep ssh " >> $CREATE_FILE 2>&1
			ps -ef | grep 'ssh' | grep -v 'grep' >> $CREATE_FILE 2>&1
			echo "4. 현황 : /opt/ssh/etc/sshd_config 파일의 PerminitRootLogin 값 확인" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			cat /opt/ssh/etc/sshd_config | grep 'PermitRootLogin' >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac

	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-02] 비밀번호 관리정책 설정"
	echo "[U-02] 비밀번호 관리정책 설정" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : 비밀번호 8자리 이상 설정 (영문,숫자,특수문자 포함) 및 최소 사용 기간 1일, 최대 사용기간 90일, 최근 비밀번호 기억 4회 이상으로 설정시" >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			echo "*****************************************" >> $CREATE_FILE 2>&1
			echo "1. HISTORY(최근 비밀번호 기억)4회 이상 설정" >> $CREATE_FILE 2>&1
			echo "2. PASSLENGTH(패스워드 최소길이) 8자리 이상 설정" >> $CREATE_FILE 2>&1
			echo "3. MINDIGHT(숫자최소 갯수) 1이상 설정" >> $CREATE_FILE 2>&1
			echo "4. MINUPPER(알파벳 대문자 최소 갯수) 1이상 설정" >> $CREATE_FILE 2>&1
			echo "5. MINLOWER(알파벳 소문자 최소 갯수) 1이상 설정" >> $CREATE_FILE 2>&1
			echo "6. MINSPECIAL(특수문자 최소 갯수) 1이상 설정" >> $CREATE_FILE 2>&1
			echo "7. WHITESPACE(공백문자 사용) No 설정" >> $CREATE_FILE 2>&1
			echo "8. MINDAYS(비밀번호 변경 최소일수) 1 이상 설정" >> $CREATE_FILE 2>&1
			echo "*****************************************" >> $CREATE_FILE 2>&1
			echo "현황 : /etc/default/passwd" >> $CREATE_FILE 2>&1
			cat /etc/default/passwd  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "현황 : /etc/security/policy.conf"  >> $CREATE_FILE 2>&1
			cat /etc/security/policy.conf >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "******************************************************" >> $CREATE_FILE 2>&1
			echo "1. Minlen(패스워드 최소길이) 8자리 이상 설정" >> $CREATE_FILE 2>&1
			echo "2. Ucredit(숫자 입력 겂증값) -1이하 설정" >> $CREATE_FILE 2>&1
			echo "3. Dcredit(대문자 입력 겂증값) -1이하 설정" >> $CREATE_FILE 2>&1
			echo "4. Ocredit(소문자 입력 검증값) -1이하 설정" >> $CREATE_FILE 2>&1
			echo "5. Lcredit(특수문자 입력 검증값) -1이하 설정" >> $CREATE_FILE 2>&1
			echo "******************************************************" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1. 현황 : /etc/login.defs 파일 내 최소,최대 패스워드 길이 확인" >> $CREATE_FILE 2>&1
			cat /etc/login.defs | grep PASS_  | grep -v '^#' >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : /etc/security/pwquality.conf 상세 내용" >> $CREATE_FILE 2>&1
			cat /etc/security/pwquality.conf >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : /etc/security/pwhistory.conf 상세 내용" >> $CREATE_FILE 2>&1
			cat /etc/security/pwhistory.conf >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4.현황 : /etc/pam.d/system-auth 상세 내용" >> $CREATE_FILE 2>&1
			cat /etc/pam.d/system-auth  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			case "$ID" in
				ubuntu | debian | kali)
				echo "5.현황 : /etc/pam.d/common-password 상세 내용(ubuntu)" >> $CREATE_FILE 2>&1
				cat /etc/pam.d/common-password  >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				;;
			esac
			;;
		AIX)
			echo "현황 : /etc/security/user" >> $CREATE_FILE 2>&1
			cat /etc/security/user >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "현황 : /tcb/files/auth/system/default" >> $CREATE_FILE 2>&1
			cat /tcb/files/auth/system/default >> $CREATE_FILE 2>&1
			echo "현황 : /etc/default/security" >> $CREATE_FILE 2>&1
			cat /etc/default/security >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1


echo "[U-03] 계정 잠금 임계값 설정"
	echo "[U-03] 계정 잠금 임계값 설정" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : 계정 임계값이 10이하의 값으로 설정" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	cat /etc/ssh/sshd_config | grep MaxAuthTries >> $CREATE_FILE 2>&1

	case $OS in
		SunOS)
			echo "***************************************************************************************" >> $CREATE_FILE 2>&1
			echo "1. /etc/default/login 파일 내 RETRIES(계정잠금 임계)값이 10인지 확인" >> $CREATE_FILE 2>&1
			echo "2. /etc/security/policy.conf 파일 내 LOCK_AFTER_RETRIES(계정잠금)값이 YES인지 확인" >> $CREATE_FILE 2>&1
			echo "***************************************************************************************" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1. 현황 : /etc/default/login" >> $CREATE_FILE 2>&1
			cat /etc/default/login | grep RETRIES>> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : /etc/security/policy.conf" >> $CREATE_FILE 2>&1
			cat /etc/security/policy.conf | grep LOCK >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "****************************************************************************************************************" >> $CREATE_FILE 2>&1
			echo "1. auth required /lib/security/pam_tally.so deny=5 unlock_time=120 no_magic_root 확인" >> $CREATE_FILE 2>&1
			echo "2. account required /lib/security/pam_tally.so no_magic_root reset 확인" >> $CREATE_FILE 2>&1
			echo "3. (CentOs 8 이상) account required pam_faillock.so preauth silent audit deny=5 unlock_time=120 확인" >> $CREATE_FILE 2>&1
			echo "****************************************************************************************************************" >> $CREATE_FILE 2>&1
			
			echo "1. 현황 : authselect  (Rocky/RHEL 8) 사용 여부 확인" >> $CREATE_FILE 2>&1
			authselect current  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : authselect  (Rocky/RHEL 8) 사용시  계정 잠금 임계값 확인" >> $CREATE_FILE 2>&1
			cat /etc/security/faillock.conf | grep deny >> $CREATE_FILE 2>&1
			cat /etc/security/faillock.conf | grep unlock_time >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			if [ -f /etc/pam.d/system-auth  ]
			then
				echo "3. 현황 : pam_tally.so, pam_tally2.so (centos7) 사용 여부 확인" >> $CREATE_FILE 2>&1
				cat /etc/pam.d/system-auth | grep auth | grep required >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "3. 현황 : /etc/pam.d/system-auth 파일 없음" >> $CREATE_FILE 2>&1
			fi
			echo " " >> $CREATE_FILE 2>&1
			
			if [ -f /etc/pam.d/password-auth  ]
			then
				echo "4. 현황 : /etc/pam.d/password-auth  (centos7)" >> $CREATE_FILE 2>&1
			cat /etc/pam.d/password-auth >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "4. 현황 : /etc/pam.d/system-auth 파일 없음" >> $CREATE_FILE 2>&1
			fi
			
			echo "5. 현황 : pam 모듈 바이너리 파일 확인(rocky, centos)" >> $CREATE_FILE 2>&1
			ls -al /lib64/security >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			case "$ID" in
				ubuntu | debian | kali)
				echo "6. 현황 : /etc/pam.d/common-auth  (ubuntu)" >> $CREATE_FILE 2>&1
				cat /etc/pam.d/common-auth >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				echo "7. 현황 : /etc/pam.d/common-account  (ubuntu)" >> $CREATE_FILE 2>&1
				cat /etc/pam.d/common-account >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1				
				echo "8. 현황 : pam 모듈 바이너리 파일 확인(ubuntu)" >> $CREATE_FILE 2>&1
				ls -al /lib/x86_64-linux-gnu/security >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				;;
			esac
			;;
		AIX)
			echo "판단기준 : loginretries=10 확인" >> $CREATE_FILE 2>&1
			echo "현황 : /etc/security/user" >> $CREATE_FILE 2>&1
			cat /etc/security/user >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "판단기준 : maxtries=10 확인" >> $CREATE_FILE 2>&1
			echo "현황 : HP-UX 11.v2 이하 일경우 /tcb/files/auth/system/default" >> $CREATE_FILE 2>&1
			cat /tcb/files/auth/system/default >> $CREATE_FILE 2>&1
			echo "현황 : HP-UX 11.v3 이상 일경우 /etc/default/security의 AUTH_MAXTRIES 확인" >> $CREATE_FILE 2>&1
			cat /etc/default/security >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-04] 패스워드 파일 보호"
	echo "[U-04] 패스워드 파일 보호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : shadow 파일을 사용하거나, 패스워드를 암호화하여 저장하는 경우" >> $CREATE_FILE 2>&1

	case $OS in
		SunOS)
			echo "**********************" >> $CREATE_FILE 2>&1
			echo "두번째 필드가 x 표시되어 있는지 확인" >> $CREATE_FILE 2>&1
			echo "**********************" >> $CREATE_FILE 2>&1
			echo "1. 현황 : ls -al /etc/passwd /etc/shadow" >> $CREATE_FILE 2>&1
			ls -al /etc/passwd /etc/shadow  >> $CREATE_FILE 2>&1
			echo "2. 현황 : /etc/passwd" >> $CREATE_FILE 2>&1
			cat /etc/passwd  | grep root >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : /etc/shadow" >> $CREATE_FILE 2>&1
			cat /etc/shadow  | grep root >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "판단기준 참고 : shadow 파일에서 두번째 필드의 x 표기 여부 확인" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1. 현황 : ls -al /etc/passwd /etc/shadow" >> $CREATE_FILE 2>&1
			ls -al /etc/passwd /etc/shadow  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : /etc/passwd 상세 내용" >> $CREATE_FILE 2>&1
			cat /etc/passwd | grep root>> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : /etc/shadow 상세 내용" >> $CREATE_FILE 2>&1
			cat /etc/shadow | grep root>> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			echo "1. 현황 : ls -al /etc/passwd /etc/shadow /etc/security/passwd" >> $CREATE_FILE 2>&1
			ls -al /etc/passwd /etc/shadow /etc/security/passwd >> $CREATE_FILE 2>&1
			echo "2. 현황 : cat /etc/passwd" >> $CREATE_FILE 2>&1
			cat /etc/passwd  | grep root >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : /etc/shadow" >> $CREATE_FILE 2>&1
			cat /etc/shadow  | grep root >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4. 현황 : /etc/security/passwd" >> $CREATE_FILE 2>&1
			cat /etc/security/passwd  | grep root >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "1. 현황 : ls -al /etc/passwd /etc/shadow" >> $CREATE_FILE 2>&1
			ls -al /etc/passwd /etc/shadow  >> $CREATE_FILE 2>&1
			echo "2. 현황 : cat /etc/passwd" >> $CREATE_FILE 2>&1
			cat /etc/passwd  | grep root >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : cat /etc/shadow" >> $CREATE_FILE 2>&1
			cat /etc/shadow  | grep root >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4. 현황 : cat /tcb/files/auth" >> $CREATE_FILE 2>&1
			cat /tcb/files/auth  | grep root >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-05] root 이외의 UID가 '0' 금지"
	echo "[U-05] root 이외의 UID가 '0' 금지" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : root 계정과 동일한 UID를 갖는 계정이 존재하지 않는 경우" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "1. 현황 : 계정별 UID 확인" >> $CREATE_FILE 2>&1
		if [ -f /etc/passwd ]
			then
				awk -F: '$3==0 { print $1 " -> UID=" $3 }' /etc/passwd    >> $CREATE_FILE 2>&1
			else
				echo "/etc/passwd 파일 미존재"	>> $CREATE_FILE 2>&1
		fi
		echo " " >> $CREATE_FILE 2>&1
		echo "2. 현황 : /etc/passwd 상세 내용"  >> $CREATE_FILE 2>&1
		cat /etc/passwd >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-06] 사용자 계정 SU 제한"
	echo "[U-06] 사용자 계정 SU 제한" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : SU 명령어를 특정 그룹에 속한 사용자만 사용하도록 제한 되어 있는 경우 (SU 파일 권한이 4750 인 경우)" >> $CREATE_FILE 2>&1
	echo "판단기준 : 일반 사용자 계정 없이 root 계정만 사용하는 경우 su 명령어 사용 제한 불필요" >> $CREATE_FILE 2>&1

	case $OS in
		SunOS)
			if [ -s /usr/bin/su ]
				then
					echo "1. 현황 : /usr/bin/su 확인 " >> $CREATE_FILE 2>&1
					ls -al /usr/bin/su   									>> $CREATE_FILE 2>&1
					sunsugroup=`ls -al /usr/bin/su | awk '{print $4}'`;
				else
					echo "1. 현황 : /usr/bin/su 파일을 찾을 수 없습니다."     		>> $CREATE_FILE 2>&1
			fi
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : su파일의 group 확인 " >> $CREATE_FILE 2>&1
			cat /etc/group | grep -w $sunsugroup >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : /etc/group" >> $CREATE_FILE 2>&1
			cat /etc/group >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo " " >> $CREATE_FILE 2>&1
			if [ -s /etc/pam.d/su ]
				then
					echo "1. 현황 : /etc/pam.d/su 파일 확인(pam 모듈)" >> $CREATE_FILE 2>&1
					ls -al /etc/pam.d/su >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					echo "1-1. 현황 : su 파일 내 모듈 값 확인" >> $CREATE_FILE 2>&1
					cat /etc/pam.d/su | grep auth | grep pam_wheel.so >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					echo "1-2. 현황 : wheel 그룹 확인" >> $CREATE_FILE 2>&1
					cat /etc/group | grep wheel >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					case "$ID" in
						ubuntu | debian | kali)
							echo "1-3. 현황 : wheel 그룹 확인(ubuntu)" >> $CREATE_FILE 2>&1
							cat /etc/group | grep sudo >> $CREATE_FILE 2>&1
							echo " " >> $CREATE_FILE 2>&1
							;;
					esac
				else
					echo "/etc/pam.d/su 파일 미존재(pam 모듈 이용중이지 않음)"	>> $CREATE_FILE 2>&1
					echo "2. 현황 : /etc/group에서 wheel 그룹 확인" >> $CREATE_FILE 2>&1
					grep -E "^$wheel" /etc/group >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					echo "3. 현황 : /etc/group 상세 내용" >> $CREATE_FILE 2>&1
					cat /etc/group >> $CREATE_FILE 2>&1
			fi
			;;
		AIX)
			echo "1. 현황 : /etc/security/user의 $ugroup=staff 설정확인" >> $CREATE_FILE 2>&1
			cat /etc/security/user >> $CREATE_FILE 2>&1

			if [ -s /usr/bin/su ]
				then
					echo "2. 현황 : /usr/bin/su 확인 " >> $CREATE_FILE 2>&1
					ls -al /usr/bin/su   									>> $CREATE_FILE 2>&1
					sunsugroup=`ls -al /usr/bin/su | awk '{print $4}'`;
				else
					echo "2. 현황 : /usr/bin/su 파일을 찾을 수 없습니다."     		>> $CREATE_FILE 2>&1
			fi
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : su파일의 그룹 확인 " >> $CREATE_FILE 2>&1
			cat /etc/group | grep $sunsugroup >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4. 현황 : /etc/group 파일 확인 " >> $CREATE_FILE 2>&1
			cat /etc/group >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "1. 현황 : /etc/defualt/security의 SU_ROOT_GROUP=wheel 설정 확인" >> $CREATE_FILE 2>&1
			cat /etc/default/security >> $CREATE_FILE 2>&1

			if [ -s /usr/bin/su ]
				then
					echo "2. 현황 : /usr/bin/su 파일 확인" >> $CREATE_FILE 2>&1
					ls -al /usr/bin/su >> $CREATE_FILE 2>&1
					sunsugroup=`ls -al /usr/bin/su | awk '{print $4}'`;
				else
					echo "2. 현황 /usr/bin/su 파일을 찾을 수 없습니다." >> $CREATE_FILE 2>&1
			fi
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : su 파일의 그룹 확인 " >> $CREATE_FILE 2>&1
			cat /etc/group | grep $sunsugroup >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4. 현황 : /etc/group 확인 " >> $CREATE_FILE 2>&1
			cat /etc/group >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1


echo "[U-07] 불필요한 계정 제거"
	echo "[U-07] 불필요한 계정 제거" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 불필요한 계정이 존재하지 않는 경우 양호" >> $CREATE_FILE 2>&1
	echo "판단기준 : 사용하지 않는 Default 계정(lp, uucp, nuucp) 점검" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
		if [ `cat /etc/passwd | egrep "lp|uucp|nuucp" | wc -l` -eq 0 ]
		then
			echo "1. 현황 : lp, uucp, nuucp 계정 미존재" >> $CREATE_FILE 2>&1
		else
			echo "1. 현황 : /etc/passwd에서 Default 계정 조회"	>> $CREATE_FILE 2>&1
			cat /etc/passwd | egrep "lp|uucp" >> $CREATE_FILE 2>&1
			#오류나서 수정 egrep -w 가 유닉스게열에서 안됨
		fi
		echo " " >> $CREATE_FILE 2>&1

		echo "2. 최근 로그인 하지 않은 계정 및 의심스러운 계정 확인 " >> $CREATE_FILE 2>&1
		case $OS in
			SunOS | HP-UX)
				echo "2-1. 현황 : 터미널 로그인 시간 확인 (finger)" >> $CREATE_FILE 2>&1
				finger | head -30 >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				;;
			Linux | AIX)
				echo "2-1. 현황 : 마지막 로그인 시간 확인 (lastlog)" >> $CREATE_FILE 2>&1
				lastlog | head -30 >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				;;
		esac
		
		echo "3. 현황 : wtmp(last) 접속로그 확인" >> $CREATE_FILE 2>&1
		last >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1

		echo "4. 현황 : wtmp 파일 존재 확인" >> $CREATE_FILE 2>&1
		case $OS in
			HP-UX | AIX)
				echo "4-1. 현황 : wtmp 파일 확인 ls -alL /var/adm/wtmp" >> $CREATE_FILE 2>&1
				ls -alL /var/adm/wtmp  >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				;;
			SunOS)
				echo "4-1. 현황 : wtmp 파일 존재 확인 ls -alL /var/adm/wtmpx" >> $CREATE_FILE 2>&1
				ls -alL /var/adm/wtmpx  >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				;;
			Linux)
				echo "4-1. 현황 : wtmp 파일 존재 확인 ls -alL /var/log/wtmp" >> $CREATE_FILE 2>&1
				ls -alL /var/log/wtmp  >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				
				if [ -f /var/log/secure  ]
				then
					echo "4-2. 현황 : 로그인 실패 횟수 확인 /var/log/secure | grep failed password" >> $CREATE_FILE 2>&1
					cat /var/log/secure | grep "Failed password" | head -20 >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "4-2. 현황 : /var/log/secure 파일 없음" >> $CREATE_FILE 2>&1
				fi
				case "$ID" in
					ubuntu | debian | kali)
					echo "4-2. 현황 : 로그인 실패 횟수 확인(ubuntu) journalctl | grep sshd | grep Failed password | head -10" >> $CREATE_FILE 2>&1
					journalctl | grep sshd | grep "Failed password" | head -10  >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					;;
				esac
			;;
		esac

		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1


echo "[U-08] 관리자 그룹에 최소한의 계정 포함"
	echo "[U-08] 관리자 그룹에 최소한의 계정 포함"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : 관리자 그룹(root or system)에 불필요한 계정이 등록되어 있지 않은 경우"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
		SunOS | HP-UX | Linux)
			echo "1. 현황 : root 그룹 확인" >> $CREATE_FILE 2>&1
			cat /etc/group | grep root  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			echo "1. 현황 : system 그룹 확인" >> $CREATE_FILE 2>&1
			cat /etc/group | grep system  >> $CREATE_FILE 2>&1
			echo " "  >> $CREATE_FILE 2>&1
			;;
	esac

	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-09] 계정이 존재하지 않는 GID 금지"
	echo "[U-09] 계정이 존재하지 않는 GID 금지"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : 불필요한 그룹(계정이 존재하지 않거나 운영에 사용되지 않는 그룹)이 존재하는 경우 취약">> $CREATE_FILE 2>&1
	echo "판단기준 참고 : /etc/group 및 /etc/passwd 파일을 비교해 판단">> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "1. 현황 : /etc/group 그룹 확인"  >> $CREATE_FILE 2>&1
	cat /etc/group >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "2. 현황 : /etc/passwd 확인" >> $CREATE_FILE 2>&1
	cat /etc/passwd >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-10] 동일한 UID 금지"
	echo "[U-10] 동일한 UID 금지"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : 동일한 UID 사용하는 계정 있는지 확인(없으면 양호)">> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
		echo "1. 현황 : /etc/passwd에서 UID 추출" >> $CREATE_FILE 2>&1
		for uid in `cat /etc/passwd | awk -F: '{print $3}'`
		do
			cat /etc/passwd | awk -F: '$3=="'${uid}'" { print "UID=" $3 " -> " $1 }'        >> $CREATE_FILE 2>&1
		done
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-11] 사용자 shell 점검"
		echo "[U-11] 사용자 shell 점검"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : 로그인이 필요하지 않은 계정에 /bin/false(/sbin/nologin)이 부여되어 있으면 양호" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1

			echo "1. 현황 : 로그인이 불필요한 계정의 SHELL 점검 (/etc/passwd) " >> $CREATE_FILE 2>&1
			if [ -f /etc/passwd ]
			then
				 cat /etc/passwd | grep -E "^deamon|^bin|^sys|^adm|^listen|^nobody|^nobody4|^noaacess|^diag|^operator|^games|^gopher" | grep -v admin  >> $CREATE_FILE 2>&1
			else
				echo "/etc/passwd 파일 미존재"     >> $CREATE_FILE 2>&1
			fi
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-12] Session Timeout 설정"
	echo "[U-12] Session Timeout 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : Session TIMEOUT=600(10분) 이하로 설정되어 있으면 양호" >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			echo "1. 현황 : /etc/profile의 TMOUT 확인 " >> $CREATE_FILE 2>&1
			grep -i "TMOUT" /etc/profile | grep -v "^#" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : 환경설정(env) 부분의 TMOUT 확인 " >> $CREATE_FILE 2>&1
			env | grep TMOUT >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "판단기준 참고 : /etc/profile 파일의 TIMEOUT=600 혹은 TMOUT=600 이상이면 양호" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1. 현황 : /etc/profile 파일의 TIMEOUT/TMOUT 확인" >> $CREATE_FILE 2>&1
			grep -i "TIMEOUT" /etc/profile | grep -v "^#" >> $CREATE_FILE 2>&1
			grep -i "TMOUT" /etc/profile | grep -v "^#" >> $CREATE_FILE 2>&1 #문구수정
			echo " " >> $CREATE_FILE 2>&1
			echo "2-1. 현황 : grep -i "TMOUT" ~/.bashrc " >> $CREATE_FILE 2>&1
			grep -i "TMOUT" ~/.bashrc >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-2. 현황 : grep -i "TMOUT" ~/.bash_profile " >> $CREATE_FILE 2>&1
			grep -i "TMOUT" ~/.bash_profile >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-3. 현황 : echo TMOUT " >> $CREATE_FILE 2>&1
			echo $TMOUT >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			echo "1. 현황 : /etc/profile의 TMOUT 확인 " >> $CREATE_FILE 2>&1
			grep -i "TIMEOUT" /etc/profile | grep -v "^#" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			grep -i "TMOUT" /etc/profile | grep -v "^#" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : csh 인경우(csh.login, csh.cshrc)의 TMOUT 확인 " >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			grep -i "autologout" /etc/csh.login | grep -v "^#" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			grep -i "autologout" /etc/csh.cshrc | grep -v "^#" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "1. 현황 : /etc/profile의 TMOUT 확인 " >> $CREATE_FILE 2>&1
			grep -i "TIMEOUT" /etc/profile | grep -v "^#" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			grep -i "TMOUT" /etc/profile | grep -v "^#" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : csh 인경우(csh.login, csh.cshrc)의 TMOUT 확인 " >> $CREATE_FILE 2>&1
			grep -i "autologout" /etc/csh.login | grep -v "^#" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			grep -i "autologout" /etc/csh.cshrc | grep -v "^#" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-13] 안전한 비밀번호 암호화 알고리즘 사용"
	echo "[U-13] 안전한 비밀번호 암호화 알고리즘 사용"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : sha-2 이상 암호화 알고리즘 적용 여부 확인" >> $CREATE_FILE 2>&1
	
	case $OS in
		SunOS)
			echo "1. 현황 : 암호화 알고리즘 확인(policy.conf)" >> $CREATE_FILE 2>&1
			cat /etc/shadow | grep root >> $CREATE_FILE 2>&1
			cat /etc/security/policy.conf | grep CRYPT_DEFAULT >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "1. shadow 패스워드 내 암호화 알고리즘 확인(5이상)" >> $CREATE_FILE 2>&1
			cat /etc/shadow | grep root >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1

			if [ -f /etc/pam.d/system-auth  ]
			then
				echo "2. 현황 : 암호화 알고리즘 확인(system-auth)" >> $CREATE_FILE 2>&1
				cat /etc/pam.d/system-auth | grep password | grep sufficient >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "2. 현황 : /etc/pam.d/system-auth 파일 없음" >> $CREATE_FILE 2>&1
			fi
			
			echo "3. 현황 : 암호화 알고리즘 확인(login.defs)" >> $CREATE_FILE 2>&1
			cat /etc/login.defs | grep ENCRYPT_METHOD >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			case "$ID" in
				ubuntu | debian | kali)
					echo "4. 현황 : 암호화 알고리즘 확인(ubuntu)" >> $CREATE_FILE 2>&1
					cat /etc/pam.d/common-password | grep password>> $CREATE_FILE 2>&1
					echo "5. 현황 : 암호화 알고리즘 확인(ubuntu)" >> $CREATE_FILE 2>&1
					cat /etc/pam.d/common-auth | grep password  >> $CREATE_FILE 2>&1
					;;
			esac
			;;
		AIX)
			echo "1. 현황 : 암호화 알고리즘 확인(/etc/security/passwd)" >> $CREATE_FILE 2>&1
			cat /etc/security/passwd | grep password  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "1. 현황 : 암호화 알고리즘 확인(/etc/default/security)" >> $CREATE_FILE 2>&1
			cat /etc/default/security | grep CRYPT_DEFAULT >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-14] root 홈, 패스 디렉터리 권한 및 패스 설정"
		echo "[U-14] root 홈, 패스 디렉터리 권한 및 패스 설정"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo "판단기준 : PATH 환경변수에서 "."(DOT)이 맨 뒤에 위치하거나 없으면 양호" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "현황 : PATH 환경변수"  >> $CREATE_FILE 2>&1
		echo $PATH  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1
	
echo "[U-15] 파일 및 디렉터리 소유자 설정"
	echo "[U-15] 파일 및 디렉터리 소유자 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : 소유자가 존재하지 않는 파일 디렉토리 중 중요한 파일인지 확인" >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			echo "현황 : find / -nouser -o -nogroup -xdev -ls 2> /dev/null" >> $CREATE_FILE 2>&1
			find / -nouser -o -nogroup -xdev -ls 2> /dev/null  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "1. 현황 : find / -nouser -ls " >> $CREATE_FILE 2>&1
			find / -xdev -nouser -ls  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : find / -nogroup -ls " >> $CREATE_FILE 2>&1
			find / -xdev -nogroup -ls  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			echo "현황 : find / -nouser -o -nogroup -xdev -ls 2> /dev/null" >> $CREATE_FILE 2>&1
			find / -nouser -o -nogroup -xdev -ls 2> /dev/null  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "현황 : find / \( -nouser -o -nogroup \) -xdev -exec ls -al {} \; 2> /dev/null" >> $CREATE_FILE 2>&1
			find / \( -nouser -o -nogroup \) -xdev -exec ls -al {} \; 2> /dev/null  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-16] /etc/passwd 파일 소유자 및 권한 설정"
	echo "[U-16] /etc/passwd 파일 소유자 및 권한설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : /etc/passwd 파일의 소유자가 root이고, 파일권한이 644이하이면 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "현황 : ls -al /etc/passwd" >> $CREATE_FILE 2>&1
	ls -al /etc/passwd >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-17] 시스템 시작 스크립트 권한 설정"
	echo "[U-17] 시스템 시작 스크립트 권한 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : 시스템 시작 스크립트 파일의 소유자가 root이고, 일반 사용자의 쓰기 권한이 제거된 경우" >> $CREATE_FILE 2>&1
	echo "참고 : 디바이스 파일은 제외" >> $CREATE_FILE 2>&1
		case $OS in
		SunOS)
			echo "1. 현황 : 시스템 시작 스크립트 파일 소유자 및 권한 확인" >> $CREATE_FILE 2>&1
			ls -alL /etc/systemd/system/*  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "1. 현황 : 시스템 시작 스크립트 파일 소유자 및 권한 확인(init)" >> $CREATE_FILE 2>&1
			ls -al `readlink -f /etc/rc.d/*/* | sed 's/$/*/'` >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : 시스템 시작 스크립트 파일 소유자 및 권한 확인(systemd)" >> $CREATE_FILE 2>&1
			ls -alL /etc/systemd/system/*  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX | HP-UX)
			echo "1. 현황 : 시스템 시작 스크립트 파일 소유자 및 권한 확인" >> $CREATE_FILE 2>&1
			find /etc/rc.d/*/* -type l -exec ls -l {} + >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-18] /etc/shadow 파일 소유자 및 권한설정"
	echo "[U-18] /etc/shadow 파일 소유자 및 권한설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : /etc/shadow 파일의 소유자가 root이고, 파일권한이 400 이하이면 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1

	case $OS in
		SunOS | Linux)
			echo "현황 : ls -al /etc/shadow" >> $CREATE_FILE 2>&1
			ls -al /etc/shadow >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "현황 : shadow 그룹 확인" >> $CREATE_FILE 2>&1
			cat /etc/group | grep shadow >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			echo "현황 : ls -al /etc/shadow" >> $CREATE_FILE 2>&1
			ls -al /etc/shadow  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "현황 : ls -al /etc/security/passwd" >> $CREATE_FILE 2>&1
			ls -al /etc/security/passwd  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "현황 : ls -al /etc/shadow" >> $CREATE_FILE 2>&1
			ls -al /etc/shadow  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "현황 : ls -alL /tcb/files/auth" >> $CREATE_FILE 2>&1
			ls -alL /tcb/files/auth  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-19] /etc/hosts 파일 소유자 및 권한 설정"
	echo "[U-19] /etc/hosts 파일 소유자 및 권한 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : /etc/hosts 파일의 소유자가 root이고, 파일권한이 644이하이면 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "1.현황 : ls -alL /etc/hosts"  >> $CREATE_FILE 2>&1
	ls -alL /etc/hosts >> $CREATE_FILE 2>&1
	echo "2.현황 : cat /etc/hosts"  >> $CREATE_FILE 2>&1
	cat /etc/hosts >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1
	
echo "[U-20] /etc/(x)inetd.conf 파일 소유자 및 권한 설정"
	echo "[U-20] /etc/(x)inetd.conf 파일 소유자 및 권한 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : /etc/(x)inetd.conf 파일의 소유자가 root이고, 권한이 600 이하이면 양호" >> $CREATE_FILE 2>&1
	case $OS in
		SunOS | AIX | HP-UX)
			echo "1. 현황 : ls -al /etc/inetd.conf" >> $CREATE_FILE 2>&1
			ls -al /etc/inetd.conf  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : ls -al /etc/inet/inetd.conf" >> $CREATE_FILE 2>&1
			ls -al /etc/inet/inetd.conf  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "1. 현황 : ls -l /etc/xinetd.conf" >> $CREATE_FILE 2>&1
			ls -l /etc/xinetd.conf  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : ls -al /etc/xinetd.d/* (참고) " >> $CREATE_FILE 2>&1
			ls -al /etc/xinetd.d/*  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-21] /etc/(r)syslog.conf 파일 소유자 및 권한 설정"
	echo "[U-21] /etc/(r)syslog.conf 파일 소유자 및 권한 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : /etc/syslog.conf 파일의 소유자가 root(또는 bin,sys)이고, 권한이 640 이하이면 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
		echo "1. 현황 : syslog 서비스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep 'syslog' | grep -v 'grep' >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2. 현황 : syslog.conf 파일 확인" >> $CREATE_FILE 2>&1
		ls -al /etc/syslog.conf >> $CREATE_FILE 2>&1
		ls -al /etc/isyslog.conf >> $CREATE_FILE 2>&1
		ls -al /etc/rsyslog.conf >> $CREATE_FILE 2>&1
		ls -al /etc/syslog-ng/syslog-ng.conf >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1	

echo "[U-22] /etc/services 파일 소유자 및 권한설정"
	echo "[U-22] /etc/services 파일 소유자 및 권한설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 참고 : /etc/services 파일의 소유자가 root이고, 퍼미션이 644 이하이면 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
		echo "현황 : ls -alL /etc/services" >> $CREATE_FILE 2>&1
		ls -alL /etc/services >> $CREATE_FILE 2>&1
		ls -al /etc/inet/services >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-23] SUID, SGID, Sticky bit 설정 파일 점검"
	echo "[U-23] SUID, SGID, Sticky bit 설정 파일 점검"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "멘트 참고 : setuid/setgid 파일 존재 여부를 점검한 결과,OS 기본 패키지에서 제공하는 필수 바이너리로 확인되었으며 불필요하거나 비인가된 setuid/setgid 파일은 발견되지 않음" >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			echo "판단기준 참고 : 중요 파일의 SUID, SGID, Sticky bit 설정이 4750인지 확인" >> $CREATE_FILE 2>&1
			ls -al /usr/bin/admintool /usr/bin/at /usr/bin/atq /usr/bin/atrm /usr/bin/lpset /usr/bin/newgrp /usr/bin/nispasswd /usr/bin/rdist /usr/bin/yppasswd /usr/dt/bin/dtappgather /usr/dt/bin/dtprintinfo /usr/dt/bin/sdtcm_convert /usr/lib/fs/ufs/ufsdump /usr/lib/fs/ufs/ufsrestore /usr/lib/lp/bin/netpr /usr/openwin/bin/ff.core /usr/openwin/bin/kcms_calibrate /usr/openwin/bin/kcms_configure /usr/openwin/bin/xlock /usr/platform/sun4u/sbin/prtdiag /usr/sbin/arp /usr/sbin/lpmove /usr/sbin/prtconf >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux) ##################################################
			echo "판단기준 참고 : 중요 파일의 SUID, SGID, Sticky bit 설정이 4750인지 확인" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			find / -user root -type f \( -perm -04000 -o -perm -02000 \) -xdev -exec ls -al {} \;  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			echo "판단기준 참고 : 중요 파일의 SUID, SGID, Sticky bit 설정이 4750인지 확인" >> $CREATE_FILE 2>&1
			ls -al /usr/dt/bin/dtaction /usr/dt/bin/dtterm /usr/bin/X11/xlock /usr/sbin/mount /usr/sbin/lchangelv >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "판단기준 참고 : 중요 파일의 SUID, SGID, Sticky bit 설정이 4750인지 확인" >> $CREATE_FILE 2>&1
			ls -al /opt/perf/bin/glance /usr/dt/bin/dtprintinfo /usr/sbin/swreg /opt/perf/bin/gpm /usr/sbin/arp /usr/sbin/swremove /opt/video/lbin/camServer /usr/sbin/lanadmin /usr/bin/at /usr/sbin/landiag /usr/bin/lpalt /usr/sbin/lpsched /usr/bin/mediainit /usr/sbin/swacl /usr/bin/newgrp /usr/sbin/swconfig /usr/bin/rdist /usr/sbin/swinstall /usr/contrib/bin/traceroute /usr/sbin/swmodify /usr/dt/bin/dtappgather /usr/sbin/swpackage >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1	

echo "[U-24] 사용자, 시스템 환경변수 파일 소유자 및 권한 설정"
	echo "[U-24] 사용자, 시스템 환경변수 파일 소유자 및 권한 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 참고 : 시스템 환경파일이 있는경우, 소유자가 root이고 권한이 644이하일 경우 양호" >> $CREATE_FILE 2>&1
	echo "판단기준 참고 : 홈 디렉터리 환경변수 파일에 root와 소유자만 쓰기 권한이 부여된 경우 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "1. 현황 : 환경변수 파일 확인" >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			ls -al /.profile /.cshrc /.kshrc /.login /.bash_profile /.bashrc /.bash_login /.xinitrc /.xsession /.login /.exrc /.netrc  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			ls -al /.profile /.cshrc /.kshrc /.login /.bash_profile /.bashrc /.bash_login /.xinitrc /.xsession /.exrc /.netrc  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			ls -al /.profile /.cshrc /.kshrc /.login /.bash_profile /.bashrc /.bash_login /.xinitrc /.xsession /.login /.exrc /.netrc >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			ls -al /.profile /.cshrc /.kshrc /.login /.bash_profile /.bashrc /.bash_login /.xinitrc /.xsession /.exrc /.netrc >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo "2. 현황 : 홈 디렉토리($HOME) 경로의 쓰기권한 확인 ( 환경변수만 확인하면 됨)" >> $CREATE_FILE 2>&1
	ls -al $HOME/ >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-25] World writable 파일 점검"
	echo "[U-25] World writable 파일 점검"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "참고판단 기준 >> world writable 파일이 존재하지 않거나, 중요 파일인 경우 644 이하이면 양호 " >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			echo "현황 : world writable 파일 확인" >> $CREATE_FILE 2>&1
			find / -type f -perm -2 ! -path "/proc/*" ! -path "/system/*" ! -path "/devices/*" -ls 2>/dev/null >>  "$CREATE_FILE"  2>/dev/null
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "현황 : world writable 파일 확인" >> $CREATE_FILE 2>&1
			find / \( -path /proc -o -path /sys -o -path /sys/fs/cgroup -o -path /run \) -prune -o -type f -perm -2 -exec ls -l {} \; >>  "$CREATE_FILE" 2>/dev/null
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			echo "현황 : world writable 파일 확인" >> $CREATE_FILE 2>&1
			find / -type f -perm -2 ! -path "/proc/*" ! -path "/dev/*" -ls 2>/dev/null >> "$CREATE_FILE" 2>/dev/null
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "현황 : world writable 파일 확인" >> $CREATE_FILE 2>&1
			find / -type f -perm -2 ! -path "/proc/*" ! -path "/stand/*" -ls >> "$CREATE_FILE" 2>/dev/null
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-26] /dev에 존재하지 않는 device 파일 점검"
	echo "[U-26] /dev에 존재하지 않는 device 파일 점검"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 참고 : 아래 find 결과 값에서 major, minor number 값을 가지고 있는 경우 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "현황 : find /dev -type f -exec ls -l {} \;" >> $CREATE_FILE 2>&1
	find /dev -type f -exec ls -l {} \; >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-27] $HOME/.rhosts, hosts.equiv 사용 금지"
	echo "[U-27] $HOME/.rhosts, hosts.equiv 사용 금지"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 파일이 존재하지 않거나, 파일 소유자가 root 또는 해당 계정이면서 권한이 600 이하이고 파일에 "+"가 없으면 양호" >> $CREATE_FILE 2>&1
	echo "판단기준 참고 : /etc/hosts.equiv : 서버 설정 파일" >> $CREATE_FILE 2>&1
	echo "판단기준 참고 : $home/.rhosts 개별 사용자의 설정 파일" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
		echo "1. 현황 : ls -al /etc/hosts.equiv" >> $CREATE_FILE 2>&1
		ls -al /etc/hosts.equiv >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		cat /etc/hosts.equiv >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2. 현황 : ls -al $HOME/.rhosts" >> $CREATE_FILE 2>&1
		ls -al $HOME/.rhosts >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		cat $HOME/.rhosts >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1
	
echo "[U-28] 접속 IP 및 포트 제한"
	echo "[U-28] 접속 IP 및 포트 제한"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 참고 : /etc/hosts.deny 파일 내에 ALL:ALL 설정되어 있고, /etc/hosts.allow 파일 내에 서버로 접속하는 접속 IP대역을 설정했을 경우 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
		echo "1-1. 현황 : iptables 확인" >> $CREATE_FILE 2>&1
		iptables -L  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "1-2. 현황 : firewalld 서비스 확인 systemctl status firewalld" >> $CREATE_FILE 2>&1
		systemctl status firewalld  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "1-3. 현황 : firewalld 서비스 확인 firewall-cmd --list-all-zones" >> $CREATE_FILE 2>&1
		firewall-cmd --list-all-zones >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		case "$ID" in
			ubuntu | debian | kali)
				echo "2. 현황 : ufw (ubuntu) " >> $CREATE_FILE 2>&1
				ufw status  >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				ufw status verbose >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				;;
		esac
		
		echo "3-1. 현황 : 차단설정 /etc/hosts.deny (tcp wrapper centos 6이하, ubuntu 18버전)" >> $CREATE_FILE 2>&1
		ls -al /etc/hosts.deny  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		cat /etc/hosts.deny  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "3-2. 현황 : 허용설정 /etc/hosts.allow  (tcp wrapper centos 6이하, ubuntu 18버전)" >> $CREATE_FILE 2>&1
		ls -al /etc/hosts.allow  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		cat /etc/hosts.allow  >> $CREATE_FILE 2>&1

	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1	

echo "[U-29] Hosts.lpd 파일 소유자 및 권한 설정"
	echo "[U-29] Hosts.lpd 파일 소유자 및 권한 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 참고 :  파일이 존재하지 않거나, 파일 존재시 소유자가 root이고 권한이 600 이하면 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "현황 : ls -alL /etc/hosts.lpd" >> $CREATE_FILE 2>&1
	ls -alL /etc/hosts.lpd >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-30] UMASK 설정 관리"
	echo "[U-30] UMASK 설정 관리"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : /etc/default/login 파일 내에 umask 설정값이 022 이상으로 설정되어 있으면 양호 " >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "1. 현황 : etc/profile umask 설정 " >> $CREATE_FILE 2>&1
	cat /etc/profile >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "2. 현황 : umask(명령어) 실행값 = "`umask` >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	
	echo "3. 현황 : /etc/login.defs 파일 내 설정 확인" >> $CREATE_FILE 2>&1
	cat /etc/login.defs | grep umask >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1

	if [ -f /etc/vsftpd/vsftpd.conf  ]
		then
			echo "4. 현황 : FTP Umask 확인_vsftp" >> $CREATE_FILE 2>&1
			/etc/vsftpd/vsftpd.conf | grep local_umask >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		else
			echo "4. 현황 : /etc/vsftpd/vsftpd.conf  파일 없음" >> $CREATE_FILE 2>&1
	fi
	
	if [ -f etc/proftpd.conf ]
		then
			echo "5-1. 현황 : FTP Umask 확인_proftp" >> $CREATE_FILE 2>&1
			/etc/proftpd.conf | grep umask >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		else
			echo "5. 현황 : /etc/proftpd.conf  파일 없음" >> $CREATE_FILE 2>&1
	fi
	
	if [ -f /etc/proftpd/proftpd.conf ]
		then
			echo "5-2. 현황 : FTP Umask 확인_proftp_ubuntu" >> $CREATE_FILE 2>&1
			/etc/proftpd/proftpd.conf | grep umask >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		else
			echo "5-2. 현황 : /etc/proftpd/proftpd.conf 파일 없음" >> $CREATE_FILE 2>&1
	fi
	
	case $OS in
		SunOS)
			echo "3. 현황 : /etc/default/login umask 설정 " >> $CREATE_FILE 2>&1
			cat /etc/default/login >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			echo "3. 현황 : /etc/security/user umask 설정 " >> $CREATE_FILE 2>&1
			cat /etc/security/user >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4. 현황 :lsuser -a umask ALL" >> $CREATE_FILE 2>&1
			echo "lsuser -a umask ALL " >> $CREATE_FILE 2>&1
			lsuser -a umask ALL >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "3. 현황 : /etc/default/security umask 설정 " >> $CREATE_FILE 2>&1
			cat /etc/default/security >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1
	
echo "[U-31] 홈 디렉터리 소유자 및 권한 설정"
	echo "[U-31] 홈 디렉터리 소유자 및 권한 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 홈디렉토리 소유자가 해당 계정이고, 타 사용자 쓰기 권한이 제거된 경우" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
		echo "1. 현황 : 홈디렉토리의 권한 확인" >> $CREATE_FILE 2>&1
		HOMEDIRS=$(awk -F: 'length($6) > 0 {print $6}' /etc/passwd | sort -u)

		for dir in $HOMEDIRS; do
			if [ -d "$dir" ]; then
				ls -dal "$dir" | grep '\d.........' >> "$CREATE_FILE" 2>&1
			fi
		done

	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1
	
echo "[U-32] 홈 디렉터리로 지정한 디렉터리의 존재 관리"
	echo "[U-32] 홈 디렉터리로 지정한 디렉터리의 존재 관리"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 홈 디렉터리가 없는 계정이 없는 경우 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "현황 : /etc/passwd 내 홈디렉터리가 없는 계정 확인" >> $CREATE_FILE 2>&1
		for U34 in `cat /etc/passwd | awk -F: 'length($6) > 0 { print $1 }'`
		do
			if [ -d `cat /etc/passwd | grep -w $U34 | awk -F: '{ print $6":"$1 }' | grep $U34$ | awk -F: '{ print $1 }'` ]
			#if [ -d `cat /etc/passwd | grep $U34 | awk -F: '{ print $6":"$1 }' | grep $U34$ | awk -F: '{ print $1 }'` ]
				then
					:
					#echo "ID : $U34" >> $CREATE_FILE 2>&1
					#TMP_HOMEDIR=`cat /etc/passwd | grep -w $U34 | awk -F: '{ print $6":"$1 }' | grep $U34$ | awk -F: '{ print $1 }'`
					#TMP_HOMEDIR=`cat /etc/passwd | grep $U34 | awk -F: '{ print $6":"$1 }' | grep $U34$ | awk -F: '{ print $1 }'`
					#echo "해당 디렉토리 있음 : $TMP_HOMEDIR" >> $CREATE_FILE 2>&1
					#echo "$TMP_HOMEDIR 존재함" >> $CREATE_FILE 2>&1
				else
					echo "========" >> $CREATE_FILE 2>&1
					echo "ID : $U34" >> $CREATE_FILE 2>&1
					#echo " " >> $CREATE_FILE 2>&1
					cat /etc/passwd | grep $U34 >> $CREATE_FILE 2>&1
					TMP_HOMEDIR=`cat /etc/passwd | grep -w $U34 | awk -F: '{ print $6":"$1 }' | grep $U34$ | awk -F: '{ print $1 }'`
					
					#TMP_HOMEDIR=`cat /etc/passwd | grep $U34 | awk -F: '{ print $6":"$1 }' | grep $U34$ | awk -F: '{ print $1 }'`
					#echo "디렉토리 없음(취약) : $TMP_HOMEDIR" >> $CREATE_FILE 2>&1
					#echo " " >> $CREATE_FILE 2>&1
					echo "$TMP_HOMEDIR 없음" >> $CREATE_FILE 2>&1
			fi
		done
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-33] 숨겨진 파일 및 디렉터리 검색 및 제거"
	echo "[U-33] 숨겨진 파일 및 디렉터리 검색 및 제거"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 숨겨져 있는 파일 및 디렉터리가 있더라도 시스템상에 영향을 끼치지 않으면 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "1. 현황(숨겨진 파일) : find / -name ".*" -type f ">> $CREATE_FILE 2>&1
	find / \( -path /proc -o -path /sys -o -path /run -o -path /dev -o -path /tmp -o -path /var/run \) -prune -o -type f -name ".*" -print >> "$CREATE_FILE" 2>/dev/null
	echo " " >> $CREATE_FILE 2>&1
	echo "2. 현황(숨겨진 디렉토리) : find / -name ".*" -type d " >> $CREATE_FILE 2>&1
	find / \( -path /proc -o -path /sys -o -path /run -o -path /dev -o -path /tmp -o -path /var/run \) -prune -o -type d -name ".*" -print >> "$CREATE_FILE" 2>/dev/null
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1
	
echo "[U-34] Finger 서비스 비활성화"
	echo "[U-34] Finger 서비스 비활성화"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 참고 : 아래 결과 값 내에 파일이 존재하지 않을경우 양호 " >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "1. 현황 : /etc/inetd.conf">> $CREATE_FILE 2>&1
	cat /etc/inetd.conf >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
	SunOS)
		echo "2. 현황(SOL 10이상) : inetadm | grep finger">> $CREATE_FILE 2>&1
		inetadm | grep "finger" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	Linux)
		if [ -d /etc/xinetd ]
		then
			echo "2. 현황(xinetd 일경우) : /etc/xinetd.d" >> $CREATE_FILE 2>&1
			ls -al /etc/xinetd.d >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1		
			echo "3. 현황(xinetd 일경우) : /etc/xinetd.d/* egrep 'echo finger' " >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/* | egrep "echo finger" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		else
			echo "2. 현황 : /etc/xinetd.d 디렉터리가 없음" >> $CREATE_FILE 2>&1
		fi
		;;
	esac
	
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-35] 공유 서비스에 대한 익명 접근 제한 설정"
	echo "[U-35] 공유 서비스에 대한 익명 접근 제한 설정" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 공유 서비스(ftp,nfs,samba)에 대해 익명 접근을 제한한 경우" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
		echo "1. 현황 : ftp 서비스 확인 " >> $CREATE_FILE 2>&1
		ps -ef | grep ftp | grep -v grep >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1		
		echo "1-1. 현황 : cat /etc/passwd | egrep 'ftp|anonymous' FTP 계정 삭제 권고" >> $CREATE_FILE 2>&1
		cat /etc/passwd | egrep "ftp|anonymous" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "1-2. 현황 : vsftpd 서비스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep vsftpd | grep -v grep >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		if [ -f /etc/vsftpd.conf ]
		then
			echo "1-2-1. 현황 : /etc/vsftpd.conf (anonymous_enable=NO 또는 주석처리시 확인)" >> $CREATE_FILE 2>&1
			cat /etc/vsftpd.conf | grep anonymous_enable >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		else
			echo "1-2-1. 현황 : /etc/vsftpd.conf 디렉터리가 없음" >> $CREATE_FILE 2>&1
		fi
		
		echo "1-3. 현황 : proftpd 서비스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep proftpd | grep -v grep >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		if [ -f /etc/vsftpd.conf ]
		then
			echo "1-3-1. 현황 : /etc/proftpd.conf 내 anonymous 필드 제거" >> $CREATE_FILE 2>&1
			cat /etc/proftpd/proftpd.conf | grep anonymous >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		else
			echo "1-3-1. 현황 : /etc/proftpd/proftpd.conf 디렉터리가 없음" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		fi
	
		echo "2. 현황 : samba 서비스 확인 " >> $CREATE_FILE 2>&1
		systemctl status smb >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2. 현황 : samba 서비스 확인 " >> $CREATE_FILE 2>&1
		systemctl status smbd >> $CREATE_FILE 2>&1
		echo "2-1. 현황 : 익명 접근 활성화 확인 " >> $CREATE_FILE 2>&1
		grep -i guest /etc/samba/smb.conf >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "3. 현황 : nfs 서비스 확인 " >> $CREATE_FILE 2>&1
		systemctl status nfs-server >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		if [ -f /etc/exports ]
		then
			echo "3-1. 현황 : 익명 접근 활성화 확인 " >> $CREATE_FILE 2>&1
			cat /etc/exports | grep -E "anonuid|anongui"  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		else
			echo "3-1. 현황 : /etc/export 파일 없음 " >> $CREATE_FILE 2>&1
		fi
		
	case $OS in
	SunOS)
		echo "1-2. 현황(SOL 10이상) : svcs ftp">> $CREATE_FILE 2>&1
		svcs ftp >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	esac
	echo "[END]" >> $CREATE_FILE 2>&1
	

echo "[U-36] r 계열 서비스 비활성화"
	echo "[U-36] r 계열 서비스 비활성화"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 참고 : rsh, rlogin, rexec (shell, login, exec) 서비스가 비활성화 되어있거나 결과값이 없을경우에 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			echo "1-1. 현황(Solaris 9버전 이하) : /etc/inetd.conf 확인하여 r로 시작하는 서비스(rexecd,rlogind,rshd 등) 주석 확인" >> $CREATE_FILE 2>&1
			cat /etc/inetd.conf >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-2. 현황(Solaris 10버전 이상) : r서비스 계열 활성화 확인(disable이면 양호)" >> $CREATE_FILE 2>&1
			inetadm | egrep "shell|rlogin|rexec">> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			if [ -d /etc/inetd.d ]
			then
				echo "1. 현황 : inetd 서비스 확인" >> $CREATE_FILE 2>&1
				ls -al /etc/inetd.d/* | egrep "rsh|rlogin|rexec" | egrep -v "grep|klogin|kshell|kexec" >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "1. 현황 : /etc/inetd.d 디렉터리 없음 " >> $CREATE_FILE 2>&1
			fi
			
			echo "1-1. cat /etc/inetd.conf 파일 확인 " >> $CREATE_FILE 2>&1
			cat /etc/inetd.conf >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			if [ -d /etc/xinetd.d ] && [ "$(ls -A /etc/xinetd.d 2>/dev/null)" ]; then
				echo "2. 현황 : xinetd 서비스 확인" >> "$CREATE_FILE" 2>&1
				ls -al /etc/xinetd.d/* | egrep "rsh|rlogin|rexec" | egrep -v "grep|klogin|kshell|kexec" >> "$CREATE_FILE" 2>&1
				echo " " >> "$CREATE_FILE" 2>&1
			else
				echo "2. 현황 : /etc/xinetd.d 디렉터리에 파일 없음" >> "$CREATE_FILE" 2>&1
			fi
			
			echo "2-1. rsh, rlogin, rexec 서비스 설정 확인" >> $CREATE_FILE 2>&1
			echo "2-2. cat /etc/xinetd.d/rsh " >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/rsh >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-3. cat /etc/xinetd.d/rlogin" >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/rlogin >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-4. cat /etc/xinetd.d/rexec" >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/rexec >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3.  systemd 에서 r 계열 서비스 확인" >> $CREATE_FILE 2>&1
			systemctl list-units --type=service | grep -E "rlogin|rsh|rexec"  >> $CREATE_FILE 2>&1
			;;
		AIX)
			cat /etc/inetd.conf >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			cat /etc/inetd.conf  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-37] crontab 설정파일 권한 설정 미흡"
	echo "[U-37] crontab 설정파일 권한 설정 미흡"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : crontab, at 명령어 파일의 권한 750이하이면 양호" >> $CREATE_FILE 2>&1
	echo "판단기준 : cron,at 관련             파일의 권한 640이하이면 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			echo "1-1. 현황 : crontab 파일" >> $CREATE_FILE 2>&1
			ls -al /usr/bin/crontab >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-2. 현황 : /var/spool/cron/crontabs 내 작업 목록 파일" >> $CREATE_FILE 2>&1
			ls -al /var/spool/cron/crontabs/ >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-3. 현황 : /etc/cron.d/ 디렉토리 내 cron 관련 파일" >> $CREATE_FILE 2>&1
			ls -al /etc/cron.d/ >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-1. 현황 : at 파일 소유자 및 권한 확인" >> $CREATE_FILE 2>&1
			ls -al /usr/bin/at  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-2. 현황 : /var/spool/cron/atjobs 디렉토리 내 파일" >> $CREATE_FILE 2>&1
			ls -al /var/spool/cron/atjobs/  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "1-1. 현황 : crontab 파일(750)" >> $CREATE_FILE 2>&1
			ls -al /usr/bin/crontab >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-2. 현황 : /var/spool/cron/ 내 작업 목록 파일" >> $CREATE_FILE 2>&1
			ls -al /var/spool/cron/ >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-3. 현황 : /etc/cron* 디렉토리 내 cron 관련 파일" >> $CREATE_FILE 2>&1
			ls -al /etc/cron* >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-1. 현황 : at 파일 소유자 및 권한 확인(750)" >> $CREATE_FILE 2>&1
			ls -al /usr/bin/at  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-2. 현황 : /var/spool/at 디렉토리 내 파일" >> $CREATE_FILE 2>&1
			ls -al /var/spool/at/  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-3. 현황 : /var/spool/cron/atjobs/ 디렉토리 내 파일  소유자 및 권한 확인" >> $CREATE_FILE 2>&1
			ls -al /var/spool/cron/atjobs/  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX | HP-UX)
			echo "1-1. 현황 : crontab 파일(750)" >> $CREATE_FILE 2>&1
			ls -al /usr/bin/crontab >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-2. 현황 : /var/spool/cron/crontabs 내 작업 목록 파일" >> $CREATE_FILE 2>&1
			ls -al /var/spool/cron/crontabs/ >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-3. 현황 : /var/adm/cron/ 디렉토리 내 cron 관련 파일" >> $CREATE_FILE 2>&1
			ls -al /var/adm/cron/ >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-1. 현황 : at 파일 소유자 및 권한 확인" >> $CREATE_FILE 2>&1
			ls -al /usr/bin/at  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-2. 현황 : /var/spool/cron/atjobs 디렉토리 내 파일" >> $CREATE_FILE 2>&1
			ls -al /var/spool/cron/atjobs/  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-38] DoS공격에 취약한 서비스 비활성화"
	echo "[U-38] DoS공격에 취약한 서비스 비활성화"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : echo, discard, daytime, chargen 서비스가 비활성화 되어있거나 결과값이 없을경우에 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			echo "1-1. 현황(Solaris 9버전 이하) : ps -ef | egrep 'echo|discard|daytime|chargen' 없으면 양호" >> $CREATE_FILE 2>&1
			ps -ef | egrep "echo|discard|daytime|chargen" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-2. 현황(Solaris 9버전 이하) : /etc/inetd.conf | egrep 'echo|discard|daytime|chargen' 확인하여 해당 서비스 주석 확인" >> $CREATE_FILE 2>&1
			cat /etc/inetd.conf | egrep "echo|discard|daytime|chargen" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-3. 현황(Solaris 10버전 이상) : 서비스 비활성화(disable) 확인, 결과 없으면 양호" >> $CREATE_FILE 2>&1
			svcs -a | egrep "echo|discard|daytime|chargen" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-4. inetadm 서비스 확인" >> $CREATE_FILE 2>&1
			inetadm | grep enable | egrep "echo|discard|daytime|chargen" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "1. inetd : cat /etc/inetd.conf 내 서비스 활성화 여부 확인" >> $CREATE_FILE 2>&1
			cat /etc/inetd.conf >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1 #간격조절
			echo "2. xinetd 디렉터리 내 서비스 활성화 여부 확인" >> $CREATE_FILE 2>&1
			echo "2-1. 현황 : chargen 확인" >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/chargen >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/chargen-dgram >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-2. 현황 : daytime 확인" >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/daytime >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/daytime-dgram >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-3. 현황 : discard 확인" >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/discard >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/discard-dgram >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-4. 현황 : echo 확인" >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/echo >> $CREATE_FILE 2>&1
			cat /etc/xinetd.d/echo-dgram >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : systemd 서비스 활성화 확인" >> $CREATE_FILE 2>&1
			systemctl list-units --type=service | grep -E "echo|discard|daytime|chargen" >> $CREATE_FILE 2>&1
			;;
		AIX | HP-UX)
			echo "1. 현황 : /etc/inetd.conf 확인하여 해당 서비스 주석 확인" >> $CREATE_FILE 2>&1
			cat /etc/inetd.conf >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-39] 불필요한 NFS 서비스 비활성화"
	echo "[U-39] 불필요한 NFS 서비스 비활성화"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 불필요한 NFS 서비스 관련 데몬이 비활성화 되어 있는 경우" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "1. 현황 : nfs|mountd|statd 서비스 확인" >> $CREATE_FILE 2>&1
	ps -ef | egrep "rpc\.statd|rpc\.mountd|nfsd" | grep -v grep >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1

	case $OS in
		SunOS  | HP-UX)
			echo "2. 현황(Solaris 10버전 이상) : nfs|mountd|statd 서비스 확인" >> $CREATE_FILE 2>&1
			inetadm | egrep "nfs|statd|lockd" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "2. 현황 : NFS 서비스 활성화 여부 확인 " >> $CREATE_FILE 2>&1
			systemctl list-units --type=service | grep nfs >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-40] NFS 접근통제"
	echo "[U-40] NFS 접근통제"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 접근 통제 설정되어있으며 NFS 설정 파일 접근 권한이 644 이하인 경우" >> $CREATE_FILE 2>&1
	echo "판단기준 : U-39에서 NFS 서비스 비활성화 되어있으면 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			if [ -f /etc/dfs/dfstab ]
			then
				echo "1-1. 현황 : ls -al /etc/dfs/dfstab 파일" >> $CREATE_FILE 2>&1
			    ls -al /etc/dfs/dfstab >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				echo "2. 현황 : /etc/dfs/dfstab 파일" >> $CREATE_FILE 2>&1
				cat /etc/dfs/dfstab >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "1. 현황 : /etc/dfs/dfstab 파일이 없습니다." >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi

			if [ -f /etc/dfs/sharetab ]
			then
				echo "1-2. 현황 : ls -al /etc/dfs/sharetab 파일" >> $CREATE_FILE 2>&1
			    ls -al /etc/dfs/sharetab >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "1-2. 현황 : /etc/dfs/sharetab 파일이 없습니다." >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
			;;
		Linux | AIX)
			if [ -f /etc/etc/exports ]
			then
				echo "1.현황 : ls -l /etc/exports" >> $CREATE_FILE 2>&1
				ls -l /etc/exports >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				echo "2.현황 : cat /etc/exports" >> $CREATE_FILE 2>&1
				cat /etc/exports >> $CREATE_FILE 2>&1
			    echo " " >> $CREATE_FILE 2>&1
			else
				echo "1. 현황 : /etc/exports 파일이 없습니다." >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
			;;
		HP-UX)
			echo "1-1.현황 : ls -l /etc/dfs/dfstab" >> $CREATE_FILE 2>&1
			ls -l /etc/dfs/dfstab >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-2.현황 : ls -l /etc/dfs/sharetab" >> $CREATE_FILE 2>&1
			ls -l /etc/dfs/sharetab >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2.현황 : cat /etc/dfs/dfstab" >> $CREATE_FILE 2>&1
			cat /etc/dfs/dfstab >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3.현황 : ls -l /etc/exports" >> $CREATE_FILE 2>&1
			ls -l /etc/exports >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4.현황 : cat /etc/exports" >> $CREATE_FILE 2>&1
			cat /etc/exports >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-41] 불필요한 automountd 제거"
	echo "[U-41] 불필요한 automountd 제거"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : automountd 및 autofs 서비스가 비활성화 된 경우 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
	SunOS)
		echo "2. 현황(Solaris 10버전 이상) : automountd 서비스 확인" >> $CREATE_FILE 2>&1
		svcs -a | egrep "autofs" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	Linux)
		echo "1. 현황 : automountd 또는 autofs 서비스 확인" >> $CREATE_FILE 2>&1
		systemctl list-units --type=service | grep -E "automount|autofs" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	AIX)
		echo "1. 현황(Solaris 10버전 이상) : automountd 서비스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep "automountd" >> $CREATE_FILE 2>&1
		ps -ef | grep "autofs" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2. automountd 서비스 확인" >> $CREATE_FILE 2>&1
		lssrc -a | grep -E "automountd|autofs" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	HP-UX)
		echo "1. 현황 automountd 서비스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep "automountd" >> $CREATE_FILE 2>&1
		ps -ef | grep "autofs" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-42] 불필요한 RPC 서비스 비활성화"
	echo "[U-42] 불필요한 RPC 서비스 비활성화" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 :  불필요한 RPC 관련 서비스가 존재하지 않으면 양호" >> $CREATE_FILE 2>&1
	echo "불필요한 RPC 서비스 >> rpc.cmsd|rpc.ttdbserverd|sadmind|rusersd|walld|sprayd|rstatd|rpc.nisd"	>> $CREATE_FILE 2>&1
	echo "불필요한 RPC 서비스 >> rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd|rexd" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1

	SERVICE_INETD="rpc.cmsd|rpc.ttdbserverd|sadmind|rusersd|walld|sprayd|rstatd|rpc.nisd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd|rexd"

	if [ -f /etc/inetd.conf ]
			then
				echo "1. 현황 : /etc/inetd.conf 파일 확인" >> $CREATE_FILE 2>&1
				cat /etc/inetd.conf | egrep $SERVICE_INETD >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "1. 현황 : /etc/inetd.conf 파일 없음 " >> $CREATE_FILE 2>&1
	fi
	
	
	case $OS in
		Linux)
			if [ -d /etc/xinetd ]
			then
					for file in $SERVICE_INETD
					do
						echo "2. 현황 : /etc/xinetd.d/$file 파일 확인" >> $CREATE_FILE 2>&1
						cat /etc/xinetd.d/$file
						echo " " >> $CREATE_FILE 2>&1
					done
					echo "3. 현황 : ls -al /etc/xinetd.d/*" >> $CREATE_FILE 2>&1
					ls -al /etc/xinetd.d/* >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			else
				echo "1. 현황 : /etc/xinetd 디렉터리 없음 " >> $CREATE_FILE 2>&1
			fi

			echo "4. 현황 : RPC 서비스 확인" >> $CREATE_FILE 2>&1
			systemctl list-units --type=service | grep rpc >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;

		SunOS)
			echo "1-2. 현황(Solaris 10버전 이상) : RPC 관련 데몬 확인" >> $CREATE_FILE 2>&1
			inetadm | grep rpc | egrep "ttdbserver|rex|rstat|rusers|spray|wall|rquota" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-43] NIS, NIS+ 점검"
	echo "[U-43] NIS, NIS+ 점검"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : NIS, NIS+ 서비스를 비활성이면 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1

	case $OS in
		SunOS)
			echo "1. NIS 데몬 구동 확인" >> $CREATE_FILE 2>&1
			svcs -a | grep nis >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "1. 현황 : systemd 서비스 활성화 확인" >> $CREATE_FILE 2>&1
			systemctl list-units --type=service | grep -E "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			echo "1. 프로세스 확인" >> $CREATE_FILE 2>&1
			ps -ef | grep -E "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 NIS 서비스 확인" >> $CREATE_FILE 2>&1
			 lssrc -a | grep -E "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "1. 프로세스 확인" >> $CREATE_FILE 2>&1
			ps -ef | grep -E "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-44] tftp, talk 서비스 비활성화"
	echo "[U-44] tftp, talk 서비스 비활성화"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : tftp , tallk 서비스가 비활성이면 양호 " >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
		Linux)
			echo "1. 현황 : tftp,talk 서비스 확인" >> $CREATE_FILE 2>&1
			ps -ef | egrep "tftp|talk|ntalk" | grep -v grep >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1

			if [ -f /etc/inetd.conf ]
			then
				echo "2. 현황 : /etc/inetd.conf 주석처리여부 확인" >> $CREATE_FILE 2>&1
				cat /etc/inetd.conf | egrep "tftp|talk|ntalk" >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "2. 현황 : /etc/inetd.conf  파일 없음 " >> $CREATE_FILE 2>&1
			fi
			
			if [ -d /etc/xinetd ]
			then
				echo "3-1. 현황 : cat /etc/xinetd.d/tftp" >> $CREATE_FILE 2>&1
				cat /etc/xinetd.d/tftp >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				echo "3-2. 현황 : cat /etc/xinetd.d/talk" >> $CREATE_FILE 2>&1
				cat /etc/xinetd.d/talk >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				echo "3-3. 현황 : cat /etc/xinetd.d/ntalk" >> $CREATE_FILE 2>&1
				cat /etc/xinetd.d/ntalk >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "3. 현황 : /etc/xinetd 디렉터리 없음 " >> $CREATE_FILE 2>&1
			fi
			
			echo "4. 현황 : systemd 서비스 활성화 확인" >> $CREATE_FILE 2>&1
			systemctl list-units --type=service | grep -E "tftp|talk|ntalk" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		SunOS)
			echo "1. 현황(Solaris 10버전 이상) :  tftp,talk 데몬 구동 확인" >> $CREATE_FILE 2>&1
			inetadm | egrep "tftp|talk" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX | HP-UX)
			echo "1. 현황 : tftp,talk 서비스 확인" >> $CREATE_FILE 2>&1
			ps -ef | egrep "tftp|talk|ntalk" | grep -v grep >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1

			echo "2. 현황 : /etc/inetd.conf 주석처리여부 확인" >> $CREATE_FILE 2>&1
			cat /etc/inetd.conf | egrep "tftp|talk|ntalk" >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1


echo "[U-45] 메일 서비스 버전 점검"
	echo "[U-45] 메일 서비스 버전 점검"  >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : sendmail을 사용하지 않거나 버전이 최신버전(8.18.2 이상)인 경우 양호" >> $CREATE_FILE 2>&1
	echo "판단기준 : postfix 사용하지 않거나 버전이 최신버전(3.10.7 이상)인 경우 양호" >> $CREATE_FILE 2>&1
	echo "판단기준 :exim을 사용하지 않거나 버전이 최신버전(4.99.1 이상)인 경우 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1

	case $OS in
	Linux)
		echo "1. sendmail 버전 확인" >> $CREATE_FILE 2>&1
		sendmail -d0 -bt >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "1-1. sendmail 서비스 활성화 여부 확인" >> $CREATE_FILE 2>&1
		systemctl list-units --type=service | grep sendmail >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "2. postfix 버전 확인" >> $CREATE_FILE 2>&1
		postconf mail_version >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "2-1. postfix 서비스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep postfix | grep -v grep >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "3. Exim 서비스 확인" >> $CREATE_FILE 2>&1
		systemctl list-units --type=service | grep exim  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "3-1. Exim 서비스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep exim | grep -v grep >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	SunOS)
		echo "1. sendmail 버전 확인" >> $CREATE_FILE 2>&1
		/usr/sbin/sendmail -d grep -Version >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "2. postfix 버전 확인" >> $CREATE_FILE 2>&1
		/usr/lib/postfix/postconf | grep mail_version >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "3. Exim 버전 확인" >> $CREATE_FILE 2>&1
		/usr/sbin/exim -bV >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	AIX)
		echo "1. sendmail 버전 확인" >> $CREATE_FILE 2>&1
		sendmail -d0 -bt >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "1-2. sendmail 서비스 활성화 여부 확인" >> $CREATE_FILE 2>&1
		lssrc -a | grep sendmail >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "2. postfix 버전 확인" >> $CREATE_FILE 2>&1
		postconf mail_version >> $CREATE_FILE 2>&1
		
		echo "2-1. postfix 서비스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep postfix >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "3. Exim 서비스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep exim >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	HP-UX)
		echo "1. sendmail 버전 확인" >> $CREATE_FILE 2>&1
		sendmail -d0 -bt >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "1-2. sendmail 서비스 활성화 여부 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep sendmail >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "2. postfix 버전 확인" >> $CREATE_FILE 2>&1
		postconf mail_version >> $CREATE_FILE 2>&1
		
		echo "2-1. postfix 서비스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep postfix >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "3. Exim 버전 확인" >> $CREATE_FILE 2>&1
		exim -bV >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		echo "3-1. Exim 서비스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep exim >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	esac
	
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-46] 일반 사용자의 sendmail 실행 방지"
	echo "[U-46] 일반 사용자의 sendmail 실행 방지"  >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : SMTP 서비스를 사용하지 않거나, 일반 사용자의 Sendmail 사용 방지 설정(PrivacyOptions=restrictqrun) 인 경우 양호" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1

	if [ -f /etc/mail/sendmail.cf ]
	then
		echo "1. 현황 : /etc/mail/sendmail.cf 에서 옵션 확인" >> $CREATE_FILE 2>&1
		cat /etc/mail/sendmail.cf | grep PrivacyOptions >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1. 현황 :/etc/mail/sendmail.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	if [ -f /usr/sbin/postsuper ]
	then
		echo "2. 현황 : /usr/sbin/postsuper 에서 옵션 확인" >> $CREATE_FILE 2>&1
		ls -l /usr/sbin/postsuper >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "2. 현황 :/usr/sbin/postsuper 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	if [ -f /usr/sbin/exiqgrep ]
	then
		echo "3. 현황 : /usr/sbin/exiqgrep 에서 옵션 확인" >> $CREATE_FILE 2>&1
		ls -l /usr/sbin/exiqgrep >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "3. 현황 :/usr/sbin/exiqgrep 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-47] 스팸 메일 릴레이 제한"
	echo "[U-47] 스팸 메일 릴레이 제한"  >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : SMTP 서비스를 사용하지 않거나, 릴레이 제한 설정을 했으면 양호" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1

	if [ -f /etc/mail/sendmail.cf ]
	then
		echo "1-1. 현황 : /etc/mail/sendmail.cf에서 릴레이 허용 설정 확인_8.9버전 미만" >> $CREATE_FILE 2>&1
		cat /etc/mail/sendmail.cf | grep "R$\*" | grep "Relaying" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-1. 현황 :/etc/mail/sendmail.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	if [ -f /etc/mail/access ]
	then
		echo "1-2. 현황 : /etc/mail/access 파일에서 릴레이 허용 설정 확인_8.9버전 이상" >> $CREATE_FILE 2>&1
		grep -v '^#' /etc/mail/access | grep -E 'Relay|OK'
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-2. 현황 :/etc/mail/access 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	if [ -f /etc/mail/sendmail.mc ]
	then
		echo "1-3. 현황 : /etc/mail/sendmail.mc 파일에서 릴레이 허용 설정 확인_8.9버전 이상" >> $CREATE_FILE 2>&1
		grep -i relay /etc/mail/sendmail.mc
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-3. 현황 :/etc/mail/sendmail.mc 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	if [ -f /etc/postfix/main.cf ]
	then
		echo "2. 현황 : /etc/postfix/main.cf 파일에서 릴레이 허용 설정 확인" >> $CREATE_FILE 2>&1
		cat /etc/postfix/main.cf | grep -E "smtpd_recipient_restrictions|mynetworks" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "2. 현황 :/etc/postfix/main.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	if [ -f /etc/exim/exim.cf ]
	then
		echo "3-1. 현황 : /etc/exim/exim.cf 파일에서 릴레이 허용 설정 확인" >> $CREATE_FILE 2>&1
		cat /etc/exim/exim.cf | grep -E "relay_from hosts|hosts" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "3-1. 현황 :/etc/exim/exim.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	if [ -f /etc/exim4/exim4.cf ]
	then
		echo "3-2. 현황 : /etc/exim4/exim4.cf 파일에서 릴레이 허용 설정 확인" >> $CREATE_FILE 2>&1
		cat /etc/exim4/exim4.cf | grep -E "relay_from hosts|hosts" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "3-2. 현황 :/etc/exim4/exim4.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-48] Expn, vrfy 명령어 제한"
	echo "[U-48] Expn, vrfy 명령어 제한" >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 메일 서비스 미사용 또는 noexpn,novrfy 옵션 추가를 포함하고 있을경우 양호 " >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1	
		
	if [ -f /etc/mail/sendmail.cf ]
	then
		echo "1. 현황 : /etc/mail/sendmail.cf에서 릴레이 허용 설정 확인_8.9버전 미만" >> $CREATE_FILE 2>&1
		cat /etc/postfix/main.cf | grep -E "PrivacyOptions" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1. 현황 :/etc/mail/sendmail.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	
	if [ -f /etc/postfix/main.cf ]
	then
		echo "2. 현황 : /etc/postfix/main.cf 파일에서 릴레이 허용 설정 확인" >> $CREATE_FILE 2>&1
		cat /etc/postfix/main.cf | grep -E "disable_vrfy_command" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "2. 현황 :/etc/postfix/main.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	if [ -f /etc/exim/exim.cf ]
	then
		echo "3-1. 현황 : /etc/exim/exim.cf 파일에서 릴레이 허용 설정 확인" >> $CREATE_FILE 2>&1
		cat /etc/exim/exim.cf | grep -E "acl_smtp_vrfy|acl_smtp_expn" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "3-1. 현황 :/etc/exim/exim.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	if [ -f /etc/exim4/exim4.cf ]
	then
		echo "3-2. 현황 : /etc/exim4/exim4.cf 파일에서 릴레이 허용 설정 확인" >> $CREATE_FILE 2>&1
		cat /etc/exim4/exim4.cf | grep -E "acl_smtp_vrfy|acl_smtp_expn" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "3-2. 현황 :/etc/exim4/exim4.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1
	
echo "[U-49] DNS 보안 버전 패치"
	echo "[U-49] DNS 보안 버전 패치"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : DNS 서비스 비활성화 또는 주기적으로 패치 하는 경우" >> $CREATE_FILE 2>&1
	echo "참고 : BIND 9.20.18 버전이 안정 버전" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	
	case $OS in
	Linux)
		echo "1. DNS 서비스 활성화 여부 확인" >> $CREATE_FILE 2>&1
		systemctl list-units --type=service | grep named >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	SunOS)
		echo "1. DNS 서비스 구동 확인" >> $CREATE_FILE 2>&1
		svcs -a | grep dns >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	AIX)
		echo "1. DNS 서비스 활성화 여부 확인" >> $CREATE_FILE 2>&1
		lssrc -a | grep named >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	HP-UX)
		echo "1. DNS 서비스 활성화 여부 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep dns >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	esac
	
	echo "2. DNS 버전 확인" >> $CREATE_FILE 2>&1
	named -v >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-50] DNS Zone Transfer 설정"
	echo "[U-50] DNS Zone Transfer 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : Zone Fransfer를 허가된 사용자에게만 허용한 경우" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1

	if [ -f /etc/named.boot ]
	then
		echo "1. /etc/named.boot | grep xfrnets 확인" >> $CREATE_FILE 2>&1
		cat /etc/named.boot | grep -E 'xfrnets' >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1. 현황 :/etc/named.boot 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	if [ -f /etc/bind/named.boot ]
	then
		echo "2. /etc/bind/named.boot | grep xfrnets 확인" >> $CREATE_FILE 2>&1
		cat /etc/bind/named.boot | grep -E 'xfrnets' >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "2. 현황 :/etc/bind/named.boot 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	
	if [ -f /etc/named.conf ]
	then
		echo "3. /etc/named.conf | grep allow-transfer 확인" >> $CREATE_FILE 2>&1
		cat /etc/named.conf | grep 'allow-transfer' >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "3. 현황 :/etc/named.conf이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	if [ -f /etc/bind/named.conf.options ]
	then
		echo "4. /etc/bind/named.conf.options | grep allow-transfer 확인" >> $CREATE_FILE 2>&1
		cat /etc/bind/named.conf.options | grep 'allow-transfer' >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "4. 현황 : /etc/bind/named.conf.options이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-51] DNS 서비스의 취약한 동적 업데이트 설정 금지"
	echo "[U-51] DNS 서비스의 취약한 동적 업데이트 설정 금지"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : DNS 서비스의 동적 업데이트 기능이 비활성화되었거나, 활성화 시 적절한 접근통제를 수행하고있는 경우" >> $CREATE_FILE 2>&1

	if [ -f /etc/named.conf ]
	then
		echo "1. 현황 : /etc/named.conf  파일에서 동적 업데이트 기능 확인" >> $CREATE_FILE 2>&1
		cat /etc/named.conf | grep allow-update >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1. 현황 : /etc/named.conf 이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	
	if [ -f /etc/named.conf ]
	then
		echo "2. 현황 : /etc/bind/named.conf.options 파일에서 동적 업데이트 기능 확인" >> $CREATE_FILE 2>&1
		cat /etc/bind/named.conf.options | grep allow-update >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "2. 현황 : /etc/bind/named.conf.options 이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi

	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-52] Telnet 서비스 비활성화"
	echo "[U-52] Telnet 서비스 비활성화"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 원격 접속 시 telnet 프로토콜 비활성화한 경우" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1

	case $OS in
		SunOS)
			echo "1. 현황 : telnet 서비스 확인(SOL10 이상)" >> $CREATE_FILE 2>&1
			svcs -a | grep telnet >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			if [ -f /etc/inetd.conf ]
			then
				echo "1. 현황 : /etc/inetd.conf 파일 내 Telnet 서비스 활성화 확인" >> $CREATE_FILE 2>&1
				cat /etc/inetd.conf | grep telnet >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "1. 현황 : /etc/inetd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/xinetd.conf ]
			then
				echo "2. 현황 : /etc/xinetd.conf 파일 내 Telnet 서비스 활성화 확인" >> $CREATE_FILE 2>&1
				cat /etc/xinetd/telnet | grep disable >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "2. 현황 : /etc/xinetd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
			
			echo "3. 현황 : Telnet 서비스 활성화 확인" >> $CREATE_FILE 2>&1
			systemctl list-units --type=socket | grep telnet >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX | HP-UX)
			echo "1. 현황 : /etc/inetd.conf 파일 내 Telnet 서비스 활성화 확인" >> $CREATE_FILE 2>&1
			cat /etc/inetd.conf | grep telnet >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-53] FTP 서비스 정보 노출 제한"
	echo "[U-53] FTP 서비스 정보 노출 제한"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : FTP 접속 배너에 노출되는 정보가 없는 경우" >> $CREATE_FILE 2>&1
	
	case $OS in
		SunOS | Linux)
						
			if [ -f /etc/vsftpd/vsftpd.conf ]
			then
				echo "1. 현황 : vsftp 설정 파일 내 노출 정보 확인" >> $CREATE_FILE 2>&1
				cat /etc/vsftpd/vsftpd.conf | grep ftpd_banner >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "1. 현황 : /etc/vsftpd/vsftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/vsftpd/vsftpd.conf ]
			then
				echo "2. 현황 : vsftp 설정 파일 내 노출 정보 확인" >> $CREATE_FILE 2>&1
				cat /etc/proftpd.conf | grep ServerIdent  >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "2. 현황 : cat /etc/proftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/vsftpd/vsftpd.conf ]
			then
				echo "3. 현황 : vsftp 설정 파일 내 노출 정보 확인" >> $CREATE_FILE 2>&1
				cat /etc/proftpd/proftpd.conf | grep ServerIdent >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "3. 현황 : /etc/proftpd/proftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
			;;
		AIX)
			echo "1. 현황 : vsftp 설정 파일 내 노출 정보 확인" >> $CREATE_FILE 2>&1
			cat /etc/proftpd.conf | grep ServerIdent  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "[Step 1] inetd에서 FTP 서비스 사용 여부 확인" >> $CREATE_FILE 2>&1
			echo "----------------------------------------------" >> $CREATE_FILE 2>&1
			if [ -f /etc/inetd.conf ]; then
				grep -i ftp /etc/inetd.conf >> $CREATE_FILE 2>&1
			else
				echo "/etc/inetd.conf 파일이 존재하지 않음" >> $CREATE_FILE 2>&1
			fi
			echo

			echo "[Step 2] ftpaccess 설정 확인" >> $CREATE_FILE 2>&1
			echo "----------------------------------------------" >> $CREATE_FILE 2>&1
			FTPACCESS="/etc/ftpd/ftpaccess"

			if [ -f $FTPACCESS ]; then
				echo "ftpaccess 파일 존재함: $FTPACCESS" >> $CREATE_FILE 2>&1
				echo >> $CREATE_FILE 2>&1
				echo "▶ hostname / version 노출 제한 설정 확인" >> $CREATE_FILE 2>&1
				grep -i "suppresshostname" $FTPACCESS 
				grep -i "suppressversion" $FTPACCESS
				echo >> $CREATE_FILE 2>&1
				echo "▶ 배너 / greeting 설정 확인" >> $CREATE_FILE 2>&1
				grep -Ei "banner|greeting" $FTPACCESS >> $CREATE_FILE 2>&1
			else >> $CREATE_FILE 2>&1
				echo "ftpaccess 파일이 존재하지 않음" >> $CREATE_FILE 2>&1
			fi
			echo >> $CREATE_FILE 2>&1

			echo "[Step 3] FTP 배너 파일 내용 확인" >> $CREATE_FILE 2>&1
			echo "----------------------------------------------" >> $CREATE_FILE 2>&1

			BANNER_FILE=`grep -Ei "banner|greeting" $FTPACCESS 2>/dev/null | awk '{print $2}'`

			if [ -n "$BANNER_FILE" ] && [ -f "$BANNER_FILE" ]; then
				echo "배너 파일 경로: $BANNER_FILE" >> $CREATE_FILE 2>&1
				echo "---------- 배너 내용 ----------" >> $CREATE_FILE 2>&1
				cat $BANNER_FILE >> $CREATE_FILE 2>&1
				echo "--------------------------------" >> $CREATE_FILE 2>&1
			else
				echo "배너 파일이 설정되어 있지 않거나 파일이 존재하지 않음" >> $CREATE_FILE 2>&1
			fi
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-54] 암호화되지 않은 FTP 비활성화"
	echo "[U-54] 암호화되지 않은 FTP 비활성화"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : 암호화되지 않은 FTP 서비스가 비활성화된 경우" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			echo "1. 현황 : ftp 서비스 확인(vsftpd)" >> $CREATE_FILE 2>&1
			svcs -a | grep vsftpd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "2. 현황 : ftp 서비스 확인(proftpd)" >> $CREATE_FILE 2>&1
			svcs -a | grep proftpd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			if [ -f /etc/inetd.conf ]
			then
				echo "1. 현황 : /etc/inetd.conf 파일 내 ftp 서비스 활성화 확인" >> $CREATE_FILE 2>&1
				cat /etc/inetd.conf | grep ftp >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "1. 현황 : /etc/inetd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/xinetd.conf ]
			then
				echo "2. 현황 : /etc/xinetd.conf 파일 내 ftp 서비스 활성화 확인" >> $CREATE_FILE 2>&1
				cat /etc/xinetd/ftp | grep service >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			else
				echo "2. 현황 : /etc/xinetd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
			
			echo "3. 현황 : Telnet 서비스 활성화 확인(vsftpd)" >> $CREATE_FILE 2>&1
			systemctl list-units --type=service | grep vsftpd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "4. 현황 : Telnet 서비스 활성화 확인(proftp)" >> $CREATE_FILE 2>&1
			systemctl list-units --type=service | grep proftp >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX | HP-UX)
			echo "1. 현황 : /etc/inetd.conf 파일 내 ftp 서비스 활성화 확인" >> $CREATE_FILE 2>&1
			cat /etc/inetd.conf | grep ftp >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "2. 현황 : vsftp 서비스 활성화 확인" >> $CREATE_FILE 2>&1
			ps -ef | grep vsftp
			echo " " >> $CREATE_FILE 2>&1
			
			echo "3. 현황 : proftp 서비스 활성화 확인" >> $CREATE_FILE 2>&1
			ps -ef | grep proftp
			echo " " >> $CREATE_FILE 2>&1
			;;
		esac
	echo "[END]" >> $CREATE_FILE 2>&1
	
echo "[U-55] FTP계정 shell 제한"
	echo "[U-55] FTP계정 shell 제한" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : ftp 서비스가 비활성화 또는 ftp 계정의 쉘이 /bin/false(솔라리스 /usr/bin/false) 또는 /sbin/nologin이면 양호  " >> $CREATE_FILE 2>&1
	echo "판단기준 참고 : ftp 서비스 상태는 54번 항목 참고" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	if [ `cat /etc/passwd | grep ftp | wc -l` -gt 0 ]
	then
		echo "1. 현황 : /etc/passwd | grep ftp" >> $CREATE_FILE 2>&1
		cat /etc/passwd | grep ftp >> $CREATE_FILE 2>&1
	else
		echo "1. ftp 프로세스가 없습니다." >> $CREATE_FILE 2>&1
	fi
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-56] ftp 서비스 접근 제어 설정"
	echo "[U-56] ftp 서비스 접근 제어 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "참고 : 특정 IP주소 또는 호스트에서만 FTP 서버에 접속할 수 있도록 접근 제어 설정을 적용한 경우" >> $CREATE_FILE 2>&1
	if [ -f /etc/ftpusers ]
	then
		echo "1-1. /etc/ftpusers 확인" >> $CREATE_FILE 2>&1
		ls -l /etc/ftpusers >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "1-2. /etc/ftpusers 파일 내 접근제어 확인" >> $CREATE_FILE 2>&1
		cat /etc/ftpusers >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-1. 현황 :/etc/ftpusers 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	
	if [ -f /etc/ftpd/ftpusers ]
	then
		echo "1-3. /etc/ftpd/ftpusers 확인" >> $CREATE_FILE 2>&1
		ls -l /etc/ftpd/ftpusers >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "1-4. /etc/ftpd/ftpusers 파일 내 접근제어 확인" >> $CREATE_FILE 2>&1
		cat /etc/ftpd/ftpusers >> $CREATE_FILE 2>&1
	else
		echo "1-2. 현황 :/etc/ftpd/ftpusers 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	
	if [ -f /etc/vsftpd.conf ]
	then
		echo "2-1. /etc/vsftpd.ftpusers 확인" >> $CREATE_FILE 2>&1
		ls -l /etc/vsftpd.ftpusers >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2-2. /etc/vsftpd.conf 파일 내 접근제어 확인" >> $CREATE_FILE 2>&1
		cat /etc/vsftpd.conf | grep userlist_enable >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "2-1. 현황 : /etc/vsftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	
	if [ -f /etc/vsftpd/vsftpd.conf ]
	then
		echo "2-3. /etc/vsftpd/ftpusers 확인" >> $CREATE_FILE 2>&1
		ls -l /etc/vsftpd/ftpusers >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2-4. /etc/vsftpd/vsftpd.conf파일 내 접근제어 확인" >> $CREATE_FILE 2>&1
		cat /etc/vsftpd/vsftpd.conf | grep userlist_enable >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "2-2. 현황 : /etc/vsftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	
	if [ -f /etc/proftpd.conf ]
	then
		echo "3-1. /etc/proftpd.conf 확인" >> $CREATE_FILE 2>&1
		ls -l /etc/proftpd.conf >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "3-2. /etc/proftpd.conf 파일 내 접근제어 확인" >> $CREATE_FILE 2>&1
		cat /etc/proftpd.conf >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "3-1. 현황 : /etc/proftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	
	if [ -f /etc/proftpd/proftpd.conf ]
	then
		echo "3-3. /etc/proftpd/proftpd.conf 확인" >> $CREATE_FILE 2>&1
		ls -l /etc/proftpd/proftpd.conf >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "3-4. /etc/proftpd/proftpd.conf 파일 내 접근제어 확인" >> $CREATE_FILE 2>&1
		cat /etc/proftpd/proftpd.conf >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "3-2. 현황 : /etc/proftpd/proftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-57] Ftpusers 파일 설정"
	echo "[U-57] Ftpusers 파일 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : root 계정으로 직접 접속 할 수 없도록 설정 " >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	if [ -f /etc/ftpusers ]
	then
		echo "1-1. 현황(기본FTP,vsFTP,ProFTP) : /etc/ftpusers 파일" >> $CREATE_FILE 2>&1
		cat /etc/ftpusers | grep root >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-1. 현황(기본FTP,vsFTP,ProFTP) : /etc/ftpusers 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	if [ -f /etc/ftpd/ftpusers ]
	then
		echo "1-2 현황(기본FTP,ProFTP) : /etc/ftpd/ftpusers 파일" >> $CREATE_FILE 2>&1
		cat /etc/ftpd/ftpusers | grep root >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-2. 현황(기본FTP,ProFTP) : /etc/ftpd/ftpusers 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	if [ -f /etc/vsftpd.conf ]
	then
		echo "1-3. 현황(vsFTP) : /etc/vsftpd.conf 파일" >> $CREATE_FILE 2>&1
		cat /etc/vsftpd.conf | grep userlist_enable >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-3. 현황(vsFTP) : /etc/vsftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	if [ -f /etc/vsftpd/vsftpd.conf ]
	then
		echo "1-4. 현황(vsFTP) : /etc/vsftpd/vsftpd.conf 파일" >> $CREATE_FILE 2>&1
		cat /etc/vsftpd/vsftpd.conf | grep userlist_enable >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-4. 현황(vsFTP) : /etc/vsftpd/vsftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	if [ -f /etc/vsftpd/ftpusers ]
	then
		echo "1-5. 현황(vsFTP) : /etc/vsftpd/ftpusers 파일" >> $CREATE_FILE 2>&1
		cat  /etc/vsftpd/ftpusers | grep root>> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-5. 현황(vsFTP) : /etc/vsftpd/ftpusers 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	if [ -f /etc/vsftpd.user_list ]
	then
		echo "1-6. 현황(vsFTP) : /etc/vsftpd.ftpusers 파일" >> $CREATE_FILE 2>&1
		cat  /etc/vsftpd.user_list | grep root>> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-6. 현황(vsFTP) : /etc/vsftpd.user_list 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	if [ -f /etc/vsftpd/user_list ]
	then
		echo "1-7. 현황(vsFTP) : /etc/vsftpd/user_list 파일" >> $CREATE_FILE 2>&1
		cat  /etc/vsftpd/user_list | grep root>> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-7. 현황(vsFTP) : /etc/vsftpd/user_list 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	if [ -f /etc/proftpd.conf ]
	then
		echo "1-8. 현황(ProFTP) : /etc/proftpd.conf 파일" >> $CREATE_FILE 2>&1
		cat  /etc/proftpd.conf | grep UseFtpUsers >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-8. 현황(ProFTP) : /etc/proftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	if [ -f /etc/proftpd/proftpd.conf ]
	then
		echo "1-9. 현황(ProFTP) : /etc/proftpd/proftpd.conf 파일" >> $CREATE_FILE 2>&1
		cat  /etc/proftpd/proftpd.conf | grep UseFtpUsers >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	else
		echo "1-9. 현황(ProFTP) : /etc/proftpd/proftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	fi
	
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-58] 불필요한 SNMP 서비스 구동 점검"
	echo "[U-58] 불필요한 SNMP 서비스 구동 점검"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : SNMP 서비스를 사용하지 않는 경우 양호 " >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1

	case $OS in
		SunOS)
			echo "1. 현황 : SNMP 프로세스 확인" >> $CREATE_FILE 2>&1
			ps -ef | grep snmp | grep -v "grep" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		
			echo "2. 현황 : snmp 서비스 확인(SOL10 이상)" >> $CREATE_FILE 2>&1
			svcs -a | grep snmp >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "1. 현황 : SNMP 서비스 활성화 확인" >> $CREATE_FILE 2>&1
			systemctl list-units --type=service | grep snmpd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		AIX)
			echo "1. 현황 : SNMP 서비스 활성화 확인" >> $CREATE_FILE 2>&1
			lssrc -a | grep snmp >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "1. 현황 : SNMP 프로세스 확인" >> $CREATE_FILE 2>&1
			ps -ef | grep snmp | grep -v "grep" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-59] 안전한 SNMP 버전 사용"
	echo "[U-59] 안전한 SNMP 버전 사용"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : snmp 서비스를 v3 이상으로 사용하는 경우" >> $CREATE_FILE 2>&1
	
	if [ -f /etc/snmp/snmpd.conf ]
		then
			echo "1. 현황 : SNMP 서비스 활성화 확인(v1, v2c)" >> $CREATE_FILE 2>&1
			cat /etc/snmp/snmpd.conf | grep group | grep -v "^#" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : SNMP 서비스 활성화 확인(v1, v2c)" >> $CREATE_FILE 2>&1
			cat /etc/snmp/snmpd.conf | grep com2sec | grep -v "^#">> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : SNMP 서비스 활성화 확인(v3)" >> $CREATE_FILE 2>&1
			cat /etc/snmp/snmpd.conf | grep createUser >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4. 현황 : SNMP 서비스 활성화 확인(v3)" >> $CREATE_FILE 2>&1
			cat /etc/snmp/snmpd.conf | grep rouser >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		else
			echo "1. 현황 : /etc/snmp/snmpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
	fi

	echo "5. 현황 : SNMP 서비스 접속 테스트(v2c)" >> $CREATE_FILE 2>&1
	snmpwalk -v2c -c public localhost  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "6. 현황 : SNMP 서비스 접속 테스트(v1)" >> $CREATE_FILE 2>&1
	snmpwalk -v1 -c public localhost  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-60] SNMP Community String 복잡성 설정"
	echo "[U-60] SNMP Community String 복잡성 설정"  >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : Community string이 public/private가 아닌 복잡성 설정시 양호 " >> $CREATE_FILE 2>&1
	echo "참고 : Snmp 서비스 상태는 58번 항목 참고" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			echo "1. 현황 : snmp 설정값 확인(SOL 9이하)" >> $CREATE_FILE 2>&1
			cat /etc/snmp/conf/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : snmp 설정값 확인(SOL 10)" >> $CREATE_FILE 2>&1
			cat /etc/sma/snmp/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : snmp 설정값 확인(SOL 11)" >> $CREATE_FILE 2>&1
			cat /etc/net-snmp/snmp/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4. 현황 : snmp 설정값 확인(SOL 10 이상)" >> $CREATE_FILE 2>&1
			svcs -a | grep snmpdx >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			if [ -f /etc/snmp/snmpd.conf ]
			then
				echo "1. 현황 : snmp 설정값 확인 /etc/snmp/snmpd.conf" >> $CREATE_FILE 2>&1
				cat /etc/snmp/snmpd.conf | grep com2sec | grep -v \# >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				
				case "$ID" in
					ubuntu | debian | kali)
						echo "2. 현황 : snmp 설정값 확인(ubuntu)" >> $CREATE_FILE 2>&1
						cat /etc/snmp/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
						echo " " >> $CREATE_FILE 2>&1
						;;
				esac
			else
				echo "1. 현황 : /etc/snmp/snmpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
			;;
		AIX)
			echo "2-1 snmp 설정값 확인 /etc/snmpd.conf" >> $CREATE_FILE 2>&1
			cat /etc/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-2. 현황 : snmp 설정값 확인 /etc/snmpd/snmpd.conf" >> $CREATE_FILE 2>&1
			cat /etc/snmpd/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-3. 현황 : snmp 설정값 확인 etc/snmp/conf/snmpd.conf" >> $CREATE_FILE 2>&1
			cat /etc/snmp/conf/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-4. 현황 : snmp 설정값 확인 /etc/snmpdv3.conf" >> $CREATE_FILE 2>&1
			cat /etc/snmpdv3.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "2-1 snmp 설정값 확인 /etc/snmpd.conf" >> $CREATE_FILE 2>&1
			cat /etc/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-2. 현황 : snmp 설정값 확인 /etc/snmpd/snmpd.conf" >> $CREATE_FILE 2>&1
			cat /etc/snmpd/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-3. 현황 : snmp 설정값 확인 etc/snmp/conf/snmpd.conf" >> $CREATE_FILE 2>&1
			cat /etc/snmp/conf/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-61] SNMP Access Control 설정"
	echo "[U-61] SNMP Access Control 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : snmp 서비스에 접근제어 설정이 되어있는 경우" >> $CREATE_FILE 2>&1
	
	case $OS in
	SunOS)
		echo "1. 현황 : snmp 설정값 확인" >> $CREATE_FILE 2>&1
		cat /etc/net-snmp/snmp/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	Linux)
		if [ -f /etc/snmp/snmpd.conf ]
		then
			echo "1. 현황 : snmp 설정값 확인 /etc/snmpd/snmpd.conf" >> $CREATE_FILE 2>&1
			cat /etc/snmp/snmpd.conf | grep com2sec | grep -v "^#" >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			case "$ID" in
					ubuntu | debian | kali)
						echo "2. 현황 : snmp 설정값 확인_ubuntu" >> $CREATE_FILE 2>&1
						cat /etc/snmp/snmpd.conf | grep community | grep -v "^#" >> $CREATE_FILE 2>&1
						echo " " >> $CREATE_FILE 2>&1
						;;
			esac
		else
			echo "1. 현황 : /etc/snmp/snmpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		fi
		;;
	AIX)
		echo "2-1 snmp 설정값 확인 /etc/snmpd.conf" >> $CREATE_FILE 2>&1
		cat /etc/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2-2. 현황 : snmp 설정값 확인 /etc/snmpd/snmpd.conf" >> $CREATE_FILE 2>&1
		cat /etc/snmpd/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2-3. 현황 : snmp 설정값 확인 etc/snmp/conf/snmpd.conf" >> $CREATE_FILE 2>&1
		cat /etc/snmp/conf/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2-4. 현황 : snmp 설정값 확인 /etc/snmpdv3.conf" >> $CREATE_FILE 2>&1
		cat /etc/snmpdv3.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	HP-UX)
		echo "2-1 snmp 설정값 확인 /etc/snmpd.conf" >> $CREATE_FILE 2>&1
		cat /etc/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2-2. 현황 : snmp 설정값 확인 /etc/snmpd/snmpd.conf" >> $CREATE_FILE 2>&1
		cat /etc/snmpd/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2-3. 현황 : snmp 설정값 확인 etc/snmp/conf/snmpd.conf" >> $CREATE_FILE 2>&1
		cat /etc/snmp/conf/snmpd.conf | grep community | grep -v \# >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1
	
echo "[U-62] 로그온 시 경고 메시지 설정"
	echo "[U-62] 로그온 시 경고 메시지 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 로그온 메시지가 설정되어 있지 않을경우 취약" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1

	case $OS in
		SunOS)
			echo "1-1. 현황 : 서버 로그인 메시지 설정 /etc/motd " >> $CREATE_FILE 2>&1
			cat /etc/motd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-2. 현황 : 서버 로그인 메시지 설정 /etc/issue " >> $CREATE_FILE 2>&1
			cat /etc/issue >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "2. 참고 : TELNET 서비스 상태는 52번 항목 참고" >> $CREATE_FILE 2>&1
		    echo "2-1. telnet 로그인 메시지 설정 /etc/issue.net" >> $CREATE_FILE 2>&1
			cat /etc/issue.net >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-2. telnet 로그인 메시지 설정 /etc/default/telnetd" >> $CREATE_FILE 2>&1
			cat /etc/default/telnetd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "3. 참고 : SSH 서비스 상태는 1번 항목 참고" >> $CREATE_FILE 2>&1
			echo "3. 현황 : SSH 서비스 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/ssh/sshd_config >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			if [ -f /etc/snmp/snmpd.conf ]
				then
					echo "4~6. 참고 :메일 서비스 상태는 45번 항목 참고" >> $CREATE_FILE 2>&1
					echo "4. 현황 : Sendmail 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/mail/sendmail.cf | grep SmtpGreetingMessage >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "4. 현황 : /etc/mail/sendmail.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/postfix/main.cf ]
				then
					echo "5. 현황 : Postfix 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/postfix/main.cf | grep smtpd_banner >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "5. 현황 : /etc/postfix/main.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /exim/exim.conf ]
				then
					echo "6. 현황 : Exim 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /exim/exim.conf | grep smtp_banner >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "6. 현황 : /exim/exim.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			echo "7. 참고 :FTP 서비스 상태는 35번 항목 참고" >> $CREATE_FILE 2>&1
			echo "7-1. 현황 : FTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/default/ftpd | grep BANNER >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			if [ -f /etc/vsftpd/vsftpd.conf ]
				then
					echo "7-2. 현황 : vsFTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/vsftpd/vsftpd.conf | grep ftpd_banner >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "7-2. 현황 : /etc/vsftpd/vsftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/proftpd/proftpd.conf ]
				then
					echo "7-3. 현황 : ProFTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/proftpd/proftpd.conf | grep DisplayLogin >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "7-3. 현황 : /etc/proftpd/proftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			;;
		Linux)
			echo "1-1. 현황 : 서버 로그인 메시지 설정 /etc/motd " >> $CREATE_FILE 2>&1
			cat /etc/motd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-2. 현황 : 서버 로그인 메시지 설정 /etc/issue " >> $CREATE_FILE 2>&1
			cat /etc/issue >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "2. 참고 : TELNET 서비스 상태는 52번 항목 참고" >> $CREATE_FILE 2>&1
		    echo "2. telnet 로그인 메시지 설정 /etc/issue.net" >> $CREATE_FILE 2>&1
			cat /etc/issue.net >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "3. 참고 : SSH 서비스 상태는 1번 항목 참고" >> $CREATE_FILE 2>&1
			echo "3. 현황 : SSH 서비스 로그인시 메시지 설정 /etc/ssh/sshd_config | grep Banner" >> $CREATE_FILE 2>&1
			cat /etc/ssh/sshd_config | grep Banner >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			BANNER_LINE=$(awk '
			$1 == "Banner" {
				print $0
				exit
			}
			$1 == "#Banner" && $2 == "none" {
				print "NONE"
				exit
			}
			' "/etc/ssh/sshd_config")

			if [ "$BANNER_LINE" = "NONE" ]; then
				echo "ssh 로그인 배너가 없습니다" >> "$CREATE_FILE" 2>&1
			else
				BANNER_FILE=$(echo "$BANNER_LINE" | awk '{ print $2 }')

				if [ -n "$BANNER_FILE" ] && [ "$BANNER_FILE" != "none" ] && [ -f "$BANNER_FILE" ]; then
					echo "=== SSH Banner File: $BANNER_FILE ===" >> "$CREATE_FILE" 2>&1
					cat "$BANNER_FILE" >> "$CREATE_FILE" 2>&1
				elif [ "$BANNER_FILE" = "none" ]; then
					echo "ssh 로그인 배너가 없습니다" >> "$CREATE_FILE" 2>&1
				else
					:
				fi
			fi
			
			if [ -f /etc/mail/sendmail.cf ]
				then
					echo "4~6. 참고 :메일 서비스 상태는 45번 항목 참고" >> $CREATE_FILE 2>&1
					echo "4. 현황 : Sendmail 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/mail/sendmail.cf | grep SmtpGreetingMessage >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "4. 현황 : /etc/mail/sendmail.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/postfix/main.cf ]
				then
					echo "5. 현황 : Postfix 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/postfix/main.cf | grep smtpd_banner >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "5. 현황 : /etc/postfix/main.cf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /exim/exim.conf ]
				then
					echo "6-1. 현황 : Exim 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /exim/exim.conf | grep smtp_banner >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "6-1. 현황 : /exim/exim.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /exim4/exim4.conf ]
				then
					echo "6-2. 현황 : Exim 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /exim4/exim4.conf | grep smtp_banner >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "6-2. 현황 : /exim4/exim4.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/vsftpd/vsftpd.conf ]
				then
					echo "7. 참고 :FTP 서비스 상태는 35번 항목 참고" >> $CREATE_FILE 2>&1
					echo "7-1. 현황 : vsFTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/vsftpd/vsftpd.conf | grep ftpd_banner >> $CREATE_FILE 2>&1
				else
					echo "7-1. 현황 : /etc/vsftpd/vsftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/vsftpd.conf ]
				then
					echo "7-2. 현황 : vsFTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/vsftpd.conf | grep ftpd_banner >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "7-2. 현황 : /etc/vsftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/proftpd/proftpd.conf ]
				then
					echo "7-3. 현황 : ProFTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/proftpd/proftpd.conf | grep DisplayLogin >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "7-3. 현황 : /etc/proftpd/proftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/proftpd.conf ]
				then
					echo "7-4. 현황 : ProFTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/proftpd.conf | grep DisplayLogin >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "7-4. 현황 : /etc/proftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/proftpd.conf ]
				then
					echo "8. 참고 :DNS 서비스 상태는 49번 항목 참고" >> $CREATE_FILE 2>&1
					echo "8-1. 현황 : DNS 서비스의 버전 질의 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/named.conf | grep version >> $CREATE_FILE 2>&1
				else
					echo "7-4. 현황 : /etc/proftpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			
			if [ -f /etc/bind/named.conf ]
				then
					echo "8-2. 현황 : DNS 서비스의 버전 질의 메시지 설정" >> $CREATE_FILE 2>&1
					cat /etc/bind/named.conf | grep version >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
				else
					echo "8-2. 현황 : /etc/bind/named.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
			fi
			;;
		AIX)
			echo "1-1. 현황 : 서버 로그인 메시지 설정 /etc/motd " >> $CREATE_FILE 2>&1
			cat /etc/motd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-2. 현황 : 서버 로그인 메시지 설정 /etc/issue " >> $CREATE_FILE 2>&1
			cat /etc/issue >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "2. 참고 : TELNET 서비스 상태는 52번 항목 참고" >> $CREATE_FILE 2>&1
		    echo "2. telnet 로그인 메시지 설정 /etc/security/login.cfg" >> $CREATE_FILE 2>&1
			cat /etc/security/login.cfg | grep herald >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "3. 참고 : SSH 서비스 상태는 1번 항목 참고" >> $CREATE_FILE 2>&1
			echo "3. 현황 : SSH 서비스 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/ssh/sshd_config | grep Banner >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "4~6. 참고 :메일 서비스 상태는 45번 항목 참고" >> $CREATE_FILE 2>&1
			echo "4. 현황 : Sendmail 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/mail/sendmail.cf | grep SmtpGreetingMessage >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
						
			echo "5. 현황 : Postfix 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/postfix/main.cf | grep smtpd_banner >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "6. 현황 : Exim 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /exim/exim.conf | grep smtp_banner >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "7. 참고 :FTP 서비스 상태는 35번 항목 참고" >> $CREATE_FILE 2>&1
			echo "7-1. 현황 : vsFTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/vsftpd.conf | grep ftpd_banner >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "7-2. 현황 : ProFTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/proftpd.conf | grep DisplayLogin >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "8. 참고 :DNS 서비스 상태는 49번 항목 참고" >> $CREATE_FILE 2>&1
			echo "8. 현황 : DNS 서비스의 버전 질의 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/named.conf | grep version >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "1-1. 현황 : 서버 로그인 메시지 설정 /etc/motd " >> $CREATE_FILE 2>&1
			cat /etc/motd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "1-2. 현황 : 서버 로그인 메시지 설정 /etc/issue " >> $CREATE_FILE 2>&1
			cat /etc/issue >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
						
			echo "3. 참고 : SSH 서비스 상태는 1번 항목 참고" >> $CREATE_FILE 2>&1
			echo "3. 현황 : SSH 서비스 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/ssh/sshd_config | grep Banner >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "4~6. 참고 :메일 서비스 상태는 45번 항목 참고" >> $CREATE_FILE 2>&1
			echo "4. 현황 : Sendmail 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/mail/sendmail.cf | grep SmtpGreetingMessage >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
						
			echo "5. 현황 : Postfix 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/postfix/main.cf | grep smtpd_banner >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "6. 현황 : Exim 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /exim/exim.conf | grep smtp_banner >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "7. 참고 :FTP 서비스 상태는 35번 항목 참고" >> $CREATE_FILE 2>&1
			echo "7-1. 현황 : vsFTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/vsftpd.conf | grep ftpd_banner >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "7-2. 현황 : ProFTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/proftpd.conf | grep DisplayLogin >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "7-3. 현황 : wuFTP 서비스 서버 로그인시 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/ftpd/ftpaccess | grep banner >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			echo "8. 참고 :DNS 서비스 상태는 49번 항목 참고" >> $CREATE_FILE 2>&1
			echo "8. 현황 : DNS 서비스의 버전 질의 메시지 설정" >> $CREATE_FILE 2>&1
			cat /etc/named.conf | grep version >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-63] sudo 명령어 접근 관리"
	echo "[U-63] sudo 명령어 접근 관리"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : 파일의 소유자 root이고 파일 권한 640 인 경우" >> $CREATE_FILE 2>&1
	ls -l /etc/sudoers >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-64] 주기적 보안패치 및 벤더 권고사항 적용"
	echo "[U-64] 주기적 보안패치 및 벤더 권고사항 적용"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 : 최신 버전의 kernel 패치 버전 또는 취약점이 존재하지 않은 버전 확인" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	case $OS in
		SunOS)
			echo "1. 현황 : cat /etc/release" >> $CREATE_FILE 2>&1
			cat /etc/release >> $CREATE_FILE 2>&1
			echo "2-1. 현황(SOL10 이하에서만 가능) : showrev -p" >> $CREATE_FILE 2>&1
			showrev -p >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2-2. 현황(SOL11에서만 가능) : pkg info kernel" >> $CREATE_FILE 2>&1
			pkg info kernel >> $CREATE_FILE 2>&1
			echo "2-3. 최신 패키지 확인" >> $CREATE_FILE 2>&1
			pkg list -af entire@latest >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "1. 현황 :  hostnamectl" >> $CREATE_FILE 2>&1
			hostnamectl >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : uname -r" >> $CREATE_FILE 2>&1
			uname -r >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : /etc/os-release or /etc/system-release" >> $CREATE_FILE 2>&1
			cat /etc/*-release >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			case "$ID" in
				ubuntu)
					echo "4. 현황 : ubuntu (pro 요금제 확인)" >> $CREATE_FILE 2>&1
					ua status --all >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					;;
			esac
			;;
		AIX)
			echo "1. 현황 : OS 버전 확인" >> $CREATE_FILE 2>&1
			oslevel -s >> $CREATE_FILE 2>&1
			
			echo "2. 현황 : 패치확인" >> $CREATE_FILE 2>&1
			instfix -i | grep ML >> $CREATE_FILE 2>&1
			instfix -i | grep SP >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		HP-UX)
			echo "1. 현황 : 패치확인" >> $CREATE_FILE 2>&1
			swlist -l product >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "[U-65] NTP 및 시각 동기화 설정"
	echo "[U-65] NTP 및 시각 동기화 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : NTP 및 시각 동기화 설정이 기준에 따라 적용된 경우" >> $CREATE_FILE 2>&1
	case $OS in
		SunOS | HP-UX | AIX)
			echo "1. 현황 : 동기화된 NTP 서버 확인" >> $CREATE_FILE 2>&1
			ntpq -pn >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			;;
		Linux)
			echo "1. 현황 : NTP 서비스 확인" >> $CREATE_FILE 2>&1
			systemctl list-units --type=service | grep ntp >> $CREATE_FILE 2>&1
			echo "1-1. 현황 : systemd-timesyncd 서비스 확인" >> $CREATE_FILE 2>&1
			systemctl status systemd-timesyncd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : 동기화된 NTP 서버 확인" >> $CREATE_FILE 2>&1
			ntpq -pn >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "3. 현황 : NTP 서비스 확인(chrony)" >> $CREATE_FILE 2>&1
			systemctl status chronyd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "4. 현황 : 동기화된 서버 확인(chrony)" >> $CREATE_FILE 2>&1
			chronyc sources -v >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "5.현황 : timedatectl 상세 내용" >> $CREATE_FILE 2>&1
			timedatectl  >> $CREATE_FILE 2>&1
			;;
	esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1
	
echo "[U-66] 정책에 따른 시스템 로깅 설정"
	echo "[U-66] 정책에 따른 시스템 로깅 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo "판단기준 :로그 기록 정책이 보안 정책에 따라 설정되어 있고 로그를 남기는 경우" >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
		echo "0. 현황 : syslog (PS)" >> $CREATE_FILE 2>&1
		ps -ef | grep 'syslog' | grep -v 'grep' >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	if [ -f /var/log/syslog ]
	then
		echo "1-1. 현황 : 로그 파일 존재 및 갱신 여부 확인 /var/log/syslog" >> $CREATE_FILE 2>&1
		ls -l /var/log/syslog >> $CREATE_FILE 2>&1
		echo "1-1-1. 현황 : 로그 기록 확인" >> $CREATE_FILE 2>&1
		tail -n 10 /var/log/syslog >> $CREATE_FILE 2>&1
	else
		echo "1-1. 현황 : /var/log/syslog 파일 없음" >> $CREATE_FILE 2>&1
	fi
	echo " " >> $CREATE_FILE 2>&1
	
	if [ -f /var/log/messages ]
	then
		echo "1-2. 현황 : 로그 파일 존재 및 갱신 여부 확인 /var/log/messages" >> $CREATE_FILE 2>&1
		ls -l /var/log/messages >> $CREATE_FILE 2>&1
		echo "1-2-1. 현황 : 로그 기록 확인" >> $CREATE_FILE 2>&1
		tail -n 10 /var/log/messages >> $CREATE_FILE 2>&1
	else
		echo "1-2. 현황 : /var/log/messages 파일 없음" >> $CREATE_FILE 2>&1
	fi
	echo " " >> $CREATE_FILE 2>&1

	if [ -f /etc/syslog.conf ]
	then
		echo "1. 현황 : /etc/syslog.conf 파일 내 로그 기록 정책 확인" >> $CREATE_FILE 2>&1
		cat /etc/syslog.conf >> $CREATE_FILE 2>&1
	else
		echo "1. 현황 : /etc/syslog.conf 파일 없음" >> $CREATE_FILE 2>&1
	fi
	echo " " >> $CREATE_FILE 2>&1

	if [ -f /etc/rsyslog.conf ]
	then
		echo "2. 현황 : /etc/rsyslog.conf" >> $CREATE_FILE 2>&1
		cat /etc/rsyslog.conf >> $CREATE_FILE 2>&1
	else
		echo "2. 현황 : /etc/rsyslog.conf 파일 없음" >> $CREATE_FILE 2>&1
	fi
	echo " " >> $CREATE_FILE 2>&1
	
	case "$ID" in
				ubuntu | debian | kali)
					if [ -f /etc/rsyslog.d/50-default.conf ]
					then
						echo "3. [Ubuntu]현황 : /etc/rsyslog.d/default.conf" >> $CREATE_FILE 2>&1
						ls -al /etc/rsyslog.d/50-default.conf >> $CREATE_FILE 2>&1
						cat /etc/rsyslog.d/50-default.conf >> $CREATE_FILE 2>&1
					else
						echo "3. [Ubuntu]현황 : /etc/rsyslog.d/50-default.conf 파일 없음" >> $CREATE_FILE 2>&1
					fi
				;;
	esac

	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "[U-67] 로그 디렉터리 소유지 및 권한 설정"
	echo "[U-67] 로그 디렉터리 소유지 및 권한 설정"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "[START]"  >> $CREATE_FILE 2>&1
	echo " " >> $CREATE_FILE 2>&1
	echo "판단기준 : 디렉터리 내 로그 파일의 소유자가 root이고, 권한이 644 이하인 경우" >> $CREATE_FILE 2>&1
		case $OS in
			HP-UX)
				echo "1. 현황 : 로그 파일 현황" >> $CREATE_FILE 2>&1
				ls -l /var/adm/syslog >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				;;
			AIX)
				echo "1. 현황 : 로그 파일 현황" >> $CREATE_FILE 2>&1
				ls -l /var/adm >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				;;
			SunOS | Linux)
				echo "1. 현황 : 로그 파일 현황" >> $CREATE_FILE 2>&1
				ls -pl /var/log | grep -v / >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				;;
			esac
	echo " " >> $CREATE_FILE 2>&1
	echo "[END]" >> $CREATE_FILE 2>&1

echo "======================================================================================================" >> $CREATE_FILE 2>&1
echo "추가 진단 항목 리스트"  >> $CREATE_FILE 2>&1
echo "======================================================================================================" >> $CREATE_FILE 2>&1
		echo "[추가 1] netrc 파일 검사"
		echo "[추가 1] netrc 파일 검사"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : .netrc 확장자 파일이 존재하지 않으면 양호" >> $CREATE_FILE 2>&1
		echo "1. netrc 파일 검사 결과 : find / -name *.netrc ">> $CREATE_FILE 2>&1
		find / -name "*.netrc"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1
		echo "[추가 2] IP포워딩 비활성화"
		echo "[추가 2] IP포워딩 비활성화" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : 두개의 결과값이 모두 0으로 나오면 양호 (IP포워딩 기능 미사용시 양호)" >> $CREATE_FILE 2>&1
		echo "1. 현황 : cat /proc/sys/net/ipv4/ip_forward" >> $CREATE_FILE 2>&1
		cat /proc/sys/net/ipv4/ip_forward  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "2. 현황 : cat /proc/sys/net/ipv4/conf/default/accept_source_route" >> $CREATE_FILE 2>&1
		cat /proc/sys/net/ipv4/conf/default/accept_source_route  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1
date   >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
echo "======================================================================================================" >> $CREATE_FILE 2>&1
echo "apache 점검"  >> $CREATE_FILE 2>&1
echo "======================================================================================================" >> $CREATE_FILE 2>&1

APACHE_CHECK=1

if ! systemctl is-active --quiet httpd 2>/dev/null && \
   ! systemctl is-active --quiet apache2 2>/dev/null && \
   ! pgrep -x httpd >/dev/null && \
   ! pgrep -x apache2 >/dev/null; then
    echo "[INFO] Apache 미실행 - 점검 제외"  >> $CREATE_FILE 2>&1
    APACHE_CHECK=0
fi

if [ $APACHE_CHECK -eq 1 ]; then
	echo "[INFO] Apache 실행 중 - 점검 시작"
    echo "[INFO] Apache 점검 시작"  >> $CREATE_FILE 2>&1
	
	echo "1 참고 : httpd 구동 확인(PS)"  >> $CREATE_FILE 2>&1
		ps -ef | grep httpd | awk '{print $8}' | uniq  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1

		echo "2. 참고 : Apache 구동 확인(PS)"  >> $CREATE_FILE 2>&1
		ps -ef | grep apache | awk '{print $8}' | uniq  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1

		case $OS in
			SunOS)
				echo "3. 참고(Solaris 10버전 이상) : : Apache 서비스 구동 확인" >> $CREATE_FILE 2>&1
				svcs -a | grep apache >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
					;;
			Linux)
				echo "4. 현황 : Apache 서비스 상태 확인(CentOS7 이상)" >> $CREATE_FILE 2>&1
				systemctl status httpd>> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
				
				case "$ID" in
					ubuntu | debian | kali)
						echo "5. 현황 : Apache 상태 확인(Ubuntu)" >> $CREATE_FILE 2>&1
						systemctl status apache2 >> $CREATE_FILE 2>&1
						echo " " >> $CREATE_FILE 2>&1
				;;
				esac
		;;
		esac
   
	echo "[WEB-01] Default 관리자 계정명 변경"
		echo "[WEB-01] Default 관리자 계정명 변경"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "apache는 해당 사항 없음" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-02] 취약한 비밀번호 사용 제한"
		echo "[WEB-02] 취약한 비밀번호 사용 제한"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "apache는 해당 사항 없음" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1
		
	echo "[WEB-03] 비밀번호 파일 권한 관리"
		echo "[WEB-03] 비밀번호 파일 권한 관리"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "apache는 해당 사항 없음" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-04] 웹 서비스 디렉터리 리스팅 방지 설정"
		echo "[WEB-04] 웹 서비스 디렉터리 리스팅 방지 설정"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : 디렉터리 리스팅이 설정되지 않은 경우" >> $CREATE_FILE 2>&1
		
		httpd_conf_=`find /etc -name httpd.conf`  >> $CREATE_FILE 2>&1
		httpd_conf_wc=`find /etc -name httpd.conf | wc -l`  >> $CREATE_FILE 2>&1
		apache_conf_=`find /etc -name apache2.conf`  >> $CREATE_FILE 2>&1
		apache_conf_wc=`find /etc -name apache2.conf | wc -l`  >> $CREATE_FILE 2>&1

		if [ $httpd_conf_wc -gt 0 ];
		then
				for file in $httpd_conf_
				do
					echo $file >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					#cat $file | egrep -i "<Directory|Indexes|</Directory" >> $CREATE_FILE 2>&1
					grep -n -C 7 'Indexes' $file >> $CREATE_FILE 2>&1
					echo "===================" >> $CREATE_FILE 2>&1
				done
		else
			if [ $apache_conf_wc -gt 0 ];
			then
				echo "1. 현황 : apache_conf 파일 확인" >> $CREATE_FILE 2>&1

				for file in $apache_conf_
				do
					echo $file >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					#cat $file | egrep -i "<Directory|Indexes|</Directory" >> $CREATE_FILE 2>&1
					grep -n -C 7 'Indexes' $file >> $CREATE_FILE 2>&1
					echo "===================" >> $CREATE_FILE 2>&1
				done
			else
				echo " " >> $CREATE_FILE 2>&1
				echo "설정 파일 없음 (양호)" >> $CREATE_FILE 2>&1
			fi
		fi
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-05] 지정하지 않은 CGI/ISAPI 실행 제한"
		echo "[WEB-05] 지정하지 않은 CGI/ISAPI 실행 제한"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : CGI 스크립트를 사용하지 않거나 CGI 스크립트가 실행 가능한 디렉터리를 제한한 경우" >> $CREATE_FILE 2>&1
		
		if [ $httpd_conf_wc -gt 0 ];
		then
				for file in $httpd_conf_
				do
					echo $file >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					echo "1. 현황 : cgi_module 존재여부 확인" >> $CREATE_FILE 2>&1
					#cat $file | egrep -i "cgi_module" >> $CREATE_FILE 2>&1
					grep -n -C 7 'cgi_module' $file >> $CREATE_FILE 2>&1
					echo "" >> $CREATE_FILE 2>&1
					echo "2. 현황 : ExecCGI 옵션 확인" >> $CREATE_FILE 2>&1
					grep -n -C 5 'ExecCGI' $file >> $CREATE_FILE 2>&1
					echo "" >> $CREATE_FILE 2>&1
				done
		else
			if [ $apache_conf_wc -gt 0 ];
			then
				for file in $apache_conf_
				do
					echo $file >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					echo "1. 현황 : cgi_module 존재여부 확인" >> $CREATE_FILE 2>&1
					#cat $file | egrep -i "cgi_module" >> $CREATE_FILE 2>&1
					grep -n -C 7 'cgi_module' $file >> $CREATE_FILE 2>&1
					echo "" >> $CREATE_FILE 2>&1
					echo "2. 현황 : ExecCGI 옵션 확인" >> $CREATE_FILE 2>&1
					grep -n -C 5 'ExecCGI' $file >> $CREATE_FILE 2>&1
					echo "" >> $CREATE_FILE 2>&1
				done
			else
				echo " " >> $CREATE_FILE 2>&1
				echo "설정 파일 없음" >> $CREATE_FILE 2>&1
			fi
		fi
		
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1


	echo "[WEB-06] 웹 서비스 상위 디렉터리 접근 제한 설정"
		echo "[WEB-06] 웹 서비스 상위 디렉터리 접근 제한 설정"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : 상위 디렉터리 접근 기능을 제거한 경우(ALL 일때 취약, None이 취약은 아님)" >> $CREATE_FILE 2>&1
		echo "참고 : AllowOverride 지시자가 None으로 설정되어 있어 .htaccess 파일을 통한 설정 변경이 제한되어 있으며, 이는 서버 설정의 무단 변경을 방지하는 보안적으로 적절한 설정임"  >> $CREATE_FILE 2>&1
		
		if [ $httpd_conf_wc -gt 0 ];
		then
				echo "1. 현황 : httpd_conf 파일 확인" >> $CREATE_FILE 2>&1

				for file in $httpd_conf_
				do
					echo $file >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					#cat $file | egrep -i "<Directory|AllowOverride|</Directory" >> $CREATE_FILE 2>&1
					grep -n -C 7 'AllowOverride' $file >> $CREATE_FILE 2>&1
					echo "===================" >> $CREATE_FILE 2>&1
				done
		else
			if [ $apache_conf_wc -gt 0 ];
			then
				echo "1. 현황 : apache_conf 파일 확인" >> $CREATE_FILE 2>&1

				for file in $apache_conf_
				do
					echo $file >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					#cat $file | egrep -i "<Directory|AllowOverride|</Directory" >> $CREATE_FILE 2>&1
					grep -n -C 7 'AllowOverride' $file >> $CREATE_FILE 2>&1
					echo "===================" >> $CREATE_FILE 2>&1
				done
			else
				echo "설정 파일 없음 (양호)" >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
		fi
	
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1


	echo "[WEB-07] 웹 서비스 경로 내 불필요한 파일 제거"
		echo "[WEB-07] 웹 서비스 경로 내 불필요한 파일 제거"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : 기본으로 생성되는 불필요한 파일 및 디렉터리가 존재하지 않을 경우" >> $CREATE_FILE 2>&1
		
		for dir in \
			/usr/share/httpd/manual \
			/usr/share/apache2/manual \
			/usr/local/apache2/htdocs/manual \
			/usr/local/apache2/manual
		do
			if [ -d "$dir" ]; then
				echo "[WARN] 매뉴얼 디렉터리 존재: $dir" >> $CREATE_FILE 2>&1
			else
				echo "[OK] 미존재: $dir" >> $CREATE_FILE 2>&1
			fi
		done
	
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1


	echo "[WEB-08] 웹 서비스 파일 업로드 및 다운로드 용량 제한"
		echo "[WEB-08] 웹 서비스 파일 업로드 및 다운로드 용량 제한"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : 파일 업로드 및 다운로드 용량을 제한한 경우 (용량 제한 없음)" >> $CREATE_FILE 2>&1
			
		if [ $httpd_conf_wc -gt 0 ];
		then

				for file in $httpd_conf_
				do
					echo $file >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					#cat $file | egrep -i "<Directory |LimitRequestBody|</Directory" >> $CREATE_FILE 2>&1
					grep -n -C 7 'LimitRequestBody' $file >> $CREATE_FILE 2>&1
					echo "===================" >> $CREATE_FILE 2>&1
				done
		else
			if [ $apache_conf_wc -gt 0 ];
			then
				
				for file in $apache_conf_
				do
					echo $file >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					#cat $file | egrep -i "<Directory |LimitRequestBody|</Directory" >> $CREATE_FILE 2>&1
					grep -n -C 7 'LimitRequestBody' $file >> $CREATE_FILE 2>&1
					echo "===================" >> $CREATE_FILE 2>&1
				done
			else
				echo "2. 현황 : httpd_conf 파일 없음 (양호)" >> $CREATE_FILE 2>&1
				echo " " >> $CREATE_FILE 2>&1
			fi
		fi
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-09] 웹 서비스 프로세스 권한 제한"
		echo "[WEB-09] 웹 서비스 프로세스 권한 제한"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : 웹 프로세스(웹 서비스)가 관리자 권한(root)이 부여된 계정이 아닌 경우" >> $CREATE_FILE 2>&1
		echo "판단기준 : 웹 프로세스 권한이 root가 아니고 읽기 권한만 있는 경우 (디렉터리 소유자가 root 계정이면 양호함)" >> $CREATE_FILE 2>&1
		
		echo "1. 현황 : 웹 프로세스 확인" >> $CREATE_FILE 2>&1
		ps -ef | grep httpd | grep -v grep >> $CREATE_FILE 2>&1
		echo "" >> $CREATE_FILE 2>&1
		echo "2. 현황 : 웹 디렉터리 확인(/var/www)" >> $CREATE_FILE 2>&1
		ls -al /var/www >> $CREATE_FILE 2>&1
		echo "" >> $CREATE_FILE 2>&1
		echo "2. 현황 : 웹 디렉터리 확인(/etc/httpd)" >> $CREATE_FILE 2>&1
		ls -al /etc/httpd >> $CREATE_FILE 2>&1
		echo "" >> $CREATE_FILE 2>&1
		echo "2. 현황 : 웹 디렉터리 확인(/etc/httpd)" >> $CREATE_FILE 2>&1
		ls -al /var/log/httpd/ >> $CREATE_FILE 2>&1
		echo "" >> $CREATE_FILE 2>&1
		
		case "$ID" in
			ubuntu | debian | kali)
				echo "1. 현황 : 웹 프로세스 확인(ubuntu)" >> $CREATE_FILE 2>&1
				ps -ef | grep apache  | grep -v grep >> $CREATE_FILE 2>&1
				echo "" >> $CREATE_FILE 2>&1
				echo "2. 현황 : 웹 디렉터리 확인(/etc/apache2)" >> $CREATE_FILE 2>&1
				ls -al /etc/apache2 >> $CREATE_FILE 2>&1
				echo "" >> $CREATE_FILE 2>&1
				echo "2. 현황 : 웹 디렉터리 확인(/var/log/apache2)" >> $CREATE_FILE 2>&1
				ls -al /var/log/apache2 >> $CREATE_FILE 2>&1
				echo "" >> $CREATE_FILE 2>&1
				echo "3. 현황 : 웹 변수 확인(ubuntu)" >> $CREATE_FILE 2>&1
				cat /etc/apache2/envvars | grep USER >> $CREATE_FILE 2>&1
				cat /etc/apache2/envvars | grep GROUP >> $CREATE_FILE 2>&1
		;;
		esac
					
		if [ $httpd_conf_wc -gt 0 ];
			then
					echo "2. 현황 : httpd_conf 파일 확인" >> $CREATE_FILE 2>&1

					for file in $httpd_conf_
					do
						echo $file >> $CREATE_FILE 2>&1
						echo " " >> $CREATE_FILE 2>&1
						cat $file | grep -i "user" | grep -v "\#" | egrep -v "^LoadModule|LogFormat|IfModule|UserDir" >> $CREATE_FILE 2>&1
						cat $file | grep -i "group" | grep -v "\#" | egrep -v "^LoadModule|LogFormat|IfModule|UserDir" >> $CREATE_FILE 2>&1
						echo "===================" >> $CREATE_FILE 2>&1
					done
			fi
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-10] 불필요한 프록시 설정 제한"
		echo "[WEB-10] 불필요한 프록시 설정 제한"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo "판단기준 :  불필요한 Proxy 설정을 제한한 경우" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		if [ $httpd_conf_wc -gt 0 ];
		then

				for file in $httpd_conf_
				do
					echo $file >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					grep -n -C 7 'Proxy' $file >> $CREATE_FILE 2>&1
					echo "===================" >> $CREATE_FILE 2>&1
				done
		fi
		
		case "$ID" in
			ubuntu | debian | kali)
				echo "1. 현황 : 웹 프로세스 확인(ubuntu)" >> $CREATE_FILE 2>&1
				ps -ef | grep apache  | grep -v grep >> $CREATE_FILE 2>&1
				echo "" >> $CREATE_FILE 2>&1
				echo "2. 현황 : 웹 디렉터리 확인(/etc/apache2)" >> $CREATE_FILE 2>&1
				ls -al /etc/apache2 >> $CREATE_FILE 2>&1
				echo "" >> $CREATE_FILE 2>&1
				echo "2. 현황 : 웹 디렉터리 확인(/var/log/apache2)" >> $CREATE_FILE 2>&1
				ls -al /var/log/apache2 >> $CREATE_FILE 2>&1
				echo "" >> $CREATE_FILE 2>&1
				echo "3. 현황 : 웹 변수 확인(ubuntu)" >> $CREATE_FILE 2>&1
				cat /etc/apache2/envvars | grep USER >> $CREATE_FILE 2>&1
				cat /etc/apache2/envvars | grep GROUP >> $CREATE_FILE 2>&1
		;;
		esac
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1


	echo "[WEB-11] 웹 서비스 경로 설정"
		echo "[WEB-11] 웹 서비스 경로 설정"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 :  웹 서버 경로를 기타 업무와 영역이 분리된 경로로 설정 및 불필요한 경로가 존재하지 않는 경우" >> $CREATE_FILE 2>&1
		if [ $httpd_conf_wc -gt 0 ];
		then

				for file in $httpd_conf_
				do
					echo $file >> $CREATE_FILE 2>&1
					echo " " >> $CREATE_FILE 2>&1
					grep -n -C 7 'DocumentRoot' $file >> $CREATE_FILE 2>&1
					echo "===================" >> $CREATE_FILE 2>&1
				done
		fi
		
		case "$ID" in
			ubuntu|debian|kali)
				echo "1. 현황 : 웹 프로세스 및 DocumentRoot 확인 (Ubuntu 계열)" >> "$CREATE_FILE" 2>&1
				grep -R -H "^[[:space:]]*DocumentRoot" /etc/apache2/sites-enabled >> "$CREATE_FILE" 2>&1
				echo "" >> "$CREATE_FILE" 2>&1
			;;
		esac
		
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-12] 웹 서비스 링크 사용 금지"
		echo "[WEB-12] 웹 서비스 링크 사용 금지"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : 심볼릭 링크, aliases, 바로가기 등의 링크 사용을 허용하지 않는 경우" >> $CREATE_FILE 2>&1
		
		if [ $httpd_conf_wc -gt 0 ];
				then

						for file in $httpd_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							echo " " >> $CREATE_FILE 2>&1
							grep -n -C 7 'FollowSymLinks' $file >> $CREATE_FILE 2>&1
							echo "===================" >> $CREATE_FILE 2>&1
						done
		fi
		
		if [ $apache_conf_wc -gt 0 ];
				then

						for file in $apache_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							echo " " >> $CREATE_FILE 2>&1
							grep -n -C 7 'FollowSymLinks' $file >> $CREATE_FILE 2>&1
							echo "===================" >> $CREATE_FILE 2>&1
						done
		fi
	
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-13] 웹 서비스 설정 파일 노출 제한"
		echo "[WEB-13] 웹 서비스 설정 파일 노출 제한"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "apache는 해당 사항 없음" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1	

	echo "[WEB-14] 웹 서비스 경로 내 파일의 접근 통제"
		echo "[WEB-14] 웹 서비스 경로 내 파일의 접근 통제"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : httpd.conf(apache2.conf) 파일의 퍼미션이 750 이하이면 양호" >> $CREATE_FILE 2>&1
		
		if [ $httpd_conf_wc -gt 0 ];
				then

						for file in $httpd_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							ls -al $file >> $CREATE_FILE 2>&1
							echo "===================" >> $CREATE_FILE 2>&1
						done
				fi
		echo " " >> $CREATE_FILE 2>&1

		if [ $apache_conf_wc -gt 0 ];
				then
						for file in $apache_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							ls -al $file >> $CREATE_FILE 2>&1
						done
		fi
		echo " " >> $CREATE_FILE 2>&1

		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-15] 웹 서비스의 불필요한 스크립트 매핑 제거"
		echo "[WEB-15] 웹 서비스의 불필요한 스크립트 매핑 제거"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "apache는 해당 사항 없음" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1	

	echo "[WEB-16] 웹 서비스 헤더 정보 노출 제한"
		echo "[WEB-16] 웹 서비스 헤더 정보 노출 제한"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 :  HTTP 응답 헤더에서 웹 서버 정보가 노출되지 않는 경우" >> $CREATE_FILE 2>&1
		
		echo "1. 현황 : 서버 응답값 확인(curl)" >> $CREATE_FILE 2>&1
		curl -I localhost >> $CREATE_FILE 2>&1
		echo "" >> $CREATE_FILE 2>&1
		
		if [ $httpd_conf_wc -gt 0 ];
				then
						for file in $httpd_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							grep -n -C 7 'ServerTokens' $file >> $CREATE_FILE 2>&1
							echo "===================" >> $CREATE_FILE 2>&1
							grep -n -C 7 'ServerSignature' $file >> $CREATE_FILE 2>&1
						done
				fi
		echo " " >> $CREATE_FILE 2>&1

		if [ $apache_conf_wc -gt 0 ];
				then
						for file in $apache_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							echo " " >> $CREATE_FILE 2>&1
							grep -n -C 7 'ServerTokens' $file >> $CREATE_FILE 2>&1
							echo "===================" >> $CREATE_FILE 2>&1
							grep -n -C 7 'ServerSignature' $file >> $CREATE_FILE 2>&1
						done
		fi
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-17] 웹 서비스 가상 디렉토리 삭제"
		echo "[WEB-17] 웹 서비스 가상 디렉토리 삭제"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : 불필요한 가상 디렉터리가 존재하지 않는 경우" >> $CREATE_FILE 2>&1
		echo "참고 : 설정 파일내 가상 디렉터리 관련 Alias 지시자가 있는지 확인" >> $CREATE_FILE 2>&1
		
		if [ $httpd_conf_wc -gt 0 ];
				then
						for file in $httpd_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							echo Alias 확인 >> $CREATE_FILE 2>&1
							grep -R -E '^[[:space:]]*Alias[[:space:]]+' $file >> "$CREATE_FILE" 2>&1
							echo "" >> $CREATE_FILE 2>&1
							echo 디렉터리 확인 >> $CREATE_FILE 2>&1
							grep -R -E '^[[:space:]]*<Directory[[:space:]]+' $file  >> "$CREATE_FILE" 2>&1
							echo "===================" >> $CREATE_FILE 2>&1
						done
				fi
		echo " " >> $CREATE_FILE 2>&1

		if [ $apache_conf_wc -gt 0 ];
				then
						for file in $apache_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							echo Alias 확인 >> $CREATE_FILE 2>&1
							grep -R -E '^[[:space:]]*Alias[[:space:]]+' $file >> "$CREATE_FILE" 2>&1
							echo "" >> $CREATE_FILE 2>&1
							echo 디렉터리 확인 >> $CREATE_FILE 2>&1
							grep -R -E '^[[:space:]]*<Directory[[:space:]]+' $file >> "$CREATE_FILE" 2>&1
						done
		fi
		
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1


	echo "[WEB-18] 웹 서비스 WebDAV 비활성화"
		echo "[WEB-18] 웹 서비스 WebDAV 비활성화"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : WebDAV 서비스를 비활성화하고 있는 경우" >> $CREATE_FILE 2>&1
	
		if [ $httpd_conf_wc -gt 0 ];
				then
						for file in $httpd_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							grep -n -C 7 'Dav' $file >> $CREATE_FILE 2>&1
							echo "===================" >> $CREATE_FILE 2>&1
						done
				fi
		echo " " >> $CREATE_FILE 2>&1

		if [ $apache_conf_wc -gt 0 ];
				then
						for file in $apache_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							echo " " >> $CREATE_FILE 2>&1
							grep -n -C 7 'Dav' $file >> $CREATE_FILE 2>&1
						done
		fi
		
		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-19] 웹 서비스 SSI(Server Side Includes) 사용 제한"
		echo "[WEB-19] 웹 서비스 SSI(Server Side Includes) 사용 제한"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 :  웹 서비스 SSI 사용 설정이 비활성화되어 있는 경우" >> $CREATE_FILE 2>&1
		echo "참고 : Options 지시자에 Includes 옵션 이 없을 경우 양호" >> $CREATE_FILE 2>&1
		
		if [ $httpd_conf_wc -gt 0 ];
				then
						for file in $httpd_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							grep -n -C 7 'Includes' $file >> $CREATE_FILE 2>&1
							echo "===================" >> $CREATE_FILE 2>&1
						done
				fi
		echo " " >> $CREATE_FILE 2>&1

		if [ $apache_conf_wc -gt 0 ];
				then
						for file in $apache_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							echo " " >> $CREATE_FILE 2>&1
							grep -n -C 7 'Includes' $file >> $CREATE_FILE 2>&1
						done
		fi
		
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1
		

	echo "[WEB-20] SSL/TLS 활성화"
		echo "[WEB-20] SSL/TLS 활성화"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : SSL/TLS 설정이 활성화되어 있는 경우" >> $CREATE_FILE 2>&1
		
		echo "1. 현황 : ssl 활성화 모듈 확인" >> $CREATE_FILE 2>&1
		apachectl -M | grep ssl >> $CREATE_FILE 2>&1

		case "$ID" in
					ubuntu | debian | kali)
						echo "1. 현황 : ssl 활성화 모듈 확인" >> $CREATE_FILE 2>&1
						apache2ctl -M | grep ssl >> $CREATE_FILE 2>&1

						echo "1-1. 현황 : ssl 활성화 모듈 확인(ubuntu)" >> $CREATE_FILE 2>&1
						ls /etc/apache2/mods-enabled | grep ssl >> $CREATE_FILE 2>&1
						echo "" >> $CREATE_FILE 2>&1
					;;
		esac
		
		echo "2. 현황 : 포트 확인" >> $CREATE_FILE 2>&1
		ss -lntp | grep 443  >> $CREATE_FILE 2>&1
		echo "" >> $CREATE_FILE 2>&1
		
		echo "3. 현황 : VirtualHost 설정 확인" >> $CREATE_FILE 2>&1
		apachectl -S  >> $CREATE_FILE 2>&1
		echo "" >> $CREATE_FILE 2>&1


		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-21] HTTP 리디렉션"
		echo "[WEB-21] HTTP 리디렉션"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : Redirect permanent 설정이 존재하는 경우" >> $CREATE_FILE 2>&1
				
		if [ -f /etc/httpd/conf.d/ssl.conf ]
		then
			echo "1. 현황 : redirect 설정 확인" >> $CREATE_FILE 2>&1
			cat /etc/httpd/conf.d/ssl.conf  | grep Redirect >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		else
			echo "1. 현황 : /etc/httpd/conf.d/ssl.conf  파일이 없습니다." >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		fi
		echo " " >> $CREATE_FILE 2>&1

		case "$ID" in
					ubuntu | debian | kali)
						echo "2. HTTP Redirection 설정 확인(ubuntu)" >> $CREATE_FILE 2>&1
						cat /etc/apache2/sites-available/default-ssl.conf | grep Redirect >> $CREATE_FILE 2>&1
						echo "" >> $CREATE_FILE 2>&1
					;;
		esac
		
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1
		
	echo "[WEB-22] 에러 페이지 관리"
		echo "[WEB-22] 에러 페이지 관리"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : 웹 서비스 에러 페이지가 별도로 지정된 경우" >> $CREATE_FILE 2>&1
		
		if [ -f /etc/httpd/conf/httpd.conf ]
		then
			echo "1. 현황 : ErrorDocument 설정 확인(httpd.conf)" >> $CREATE_FILE 2>&1
			cat /etc/httpd/conf/httpd.conf  | grep ErrorDocument >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		else
			echo "1. 현황 : /etc/httpd/conf/httpd.conf 파일이 없습니다." >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		fi
		
		echo "2. 현황 : /etc/httpd/conf.d/*.conf 설정 확인" >> $CREATE_FILE 2>&1
		grep "ErrorDocument" /etc/httpd/conf.d/*.conf >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		
		case "$ID" in
					ubuntu | debian | kali)
						echo "2. HTTP Redirection 설정 확인(ubuntu)" >> $CREATE_FILE 2>&1
						cat /etc/apache2/sites-available/*.conf | grep ErrorDocument >> $CREATE_FILE 2>&1
						echo "" >> $CREATE_FILE 2>&1
					;;
		esac
		
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-23] LDAP 알고리즘 적절하게 구성"
		echo "[WEB-23] LDAP 알고리즘 적절하게 구성"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "apache는 해당 사항 없음" >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

	echo "[WEB-24] 별도의 업로드 경로 사용 및 권한 설정"
		echo "[WEB-24] 별도의 업로드 경로 사용 및 권한 설정"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 : 별도의 업로드 경로를 사용하고 일반 사용자의 접근 권한이 부여되지 않은 경우" >> $CREATE_FILE 2>&1
		
		if [ $httpd_conf_wc -gt 0 ];
				then
						for file in $httpd_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							echo Alias 확인 >> $CREATE_FILE 2>&1
							grep -R -E '^[[:space:]]*Alias[[:space:]]+' $file >> "$CREATE_FILE" 2>&1
							echo "" >> $CREATE_FILE 2>&1
							echo 디렉터리 확인 >> $CREATE_FILE 2>&1
							grep -R -E '^[[:space:]]*<Directory[[:space:]]+' $file >> "$CREATE_FILE" 2>&1
							echo "===================" >> $CREATE_FILE 2>&1
						done
				fi
		echo " " >> $CREATE_FILE 2>&1

		if [ $apache_conf_wc -gt 0 ];
				then
						for file in $apache_conf_
						do
							echo $file >> $CREATE_FILE 2>&1
							echo Alias 확인 >> $CREATE_FILE 2>&1
							grep -R -E '^[[:space:]]*Alias[[:space:]]+' $file >> "$CREATE_FILE" 2>&1
							echo "" >> $CREATE_FILE 2>&1
							echo 디렉터리 확인 >> $CREATE_FILE 2>&1
							grep -R -E '^[[:space:]]*<Directory[[:space:]]+' $file >> "$CREATE_FILE" 2>&1
						done
		fi
		
		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1


	echo "[WEB-25] 주기적 보안 패치 및 벤더 권고사항 적용"
		echo "[WEB-25] 주기적 보안 패치 및 벤더 권고사항 적용"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
	
			echo "1. 현황 : apache 버전 확인" >> $CREATE_FILE 2>&1
			httpd -v >> $CREATE_FILE 2>&1
			
			echo "2. 현황 : apache 패키지 정보" >> $CREATE_FILE 2>&1
			rpm -qi httpd >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			
			case "$ID" in
				ubuntu | debian | kali)
				echo "1. 현황 : apache 버전 확인(ubuntu)" >> $CREATE_FILE 2>&1
				apachectl -v >> $CREATE_FILE 2>&1
				echo "2. 현황 : apache 상세 버전 확인(ubuntu)" >> $CREATE_FILE 2>&1
				dpkg -l apache2  >> $CREATE_FILE 2>&1
				;;
			esac

		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1	

	echo "[WEB-26] 로그 디렉터리 및 파일 권한 설정"
		echo "[WEB-26] 로그 디렉터리 및 파일 권한 설정"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "[START]"  >> $CREATE_FILE 2>&1
		echo " " >> $CREATE_FILE 2>&1
		echo "판단기준 :  로그 디렉터리 및 파일에 일반 사용자의 접근 권한이 없는 경우" >> $CREATE_FILE 2>&1
		
		if [ -d /var/log/httpd ]
		then
			echo "1. 현황 : /var/log/httpd 디렉터리 확인 " >> $CREATE_FILE 2>&1
			ls -ald /var/log/httpd/  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : /var/log/httpd 디렉터리 내 파일 확인" >> $CREATE_FILE 2>&1
			ls -al /var/log/httpd/  >> $CREATE_FILE 2>&1
		else
			echo "1. 현황 : /var/log/httpd 디렉터리가 없습니다." >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
		fi
					
		case "$ID" in
		ubuntu | debian | kali)
			echo "1. 현황 : /var/log/apache2 디렉터리 확인(ubuntu) " >> $CREATE_FILE 2>&1
			ls -ald /var/log/apache2/  >> $CREATE_FILE 2>&1
			echo " " >> $CREATE_FILE 2>&1
			echo "2. 현황 : /var/log/apache2 디렉터리 내 파일 확인(ubuntu) " >> $CREATE_FILE 2>&1
			ls -al /var/log/apache2/  >> $CREATE_FILE 2>&1
			;;
		esac

		echo " " >> $CREATE_FILE 2>&1
		echo "[END]" >> $CREATE_FILE 2>&1

fi


echo "UNIX/Linux Security Check END"
echo "==============================================================="
echo " UNIX 스크립트 작업이 완료되었습니다."
echo " "
echo " 스크립트 결과 파일을 보안담당자에게 전달 바랍니다."
echo " "
echo " 감사합니다."
echo "==============================================================="
echo " " >> $CREATE_FILE 2>&1
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> $CREATE_FILE 2>&1
echo "Reference info." >> $CREATE_FILE 2>&1
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
echo "****************************************************************************************************" >> $CREATE_FILE 2>&1
echo "****************************************   INFO_CHKSTART   *************************************" >> $CREATE_FILE 2>&1
echo "****************************************************************************************************" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "==============================" >> $CREATE_FILE 2>&1
echo "System Information Query Start" 							  >> $CREATE_FILE 2>&1
echo "==============================" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "--------------------------------------   Kernel Information   --------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
uname -a >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
echo "----------------------------------------------------------------------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "----------------------------------------   IP Information   ----------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
ifconfig -a >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
echo "----------------------------------------------------------------------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "----------------------------------------   Network Status   ----------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
netstat -tulnp >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
echo "----------------------------------------------------------------------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "----------------------------------------   Listen port check   ----------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
netstat -naop | grep LISTEN >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
echo "----------------------------------------------------------------------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "-------------------------------------   Routing Information   --------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
netstat -rn >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
echo "----------------------------------------------------------------------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "---------------------------------------   Process Status   -----------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
ps -ef >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
echo "----------------------------------------------------------------------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "------------------------------------------   User Env   --------------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
env >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
echo "----------------------------------------------------------------------------------------------------" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "============================" >> $CREATE_FILE 2>&1
echo "System Information Query End" 							   >> $CREATE_FILE 2>&1
echo "============================" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1

echo "****************************************************************************************************" >> $CREATE_FILE 2>&1
echo "*****************************************   INFO_CHKEND   **************************************" >> $CREATE_FILE 2>&1
echo "****************************************************************************************************" >> $CREATE_FILE 2>&1
echo " " >> $CREATE_FILE 2>&1
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> $CREATE_FILE 2>&1
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<" >> $CREATE_FILE 2>&1
