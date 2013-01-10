#!/bin/bash
#**********************      AppMan v1.0   README    ************************#
#                  (Completely free, use it at your own risk)                #
#                                                                            #
#     How to use: Set your UNIQUE application name and other parameters at   #
#                 settings section. Then run the script with parameters      #
#                 shown below. Have fun.                                     #
#                                                                            #
#     Examples:                                                              #
#        appMan.sh start config.sh  >   start application                    #
#        appMan.sh s     config.sh  >   start application                    #
#        appMan.sh tail  config.sh  >   tail the log file                    #
#        appMan.sh st    config.sh  >   start app. and tail the log file     #
#        appMan.sh wst   config.sh  >   deploy war, start app, tail log      #
#        appMan.sh kbwst config.sh  >   kill, backup, deploy war, start, tail#
#        appMan.sh help  config.sh  >   show help                            #
#                                                                            #
#     Supported Commands                                                     #
#     command name     short   explanation                                   #
#     ====================================================================   #
#     start            s       runs the START_SCRIPT parameter               #
#     stop             p       runs the STOP_SCRIPT parameter                #
#     kill             k       kills ALL process with APP_NAME parameter     #
#     tail             t       tails the LOG_FILE_PATH parameter             #
#     check            c       shows pid, memory etc with APP_NAME param.    #
#     deploywar        w       deploys war. see WAR_FILE_PATH parameter      #
#     deploydir        d       deploys dir. see NEW_RELEASE_DIRECTORY param. #
#     backup           b       backups app. see BACKUP_DIRECTORY param.      #
#     custom           m       calls your custom function.                   #
#                                                                            #
#    ABOUT:                                                                  #
#    Can be used for Apache Tomcat, Gunicorn etc. or any running process...  #
#    Start editing the parameters at Settings Sections.                      #
#                                                                            #
#****************************************************************************#

#************************ - SETTINGS SECTION START - *************************

# DESCRIPTION: This parameter can be the alias of your application process or
#              directory of your application. (ps command will use this param)
# NOTE:        IMPORTANT! Parameter must be UNIQUE system wide.
# MUST/OPT:    MUST
# SAMPLE:      "mytomcatapp"
#APP_NAME=""

# DESCRIPTION: Your app's start script.
# NOTE:        "start" command will execute this script.
# MUST/OPT:    OPTIONAL
# SAMPLE:      "/home/user/mytomcatapp/bin/startup.sh"
#START_SCRIPT=""

# DESCRIPTION: Your app's stop script.
# NOTE:        "stop" command will execute this script.
# MUST/OPT:    OPTIONAL
# SAMPLE:      "/home/user/mytomcatapp/bin/shutdown.sh"
#STOP_SCRIPT=""

# DESCRIPTION: Path of the log file.
# NOTE:        "tail" command will use this file
# MUST/OPT:    OPTIONAL
# SAMPLE:      "/home/user/mytomcatapp/logs/catalina.out"
#LOG_FILE_PATH=""

# DESCRIPTION: Directory of the running application.
# NOTE:        deploy commands removes this directory and copies
#              new files from RELEASE_APP_DIRECTORY or extract
#              the war file to this directory.
# MUST/OPT:    OPTIONAL
# SAMPLE:      "/home/user/mytomcatapp/webapp/ROOT"
#RUNNING_APP_DIRECTORY=""

# DESCRIPTION: Directory of the new release.
# NOTE:        "deploydir" command copies this directory to
#              RUNNING_APP_DIRECTORY.
# MUST/OPT:    OPTIONAL
# SAMPLE:      "/home/user/mytomcatapp/webapp/temp/release"
#NEW_RELEASE_DIRECTORY=""

# DESCRIPTION: War file of the application.
# NOTE:        "deploywar" command extracts this war and copies
#              to RUNNING_APP_DIRECTORY.
# MUST/OPT:    OPTIONAL
# SAMPLE:      "/home/user/mytomcatapp/temp/myapp.war"
#WAR_FILE_PATH=""

