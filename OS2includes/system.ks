//CONFIG
SET me TO "System".

//DEPENDENCIES
wantModule("IO").

//MODULE
//SHUTS DOWN SYSTEM AND ATTEMPTS LOGDUMP
FUNCTION shutdownSystem{
	systemLog("SYSTEM SHUTDOWN", me).
	dumpSystemLog().
	SHUTDOWN.
}
//REBOOTS SYSTEM
FUNCTION rebootSystem{
	systemLog("SYSTEM REBOOTING", me).
	REBOOT.
}
//REBOOTS WITH A MESSAGE
FUNCTION systemInterrupt{
	PARAMETER msg IS "".
	IF hasModule("IO") systemLog(msg, me).
	rebootSystem().
}