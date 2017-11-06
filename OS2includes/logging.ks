//CONFIG
SET saveLocalLogs TO FALSE.
SET printToSyslog TO TRUE.

//DEPENDENCIES
needModule("IO").
wantModule("comms").

//MODULE
FUNCTION output {
  PARAMETER text.
  PARAMETER logFile IS "output.log".
  SET logStr TO "[" +round(timer)+ "] " + text.
  IF saveLocalLogs safeLog(logStr, ("/log/"+logFile)).
  outputToArchive(logStr, logfile).
  IF printToSyslog systemLog("[-logFile-] "+logStr).
}

FUNCTION outputToArchive {
  PARAMETER str.
  PARAMETER logFile.
  IF hasModule("comms"){
    IF comms_hasSignal{
      IF NOT archive:exists("/Vessels/" + ship:name + "/log/"+logFile) archive:create("/Vessels" + ship:name + "/log/"+logFile).
      archive:open("/Vessels/" + ship:name + "/log/"+logFile):writeln(str).
    }
    ELSE{
      safeLog(text, "/logCache/"+logfile).
    }
  }
  ELSE{
    safeLog(text, "/logCache/"+logfile).
  }
}

FUNCTION dumpLogCache {
  IF core:volume:exists("/logCache") {
    FOR cacheFile IN core:volume:open("/logCache"):list:values{
      systemLog("Dumping cached log "+cacheFile, "Logging").
      IF NOT core:volume:open("/logCache/"+cacheFile):readall:empty {
        SET cacheIterator to core:volume:open("/logCache/"+cacheFile):readall:iterator.
        UNTIL NOT cacheIterator:NEXT {
          outputToArchive(cacheIterator:VALUE, cacheFile).
          wait 0.
        }
      }
      ELSE systemLog("Cached log "+cacheFile+" empty", "Logging").
    }
    core:volume:delete("/logCache/").
  }
}

IF hasModule("comms"){
  ON comms_hasSignalKSC{
    IF comms_hasSignalKSC dumpLogCache().
    RETURN TRUE.
  }
}