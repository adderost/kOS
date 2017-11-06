//CONFIG
SET io_logToKSC TO TRUE.
SET io_saveLocalLogs TO FALSE.

//DEPENDENCIES
wantModule("comms").

//MODULE
//LOGS SYSTEM MESSAGES. OUTPUTS TO TERMINAL IF AVAILABLE
FUNCTION log_system{
	PARAMETER out.
	PARAMETER sender IS "UNKNOWN".

	SET out TO "["+sender+"] "+out.

	IF io_saveLocalLogs io_safeLog(out, "/system.log").
	IF hasModule("comms"){
		IF comms_hasLocalControl {
			IF NOT hasModule("cli_display") PRINT out.
			ELSE cli_print(out).
		}
		IF io_logToKSC AND comms_hasSignalKSC{
			IF NOT comms_hasLocalControl {
				IF NOT hasModule("cli_display") PRINT out.
				ELSE cli_print(out).
			}
			dumplog_system().
		}
	}
	ELSE {
		IF NOT hasModule("cli_display") PRINT out.
		ELSE cli_print(out).
	} 
}
//DUMPS THE SYSTEM LOG TO KSC ARCHIVE
FUNCTION dumplog_system{
	IF hasModule("comms"){
		IF comms_hasSignalKSC{
			IF core:volume:exists("/system.log"){
				SET logstr TO OPEN("/system.log"):READALL:STRING.
				LOG logstr TO "0:/Vessels/"+SHIP:NAME+"/log/system.log".
				DELETEPATH("/system.log").
			}
		}
	}
	ELSE log_system("Unable to dump system log. Commsmodule not available", "IO").
}
//LOGS STUFF TO PATH. IF MEMORY IS FULL DELETE LOG AND START AGIAN.
FUNCTION io_safeLog{
	PARAMETER str.
	PARAMETER path.
	SET str TO "["+timer+"]	"+str. 
	IF core:volume:freespace > (str:LENGTH + 1) {
		LOG str TO (path).
	}
	ELSE {
		IF core:volume:exists(path) core:volume:delete(path).
		IF core:volume:freespace < (str:LENGTH + 1) {
			core:volume:delete("/log").
			IF core:volume:freespace < (str:LENGTH + 1){
				core:volume:delete("/logCache").
			}
		}
		log_system("Out of memory! New file ["+path+"]", "IO").
		IF core:volume:freespace > (str:LENGTH + 1) LOG str TO (path).
	}
}