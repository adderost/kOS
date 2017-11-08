//VARIABLES
SET comms_hasSignal TO FALSE.
SET comms_hasSignalKSC TO FALSE.
SET comms_hasLocalControl TO FALSE.

SET comms_logToKSC TO TRUE.

//MODULE
ON comms_hasSignal {
	IF hasModule("IO"){
		IF comms_hasSignal io_syslog("Communications established","Comms").	
		ELSE io_syslog("Communications lost","Comms").
	}
	RETURN TRUE.
}
ON comms_hasSignalKSC {
	IF hasModule("IO"){
		IF comms_hasSignalKSC {
			IF comms_logToKSC io_logdump().
			io_syslog("Connection to KSC established","Comms").	
		}
		ELSE io_syslog("Connection to KSC lost","Comms").
	}
	RETURN TRUE.
}
ON comms_hasLocalControl {
	IF hasModule("IO"){
		IF comms_hasLocalControl io_syslog("Local control active","Comms").	
		ELSE io_syslog("Local control inactive","Comms").
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
		IF hasModule("IO") io_syslog("Fatal error: No radiomodule available","Comms").
		IF hasModule("system") shutdownSystem().
	}
	IF remoteConnection:HASKSCCONNECTION(SHIP) SET comms_hasSignalKSC TO TRUE.
	ELSE SET comms_hasSignalKSC TO FALSE.
	IF remoteConnection:hasLocalControl(SHIP) SET comms_hasLocalControl TO TRUE.
	ELSE SET comms_hasLocalControl TO FALSE.
	IF remoteConnection:HASCONNECTION(SHIP) SET comms_hasSignal TO TRUE.
	ELSE SET comms_hasSignal TO FALSE.
}

checkSignal().