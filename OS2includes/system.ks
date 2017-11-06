//CONFIG

//DEPENDENCIES
wantModule("IO").
wantModule("resources").

//MODULE
//SHUTS DOWN SYSTEM AND ATTEMPTS LOGDUMP
FUNCTION shutdownSystem{
	log_system("SYSTEM SHUTDOWN", "System").
	dumplog_system().
	SHUTDOWN.
}
//REBOOTS SYSTEM
FUNCTION rebootSystem{
	log_system("SYSTEM REBOOTING", "System").
	REBOOT.
}
//REBOOTS WITH A MESSAGE
FUNCTION systemInterrupt{
	PARAMETER msg IS "".
	IF hasModule("IO") log_system(msg, "System").
	rebootSystem().
}