#! /bin/bash

###########################################
### Fuction:  This is a shell script for Kill&Count MySQL connected threads
## 远程kill 版本： 
## 1、填充用户名和密码
## 2、sh mykill.sh ip:port
###########################################




IT=$1
shift 
IP=$(echo $IT|awk -F: '{print $1}')
PORT=$(echo $IT|awk -F: '{print $2}')


USER=
PASSWD=


function do_mysql()
{
	
        cmd="$1"
        mysql -h $IP -u $USER -P $PORT -p$PASSWD -BN -e "$cmd" 2>&1
        if [[ $? -eq 0 ]]
        then
                return 0
        fi
        exit 1
}


function do_mysqladmin()
{
	cmd="$1"
        $DATABASE_PATH/bin/mysqladmin --defaults-extra-file=$AUTH_FILE $cmd 2>&1
        if [[ $? -eq 0 ]]
        then
                return 0
        fi
        exit 1
}


######## Main function, kill some threads ########

echo "##### START #####"

##### just for test #####
#do_mysql 'select version()'
#do_mysqladmin 'version'

NO_ARGS=0
E_OPTERROR=65
if [ $# -eq "$NO_ARGS" ]
then 
     echo "Usage: `basename $0` [OPTIONS]"
     echo "Options:"
     echo "  -A,--all		kill all threads expect system and root"
     echo "  -C,--count		count the number of someone or all user threads"
     echo "  -S,--source		count the number of databases threads"
     echo "  -D,--database=name	kill all threads which database connected"
     echo "  -T,--thread=thrid	kill the thread according to thread_id"
     echo "  -U,--username=name	kill all threads which user connected"
     echo "  -I,--ip=ip 	kill all threads which ip  connected"
     echo "  -L,--list	"
     echo "  -h,--help		help manul"
     exit $E_OPTERROR
fi



ARGS=`getopt -a -o U:I:T:D:SAChL -l username:,ip:,thread:,database:,source,all,count,help,list -- "$@"`  
eval set -- "${ARGS}"


while true
do
	case "$1" in
	     -U|--username)

        	username="$2"     ####${OPTIND}	
		### echo "Section 1 ..."
		echo -e "##### KILL ALL THREADS OF USER ${username} #####\n"
		for i in `do_mysql 'show processlist'|awk -F "\t" '{if($2=="'${username}'")print $1}'`;do
			ret=`do_mysql "kill $i"`
		done
		shift 2
		;;

	     -I|--ip)

        	ip="$2"     ####${OPTIND}	
		### echo "Section 1 ..."
		echo -e "##### KILL ALL THREADS OF IP ${ip} #####\n"
		for i in `do_mysql 'show processlist'|grep ${ip}|awk -F "\t" '{print $1}'`;do
			ret=`do_mysql "kill $i"`
		done
		shift 2
		;;
	
	     -T|--thread)
	
		thread_id="$2"
		### echo "Section 2 ..."
		ret=`do_mysql "kill ${thread_id}"`
		shift 2
		;;

	     -L|--list)

		do_mysql "show full processlist;"|grep -v Sleep|grep -v 'system user'|grep -v slave|sort -n -k 6 -r |head -10
		shift 
		;;

	     -D|--database)

		database="$2"
		### echo "Section 3 ..."
		echo -e "##### KILL ALL THREADS OF DATABASE ${database} #####\n"
		for i in `do_mysql 'show processlist'|awk -F "\t" '{if($4=="'${database}'")print $1}'`;do
                        ret=`do_mysql "kill $i"`
                done
		shift 2
		;;

	     -S|--source)
		### echo "Section 6 ..."
		echo -e "##### COUNT NUMBER OF CONNECT THREADS OF DATABASE\n"
		for i in `do_mysql 'show processlist'|awk '{print $4}'|sort|uniq`;do
			thread_num=`do_mysql 'show processlist'|awk -F "\t" '{print $4}'|grep -i $i|wc -l`
			if [ "$i" = "NULL" ]
			then
				i="NO-NAME DB"
			fi	
		echo "The connected to database $i threads number is : ${thread_num}"
		done
		shift 
		;;

	     -A|--all)
		### echo "Section 4 ..."
		echo -e "##### KILL ALL THREADS EXPCEPT SYSTEM #####\n"
		for i in `do_mysql 'show processlist'|grep -v mysqlsync|grep -v system|grep -v slave|grep -v root|awk '{print $1}'`;do
			ret=`do_mysql "kill $i"`
		done
		shift
		;;
	
	     -C|--count)
		### echo "Section 5 ..."
		echo -e "##### COUNT NUMBER OF CONNECTED THREADS #####\n"
		for i in `do_mysql 'show processlist'|awk '{print $2}'|sort|uniq`;do
			thread_num=`do_mysql 'show processlist'|awk '{print $2}'|grep -i $i|wc -l`
			echo "The connected threads number of user $i is : ${thread_num}"
		done
		shift
		;;
			

	     -h|--help)
		echo "Usage: `basename $0` [OPTIONS]"
     		echo "Options:"
     		echo "  -A,--all                   kill all threads expect system and root"
     		echo "  -C,--count                 count the number of someone or all user threads"
		echo "  -S,--source		     count the number of all database threads"
	        echo "  -D,--database=name         kill all threads which database connected"
     		echo "  -T,--thread=thrid          kill the thread according to thread_id"
     		echo "  -U,--username=name         kill all threads which user connected"
     		echo "  -I,--ip=name               kill all threads which ip  connected"
     		echo "  -h,--help                  help manual"
		shift
		;;

	     --)
		echo "##### FINISH #####"
		shift
		break
		;;

	esac

done

#echo "##### FINISH #####"

