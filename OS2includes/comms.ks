//CONFIG
SET hasSignal TO FALSE.
SET hasSignalKSC TO FALSE.
SET hasLocalControl TO FALSE.
SET me TO "Comms".

//TIMER
LOCK timer TO ROUND(TIME:SECONDS - systemBootTime).

//MODULE
ON hasSignal {
	IF hasModule("IO"){
		IF hasSignal systemLog("Communications established", me).	
		ELSE systemLog("Communications lost", me).
	}
	RETURN TRUE.
}
ON hasSignalKSC {
	IF hasModule("IO"){
		IF hasSignalKSC {
			IF logToKSC dumpSystemLog().
			systemLog("Connection to ksc established", me).	
		}
		ELSE systemLog("Connection to ksc lost", me).
	}
	RETURN TRUE.
}
ON hasLocalControl {
	IF hasModule("IO"){
		IF hasLocalControl systemLog("Local control established", me).	
		ELSE systemLog("Local control established lost", me).
	}
	RETURN TRUE.
}

ON timer {
	checkSignal().
	RETURN TRUE.
}

FUNCTION checkSignal {
	IF addons:available("RT") SET remoteConnection TO addons:RT.
	ELSE {
		IF hasModule("IO") systemLog("Fatal error: No radiomodule available", me).
		IF hasModule("system") shutdownSystem().
	}
	IF remoteConnection:HASKSCCONNECTION(SHIP) SET hasSignalKSC TO TRUE.
	ELSE SET hasSignalKSC TO FALSE.
	IF remoteConnection:HASLOCALCONTROL(SHIP) SET hasLocalControl TO TRUE.
	ELSE SET hasLocalControl TO FALSE.
	IF remoteConnection:HASCONNECTION(SHIP) SET hasSignal TO TRUE.
	ELSE SET hasSignal TO FALSE.
}

checkSignal().