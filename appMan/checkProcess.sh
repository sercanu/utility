#!/bin/bash

REMOTE_SERVER_ADDRS="user@10.0.0.1:PROCESS_ALIAS:PROCESS_EXPLANATION"
REMOTE_SERVER_ADDRS=$REMOTE_SERVER_ADDRS";user@10.1.1.1:tomcat:My_tomcat_app"

###  CHECK FUNCTION  ### 
function checkApp() {

    APP_NAME_FOR_PID="'[${APP_NAME:0:1}]${APP_NAME:1}'"
    PID_COMMAND="ps aux | grep $APP_NAME_FOR_PID | awk '{print "'$2'"}'"
    PIDS=`eval $PID_COMMAND`
    COUNT=0
    ONE=1

    if [ -z "$PIDS" ] ; then 
         echo "<td style=\"background-color:red;\">NOK</td><td>$APP_NAME_EXP</td><td>$ADDRESS</td><td>$APP_NAME</td><td colspan="6">No Process Found</td>"
    else 
        for pid in $PIDS; do

            NAME_COMMAND="ps aux | grep $APP_NAME_FOR_PID | grep $pid | awk '{print "'$11'"}'"
            NAME=`eval $NAME_COMMAND`

            if [[ ! -z "$NAME" && "$NAME" != "bash" && "$NAME" != "ssh" ]]; then

                MEM_USAGE_COMMAND="ps aux | grep $APP_NAME_FOR_PID | grep $pid | awk '{print "'$6'"}'"
                MEM_USAGE=`eval $MEM_USAGE_COMMAND`
                let "MEM_USAGE_T = $MEM_USAGE / 1024"

                VSZ_USAGE_COMMAND="ps aux | grep $APP_NAME_FOR_PID | grep $pid | awk '{print "'$5'"}'"
                VSZ_USAGE=`eval $VSZ_USAGE_COMMAND`
                let "VSZ_USAGE_T = $VSZ_USAGE / 1024"

                MEMP_USAGE_COMMAND="ps aux | grep $APP_NAME_FOR_PID | grep $pid | awk '{print "'$4'"}'"
                MEMP_USAGE=`eval $MEMP_USAGE_COMMAND`

                CPU_USAGE_COMMAND="ps aux | grep $APP_NAME_FOR_PID | grep $pid | awk '{print "'$3'"}'"
                CPU_USAGE=`eval $CPU_USAGE_COMMAND`

                if [ $COUNT != 0 ] ; then 
                    echo "<tr>"
                fi

                echo "<td style=\"background-color:green;\">OK</td><td>$APP_NAME_EXP</td><td>$ADDRESS</td><td>$APP_NAME</td><td>$pid</td><td>$MEM_USAGE_T MB</td><td>$VSZ_USAGE_T MB</td><td>$MEMP_USAGE</td><td>$CPU_USAGE</td><td>$NAME</td>"

                if [ $COUNT != 0 ] ; then 
                    echo "</tr>"
                fi

                COUNT=$(($COUNT + $ONE))
           fi
        done

        if [ $COUNT == 0 ] ; then 
             echo "<td style=\"background-color:red;\">NOK</td><td>$APP_NAME_EXP</td><td>$ADDRESS</td><td>$APP_NAME</td><td colspan="6">No Process Found</td>"
        fi
    fi 

    COUNT=0

}

APP_NAME=$1
APP_NAME_EXP=$2
ADDRESS=$3
REMOTE_BOOL=$4

if [[ ! -z "$REMOTE_BOOL" && "$REMOTE_BOOL" != "R" ]]; then
    REMOTE_BOOL=""
fi



SCRIPT_FILENAME=`basename $0`
SCRIPT_PATH="`dirname \"$0\"`"
SCRIPT_PATH="`( cd \"$SCRIPT_PATH\" && pwd )`"
SCRIPT_PATH="$SCRIPT_PATH/$SCRIPT_FILENAME"


if [ ! -z "$REMOTE_SERVER_ADDRS" ]; then

    if [ ! -z "$REMOTE_BOOL" ]; then
        checkApp
        exit 0
    else
        addrs=($(echo $REMOTE_SERVER_ADDRS | tr ";" "\n"))

        size=${#addrs[@]}

        if [[ size -gt 0 ]]; then

            echo "From: process@checker"
            echo "Subject: Daily Process Check Report"

            echo "Mime-Version: 1.0"
            echo "Content-type: text/html; charset=”iso-8859-1″"


            echo "<html> <head> <style>
                    table
                    {
                    border-collapse:collapse;
                    }
                    table, td, th
                    {
                    border:1px solid black;
                    padding: 2px;
                    }
                    </style>

                    </head>
                    <table border="1"> <tr> <th>Status</th> <th>Application</th> <th>Server</th> <th>Process</th>  <th>PID</th> <th>Mem Usage</th> <th>VSZ</th> <th>Mem%</th> <th>CPU%</th> <th>Name</th></tr>"

            for i in ${addrs[@]}; do
                echo "<tr>"
                user_serv_pro_mess=($(echo $i | tr ":" "\n"))
                USER_SERV=${user_serv_pro_mess[0]}
                APP_NAME_PARAM=${user_serv_pro_mess[1]}
                APP_NAME_EXP_PARAM=${user_serv_pro_mess[2]}

                result=`ssh $USER_SERV 'echo' 2>&1`
                if [[ -n $result ]]; then
                    echo "<td style=\"background-color:red;\">NOK</td><td>$APP_NAME_EXP_PARAM</td><td>$USER_SERV</td><td>$APP_NAME_PARAM</td><td colspan="6">$result</td>"
                else 
                    ssh $USER_SERV 'bash -s' < "$SCRIPT_PATH" "$APP_NAME_PARAM" "$APP_NAME_EXP_PARAM" "$USER_SERV" "R"
                fi

                echo "</tr>"
            done

            echo "</html>"
        fi
    fi
fi
