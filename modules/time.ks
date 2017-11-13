//CONFIG
SET time_T TO FALSE.

//DEPENDENCIES

//MODULE
FUNCTION time_current {
	  RETURN time_format().
}

FUNCTION time_delta {
	PARAMETER thisTime.
	PARAMETER primeTime IS time.

	IF thisTime:seconds > primeTime:seconds SET sign TO "-".
	ELSE SET sign TO "+".
	
	RETURN sign+time_format((primeTime - thisTime)).
	
}

FUNCTION time_getDeltaT{
	IF time_T:typename = "TimeSpan" {
		RETURN time_delta(time_T).
	}
	ELSE RETURN "null".
}

FUNCTION time_format {
	PARAMETER timevalue IS time.
	IF timevalue:typename = "TimeSpan" {
		set hours to timevalue:hour.
		set minutes to timevalue:minute.
		set seconds to timevalue:second.
		IF hours < 0 SET hours TO hours+1.
		IF minutes < 0 SET minutes TO minutes+1.
		IF ABS(hours) < 10 set hours to "0" + ABS(hours).
		IF ABS(minutes) < 10 set minutes to "0" + ABS(minutes).
		IF ABS(seconds) < 10 set seconds to "0" + ABS(seconds).

		RETURN (hours+":"+minutes+":"+seconds).
	}
	ELSE RETURN "".
}

FUNCTION time_setT { //time Sets what time is to be regarded as T.
	Parameter T is time.
	IF T:typename = "TimeSpan" {
		SET time_T TO T.
		IF hasModule("IO") io_syslog("T set to "+time_format(time_T), "Time").
		RETURN TRUE.
	}
	ELSE RETURN FALSE.
}