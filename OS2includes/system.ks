//CONFIG

//DEPENDENCIES
wantModule("IO").

//MODULE
//SHUTS DOWN SYSTEM AND ATTEMPTS LOGDUMP
FUNCTION shutdownSystem{
	systemLog("SYSTEM SHUTDOWN", "System").
	dumpSystemLog().
	SHUTDOWN.
}
//REBOOTS SYSTEM
FUNCTION rebootSystem{
	systemLog("SYSTEM REBOOTING", "System").
	REBOOT.
}
//REBOOTS WITH A MESSAGE
FUNCTION systemInterrupt{
	PARAMETER msg IS "".
	IF hasModule("IO") systemLog(msg, "System").
	rebootSystem().
}