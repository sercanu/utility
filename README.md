Utility repo is for any useful script, code, etc. 
Current scripts are

 * AppMan.sh : Wrapper for any process. It is possible to kill, start, stop, see memory usage etc. Remote scripting is possible.

AppMan.sh
============

How to use : Set your UNIQUE application name and other parameters at settings section. Then run the script with parameters shown below. Can be used for Apache Tomcat, Gunicorn etc. or any running process. Start editing the parameters at Settings Sections. Have fun.

Commands  

    command name     short   explanation                                   
    -------------------------------------------------------
    start            s       runs the START_SCRIPT parameter               
    stop             p       runs the STOP_SCRIPT parameter                
    kill             k       kills ALL process with APP_NAME parameter     
    tail             t       tails the LOG_FILE_PATH parameter             
    check            c       shows pid, memory etc with APP_NAME param.    
    deploywar        w       deploys war. see WAR_FILE_PATH parameter      
    deploydir        d       deploys dir. see NEW_RELEASE_DIRECTORY param. 
    backup           b       backups app. see BACKUP_DIRECTORY param.      
    custom           m       calls your custom function.

Examples
                                                            
    appMan.sh start   >   start application                           
    appMan.sh s       >   start application                           
    appMan.sh tail    >   tail the log file                           
    appMan.sh st      >   start app. and tail the log file            
    appMan.sh wst     >   deploy war, start app, tail log             
    appMan.sh kbwst   >   kill, backup, deploy war, start, tail       
    appMan.sh help    >   show help  

Output

    ./appMan.sh check
    Enter y/n to execute script for tomcat@server01?y
    Server: tomcat@server01
    --------------------------------------------

    mytomcatapp is running!

    PID     Mem Usage   VSZ        Mem%     CPU%    
    --------------------------------------------
    27519   792 MB      3317 MB    6.6      2.8     

    Enter y/n to execute script for tomcat@server02?n
    tomcat@server02 skipped.

