FUNCTION output {
  PARAMETER text.
  PARAMETER logFile IS "output.log".
  SET logStr TO "[" +round(timer)+ "] " + text.
  IF saveLocalLogs safeLog(logStr, ("/log/"+logFile)).
  IF hasSignalKSC {
    outputToArchive(logStr, logfile).
  } 
  ELSE {
    safeLog(text, "/logCache/"+logfile).
  }
}
FUNCTION outputToArchive {
  PARAMETER str.
  PARAMETER logFile.
  IF NOT archive:exists("/Vessels/" + ship:name + "/log/"+logFile) archive:create("/Vessels/" + ship:name + "/log/"+logFile).
  archive:open("/Vessels/" + ship:name + "/log/"+logFile):writeln(str).
}
FUNCTION dumpLogCache {
  IF core:volume:exists("/logCache") {
    FOR cacheFile IN core:volume:open("/logCache"):list:values{
      systemLog("Output.ks: Dumping cached log "+cacheFile).
      IF NOT core:volume:open("/logCache/"+cacheFile):readall:empty {
        SET cacheIterator to core:volume:open("/logCache/"+cacheFile):readall:iterator.
        UNTIL NOT cacheIterator:NEXT {
          outputToArchive(cacheIterator:VALUE, cacheFile).
          wait 0.
        }
      }
      ELSE systemLog("Output.ks: Cached log "+cacheFile+" empty").
    }
    core:volume:delete("/logCache/").
  }
}
ON hasSignalKSC {
  IF hasSignalKSC dumpLogCache().
  RETURN TRUE.
}