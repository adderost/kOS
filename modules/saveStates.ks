//CONFIG

//DEPENDENCIES
needModule("IO").

//VARIABLES
SET saveStates_path TO "/saveState".
SET saveStates_states TO LEXICON().

//MODULE
FUNCTION saveStates_getState {
	PARAMETER label.
	PARAMETER default IS FALSE.

	IF saveStates_states:HASKEY(label) RETURN saveStates[label].
	ELSE RETURN default.
}

FUNCTION saveStates_setState {
	PARAMETER label.
	PARAMETER value.

	SET saveStates_states[label] TO value.
	saveStates_write().
}

FUNCTION saveStates_write {
	IF CORE:VOLUME:EXISTS(saveStates_path) CORE:VOLUME:DELETE(saveStates_path).
	SET stateFile TO CORE:VOLUME:CREATE(saveStates_path).
	FOR label IN saveState:KEYS {
		IF NOT stateFile:WRITELN(label+":"+saveStates[label]) io_syslog("Couldnt write "+label+" to file","saveStates").
	}
}

FUNCTION saveStates_read {
	saveStates_states:CLEAR().
	IF CORE:VOLUME:EXISTS(saveStates_path) {
		SET iterator TO CORE:VOLUME:CREATE(saveStates_path):READALL:ITERATOR.
		UNTIL NOT iterator:NEXT {
			SET lineData TO iterator:value:split(":").
			SET saveStates_states[lineData[0]] TO lineData[1].
		}
	}
}

saveStates_read().