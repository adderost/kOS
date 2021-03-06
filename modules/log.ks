//CONFIG
SET log_saveLocalLogs TO FALSE.
SET log_printToSyslog TO TRUE.

//DEPENDENCIES
needModule("IO").
needModule("time").
wantModule("comms").

//MODULE
FUNCTION log_output {
  PARAMETER text.
  PARAMETER logFile IS "output.log".
  SET logStr TO "[T" +time_getDeltaT()+ "]	" + text.
  IF log_saveLocalLogs io_safeLog(logStr, ("/log/"+logFile)).
  log_toArchive(logStr, logfile).
  IF log_printToSyslog io_syslog("["+logFile+"]	"+logStr, "Log").
}

FUNCTION log_toArchive {
  PARAMETER str.
  PARAMETER logFile.

  SET logPath TO ship:name:REPLACE(" - ", "/")+"/log/".

  IF hasModule("comms"){
    IF comms_hasSignalKSC(){
      IF NOT archive:exists("/Vessels/"+logPath+logFile) archive:create("/Vessels/"+logPath+logFile).
      archive:open("/Vessels/"+logPath+logFile):writeln(str).
    }
    ELSE{
      io_safeLog(str, "/logCache/"+logfile).
    }
  }
  ELSE{
    io_safeLog(text, "/logCache/"+logfile).
  }
}

FUNCTION log_dumpCache {
  IF core:volume:exists("/logCache") {
    FOR cacheFile IN core:volume:open("/logCache"):list:values{
      io_syslog("Dumping cached log "+cacheFile, "Log").
      IF NOT core:volume:open("/logCache/"+cacheFile):readall:empty {
        SET cacheIterator to core:volume:open("/logCache/"+cacheFile):readall:iterator.
        UNTIL NOT cacheIterator:NEXT {
          log_toArchive(cacheIterator:VALUE, cacheFile).
          wait 0.
        }
      }
      ELSE io_syslog("Cached log "+cacheFile+" empty", "Log").
    }
    core:volume:delete("/logCache/").
  }
}

IF hasModule("comms"){
  ON comms_hasSignalKSC{
    IF comms_hasSignalKSC()log_dumpCache().
    RETURN TRUE.
  }
}