clearscreen.
PRINT "System startup".

//CONFIGS
SET includesDir TO "/OS2includes/".
SET saveLocalModules TO FALSE.

//SIGNALS
SET systemInitialized TO FALSE.
SET systemInterrupt TO FALSE.

//TIMER (Fires every second)
LOCK timer TO ROUND(TIME:SECONDS - systemBootTime).

//STATIC VARIABLES
SET systemBootTime TO TIME:SECONDS.

//DYNAMIC GLOBAL VARIABLES
DECLARE GLOBAL loadedModules TO lexicon().

FUNCTION bootSequence {	//Starts the system
	needModule("system").
	needModule("operations").
	wantModule("saveStates").
	IF hasModule("saveStates"){
		getSaveState("systemBootTime", systemBootTime).
		setSaveState("systemBootTime", systemBootTime).
	}

	SET systemInitialized TO TRUE.
	io_syslog("System has booted up successfully", "OS").
}

FUNCTION loadModule{	//Loads and runs a named module.
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
			IF hasModule("IO") io_syslog("Loaded module: "+module, "OS").
			IF NOT saveLocalModules{
				CORE:VOLUME:DELETE(modulePath).
			}
			RETURN TRUE.
		}
		ELSE RETURN FALSE.
	}
	ELSE RETURN TRUE.
}

FUNCTION needModule{	//Used to load a required module. Will interrupt system if fail
	PARAMETER module.
	PARAMETER clearCache IS FALSE.

	IF NOT loadModule(module, clearCache){
		system_interrupt("FATAL ERROR: Unable to load required module '"+module+"'", "OS").
		RETURN FALSE.
	}
	ELSE RETURN TRUE.
}

FUNCTION wantModule{	//Used to load an optional module. It's up to the caller to handle if it fails.
	PARAMETER module.
	PARAMETER clearCache IS FALSE.

	IF NOT loadModule(module, clearCache){
		IF hasModule("IO") io_syslog("NOTICE: Unable to load optional module '"+module+"'", "OS").
		RETURN FALSE.
	}
	ELSE RETURN TRUE.
}

FUNCTION hasModule{		//Returns true if the module is loaded and available. Otherwise false.
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

//RUN operations
io_syslog("Entering operations main loop", "OS").
UNTIL systemInterrupt {
	IF hasModule("cli") cli_display_update().
	operations_run().
	wait 0.
}

//If we get here something is probably wrong
system_interrupt("SYSTEM ENTERED INTERRUPT STATE. REBOOT").