# DESCRIPTION: Directory of the backups.
# NOTE:        "backup" command creates directory
#                    with name of APP_NAME_YYMMDDHHSS. Then copies
#              all files from RUNNING_APP_DIRECTORY.
# MUST/OPT:    OPTIONAL
# SAMPLE:      "/home/user/mytomcatapp/temp/backup/"
#BACKUP_DIRECTORY=""

# DESCRIPTION: Remote server's address. If you leave blank script
#              will be run on this machine. 
# NOTE:        Several servers can be added with seperator ;
# MUST/OPT:    OPTIONAL
# SAMPLE:      "user1@server1;user2@server2;userN@serverN"
#REMOTE_SERVER_ADDRS=""

# DESCRIPTION: Custom function. It is a hook that you can do anything.
# NOTE:        "custom" command calls this function.
# MUST/OPT:    OPTIONAL
# SAMPLE:      cp database.properties $RUNNING_APP_DIRECTORY/classes/
#function custom() {
#
# echo "custom function started..."

   # Code anything you wish...
   # copy database.properties, set environment parameters etc..

#   echo "custom function ended."

 #}


#*********************   - SETTINGS SECTION END -    *************************

#*****************************************************************************
#***************   NO NEED TO CHANGE THE SCRIPTS BELOW    ********************
#*****************************************************************************


#*****************************************************************************
#***********************   FUNCTIONS SECTION START    ************************
#*****************************************************************************

function checkAppNameIsEmpty() {

    if [ -z "$APP_NAME" ]; then
       echo "ERROR: Application name (APP_NAME) can not be blank"
       echo ""
       exit -1
    fi
}


###  CHECK FUNCTION  ### 
function checkApp() {

    checkAppNameIsEmpty
  
    PIDS=`eval $PID_COMMAND`
    divider======================================
    divider=$divider$divider
    header="\n %-7s %-11s %-10s %-8s %-8s %-11s\n"
    format=" %-7s %-11s %-10s %-8s %-8s %-11s\n"
    width=45

    if [ -z "$PIDS" ] ; then 
        echo "$APP_NAME is NOT running!"
    else 
        echo "$APP_NAME is running!" 

        printf "$header" "PID" "Mem Usage" "VSZ" "Mem%" "CPU%" "Name" 
        printf "%$width.${width}s\n" "$divider"

        for pid in $PIDS; do

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

            NAME_COMMAND="ps aux | grep $APP_NAME_FOR_PID | grep $pid | awk '{print "'$11'"}'"
            NAME=`eval $NAME_COMMAND`

            printf "$format" \
            $pid "$MEM_USAGE_T MB" "$VSZ_USAGE_T MB" "$MEMP_USAGE" "$CPU_USAGE" "$NAME"
        done
    fi 

 echo ""
}


###  TAIL FUNCTION  ### 
function tailLogFile() {

    if [ -z "$LOG_FILE_PATH" ]; then
        echo "ERROR: Log file path (LOG_FILE_PATH) can not be blank."
        echo ""
        exit -1
    fi

    if [ ! -f "$LOG_FILE_PATH" ]; then
        echo "ERROR: Log file does not exists. $LOG_FILE_PATH"
        echo ""
        exit -1
    fi

    tail -200ft $LOG_FILE_PATH | while read line 
    do
        echo $line
    done

}

###  START FUNCTION  ### 
function startApp() {

    if [ -z "$START_SCRIPT" ]; then
        echo "ERROR: Start script parameter (START_SCRIPT) can not be blank."
        echo ""
        exit -1
    fi

    if [ ! -f "$START_SCRIPT" ]; then
        echo "ERROR: Start script file does not exists. $START_SCRIPT"
        echo ""
        exit -1
    fi

    echo "Application is starting..." 
    $START_SCRIPT
}



