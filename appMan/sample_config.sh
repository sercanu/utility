# "mytomcatapp"
APP_NAME=""
# /home/user/mytomcatapp/bin/startup.sh"
START_SCRIPT=""
# "/home/user/mytomcatapp/bin/shutdown.sh"
STOP_SCRIPT=""
# "/home/user/mytomcatapp/logs/catalina.out"
LOG_FILE_PATH=""
# "/home/user/mytomcatapp/webapp/ROOT"
RUNNING_APP_DIRECTORY=""
# "/home/user/mytomcatapp/webapp/temp/release"
NEW_RELEASE_DIRECTORY=""
# "/home/user/mytomcatapp/temp/myapp.war"
WAR_FILE_PATH=""
# "/home/user/mytomcatapp/temp/backup/"
BACKUP_DIRECTORY=""
# "user1@server1;user2@server2;userN@serverN"
REMOTE_SERVER_ADDRS=""
# Default is user's home, leave it blank for default
REMOTE_SCRIPT_PATH=""

# cp database.properties $RUNNING_APP_DIRECTORY/classes/
function custom() {

 echo "custom function started..."

   # Code anything you wish...
   # copy database.properties, set environment parameters etc..

   echo "custom function ended."

 }