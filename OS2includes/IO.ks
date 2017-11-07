//CONFIG
SET io_logToKSC TO TRUE.
SET io_saveLocalLogs TO TRUE.

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
			io_logdump().
		}
	}
	ELSE {
		IF NOT hasModule("cli_display") PRINT out.
		ELSE cli_print(out).
	} 
}
//DUMPS THE SYSTEM LOG TO KSC ARCHIVE
FUNCTION io_logdump{
	IF hasModule("comms"){
		IF comms_hasSignalKSC{
			IF core:volume:exists("/system.log"){
				SET logstr TO OPEN("/system.log"):READALL:ITERATOR.
				UNTIL NOT logstr:NEXT {
					IF NOT ARCHIVE:EXISTS("/Vessels/"+SHIP:NAME+"/log/system.log") ARCHIVE:CREATE("/Vessels/"+SHIP:NAME+"/log/system.log").
					ARCHIVE:OPEN("/Vessels/"+SHIP:NAME+"/log/system.log"):writeln(logstr:VALUE).
				}
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
		log_system("Out of memory! New file ["+path+"]", "IO").
		IF core:volume:freespace > (str:LENGTH + 1) LOG str TO (path).
	}
}