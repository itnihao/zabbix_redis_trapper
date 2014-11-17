#!/bin/bash

DATA_VARIABLES="used_memory used_memory_rss used_memory_peak used_memory_lua connected_clients client_longest_output_list client_biggest_input_buf blocked_clients total_connections_received total_commands_processed instantaneous_ops_per_sec rejected_connections expired_keys evicted_keys keyspace_hits keyspace_misses pubsub_channels pubsub_patterns used_cpu_sys used_cpu_user used_cpu_sys_children used_cpu_user_children"
REDIS_BIN=`which redis-cli`
ZABBIX_HOME="/mnt/www/zabbix/"
ZABBIX_BIN="$ZABBIX_HOME/bin/zabbix_sender -c $ZABBIX_HOME/etc/zabbix_agentd.conf"
ZABBIX_SERVER="zabbix01.i.fdmdns.local"



source /etc/profile



case $1 in
	discovery)
		REDIS_PORTS=`netstat -natp|awk -F: '/redis-server/&&/LISTEN/{print $2}'|awk '{print $1}'`
		COUNT=`echo "$REDIS_PORTS" | wc -w`
		INDEX=0
		echo '{"data":['
		for REDIS_PORT in $REDIS_PORTS; do
			echo -n '{"{'#REDISPORT'}":"'$REDIS_PORT'"}'
				INDEX=`expr $INDEX + 1`
				if [ $INDEX -lt $COUNT ]; then
					echo ','
				fi
		done
			echo ']}'
		;;

	collector)
		shift
		if [ -z $1 ] || [ -z $2 ];then
			$0
			exit 0
		fi

		HOST_NAME="$1"
		PORT="$2"
		DATA=""
		COUNT=`echo "$DATA_VARIABLES" | wc -w`
		INDEX=0
		for DATA_VARIABLE in $DATA_VARIABLES 
			do
			VALUE=`$REDIS_BIN -a fdm info |grep "${DATA_VARIABLE}:"|awk -F ":" '{print $2}'|sed "s/M//g"`
			INDEX=`expr $INDEX + 1`
			        if [ -n "$VALUE" ]; then
					if [ $INDEX -ne $COUNT ];then
            					DATA=$DATA"- redis[$DATA_VARIABLE,$PORT] $VALUE\n"
					else
						DATA=$DATA"- redis[$DATA_VARIABLE,$PORT] $VALUE"
					fi
        			fi
    			done
		
		if [ -n "$DATA" ]; then
			echo -e "$DATA" | $ZABBIX_BIN -s "$HOST_NAME" -z $ZABBIX_SERVER -i- >/dev/null 2>&1
		else
			echo 0
		fi
		;;

	*)
	echo "please use <discovery> | <collector> <HOST_NAME> <PORT>"
	;;
esac
