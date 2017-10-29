clearscreen.
//CONFIGS
SET deleteOnFinish TO FALSE.
SET logToKSC TO TRUE.
SET saveLocalLogs TO FALSE.
//SIGNALS
SET initialized TO FALSE.
SET systemInterrupt TO 	FALSE.
//STATIC VARIABLES
SET systemBootTime TO TIME:SECONDS.
//DYNAMIC GLOBAL VARIABLES
SET hasSignal TO FALSE.
SET hasSignalKSC TO FALSE.
SET hasLocalControl TO FALSE.
SET opCode TO 0.
//TIMER
LOCK timer TO ROUND(TIME:SECONDS - systemBootTime).
////ESSENTIAL SYSTEM FUNCTIONS////
//LOGS SYSTEM MESSAGES. OUTPUTS TO TERMINAL IF AVAILABLE
FUNCTION systemLog{
	PARAMETER out.
	IF saveLocalLogs safeLog(out, "/system.log").
	IF hasLocalControl PRINT out.
	IF logToKSC AND hasSignalKSC{
		IF NOT hasLocalControl PRINT out.
		dumpSystemLog().
	}
}
//DUMPS THE SYSTEM LOG TO KSC ARCHIVE
FUNCTION dumpSystemLog{
	IF hasSignalKSC{
		IF core:volume:exists("/system.log"){
			SET logstr TO OPEN("/system.log"):READALL:STRING.
			LOG logstr TO "0:/Vessels/"+SHIP:NAME+"/log/system.log".
			DELETEPATH("/system.log").
		}
	}
}
//LOGS STUFF TO PATH. IF MEMORY IS FULL DELETE LOG AND START AGIAN.
FUNCTION safeLog{
	PARAMETER str.
	PARAMETER path.
	SET str TO "["+timer+"]	"+str. 
	//Sizecheck. Null terminated? Maybe
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
		systemLog("Out of memory! New file ["+path+"]").
		IF core:volume:freespace > (str:LENGTH + 1) LOG str TO (path).
	}
}
//SHUTS DOWN SYSTEM AND ATTEMPTS LOGDUMP
FUNCTION shutdownSystem{
	systemLog("SYSTEM SHUTDOWN").
	dumpSystemLog().
	SHUTDOWN.
}
//REBOOTS SYSTEM
FUNCTION rebootSystem{
	systemLog("SYSTEM REBOOTING").
	REBOOT.
}
////COMMUNICATIONS CONTROL////
ON timer {
	checkSignal().
	RETURN TRUE.
}

ON hasSignal {
	IF hasSignal systemLog("COMMUNICATIONS ESTABLISHED").	
	ELSE systemLog("COMMUNICATIONS LOST").
	RETURN TRUE.
}
ON hasSignalKSC {
	IF hasSignalKSC {
		IF logToKSC dumpSystemLog().
		systemLog("CONNECTION TO KSC ESTABLISHED").	
	}
	ELSE systemLog("CONNECTION TO KSC LOST").
	RETURN TRUE.
}
ON hasLocalControl {
	IF hasLocalControl systemLog("LOCAL CONTROL ESTABLISHED").	
	ELSE systemLog("LOCAL CONTROL ESTABLISHED LOST").
	RETURN TRUE.
}
//TRIGGER SIGNALS
FUNCTION checkSignal {
	IF addons:available("RT") SET remoteConnection TO addons:RT.
	ELSE {
		systemLog("Fatal error: No radiomodule available").
		shutdownSystem().
	}
	IF remoteConnection:HASKSCCONNECTION(SHIP) SET hasSignalKSC TO TRUE.
	ELSE SET hasSignalKSC TO FALSE.
	IF remoteConnection:HASLOCALCONTROL(SHIP) SET hasLocalControl TO TRUE.
	ELSE SET hasLocalControl TO FALSE.
	IF remoteConnection:HASCONNECTION(SHIP) SET hasSignal TO TRUE.
	ELSE SET hasSignal TO FALSE.
}
////SYSTEM SETUP AND RUNTIME////
//LOADS DEPENDENCIES INTO SYSTEM
FUNCTION bootSequence {
	IF core:volume:exists("/systemData/opcode.sav"){
		systemLog("RESTORING SAVED STATE").
		SET opCode TO OPEN("/systemData/opcode.sav"):readall:string:TONUMBER(0).
	}
	IF core:volume:exists("/systemData/systemBootTime.sav"){
		systemLog("RESTORING SAVED STATE").
		SET systemBootTime TO OPEN("/systemData/systemBootTime.sav"):readall:string:TONUMBER(0).
	}
	//Save state in case of power down.
	IF core:volume:exists("/systemData/systemBootTime.sav")	OPEN("/systemData/systemBootTime.sav"):clear.
	ELSE CREATE("/systemData/systemBootTime.sav").
	OPEN("/systemData/systemBootTime.sav"):write(systemBootTime:TOSTRING).
	IF hasSignalKSC {
		// load dependencies - IF they are not found we are on the launchpad initializing, load from the archive
		systemLog("Loading dependencies").
		IF not core:volume:exists("/includes") {
			COPYPATH("0:/includes", core:volume:root).
		}
	}
	IF core:volume:exists("/includes") {
		FOR includeFile in core:volume:open("/includes"):list:values{
			systemLog("Loading file: " + includeFile).
			RUNPATH("/includes/" + includeFile).
		}
		SET initialized TO TRUE.
		systemLog("System initialized").
	}
	ELSE {
		systemLog("Can't load dependencies - Reboot").
		rebootSystem().
	}
}
//CHECKS FOR SHIP SPECIFIC OPERATIONS. DOWNLOADS AND RUNS
FUNCTION opsRun {	
	IF core:volume:exists("/systemData/opcode.sav")	OPEN("/systemData/opcode.sav"):clear.
	ELSE CREATE("/systemData/opcode.sav").
	OPEN("/systemData/opcode.sav"):write(opCode:TOSTRING).
	SET opsFilename TO "ops_"+opCode+".ks".	
	IF hasSignalKSC {
		IF archive:exists("/Vessels/"+ship:name+"/ops.ks") {
			systemLog("Downloading operations: "+opsFilename).
			IF COPYPATH("0:/Vessels"+ship:name+"/ops.ks", "0:/Vessels"+ship:name+"/"+opsFilename){
				archive:delete("/Vessels"+ship:name+"/ops.ks").
				IF NOT COPYPATH("0:/Vessels"+ship:name+"/"+opsFilename, "/ops/"+opsFilename) systemLog("Download of operations failed. Free space: "+core:volume:freespace+" bytes").
			}
		}
	}
	IF core:volume:exists("/ops/"+opsFilename) {
		systemLog("Running stored operation: "+opsFilename).
		RUNPATH("/ops/"+opsFilename).
		systemLog("Operation execution finished: "+opsFilename).
		IF deleteOnFinish {
			systemLog("Deleting operations file from internal memory: "+opsFilename).
			core:volume:delete("/ops/"+opsFilename).
		}
		SET opCode TO opCode + 1.
	}
}
//RUNS BOOT SEQUENCE
systemLog("Booting System").
UNTIL initialized {
	bootSequence().
	wait 0.
}
//THEN RUNS OPS
systemLog("Starting OPS-loop").
UNTIL systemInterrupt{
	opsRun().
	wait 0.
}