clearscreen.
PRINT "System startup".
//CONFIGS
SET includesDir TO "/OS2includes/".
SET saveLocalModules TO FALSE.

//SIGNALS
SET systemInitialized TO FALSE.

//TIMER (Fires every second)
LOCK timer TO ROUND(TIME:SECONDS - systemBootTime).

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
	systemLog("SYSTEM BOOTED SUCCESSFULLY", "OS2").
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
			IF hasModule("IO") systemLog("Loaded module: "+module, "OS2").
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
		systemInterrupt("FATAL ERROR: Unable to load required module '"+module+"'", "OS2").
		RETURN FALSE.
	}
	ELSE RETURN TRUE.
}

FUNCTION wantModule{
	PARAMETER module.
	PARAMETER clearCache IS FALSE.

	IF NOT loadModule(module, clearCache){
		IF hasModule("IO") systemLog("NOTICE: Unable to load optional module '"+module+"'", "OS2").
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

wantModule("cli_display").
startDisplay().



SET i to 0.
UNTIL NOT systeminitialized {
	wait 0. //Placeholder action loop
	SET i TO i + 1.
	IF i > 50 {
		systemLog("Time is: "+ROUND(TIME:SECONDS), "OS").
		SET i TO 0.
	}
}