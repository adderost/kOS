SET logList TO list().

FUNCTION output {
  PARAMETER text.
  PARAMETER logFile IS "output.log".
  
  // LOG the new data TO the file IF it will fit
  // otherwise delete the LOG TO start anew
  SET logStr TO "[" +timer+ "] " + text.
  safeLog(logStr, ("/log/"+logFile)).

  // store a copy on KSC hard drives IF we are IN contact
  // otherwise save and copy over as soon as we are back IN contact
  IF hasSignalKSC {
    dumpLogCache().
    outputToArchive(logStr, logfile).
  } 
  ELSE {
    safeLog(logStr, "/logCache/"+logfile).
  }
}

FUNCTION outputToArchive {
  PARAMETER str.
  PARAMETER logFile.

  IF NOT archive:exists("/" + ship:name + "/log/"+logFile) archive:create("/" + ship:name + "/log/"+logFile).
  archive:open("/" + ship:name + "/log/"+logFile):writeln(str).
}

FUNCTION dumpLogCache {
  IF core:volume:exists("/logCache") {
    FOR cacheFile IN core:volume:open("/logCache"):list:values{
      SET cacheIterator to core:volume:open("/logCache/"+cacheFile):readall:iterator.
      UNTIL NOT cacheIterator:NEXT {
        outputToArchive(cacheIterator:VALUE, logFile).
        wait 0.
      }
    }
    core:volume:delete("/logCache/").
  }
}

ON hasSignalKSC {
  IF hasSignalKSC dumpLogCache().
}