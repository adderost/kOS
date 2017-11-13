//CONFIG
SET time_T TO 0.

//DEPENDENCIES

//MODULE
FUNCTION time_current {
	  RETURN time_format().
}

FUNCTION time_deltaT {
	IF time_T <> 0 {
		RETURN time_format((time - time_T)).
	}
	ELSE RETURN "null".
}

FUNCTION time_format {
	PARAMETER timevalue IS time.
	IF timevalue:typename = "TimeSpan" {
		set hours to time:hour.
		set minutes to time:minute.
		set seconds to time:second.
		if hours < 10 set hours to "0" + hours.
		if minutes < 10 set minutes to "0" + minutes.
		if seconds < 10 set seconds to "0" + seconds.
		RETURN (hours+":"+minutes+":"+seconds).
	}
	ELSE RETURN "".
}

FUNCTION time_setT { //time Sets what time is to be regarded as T.
	Parameter T
	IF T:typename = "TimeSpan" {
		SET time_T TO T.
		RETURN TRUE.
	}
	ELSE RETURN FALSE.
}