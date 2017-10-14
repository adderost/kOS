//////////////////
// Initilaization
//////////////////

clearscreen.

//CONFIGS
SET deleteOnFinish TO FALSE.
SET logToKSC TO TRUE.

//SIGNALS
SET initialized TO FALSE.
SET systemInterrupt TO FALSE.

//STATIC VARIABLES
SET systemBootTime TO TIME:SECONDS.

//DYNAMIC GLOBAL VARIABLES
SET hasSignal TO FALSE.
SET hasSignalKSC TO FALSE.
SET hasLocalControl TO FALSE.
SET opCode TO 0.

//TIMER
LOCK timer TO (TIME:SECONDS - systemBootTime).

////ESSENTIAL SYSTEM FUNCTIONS////

//LOGS SYSTEM MESSAGES. OUTPUTS TO TERMINAL IF AVAILABLE
FUNCTION systemLog{
	PARAMETER out.
	checkSignal().
	safeLog(out, "/system.log").
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
			LOG logstr TO "0:/"+SHIP:NAME+"/log/system.log".
			DELETEPATH("/system.log").
		}
	}
}

//LOGS STUFF TO PATH. IF MEMORY IS FULL DELETE LOG AND START AGIAN.
FUNCTION safeLog{
	PARAMETER str.
	PARAMETER path.

	checkSignal().	
	SET str TO "["+timer+"]	"+str. 
	//Sizecheck. Null terminated? Maybe
	IF core:volume:freespace > (str:LENGTH + 1) {
		LOG str TO (path).
	}
	ELSE {
		core:volume:delete(path).
		IF core:volume:freespace < (str:LENGTH + 1) {
			core:volume:delete("/log").
		}
		systemLog("Out of memory! New file ["+path+"]").
		LOG str TO (path).
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

//CHECK FOR ANY SIGNAL
ON hasSignal {
	IF hasSignal systemLog("COMMUNICATIONS ESTABLISHED").	
	ELSE systemLog("COMMUNICATIONS LOST").
}

//DO WE HAVE COMMUNICATION WITH KSC
ON hasSignalKSC {
	IF hasSignalKSC {
		IF logToKSC dumpSystemLog().
		systemLog("CONNECTION TO KSC ESTABLISHED").	
	}
	ELSE systemLog("CONNECTION TO KSC LOST").
}

//DO WE HAVE LOCAL CONTROL
ON hasLocalControl {
	IF hasLocalControl systemLog("LOCAL CONTROL ESTABLISHED").	
	ELSE systemLog("LOCAL CONTROL ESTABLISHED LOST").
}

//TRIGGER SIGNALS
FUNCTION checkSignal {

	IF addons:available("RT") SET remoteConnection TO addons:RT.
	ELSE {
		systemLog("Fatal error: No radiomodule available").
	}

	IF remoteConnection:HASKSCCONNECTION(SHIP) SET hasSignalKSC TO TRUE.
	ELSE SET hasSignalKSC TO FALSE.
	
	//TODO Check for mobile commandcenter
	IF remoteConnection:HASLOCALCONTROL(SHIP) SET hasLocalControl TO TRUE.
	ELSE SET hasLocalControl TO FALSE.

	IF remoteConnection:HASCONNECTION(SHIP) SET hasSignal TO TRUE.
	ELSE SET hasSignal TO FALSE.
}


////SYSTEM SETUP AND RUNTIME////

//LOADS DEPENDENCIES INTO SYSTEM
FUNCTION bootSequence {
	//TODO. MAKE SYSTEM ABLE TO RESUME FROM SHUTDOWN
	checkSignal().

	//FIRST TRY TO DOWNLOAD DEPENDENCIES
	IF hasSignalKSC {
		// load dependencies - IF they are not found we are on the launchpad initializing, load from the archive
		systemLog("Loading dependencies").
		IF not core:volume:exists("/includes") {
			COPYPATH("0:/includes", core:volume:root).
		}
	}
	//THEN TRY TO RUN DEPENDENCIES WHEN SAVED
	IF core:volume:exists("/includes") {
		FOR includeFile in core:volume:open("/includes"):list:values{
			systemLog("Loading file: " + includeFile).
			RUNPATH("/includes/" + includeFile).
		}
		SET initialized TO TRUE.
		systemLog("System initialized").
	}
	//OTHERWISE WE'RE SHIT OUT OF LUCK
	ELSE {
		systemLog("Can't load dependencies - Reboot").
		rebootSystem().
	}
}

//CHECKS FOR SHIP SPECIFIC OPERATIONS. RUNS THEM IF THEY EXIST
FUNCTION opsRun {
		
	// check IF a new ops file is waiting TO be executed
	IF hasSignalKSC AND NOT archive:open("/"+ship:name + "/ops.ks"):readall:empty {
		COPYPATH("0:/" + ship:name + "/ops.ks", "/ops/ops.ks").
		systemLog("operations received, executing Operations " + opCode).
		RUNPATH("/ops/ops.ks").
		IF deleteOnFinish {
			core:volume:delete("/ops/ops.ks").
		}
		ELSE {
			MOVEPATH("/ops/ops.ks", "/ops/oldOps"+opcode+".ks").
		}

		systemLog("Operations "+opCode+" complete").
		IF hasSignalKSC { 
			COPYPATH("0:/" + ship:name + "/ops.ks", "0:/" + ship:name + "/ops" + opCode + ".ks").
			archive:open("/"+ship:name + "/ops.ks"):clear.
		}
		systemLog("Waiting to receive operations...").
		SET opCode TO opCode + 1.
	}
	// Run any existing ops
	ELSE IF core:volume:exists("/ops/ops.ks") {
		systemLog("Running stored operations...").
		RUNPATH("/ops/ops.ks").
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
	checkSignal().
	wait 0.
}