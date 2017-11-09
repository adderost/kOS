//CONFIG
SET operations_opsCounter TO 0.
SET operations_opsQueue TO LIST().
SET operations_opsRun TO LIST().
SET operations_opsLocked TO FALSE.

//DEPENDENCIES
needModule("IO").
needModule("comms").
wantModule("log").
wantModule("saveStates").

//MODULE
FUNCTION operations_load {
	IF hasModule("saveStates") {
		getSaveState("operations_opsCounter", operations_opsCounter).
		setSaveState("operations_opsCounter", operations_opsCounter).
	}

	IF NOT operations_opsLocked {
		IF comms_hasSignalKSC(){
			SET archivePath TO "/Vessels/"+ship:name+"/".
			SET opsFilename TO "ops_"+operations_opsCounter+".ks".	
			IF archive:exists(archivePath+"ops.ks") {
				IF hasModule("log") log_output("Loading operations #"+operations_opsCounter, "operations.log").
				ELSE io_syslog("Loading operations #"+operations_opsCounter, "Operations").
				IF COPYPATH("0:"+archivePath+"ops.ks", "0:"+archivePath+opsFilename){
					archive:delete(archivePath+"ops.ks").
					IF NOT COPYPATH("0:"+archivePath+opsFilename, "/ops/"+opsFilename){
						IF hasModule("log") log_output("Unable to download ops", "operations.log").
						ELSE io_syslog("Unable to download ops", "Operations").
					}
					ELSE{
						IF hasModule("log") log_output("Ops "+opsFilename+" downloaded successfully", "operations.log").
						ELSE io_syslog("Ops "+opsFilename+" downloaded successfully", "Operations").
						operations_add(operations_read@).
					}
				}
			}
			ELSE{
				
			}
		}
		ELSE{
			io_syslog("Can't load operations. No connection to archive", "Operations").
			ON comms_hasSignalKSC(){
				operations_load().
			}
		}
	}
}

FUNCTION operations_read{
	SET opsFilename TO "/ops/ops_"+operations_opsCounter+".ks".	
	IF hasModule("log") log_output("Importing operations "+ opsFilename, "operations.log").
	ELSE io_syslog("Importing operations "+ opsFilename, "Operations").
	IF core:volume:exists(opsFilename) RUNPATH(opsFilename).
	ELSE {
		IF hasModule("log") log_output("Operations file doesn't exist. "+opsFilename, "operations.log").
		ELSE io_syslog("Operations file doesn't exist. "+opsFilename, "Operations").
	}
	SET operations_opsCounter TO operations_opsCounter + 1.
}

FUNCTION operations_add{
	PARAMETER ops.
	IF ops:typename = "UserDelegate" operations_opsQueue:ADD(ops).
}

FUNCTION operations_lock {
	SET operations_opsLocked TO TRUE.
}

FUNCTION operations_unlock {
	SET operations_opsLocked TO FALSE.
}

FUNCTION operations_run {
	SET operations_opsRun TO operations_opsQueue:COPY.
	SET operations_opsQueue TO LIST().
	IF operations_opsRun:LENGTH <= 0 operations_add(operations_load@).
	FOR operation IN operations_opsRun {
		operation:call().
	}
}