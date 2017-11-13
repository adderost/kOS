//CONFIG
SET time_T TO 0.

//DEPENDENCIES

//MODULE
FUNCTION time_current {
	  RETURN time_format().
}

FUNCTION time_deltaT {
	IF time_T <> 0 {
		RETURN time_format((time - time_T), TRUE).
	}
	ELSE RETURN "null".
}

FUNCTION time_format {
	PARAMETER timevalue IS time.
	PARAMETER wantSign IS false.
	IF timevalue:typename = "TimeSpan" {
		set hours to timevalue:hour.
		set minutes to timevalue:minute.
		set seconds to timevalue:second.
		IF hours < 10 set hours to "0" + ABS(hours).
		IF minutes < 10 set minutes to "0" + ABS(minutes).
		IF seconds < 10 set seconds to "0" + ABS(seconds).

		IF wantSign {
			IF timevalue:seconds < time:seconds SET sign TO "+".
			ELSE SET sign TO "-".
		}
		ELSE SET sign TO "".

		RETURN (sign+hours+":"+minutes+":"+seconds).
	}
	ELSE RETURN "".
}

FUNCTION time_setT { //time Sets what time is to be regarded as T.
	Parameter T is time.
	IF T:typename = "TimeSpan" {
		SET time_T TO T.
		IF hasModule("IO") io_syslog("T set to "+time_format(time_T), "time").
		RETURN TRUE.
	}
	ELSE RETURN FALSE.
}