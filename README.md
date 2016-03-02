# SMT
Service Manager Tools
Helps to operate HP Service Manager server in easy way.

 smt.sh -[command] {param} {option}
  Commands:

    -lb                             Show lbstatus
    -rp {port number}               Restart port {port number}
    -pch {port number}              Check if port is running
    -sp {port number}               Start port number
    -kp {port number}               Kill {port number} port
    -pbp {PID}                      Port by {PID} process id
    -pu                             Ports UP - check if all valid (base on sm.cfg) ports running and show err ports.

    -rs                             Restart server via smstop -f and start it again with smstart
    -ks                             Kill server aka smstop -f
    -ss                             Start server aka smstart
    -sch                            Check server status aka smstatus

    -logs                           Make copy of logs to arch dir and make logs empty + delete errlogs
    -los                            List size of logs in dir: CUSTOM/path
    -la                             List contents of: CUSTOM/path with sizes
    -zla                            Zip archives from list and (optional) delete source directory
    -uza {ZipName}                  Unzip archive {ZipName} - unzip {ZipName} to CUSTOM/path
    -gls {logname} {string}         Grep from param {logname} param {string} - {logname} is port number or sm
    -glu {logname} {userlogin}      Grep from param {logname} param {userlogin} - {logname} is port number or sm
    -tp {port number}               Tail -f on log port number, can tail sm.log if parameter is sm
    -df                             Disk usage for hpsm user

    -v                              Show version of the script
    -cfgshow                        Show script variables
    -h                              Show help
    -?                              Show help

