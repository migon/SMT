 #!/bin/sh

 ####################################
 #
 #                                                                                                       
 # s
 #
 # Service Manager Tools.
 #
 # Author: Michal Soukup | email: soukup.michal@gmail.com
 #
 # Do not remove copyright and enjoy.
 #
 #
 ####################################
 
#rm -rf dirname # removes directorz and contents
#zip -r filename.zip dir/ #create zip


 #set hostname
 hostname=`hostname`
 userid=`id|sed 's/ .*//'|sed 's/.*=//'|sed 's/[^0-9].*//'`
 
#from where im running
RTE_DIR=`dirname $0`
RTE_DIR=`(cd "${RTE_DIR}"; pwd)`

#runing under user
user=`whoami`

 #set the right directory
 dir_run="/services/sm/Server/RUN/"
 dir_log="/services/logs/"
 dir_larch="/services/logs/arch/"
 dir_ports_name="ports"
 #df strings
 dfgl_sm="/services/sm" #hidden from cfgshow

 #date format
 NOW=$(date +"%Y%m%d-%H%M")
     
 #cfg file to read
 cfgfile="/services/sm/Server/RUN/sm.cfg"

#dynamic script to run sm <port>
 portfile="/services/sm/Server/RUN/pfile.sh"


#sm main log
 sml="sm.log"

 #log max file size
 lmaxs='755000000' #aprox 0.755Gb
 dfmax_sm="95" #hidden from cfgshow
 

 #delimiter
 dlmtrf="-"

 #version
 VER="0.9.50"
 
 #tar the archive?
 tar="0"
