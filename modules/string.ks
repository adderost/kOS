//CONFIG	

//DEPENDENCIES

//VARIABLES

//MODULE

FUNCTION string_repeat {	//(str, num) Return a string with 'num' repeats of 'str'
	PARAMETER inStr IS "".
	PARAMETER repeats IS 0.
	
	SET outStr TO "".
	SET iterator TO 0.
	UNTIL iterator >= repeats {
		SET outStr TO outStr + inStr.
		SET iterator TO iterator + 1.
	}
	RETURN outStr.
}