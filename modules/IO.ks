//CONFIG
SET io_logToKSC TO TRUE.
SET io_saveLocalLogs TO TRUE.

//DEPENDENCIES
needModule("time").
wantModule("comms").

//MODULE
//LOGS SYSTEM MESSAGES. OUTPUTS TO TERMINAL IF AVAILABLE
FUNCTION io_syslog {
	PARAMETER out.
	PARAMETER sender IS "UNKNOWN".

	SET out TO "["+sender+"]	"+out.

	IF io_saveLocalLogs io_safeLog(out, "/system.log").
	IF hasModule("comms"){
		IF comms_hasLocalControl() {
			IF NOT hasModule("cli") PRINT out.
			ELSE cli_print(out).
		}
		IF io_logToKSC AND comms_hasSignalKSC(){
			IF NOT comms_hasLocalControl() {
				IF NOT hasModule("cli") PRINT out.
				ELSE cli_print(out).
			}
			io_logdump().
		}
	}
	ELSE {
		IF NOT hasModule("cli") PRINT out.
		ELSE cli_print(out).
	} 
}
//DUMPS THE SYSTEM LOG TO KSC ARCHIVE
FUNCTION io_logdump{
	SET logPath TO ship:name:REPLACE(" - ", "/")+"/log/".
	IF hasModule("comms"){
		IF comms_hasSignalKSC(){
			IF core:volume:exists("/system.log"){
				SET logstr TO OPEN("/system.log"):READALL:ITERATOR.
				UNTIL NOT logstr:NEXT {
					IF NOT ARCHIVE:EXISTS("/Vessels/"+logPath+"system.log") ARCHIVE:CREATE("/Vessels/"+SHIP:NAME+"/log/system.log").
					ARCHIVE:OPEN("/Vessels/"+logPath+"system.log"):writeln(logstr:VALUE).
				}
				DELETEPATH("/system.log").
			}
		}
	}
	ELSE io_syslog("Unable to dump system log. Commsmodule not available", "IO").
}
//LOGS STUFF TO PATH. IF MEMORY IS FULL DELETE LOG AND START AGIAN.
FUNCTION io_safeLog{
	PARAMETER str.
	PARAMETER path.
	SET str TO "["+time_current()+"]	"+str. 
	IF core:volume:freespace > (str:LENGTH + 1) {
		IF NOT core:volume:exists(path) core:volume:create(path).
		core:volume:open(path):writeln(str).
	}
	ELSE {
		IF core:volume:exists(path) core:volume:delete(path).
		IF core:volume:freespace < (str:LENGTH + 1) {
			core:volume:delete("/log").
			IF core:volume:freespace < (str:LENGTH + 1){
				core:volume:delete("/logCache").
			}
		}
		io_syslog("Out of memory! New file ["+path+"]", "IO").
		IF core:volume:freespace > (str:LENGTH + 1) LOG str TO (path).
	}
}