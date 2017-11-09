//VARIABLES
LOCK scheduler_seconds TO ROUND(TIME:SECONDS).
LOCK scheduler_minutes TO ROUND(TIME:SECONDS/60).

SET scheduler_everySecond TO LEXICON().
SET scheduler_everyMinute TO LEXICON().

//DEPENDENCIES

//MODULE
FUNCTION scheduler_add_everySecond {
	PARAMETER name.
	PARAMETER func.

	IF func:typename = "UserDelegate" scheduler_everySecond:ADD(name, func).
}

FUNCTION scheduler_add_everyMinute {
	PARAMETER name.
	PARAMETER func.

	IF func:typename = "UserDelegate" scheduler_everyMinute:ADD(name, func).
}

FUNCTION scheduler_remove_everySecond {
	PARAMETER name.
	IF scheduler_everySecond:HASKEY(name) scheduler_everySecond:REMOVE(name).
}

FUNCTION scheduler_remove_everyMinute {
	PARAMETER name.
	IF scheduler_everyMinute:HASKEY(name) scheduler_everyMinute:REMOVE(name).
}

ON scheduler_seconds {
	FOR func IN scheduler_everySecond:values {
		func:call().
	}
	RETURN TRUE.
}

ON scheduler_minutes {
	FOR func IN scheduler_everyMinute:values {
		func:call().
	}
	RETURN TRUE.
}