//VARIABLES
SET hasSignal TO FALSE.
SET hasSignalKSC TO FALSE.
SET hasLocalControl TO FALSE.

//MODULE
ON hasSignal {
	IF hasModule("IO"){
		IF hasSignal systemLog("Communications established","Comms").	
		ELSE systemLog("Communications lost","Comms").
	}
	RETURN TRUE.
}
ON hasSignalKSC {
	IF hasModule("IO"){
		IF hasSignalKSC {
			IF logToKSC dumpSystemLog().
			systemLog("Connection to ksc established","Comms").	
		}
		ELSE systemLog("Connection to ksc lost","Comms").
	}
	RETURN TRUE.
}
ON hasLocalControl {
	IF hasModule("IO"){
		IF hasLocalControl systemLog("Local control established","Comms").	
		ELSE systemLog("Local control established lost","Comms").
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
		IF hasModule("IO") systemLog("Fatal error: No radiomodule available","Comms").
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