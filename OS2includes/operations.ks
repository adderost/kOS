//CONFIG
SET operations_opsCounter TO 0.
SET operations_opsQueue TO LIST().

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

	IF comms_hasSignalKSC {
		SET archivePath TO "/Vessels/"+ship:name+"/".
		SET opsFilename TO "ops_"+operations_opsCounter+".ks".	
		IF archive:exists(archivePath+"ops.ks") {
			IF hasModule("log") log_output("Loading operations #"+operations_opsCounter, "operations.log").
			ELSE log_system("Loading operations #"+operations_opsCounter, "Operations").
			IF COPYPATH("0:"+archivePath+"ops.ks", "0:"+archivePath+opsFilename){
				archive:delete(archivePath+"ops.ks").
				IF NOT COPYPATH("0:"+archivePath+opsFilename, "/ops/"+opsFilename){
					IF hasModule("log") log_output("Unable to download ops", "operations.log").
					ELSE log_system("Unable to download ops", "Operations").
				}
				ELSE{
					IF hasModule("log") log_output("Ops "+opsFilename+" downloaded successfully", "operations.log").
					ELSE log_system("Ops "+opsFilename+" downloaded successfully", "Operations").
				}
			}
		}
		ELSE{
			log_system("No ops found for this vessel", "Operations").
		}
	}
	ELSE{
		log_system("Can't load operations. No connection to archive", "Operations").
		ON comms_hasSignalKSC {
			operations_load().
		}
	}
}

FUNCTION operations_read{
	SET opsFilename TO "/ops/ops_"+operations_opsCounter+".ks".	
	IF hasModule("log") log_output("Importing operations "+ opsFilename, "operations.log").
	ELSE log_system("Importing operations "+ opsFilename, "Operations").
	IF core:volume:exists(opsFilename) RUNPATH(opsFilename).
	ELSE {
		IF hasModule("log") log_output("Operations file doesn't exist. "+opsFilename, "operations.log").
		ELSE log_system("Operations file doesn't exist. "+opsFilename, "Operations").
	}
}

FUNCTION operations_add{
	PARAMETER ops.
	IF ops:typename = "UserDelegate" operations_opsQueue:ADD(ops).
}

FUNCTION operations_run {
	IF operations_opsQueue:LENGTH <= 0 operations_add(operations_load@).
	FOR operation IN operations_opsQueue {
		operation:call().
	}
}