##########################################################################
##########################################################################
##########################################################################
    if [ -d "${dir_larch}" ]; 
        then
        actarchdir="${dir_larch}"   
    else
        echo "Making arch dir"
        mkdir ${dir_larch}
     fi 


    if [ ${#} -ge 1 ]
        then
    	command=${1}
        
    	if [ ${#} -ge 2 ]
        	    then
                param=${2}

                if [ ${#} -eq 3 ]
                    then
                    option=${3}
                fi    

    	fi
    fi

######################################################################
 #######################FUNCTION DEFINITION##########################

    function iApp () {

        echo "INSTALING..."
        echo "Making alias for SMT ${VER}"

        echo `alias smt="${RTE_DIR}/smt.sh"`
        echo "alias created"


    }

    function gVer () {
        echo "SMT version is:   ${VER}"

    }


    function printHelp {
                        LOGO2
        #echo ""
        #echo ""
        echo ""
        echo -e "  \e[1;10mService Manager Tools ${VER}\e[0m"
        echo -e "|---------------------------------------------------------------------------------------------------------|"	
    	echo -e "  How to use Service Manager Tools"
	    echo ""
	    echo -e "  \e[1;10msmt.sh\e[0m -[command] {param} {option}"
	    echo -e "  Commands:"
	    echo ""
        echo -e "    \e[1;10m-lb\e[0m                             Show lbstatus"
        echo -e "    \e[1;10m-rp\e[0m {port number}               Restart port {port number}"
        echo -e "    \e[1;10m-pch\e[0m {port number}              Check if port is running"
        echo -e "    \e[1;10m-sp\e[0m {port number}               Start port number"
        echo -e "    \e[1;10m-kp\e[0m {port number}               Kill {port number} port"
        echo -e "    \e[1;10m-pbp\e[0m {PID}                      Port by {PID} process id"
        echo -e "    \e[1;10m-pu\e[0m                             Ports UP - check if all valid (base on sm.cfg) ports running and show eer ports."        
        echo ""
	    echo -e "    \e[1;10m-rs\e[0m                             Restart server via smstop -f and start it again with smstart"
        echo -e "    \e[1;10m-ks\e[0m                             Kill server aka smstop -f"
        echo -e "    \e[1;10m-ss\e[0m                             Start server aka smstart"
        echo -e "    \e[1;10m-sch\e[0m                            Check server status aka smstatus"                  
        echo ""
	    echo -e "    \e[1;10m-logs\e[0m                           Make copy of logs to arch dir and make logs empty + delete errlogs"
        echo -e "    \e[1;10m-los\e[0m                            List size of logs in dir: ${dir_log}"
        echo -e "    \e[1;10m-la\e[0m                             List contents of: ${dir_larch} with sizes"
        echo -e "    \e[1;10m-gls\e[0m {logname} {string}         Grep from param {logname} param {string} - {logname} is port number or sm"
        echo -e "    \e[1;10m-glu\e[0m {logname} {userlogin}      Grep from param {logname} param {userlogin} - {logname} is port number or sm"
        echo -e "    \e[1;10m-tp\e[0m {port number}               Tail -f on log port number, can tail sm.log if parametr is sm"
        echo -e "    \e[1;10m-df\e[0m                             Disk usage for hpsm user"
        echo ""
        echo -e "    \e[1;10m-v\e[0m                              Show version of the script"
        echo -e "    \e[1;10m-cfgshow\e[0m                        Show script variables"
	    echo -e "    \e[1;10m-h\e[0m                              Show help"
	    echo -e "    \e[1;10m-?\e[0m                              Show help"
        echo ""
        echo ""
        echo ""        
						
	}


	function printVars {

        echo "SMT ${VER} script variables output"
        echo ""  
        echo "Version:				${VER}"
	echo "HOSTNAME:				${hostname}"
        echo "user id: 				${userid}"        
        echo "Timestamp:				${NOW}"
        echo "RUN DIR:				${RTE_DIR}"
	echo "Configuration file:			${cfgfile}"
	echo "Dyn. restart file:			${portfile}" 
	echo "Main log file:				${sml}"
	echo "Log directory:				${dir_log}"
        echo "MAX log size:				${lmaxs}"
	echo "Archive directory:			${dir_larch}"
        
        
	    #echo "Delimiter file:				${dlmtrf}"
	    #echo "Archive compression?:			${tar}"
	   echo ""
	}



	
	function makePortShFile () {
	
    	if [ -x ${portfile} ]
    	then
    	    V=''
            #echo "..." ${portfile}      
    	  else
    	     rm ${portfile} 
    	     touch ${portfile}
    	     echo ${portfile} "CREATED..."
             echo ""
    	     chmod +x ${portfile}
    	fi
	
	}


    # restart the port
	function rRP {
    	
    	    #make file for script
    	    makePortShFile
    	    
    	    #smruncmd=`grep ${param} ${cfgfilecrp}`
    	    smruncmd=`grep ${param} ${cfgfile}` 
    	    
    	    fcmd=${smruncmd}
    	    echo "${fcmd}" > ${portfile} #write new config to port file
    	    
    	    #smruncmd=${RTE_DIR}${slash}${smruncmd}
    						#port		#hostname	#first collum
    	    prcsid=`sm -reportlbstatus | grep ${param} | grep ${hostname} | awk '{print $1}'`
    	    
        if [ "${prcsid}" != "" ]
        then

            echo "Proces id for port: ${param} found. (${prcsid})"  
            echo "Killing (port: ${param}) process id ${prcsid}"
            
            echo `kill -9 ${prcsid}`

            echo "Process ${prcsid} killed successfully"
            echo "Starting port: ${param}"
            echo "Running command:"
            
            cmd=${prefixsmrun}${portfile}${sufix}
            echo "${cmd}"
            nohup ${portfile} 2>&1>/dev/null &		

            echo `sm -reportlbstatus`

        else
    	    echo "Process number (${prcsid}) NOT FOUND in lbstatus"
    	    echo "Running check:"
    	    echo `ps ax | grep ${param}`
            exit
        fi
	   echo ""
	}

    
    #start the port
    function sPort() {
        makePortShFile
        
        #smruncmd=`grep ${param} ${cfgfilecrp}`
        smruncmd=`grep ${param} ${cfgfile}` 
        if [[ -z "${smruncmd}" ]]; #is result empty?
            then
            echo -e "\e[31mYour port: \e[97m${param} \e[31mnot found in sm.cfg\e[0m"
        else #is not we found it
            echo -e "Port: ${param} \e[32mfound in sm.cfg\e[0m"
            fcmd=${smruncmd}
            
            dfpfile=( $(df | grep ${dfgl_sm} | awk '{print $4}') ) #return how many percent disk space (from allocated space) sm takes
            smdiskalloc="${dfpfile%?}"
           
            if (("${smdiskalloc}" >= "${dfmax_sm}")) #check if disk is writable
                then
                echo -e "\e[31mNo space in: (${dfgl_sm}) - disk have ${smdiskalloc}% used\e[0m"
                echo "Please, remove some stuff and try again"
            else 
                echo "${fcmd}" > ${portfile} #write new config to port file

                cmd=${prefixsmrun}${portfile}${sufix}
                echo "${cmd}"
                nohup ${portfile} 2>&1>/dev/null &      
                
                sleep 10
                ps ax | grep ${param} | grep sm
                echo ""          
            fi

           
        fi

    }



    #kill/end port with port number
    function ePort () {
        #echo "kill port"
        kpcmd=( $(ps ax | grep ${param} | grep sm | awk '{print $1}') )
        #echo `ps ax | grep ${param} | grep sm | awk '{print $1}'`


        echo "Number of processes found: "${#kpcmd[@]}

        for each in "${kpcmd[@]}"
        do
            `kill -9 ${each}`
            echo -e "Process: \e[31m${each} killed \e[32msuccessfully.\e[39m RIP :)"
        done   
        echo ""     
    }

    
    #tail specific port log
    function sTailPort () {

        if [ "${param}" != "sm" ]
            then
                echo "Snifing around: "${dir_log}${param}.log
                echo ""
                tail -f ${dir_log}${param}.log 
        else 
            if [ "${param}" == "sm" ]
                then
                echo "Snifing around: "${dir_log}${sml}
                echo ""            
                tail -f ${dir_log}${sml} 
            else
                echo "Please supply the right parameters"
            fi
        fi

        
    }

    function sDF() {
        df
    }

    #show ports running on this proces ID
    function sPortByPsID () {
        
        pstype=( $(ps ax | grep sm | grep ${param} | awk '{print $3}') ) #return S or Sl lines are diferent in number of colums
        #echo ${pstype}

        if [ ${pstype} == "S" ]
            then
                http=( $(ps ax | grep sm | grep ${param} | awk '{print $7}') )
                https=( $(ps ax | grep sm | grep ${param} | awk '{print $8}') )        
        elif [ ${pstype} == "Sl" ]
            then
                http=( $(ps ax | grep sm | grep ${param} | awk '{print $6}') )
                https=( $(ps ax | grep sm | grep ${param} | awk '{print $7}') )  

                #echo "(ps ax | grep sm | grep ${param} | awk '{print \$6}')"
                #echo "ps ax | grep sm | grep ${param} | awk '{print \$7}')"

               #echo ${http}
                #$echo ${https}
        else
            echo "Something is wrong. Program or your hands :]"  
            ps ax | grep ${param}
        fi

        echo "Process(${param}) running on port: ${http:10} and ${https:11}"
        echo ""

    }


	#restart server
	function rServer () {
	
	    smstop -f
        smstart	

        sm -reportlbstatus
	}

    #start server
    function sServer () {
    
        smstart 

    }
    #stop server
    function kServer () {
    
        smstop -f

    }

    #server status
    function sSrvStatus () {
    
        smstatus

    }

    function sLBstatus () {

        sm -reportlbstatus
    }


    function sGrepLogForString () {

        if [ -e  ${dir_log}${param}.log ]
            then
            echo ${dir_log}${param}.log "exists running grep ofr string '${option}'"

            echo "`cat ${dir_log}${param}.log | grep ${option}`"
        else
            echo "You entered param ${param} - but file ${dir_log}${param}.log is not there."
        fi

        
    }

    #smt -glu [user]
    function sGrepLogForUser () {

        if [ -e  ${dir_log}${param}.log ]
            then
            echo ${dir_log}${param}.log "exists running grep for string 'User ${option}'"

            echo "`cat ${dir_log}${param}.log | grep \"User ${option}\"`"
            echo "cat ${dir_log}${param}.log | grep \"User ${option}\""
        else
            echo "You entered param ${param} - but file ${dir_log}${param}.log is not there."
        fi

        
    }


   
function makeHaderPUP() {
    echo "||----------------------------------------||"
    echo "|| .. |   PORT   |  PS  |  LB  |  STATUS  ||"
    echo "============================================"


}
function makeFooterPUP() {

    echo "============================================"


}
    #check if port is up and return port statistics
    function chPortsUP () {
        
            echo "checking ports UP..."

        gls=( $(cat ${cfgfile} | grep ^sm | grep http |awk '{print $2}') ) #load the valid ports from config file
        #echo "cat ${cfgfile} | grep ^sm | awk '{print \$2}'"
        len=${#gls[@]} #number of lines in config
        #echo -e "Number of valid ports: \e[32m${len}\e[39m" 
        
        #define iterators
        ok=0
        i=0
        lbok=0
        err=0
        errtxt=''
        oktxt=''
        lberr=0 
        ln=1 #line number  
        printfmask=".."
        
       #echo "sm -reportlbstatus | grep ${hostname} | awk '{print \$3}' | egrep '^[0-9]{5}$'"
        
        lbpnl=`/services/sm/Server/RUN/sm -reportlbstatus | grep ${hostname} | awk '{print $3}' | egrep '^[0-9]{5}$'` #lbbstatus port number list
        #lbpnl=( $( sm -reportlbstatus | grep ${hostname} | awk '{print $3}' | egrep '^[0-9]{5}$') )
        
        #echo "sm -reportlbstatus | grep ${hostname} | awk '{print \$3}' | egrep '^[0-9]{5}$'"

        for ((i = 0; i != len; i++)); do
            port=${gls[i]:10}
            ilen=0
            lblen=0
            #echo  "ps ax | grep ${port} | grep sm | awk '{print $1}'"
            #pscmd=( $(ps ax | grep ${port} | grep sm | awk '{print $1}') )
            pscmd=( $(ps ax | grep ${port} | grep sm  | awk '{print $1}') )
            ilen=${#pscmd[@]} #number of processes

            lbcmd=( $( echo "${lbpnl}" | grep ${port} ) )
            lblen=${#lbcmd[@]} #number of lb lines
            #echo "${lblen} lb lines"
            #echo " ${port}: ${i} > len=${ilen}"

            #always 2 processes up and one record in lb
            if [[ ${ilen} -eq 2  && $lblen -eq 1 ]] #always 2 processes up and one record in lb OK
                then
                    lbok=$((lbok+1))
                    ok=$((ok+1))
                    lntxt=$(printf "%02d" ${ln}) #linenumber
                    okecho+=$(printf "|| %s |   %s  |   %s  |  %s   |  \e[32m%s\e[0m      ||" ${lntxt} ${port} ${ilen} ${lblen} OK) #linenumber


                    ln=$((ln+1)) #linenumber++
            elif [[ ${ilen} -eq 2  && $lblen -ne 1 ]] #LB missing
                then
                    ok=$((ok+1))
                    lntxt=$(printf "%02d" ${ln}) #linenumber
                    okecho+=$(printf "|| %s |   \e[41m%s\e[0m  |   %s  |  \e[41m%s\e[0m   |  \e[41m%s\e[0m     ||" ${lntxt} ${port} ${ilen} ${lblen} err) #linenumber
                    lberr=$((lberr+1))

                    ln=$((ln+1)) #linenumber++
            elif [[ ${ilen} -ne 2  && $lblen -eq 1 ]] #ps wrong number of processes need to be 2
                then
                    lbok=$((lbok+1))
                    err=$((err+1))
                    lntxt=$(printf "%02d" ${ln}) #linenumber
                    okecho+=$(printf "|| %s |   \e[41m%s\e[0m  |   \e[41m%s\e[0m  |  %s   |  \e[41m%s\e[0m     ||" ${lntxt} ${port} ${ilen} ${lblen} err) #linenumber


                    ln=$((ln+1)) #linenumber++
            elif [[ ${ilen} -ne 2  && $lblen -ne 1 ]] #all is wrong
                then
                    err=$((err+1))
                    lntxt=$(printf "%02d" ${ln}) #linenumber
                    okecho+=$(printf "|| \e[41m%s\e[0m |   %s  |   %s  |  %s   |  \e[41m%s\e[0m     ||" ${lntxt} ${port} ${ilen} ${lblen} err) #linenumber
                    lberr=$((lberr+1))

                    ln=$((ln+1)) #linenumber++
            else
                    echo "unexpected fail."
            fi



            okecho+="\n" #end of table line

        done 
        #ok=$((ok-1))
        ttlerr=$((${err} + ${lberr})) #add normal errs and lb errors

        #echo "all errrs : ${ttlerr}"
        makeHaderPUP
        echo -e "${okecho}"
        makeFooterPUP
        echo ""

        echo -e "Number of valid ports: \e[32m${len}\e[39m"

        if [[ ${ok} == ${len} && ${lbok} == ${len} ]]
            then
            echo -e "Number of running ports: \e[32m${ok}\e[39m"
            echo -e "Number of LB ports: \e[32m${lbok}\e[39m"
            echo -e "\e[32mALL PORTS RUNNING\e[39m"
        elif [ ${ttlerr} -gt 0 ]
            then
                echo "Number of running ports: ${ok}" 
                echo -e "Number of running LB ports: \e[32m${lbok}\e[39m"
                echo -e "\e[31mNumber of errors: ${ttlerr}\e[39m"
        else
                echo -e "Dont know what happend - ask google man. He knows everything."
                echo -e "Number of running ports: \e[32m${ok}\e[39m"
                echo -e "Number of LBB ports: \e[32m${lbok}\e[39m"
                echo -e "\e[31mNumber of errors: ${err}\e[39m" 
                echo -e "\e[31mNumber of LB errors: ${lberr}\e[39m"              
        fi

    }

    #check if the port is running - 
    #todo: add lb status data
    function chPort () {

        pscmd=( $(ps ax | grep ${param} | grep sm | awk '{print $1}') )
        #echo "ps ax | grep ${param} | grep sm | awk '{print \$1}'"
        ilen=${#pscmd[@]} #number of processes
        #echo " ${port}: ${i}> len=${ilen}"
        if [ ${ilen} -eq 2 ] #always 2 processes up
            then
                echo "Processes found (2)."
                echo -e "\e[32mPort: ${param} - is running.\e[39m"
        else

                echo -e " \e[31mError found at port: \e[39m${port}"
                echo -e "${ilen} processes runing."
        fi

        echo ""

    }



    function rLogs () {
    
	   if [ -d "${dir_larch}${NOW}" ]; 
	       then
	           actarchdir="${dir_larch}${NOW}/"   
	   else
	           mkdir ${dir_larch}${NOW}
	           actarchdir="${dir_larch}${NOW}/"
	           echo -e "${dir_larch}${NOW}... 			\e[34mcreated\e[0m"
	   fi
        
       if [ -d "${dir_larch}${NOW}/${dir_ports_name}" ]; 
           then
               portsarch="${dir_larch}${NOW}/${dir_ports_name}/"   
       else
               `mkdir ${dir_larch}${NOW}/${dir_ports_name}`

               if [ -d "${dir_larch}${NOW}/${dir_ports_name}" ]
                    then

                        portsarch="${dir_larch}${NOW}/${dir_ports_name}/"
                        echo -e "${dir_larch}${NOW}/${dir_ports_name}...           \e[34mcreated\e[0m"
                else
                        echo -e "${dir_larch}${NOW}/${dir_ports_name}...           \e[34mFAILED. No directory created\e[0m"
                fi
       fi       
    	# echo ` mkdir ${dir_larch}${NOW}`
    	 lsarr=( $(ls ${dir_log} | egrep '^[0-9]{5}.log$') )
    	
    	for each in "${lsarr[@]}"
    	do
            cp ${dir_log}${each} ${portsarch}${each}
            echo -e "\e[0mFile: ${dir_log}${each} copy created"
            `echo > ${dir_log}${each}`
            echo -e "\e[0mFile: ${dir_log}${each} shrinked to 0"
    	done
        
        echo -e "\e[31mdeleting stdouterr\e[0"

        lsarr=( $(ls ${dir_log} | egrep 'sm_[0-9]+_[a-z]+err\.log') )
        for each in "${lsarr[@]}"
        do
            `rm ${dir_log}${each}`
            echo -e "\e[0mFile: ${dir_log}${each} ... \e[31mdeleted\e[0m"
        done
	   
       cp ${dir_log}${sml} ${actarchdir}${sml} 
	   echo -e "\e[32mCreating copy of\e[0m" ${dir_log}${sml} "\e[32m to \e[0m" ${actarchdir}${sml} 
	   `echo > ${dir_log}${sml}`
	   echo "----------------------------"
	   echo "${dir_log}${sml} file shrinked to 0"
       echo ""

    }	

    #check sizes of logs
    function sizeLogs () {
        
        # echo ` mkdir ${dir_larch}${NOW}`
        lsarr=( $(ls ${dir_log} | egrep '^[0-9]{5}.log$') )
        
        #maximum log size 755000000 

        for each in "${lsarr[@]}"
        do
            #`echo > ${dir_log}${each}`
            #echo -e "\e[0mFile: ${dir_log}${each} shrinked to 0"
            #echo    "ls -la ${dir_log} | grep ${each} | awk '{print \$5}'"
            size=( $(ls -la ${dir_log} | grep ${each} | awk '{print $5}') )
            psize=( $(ls -lh ${dir_log} | grep ${each} | awk '{print $5}') )

            if [[ ${size} -lt ${lmaxs} ]] 
                then
                echo -e "${each}    ...\e[32mOK\e[0m ${psize}"
            elif [[ ${size} -gt ${lmaxs} ]]; 
                then
                echo -e "${each}    ...\e[31mMAX size exceeded\e[0m (${psize})"
            fi
       
        done

            size=( $(ls -la ${dir_log} | grep ${sml} | awk '{print $5}') )
            psize=( $(ls -lh ${dir_log} | grep ${sml} | awk '{print $5}') )

             if [[ ${size} -lt ${lmaxs} ]] 
                then
                echo -e "${sml}       ...\e[32mOK\e[0m ${psize}"
            elif [[ ${size} -gt ${lmaxs} ]]; 
                then
                echo -e "${sml}       ...\e[31mMAX size exceeded\e[0m (${psize})"
            fi 
            echo ""   

    }  

#-la 
    function listArchive () {
        #only 4096 grep to omit the . .. directories 
        lsarr=( $(ls ${dir_larch}) )
        

        echo "Archive contents (${dir_larch}): "
divider="=============================="
divider=$divider$divider$divider

header="\n %-5s %-20s %-12s %7s %7s %7s %9s\n"
format=" %-5s %-20s %-12s %7s %7s %7s %9s\n"
width=80

printf "$header" "TYPE" "NAME" "DATE" "TIME" "MLOG" "PLOG" "TTL"
printf "%$width.${width}s\n" "$divider"


        for each in "${lsarr[@]}"
        do

            if [[ -d "${dir_larch}${each}" ]]
                then
                    typ="DIR"
                    date="${each:6:2}.${each:4:2}.${each:0:4}"
                    name="${each}"
                    tim="${each:9:2}:${each:11:2}"
                    psize=( $(ls -lh ${dir_larch}${each}/ | grep ${sml}  | awk '{print $5}') )
                    ppsize=( $(du -sh "${dir_larch}${each}/${dir_ports_name}" | awk '{print $1}') )

                    printf "$format" ${typ} ${each} ${date} ${tim} ${psize} ${ppsize} "0"

                    #echo "Archive [${each}] from (date):  ...found ( ${sml}: ${psize} / ports: ${ppsize}) "

            elif [[ -f "${dir_larch}${each}" ]]
                then
                typ="ZIP"
                date="${each:6:2}.${each:4:2}.${each:0:4}"

                tim="${each:9:2}:${each:11:2}"
                name="${each}"                
                psize=( $(ls -lh ${dir_larch}${each} | grep ${each}  | awk '{print $5}') )
                #echo "ls -lh ${dir_larch}${each} | grep ${each}  | awk '{print \$5}'"
                printf "$format" ${typ} ${each} ${date} ${tim}  "0" "0" ${psize}
               #echo "Archive [${each}] from (date): ${each:6:2}.${each:4:2}.${each:0:4}  ...found ( ${each}: ${psize} ) "
            fi           

        

      
        done
        #count it all 
        
        size=( $(du -sh "${dir_larch}" | awk '{print $1}') ) #siye of the directory human readable
        #dflogs=( $(df | grep ${dfgl_log} | awk '{print $4}') ) #return how many percent disk space (from allocated space) logs takes
        dflogs=( $(df | grep ${dir_log%?} | awk '{print $4}') ) #return how many percent disk space (from allocated space) logs takes
        
        
        printf "%$width.${width}s\n" "$divider"
        echo -e "TOTAL Archive size: ${size} \t Disk space usage for ${dir_log}:  ${dflogs}"
        #echo "Disk space usage for ${dir_log}:  ${dflogs}"
        echo ""

    }



LOGO2() {
cat <<"EOT"
.|'''|                                            '||\   /||`                                               
||                            ''                   ||\\.//||                                                
`|'''|, .|''|, '||''| \\  //  ||  .|'', .|''|,     ||     ||   '''|.  `||''|,   '''|.  .|''|, .|''|, '||''| 
 .   || ||..||  ||     \\//   ||  ||    ||..||     ||     ||  .|''||   ||  ||  .|''||  ||  || ||..||  ||   
 |...|' `|...  .||.     \/   .||. `|..' `|...     .||     ||. `|..||. .||  ||. `|..||. `|..|| `|...  .||.  
                                                                                           ||               
                                                                                        `..|'               
|''||''|               '||`                        ||     .''',     
   ||                   ||                        '||     |   |     
   ||    .|''|, .|''|,  ||  (''''    \\  //        ||     |   |     Author: Michal Soukup  
   ||    ||  || ||  ||  ||   `'')     \\//         ||     |   |     E-mail: soukup.michal@gmail.com
  .||.   `|..|' `|..|' .||. `...'      \/   ..    .||. .. `,,,' 
EOT
}

##########################################################################################
	if [ $# -eq 0 ]  # Must have command-line args to demo script.
    then
		echo "Please invoke this script with one or more command-line arguments."
		echo ""
		echo  "FOR help pls use: smt -h"
		echo ""
		echo "Number of command-line arguments passed to script = ${#@}"
		echo "Number of command-line arguments passed to script = ${#*}"
        echo ""
		exit $E_NO_ARGS
	 else

	    if [ ${#} -ge 1 ] # have we  or more params?
		then
		command=${1}
		  		
    		if [ ${#} -ge 2 ] #are there 2 params?
    		    then
    		    param=${2}
                
                if [ ${#} -eq 3 ]
                    then
                    option=${3}
                fi     		    
    		fi
	    fi
				        
	 fi
    	
	#what to run
	if [ ${command} == "-h" -o ${command} == "-?" ];
    	     then
             printHelp;
     	elif [ ${command} == "-cfgshow" ];
    	    then
    	        printVars;
    	elif [ ${command} == "-rp" -a ${#} -eq 2 ]
    	    then
    	    echo "SMT ${VER} is attempting to shutdown port: ${param}"        
    		rRP
            sm -reportlbstatus
        elif [ ${command} == "-lb" ] 
            then
            sLBstatus
    	elif [ ${command} == "-rs" ] #server restart smstop -f
    	    then
        	echo "Attempting to restart server (with option -f)"
    		rServer
        elif [ ${command} == "-ss" ] #server start
            then
            echo "Attempting to start server"
            sServer   
        elif [ ${command} == "-ks" ] #server start
            then
            echo "Attempting to Shutdown the server (with option -f)"
            kServer
        elif [ ${command} == "-sch" ] #server start
            then
            echo "Checking server status"
            sSrvStatus                                    
    	elif [ ${command} == "-logs" ]
    	    then
    	    rLogs
        elif [ ${command} == "--install" ]  
            then
            iApp 
        elif [ ${command} == "-sp"  -a ${#} -eq 2 ]
            then
            sPort
        elif [ ${command} == "-kp"  -a ${#} -eq 2 ]
            then
            ePort
        elif [ ${command} == "-v" ]
            then
             gVer   
        elif [ ${command} == "-lb" ]
            then
             sLBstatus
        elif [ ${command} == "-tp" -a ${#} -eq 2 ]
            then
             sTailPort  
        elif [ ${command} == "-pbp" -a ${#} -eq 2 ]
            then
             sPortByPsID 
        elif [ ${command} == "-gls" -a ${#} -eq 3 ]
            then
            sGrepLogForString
        elif [ ${command} == "-glu" -a ${#} -eq 3 ]
            then
            sGrepLogForUser  
        elif [ ${command} == "-pu" ]
            then
            chPortsUP
        elif [ ${command} == "-df" ]
            then
            sDF
        elif [ ${command} == "-pch" -a ${#} -eq 2 ]
            then
            chPort
        elif [ ${command} == "-los" ] #log sizes
            then
            sizeLogs  
        elif [ ${command} == "-la" ] #list archive
            then
           listArchive    

               #smt -glu [user]
                                                     
        elif [ ${command} == "-ttt" -a ${#} -eq 3 ]
            then
            
            echo "command" ${command}
            echo "param" ${param}
            echo "opt" ${option}                                     
        else
    	    echo "Command not recognized"
    	    echo "FOR HELP WITH THE SMT ${VER} use smt.sh -h"
    	fi
        
   
  
