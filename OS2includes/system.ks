//CONFIG

//DEPENDENCIES
wantModule("IO").
wantModule("resources").

//MODULE
//SHUTS DOWN SYSTEM AND ATTEMPTS LOGDUMP
FUNCTION shutdownSystem{
	io_syslog("SYSTEM SHUTDOWN", "System").
	dumpio_syslog().
	SHUTDOWN.
}
//REBOOTS SYSTEM
FUNCTION rebootSystem{
	io_syslog("SYSTEM REBOOTING", "System").
	REBOOT.
}
//REBOOTS WITH A MESSAGE
FUNCTION systemInterrupt{
	PARAMETER msg IS "".
	IF hasModule("IO") io_syslog(msg, "System").
	rebootSystem().
}