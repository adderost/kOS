clearscreen.
PRINT "System startup".
//CONFIGS
SET includesDir TO "/OS2includes/".
SET saveLocalModules TO FALSE.

//SIGNALS
SET systemInitialized TO FALSE.

//STATIC VARIABLES
SET systemBootTime TO TIME:SECONDS.

//DYNAMIC GLOBAL VARIABLES
DECLARE GLOBAL loadedModules TO lexicon().

FUNCTION bootSequence {
	needModule("system").
	wantModule("saveStates").
	IF hasModule("saveStates"){
		getSaveState("systemBootTime", systemBootTime).
		setSaveState("systemBootTime", systemBootTime).
	}

	SET systemInitialized TO TRUE.
	systemLog("SYSTEM BOOTED SUCCESSFULLY", "Boot").
}

FUNCTION loadModule{ //LOADS A MODULE INTO MEMORY
	PARAMETER module.
	PARAMETER clearCache IS FALSE.
	DECLARE LOCAL modulePath IS includesDir+module+".ks".
	DECLARE LOCAL moduleLoaded IS FALSE.

	IF NOT loadedModules:HASKEY(module){
		loadedModules:ADD(module, FALSE).
		IF NOT clearCache AND core:volume:exists(modulePath){
			SET moduleLoaded TO TRUE.
		}
		ELSE IF archive:exists(modulePath) {
			COPYPATH("0:"+modulePath, modulePath).
			SET moduleLoaded TO TRUE.
		}

		IF moduleLoaded{
			RUNPATH(modulePath).
			SET loadedModules[module] TO TRUE.
			IF hasModule("IO") systemLog("Loaded module: "+module, "Module Loader").
			IF NOT saveLocalModules{
				CORE:VOLUME:DELETE(modulePath).
			}
			RETURN TRUE.
		}
		ELSE RETURN FALSE.
	}
	ELSE RETURN TRUE.
}

FUNCTION needModule{
	PARAMETER module.
	PARAMETER clearCache IS FALSE.

	IF NOT loadModule(module, clearCache){
		systemInterrupt("FATAL ERROR: Unable to load required module '"+module+"'", "Module Loader").
		RETURN FALSE.
	}
	ELSE RETURN TRUE.
}

FUNCTION wantModule{
	PARAMETER module.
	PARAMETER clearCache IS FALSE.

	IF NOT loadModule(module, clearCache){
		IF hasModule("IO") systemLog("NOTICE: Unable to load optional module '"+module+"'", "Module Loader").
		RETURN FALSE.
	}
	ELSE RETURN TRUE.
}

FUNCTION hasModule{
	PARAMETER module IS "dummy".
	IF loadedModules:HASKEY(module){
		RETURN loadedModules[module].
	}
	ELSE RETURN FALSE.
}

//RUN BOOT SEQUENCE
UNTIL systemInitialized {
	bootSequence().
	wait 0.
}