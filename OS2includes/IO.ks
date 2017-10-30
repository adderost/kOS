//CONFIG
SET logToKSC TO TRUE.
SET saveLocalLogs TO FALSE.
SET me TO "IO".

//DEPENDENCIES
wantModule("comms").

//MODULE
//LOGS SYSTEM MESSAGES. OUTPUTS TO TERMINAL IF AVAILABLE
FUNCTION systemLog{
	PARAMETER out.
	PARAMETER sender IS "UNKNOWN".

	SET out TO "["+sender+"] "+out.

	IF saveLocalLogs safeLog(out, "/system.log").
	IF hasModule("comms"){
		IF hasLocalControl PRINT out.
		IF logToKSC AND hasSignalKSC{
			IF NOT hasLocalControl PRINT out.
			dumpSystemLog().
		}
	}
	ELSE PRINT out.
}
//DUMPS THE SYSTEM LOG TO KSC ARCHIVE
FUNCTION dumpSystemLog{
	IF hasModule("comms"){
		IF hasSignalKSC{
			IF core:volume:exists("/system.log"){
				SET logstr TO OPEN("/system.log"):READALL:STRING.
				LOG logstr TO "0:/Vessels/"+SHIP:NAME+"/log/system.log".
				DELETEPATH("/system.log").
			}
		}
	}
	ELSE systemLog("Unable to dump system log. Commsmodule not available", me).
}
//LOGS STUFF TO PATH. IF MEMORY IS FULL DELETE LOG AND START AGIAN.
FUNCTION safeLog{
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
		systemLog("Out of memory! New file ["+path+"]", me).
		IF core:volume:freespace > (str:LENGTH + 1) LOG str TO (path).
	}
}