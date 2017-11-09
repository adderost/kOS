//VARIABLES
SET comms_varHasSignal TO FALSE.
SET comms_varHasSignalKSC TO FALSE.
SET comms_varHasLocalControl TO FALSE.

SET comms_logToKSC TO TRUE.

//DEPENDENCIES
needModule("scheduler").

//MODULE
ON comms_varHasSignal {
	IF hasModule("IO"){
		IF comms_varHasSignal io_syslog("Communications established","Comms").	
		ELSE io_syslog("Communications lost","Comms").
	}
	RETURN TRUE.
}
ON comms_varHasSignalKSC {
	IF hasModule("IO"){
		IF comms_varHasSignalKSC {
			IF comms_logToKSC io_logdump().
			io_syslog("Connection to KSC established","Comms").	
		}
		ELSE io_syslog("Connection to KSC lost","Comms").
	}
	RETURN TRUE.
}
ON comms_varHasLocalControl {
	IF hasModule("IO"){
		IF comms_varHasLocalControl io_syslog("Local control active","Comms").	
		ELSE io_syslog("Local control inactive","Comms").
	}
	RETURN TRUE.
}

FUNCTION comms_hasSignalKSC {
	comms_check().
	RETURN comms_varHasSignalKSC.
}

FUNCTION comms_hasLocalControl {
	comms_check().
	RETURN comms_varHasLocalControl.
}

FUNCTION comms_hasSignal {
	comms_check().
	RETURN comms_varHasSignal.
}

FUNCTION comms_check {
	IF addons:available("RT") SET remoteConnection TO addons:RT.
	ELSE {
		IF hasModule("IO") io_syslog("Fatal error: No radiomodule available","Comms").
		IF hasModule("system") shutdownSystem().
	}
	IF remoteConnection:HASKSCCONNECTION(SHIP) SET comms_varHasSignalKSC TO TRUE.
	ELSE SET comms_varHasSignalKSC TO FALSE.
	IF remoteConnection:hasLocalControl(SHIP) SET comms_varHasLocalControl TO TRUE.
	ELSE SET comms_varHasLocalControl TO FALSE.
	IF remoteConnection:HASCONNECTION(SHIP) SET comms_varHasSignal TO TRUE.
	ELSE SET comms_varHasSignal TO FALSE.
}

scheduler_add_everySecond("comms_check", comms_check@).