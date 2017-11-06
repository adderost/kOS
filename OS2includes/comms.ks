//VARIABLES
SET comms_hasSignal TO FALSE.
SET comms_hasSignalKSC TO FALSE.
SET comms_hasLocalControl TO FALSE.

//MODULE
ON comms_hasSignal {
	IF hasModule("IO"){
		IF comms_hasSignal log_system("Communications established","Comms").	
		ELSE log_system("Communications lost","Comms").
	}
	RETURN TRUE.
}
ON comms_hasSignalKSC {
	IF hasModule("IO"){
		IF comms_hasSignalKSC {
			IF logToKSC dumplog_system().
			log_system("Connection to ksc established","Comms").	
		}
		ELSE log_system("Connection to ksc lost","Comms").
	}
	RETURN TRUE.
}
ON comms_hasLocalControl {
	IF hasModule("IO"){
		IF comms_hasLocalControl log_system("Local control active","Comms").	
		ELSE log_system("Local control inactive","Comms").
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
		IF hasModule("IO") log_system("Fatal error: No radiomodule available","Comms").
		IF hasModule("system") shutdownSystem().
	}
	IF remoteConnection:HASKSCCONNECTION(SHIP) SET comms_hasSignalKSC TO TRUE.
	ELSE SET comms_hasSignalKSC TO FALSE.
	IF remoteConnection:comms_hasLocalControl(SHIP) SET comms_hasLocalControl TO TRUE.
	ELSE SET comms_hasLocalControl TO FALSE.
	IF remoteConnection:HASCONNECTION(SHIP) SET comms_hasSignal TO TRUE.
	ELSE SET comms_hasSignal TO FALSE.
}

checkSignal().