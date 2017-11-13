//CONFIG

//DEPENDENCIES
needModule("IO").

//MODULE
//SHUTS DOWN SYSTEM AND ATTEMPTS LOGDUMP
FUNCTION system_shutdown{
	io_syslog("SYSTEM SHUTDOWN", "System").
	io_logdump().
	SHUTDOWN.
}
//REBOOTS SYSTEM
FUNCTION system_reboot{
	IF hasModule("IO") io_syslog("SYSTEM REBOOTING", "System").
	REBOOT.
}
//REBOOTS WITH A MESSAGE
FUNCTION system_interrupt{
	PARAMETER msg IS "".
	IF hasModule("IO") io_syslog(msg, "System").
	system_reboot().
}