###  STOP FUNCTION  ### 
function stopApp() {

    if [ -z "$STOP_SCRIPT" ]; then
        echo "ERROR: Stop script parameter (STOP_SCRIPT) can not be blank."
        echo ""
        exit -1
    fi

    if [ ! -f "$STOP_SCRIPT" ]; then
        echo "ERROR: Stop script file does not exists. $STOP_SCRIPT"
        echo ""
        exit -1
    fi

    checkAppNameIsEmpty

    PID=`eval $PID_COMMAND`

    if [ -z "$PID" ] ; then 
        echo "$APP_NAME already stopped."
    else 
        echo "Stopping application $APP_NAME, pid=$PID " 

        $STOP_SCRIPT
        APP_STOP_WAITING_TIME=0
        PID=`eval $PID_COMMAND`

        while [ ! -z "$PID"  ]; do
            echo " Application is still running... $APP_STOP_WAITING_TIME sec."
            sleep 1s

            PID=`eval $PID_COMMAND`
            if [ -z "$PID" ] ; then
                break
            fi
            let APP_STOP_WAITING_TIME=APP_STOP_WAITING_TIME+1
        done 
        echo "$APP_NAME stopped."
    fi 
    echo ""
}


###  KILL FUNCTION  ### 
function killApp() {

   checkAppNameIsEmpty
   PID=`eval $PID_COMMAND`

   echo ""
   if [ -z "$PID" ] ; then 
       echo "$APP_NAME already killed."
   else 
       echo "Killing application $APP_NAME, pid=$PID " 

       `eval kill -9 $PID`
       APP_KILL_WAITING_TIME=0
       PID=`eval $PID_COMMAND`

       while [ ! -z "$PID"  ]; do
           echo " Application is still running... $APP_KILL_WAITING_TIME sec."
           sleep 1s
           PID=`eval $PID_COMMAND`

           if [ -z "$PID" ] ; then
               echo "$APP_NAME killed."
               break
           fi
           let APP_KILL_WAITING_TIME=APP_KILL_WAITING_TIME+1
       done 
       echo "$APP_NAME killed."
    fi 
    echo ""
}


###  DEPLOY DIR FUNCTION  ### 
function deployDir() {

    if [ -z "$RUNNING_APP_DIRECTORY" ]; then
        echo "RUNNING_APP_DIRECTORY can not be blank."
        exit -1
    fi

    if [ ! -d "$RUNNING_APP_DIRECTORY" ]; then
        echo "Running application directory does not exists. $RUNNING_APP_DIRECTORY"
        exit -1
    fi

    if [ -z "$NEW_RELEASE_DIRECTORY" ]; then
        echo "ERROR: NEW_RELEASE_DIRECTORY can not be blank."
        echo ""
        exit -1
    fi

    if [ ! -d "$NEW_RELEASE_DIRECTORY" ]; then
        echo "ERROR: New release directory does not exists. $NEW_RELEASE_DIRECTORY"
        echo ""
        exit -1
    fi

    echo ""
    echo "Deploying directory..." 

    rm -rf $RUNNING_APP_DIRECTORY
    mkdir $RUNNING_APP_DIRECTORY
    cp -R $RELEASE_APP_DIRECTORY $RUNNING_APP_DIRECTORY

    echo "Deploy completed successfully."
    echo "" 
}


###  DEPLOY FUNCTION  ### 
function deployWar() {

    if [ -z "$RUNNING_APP_DIRECTORY" ]; then
        echo "RUNNING_APP_DIRECTORY can not be blank."
        exit -1
    fi

    if [ ! -d "$RUNNING_APP_DIRECTORY" ]; then
        echo "Running application directory does not exists. $RUNNING_APP_DIRECTORY"
        exit -1
    fi

    if [ -z "$WAR_FILE_PATH" ]; then
        echo "ERROR: WAR_FILE_PATH can not be blank."
        echo ""
        exit -1
    fi

    if [ ! -f "$WAR_FILE_PATH" ]; then
        echo "ERROR: War file does not exists. $WAR_FILE_PATH"
        echo ""
        exit -1
    fi

    JAR_TEST=`which jar`

    if [ -z "$JAR_TEST" ]; then
          echo "PATH is: $PATH"
          echo "jar command could not be found. Check your java installation."
          echo "Be SURE that PATH setting at basrc is above the line --If not running interactively, don't do anything--"
          exit -1
    fi

    echo ""
    echo "Deploying war file..." 

    rm -rf $RUNNING_APP_DIRECTORY
    mkdir $RUNNING_APP_DIRECTORY
    cp $WAR_FILE_PATH $RUNNING_APP_DIRECTORY
    cd $RUNNING_APP_DIRECTORY
    jar xf *.war
    rm -f *.war

    echo "Deploy completed successfully."
    echo "" 
}

