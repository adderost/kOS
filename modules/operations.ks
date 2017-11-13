//CONFIG
SET operations_opsLoader TO 0.		//What ops are we Loading?
SET operations_opsCounter TO 0.		//What ops are we running?
SET operations_opsQueue TO LIST().	//List of ops running next cycle
SET operations_opsRun TO LIST().	//List of ops running this cycle.
SET operations_opsLocked TO FALSE.	//If true. We will not download new ops-files.
SET operations_keepLocal TO FALSE.	//Should the system save local copies of ops-files

//DEPENDENCIES
needModule("IO").
needModule("comms").
wantModule("log").
wantModule("saveStates").

//MODULE
FUNCTION operations_load {
	IF hasModule("saveStates") {
		getSaveState("operations_opsLoader", operations_opsLoader).
		setSaveState("operations_opsLoader", operations_opsLoader).
	}

	IF comms_hasSignalKSC(){
		SET opsPath TO ship:name:REPLACE(" - ", "/").
		SET archivePath TO "/Vessels/"+opsPath+"/".
		SET opsFilename TO "ops_"+operations_opsLoader+".ks".
		SET sourcePath TO archivePath+opsFilename.
		IF NOT archive:exists(sourcePath) SET sourcePath TO archivePath+"ops.ks".
		IF archive:exists(sourcePath) {
			IF hasModule("log") log_output("Loading operations #"+operations_opsLoader, "operations.log").
			ELSE io_syslog("Loading operations #"+operations_opsLoader, "Operations").
			IF COPYPATH("0:"+sourcePath, "0:"+archivePath+opsFilename){
				IF sourcePath = (archivePath+"ops.ks") archive:delete(archivePath+"ops.ks").
				IF NOT COPYPATH("0:"+archivePath+opsFilename, "/ops/"+opsFilename){
					IF hasModule("log") log_output("Unable to download ops", "operations.log").
					ELSE io_syslog("Unable to download ops - Not enough memory?", "Operations").
				}
				ELSE{
					IF hasModule("log") log_output("Ops "+opsFilename+" downloaded successfully", "operations.log").
					ELSE io_syslog("Ops "+opsFilename+" downloaded successfully", "Operations").
					SET operations_opsLoader TO operations_opsLoader + 1.
				}
			}
		}
		ELSE{
			
		}
	}
	ELSE{
		ON comms_hasSignalKSC(){
			operations_load().
		}
	}

	IF operations_opsLoader > operations_opsCounter operations_add(operations_read@).
}

FUNCTION operations_read{	
	IF NOT operations_opsLocked {
		SET opsFilename TO "/ops/ops_"+operations_opsCounter+".ks".	
		IF hasModule("log") log_output("Importing operations "+ opsFilename, "operations.log").
		ELSE io_syslog("Importing operations "+ opsFilename, "Operations").
		IF core:volume:exists(opsFilename) 
		{
			RUNPATH(opsFilename).
			IF NOT operations_keepLocal core:volume:delete(opsFilename).
		}
		ELSE {
			IF hasModule("log") log_output("Operations file doesn't exist. "+opsFilename, "operations.log").
			ELSE io_syslog("Operations file doesn't exist. "+opsFilename, "Operations").
		}
		SET operations_opsCounter TO operations_opsCounter + 1.	
	}
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