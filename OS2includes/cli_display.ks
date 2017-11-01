//CONFIG	
SET displayWidth TO ROUND(terminal:width / 2). //Make room for border
SET displayHeight TO 15.

//DEPENDENCIES
needModule("comms").

//VARIABLES
SET cli_displayActive TO FALSE.
SET numUpdates TO 0.
SET cli_gauges TO LIST().
SET cli_log TO LIST().

SET cli_log_updated TO FALSE.
SET cli_log_length TO 0.
SET cli_latest_log TO "".

//MODULE
FUNCTION startDisplay {
	PRINT "Display width is "+displayWidth.

	SET cli_displayActive TO TRUE.
	clearscreen.
	ON timer {
		updateDisplay().
		IF cli_displayActive RETURN TRUE.
	}
}

FUNCTION stopDisplay {
	SET cli_displayActive TO FALSE.
}

FUNCTION updateDisplay {
	SET numUpdates TO numUpdates + 1.
	SET iterator TO 0.
	SET row TO 0.

	IF hasSignalKSC OR hasLocalControl {

		SET row TO renderBox(row, "System info", cli_gauges).

		SET new_log_length TO (displayHeight - row).
		IF new_log_length <> cli_log_length SET cli_log_updated TO TRUE.
		SET cli_log_length TO new_log_length.

		IF cli_log_updated AND cli_log_length > 2 {
			SET logStart TO (cli_log:LENGTH - cli_log_length).
			IF logStart < 0 SET logStart TO 0.
			SET logPart TO cli_log:SUBLIST(logStart, cli_log_length).
			SET row TO renderbox(row, "Log", logPart).
			SET cli_log TO logPart.
			SET cli_log_updated TO FALSE.
		}
	}
}

FUNCTION renderBox {
	PARAMETER row.
	PARAMETER title IS "".
	PARAMETER content IS LIST().
	

	SET returnval TO (row+content:length+2).

	PRINT ("┏──" + title + repeatString("─", (displayWidth-title:LENGTH-4)) + "┓") AT(0,row).
	FOR entry IN content {
		SET row TO row + 1.
		SET entry TO entry+repeatstring(" ", displayWidth-entry:LENGTH-2).
		PRINT "┃" + entry + "┃" AT(0,row).
	}
	PRINT ("┗" + repeatString("─", (displayWidth-2)) + "┛") AT(0,row+1).

	RETURN returnval.
}

FUNCTION repeatString {
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

FUNCTION cli_add_gauge {
	PARAMETER variable.
	PARAMETER min IS 0.
	PARAMETER max IS 1.
	PARAMETER title IS "Value".
}

FUNCTION cli_print {
	PARAMETER out.
	IF cli_displayActive {
		cli_log:ADD(out).
		SET cli_log_updated TO TRUE.
		SET cli_latest_log TO out.
	}
	ELSE PRINT out.
}