###  BACKUP FUNCTION  ### 
function backupApp() {


    if [ -z "$RUNNING_APP_DIRECTORY" ]; then
        echo "RUNNING_APP_DIRECTORY can not be blank"
        exit -1
    fi

    if [ ! -d "$RUNNING_APP_DIRECTORY" ]; then
        echo "Running application directory does not exists. $RUNNING_APP_DIRECTORY"
        exit -1
    fi

    if [ -z "$BACKUP_DIRECTORY" ]; then
          echo "BACKUP_DIRECTORY can not be blank"
          exit -1
    fi

    if [ ! -d "$BACKUP_DIRECTORY" ]; then
        echo "Backup directory does not exists. $BACKUP_DIRECTORY"
        exit -1
    fi

    echo ""
    echo "Backup is starting..." 

    NOW=$(date +"%Y%m%d_%H%M")
    NOW="$APP_NAME_$NOW"
    BACKUP_PATH="$BACKUP_DIRECTORY$APP_NAME_$NOW"

    cp -r $RUNNING_APP_DIRECTORY $BACKUP_PATH

    echo "Backup completed."
    echo "" 
}



function executeCommand() {

    case $COMMAND_TYPE in
      
       "start" | "s")   echo ""
                        startApp
                        ;;

        "stop" | "p")   echo ""
                        stopApp
                        ;;

        "kill" | "k")   echo ""
                        killApp
                        ;;

        "tail" | "t")   echo ""
                        tailLogFile
                        ;;

        "check" | "c")  echo ""
                        checkApp
                        ;;

        "deploywar" | "w")  echo ""
                            deployWar
                            ;;

        "deploydir" | "d")  echo ""
                            deploydir
                            ;;

        "backup" | "b")     echo ""
                            backupApp
                            ;;

        "custom" | "m")     echo ""
                            custom
                            ;;    

                      * )   echo "$COMMAND_TYPE is invalid option."
     esac
}

function executeShortCommand() {

    checkShortCommands

    SHORT_COMMANDS="$COMMAND_TYPE"

    for i in $(seq 0 $((${#SHORT_COMMANDS} - 1))); do

        COMMAND_TYPE=${SHORT_COMMANDS:$i:1}
        executeCommand
    done
    exit 0
}

function checkShortCommands() {

    SHORT_COMMANDS="$COMMAND_TYPE"

      for i in $(seq 0 $((${#SHORT_COMMANDS} - 1))); do

            SHORT_COMMAND=${SHORT_COMMANDS:$i:1}
            case $SHORT_COMMAND in

                "s") ;;              
                "p") ;;
                "k") ;;
                "t") ;;
                "c") ;;
                "w") ;;
                "d") ;;
                "b") ;;
                "m") ;;     
                 * )  
                     echo "$SHORT_COMMAND option is invalid." 
                     exit -1
                     ;;
        esac
    done
}


function options() {

  ### OPTIONS ###
case $COMMAND_TYPE in

    "start")  executeCommand
              exit 0
              ;;               
    "stop")   executeCommand                
              exit 0
              ;;  
    "kill")   executeCommand
              exit 0
              ;;  
    "tail")   executeCommand                
              exit 0
              ;;  
    "check")  executeCommand                
              exit 0
              ;;  
    "deploywar")  executeCommand
                  exit 0
                  ;;  
    "deploydir")  executeCommand
                  exit 0
                  ;;  
    "backup")     executeCommand
                  exit 0
                  ;;  
    "custom")     executeCommand
                  exit 0
                  ;;      

    * )   executeShortCommand;;

esac
}

function setConfigFile() {

    if [ -z "$CONFIG_FILE" ]; then
        echo ""
        echo "Set configuration file parameter."
        echo ""
        exit -1
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        echo ""
        echo "ERROR: Configuration script file does not exists. $CONFIG_FILE"
        echo ""
        exit -1
    fi

    source "$CONFIG_FILE"

    APP_NAME_FOR_PID="'[${APP_NAME:0:1}]${APP_NAME:1}'"
    PID_COMMAND="ps aux | grep $APP_NAME_FOR_PID | awk '{print "'$2'"}'"

}

COMMAND_TYPE=$1
CONFIG_FILE=$2
REMOTE_BOOL=$3

if [[ ! -z "$REMOTE_BOOL" && "$REMOTE_BOOL" != "R" ]]; then
    REMOTE_BOOL=""
fi

if [[ "$COMMAND_TYPE" == "" || "$COMMAND_TYPE" == "-help" || "$COMMAND_TYPE" == "help" ]] ; then

    echo '
    See README Section at the script file for details.                       
    command name     short   explanation                                   
    ====================================================================   
    start            s       runs the START_SCRIPT parameter              
    stop             p       runs the STOP_SCRIPT parameter                
    kill             k       kills ALL process with APP_NAME parameter     
    tail             t       tails the LOG_FILE_PATH parameter            
    check            c       shows pid, memory etc with APP_NAME param.    
    deploywar        w       deploys war. see WAR_FILE_PATH parameter      
    deploydir        d       deploys dir. see NEW_RELEASE_DIRECTORY param. 
    backup           b       backups app. see BACKUP_DIRECTORY param.      
    custom           m       calls your custom function.
    '                                                                                                  
    exit 0
fi

setConfigFile

SCRIPT_FILENAME=`basename $0`
SCRIPT_PATH="`dirname \"$0\"`"
SCRIPT_PATH="`( cd \"$SCRIPT_PATH\" && pwd )`"
SCRIPT_PATH="$SCRIPT_PATH/$SCRIPT_FILENAME"


if [ ! -z "$REMOTE_SERVER_ADDRS" ]; then

    if [ ! -z "$REMOTE_BOOL" ]; then
        setConfigFile
        options
    else
        addrs=($(echo $REMOTE_SERVER_ADDRS | tr ";" "\n"))

        size=${#addrs[@]}

        if [[ size -gt 1 ]]; then

            for i in ${addrs[@]}; do
                while true; do
                    read -p "Enter y/n to execute script for $i?" yn
                    case $yn in
                    [Yy]* ) 
                            usernamepair=($(echo $i | tr "@" "\n"))
                            username=${usernamepair[0]}
                            if [ -z "$REMOTE_SCRIPT_PATH" ]; then 
                                 REMOTE_SCRIPT_PATH="$i:/home/$username"
                            fi
                            scp -q "$CONFIG_FILE" "$i:$REMOTE_SCRIPT_PATH"
                            echo ""
                            echo "Configuration file sync to $i:$REMOTE_SCRIPT_PATH"
                            echo "Server: $i"
                            echo "============================================="
                            ssh $i 'bash -s' < "$SCRIPT_PATH" "$COMMAND_TYPE" "$REMOTE_SCRIPT_PATH$CONFIG_FILE" "R"
                            break
                          ;;
                    [Nn]* ) echo "$i skipped."
                            break
                            ;;
                        * ) echo "Please answer y/n."
                            ;;
                    esac
                done
            done
        else
            usernamepair=($(echo ${addrs[0]} | tr "@" "\n"))
            username=${usernamepair[0]}
            if [ -z "$REMOTE_SCRIPT_PATH" ]; then 
                 REMOTE_SCRIPT_PATH="${addrs[0]}:/home/$username"
            fi
            scp -q "$CONFIG_FILE" "${addrs[0]}:$REMOTE_SCRIPT_PATH"
            echo ""
            echo "Configuration file sync to ${addrs[0]}:$REMOTE_SCRIPT_PATH"
            echo "Server: ${addrs[0]}"
            echo "============================================="
            ssh ${addrs[0]} 'bash -s -t' < "$SCRIPT_PATH" "$COMMAND_TYPE" "$REMOTE_SCRIPT_PATH$CONFIG_FILE" "R"
        fi
    fi
else
    setConfigFile
    options
fi