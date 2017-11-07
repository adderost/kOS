//CONFIG	
SET displayWidth TO ROUND(terminal:width).
SET displayHeight TO 15.

//DEPENDENCIES
needModule("comms").

//VARIABLES
SET cli_displayActive TO FALSE.
SET cli_numUpdates TO 0.
SET cli_gauges TO LIST().
SET cli_log TO LIST().

SET cli_log_updated TO FALSE.
SET cli_log_length TO 0.
SET cli_latest_log TO "".

SET cli_logBuffer TO "".
SET cli_gaugeBuffer TO "".

//MODULE
FUNCTION startDisplay {
	IF NOT cli_displayActive{
		SET cli_displayActive TO TRUE.
		clearscreen.
		updateDisplay().
	}
}

FUNCTION stopDisplay {
	SET cli_displayActive TO FALSE.
}

FUNCTION updateDisplay {
	SET cli_numUpdates TO cli_numUpdates + 1.
	SET iterator TO 0.
	SET row TO 0.

	IF comms_hasSignalKSC OR comms_hasLocalControl {

		SET gauges TO renderBox("System info", cli_render_gauges()).
		IF gauges <> cli_gaugeBuffer {
			SET cli_gaugeBuffer TO gauges.
			PRINT cli_gaugeBuffer AT(0,row).
		}
		SET row TO row+CEILING(cli_gaugeBuffer:LENGTH/displayWidth).

		SET new_log_length TO (displayHeight - row).
		IF new_log_length <> cli_log_length SET cli_log_updated TO TRUE.
		SET cli_log_length TO new_log_length.

		IF cli_log_updated AND cli_log_length > 0 {
			SET logStart TO (cli_log:LENGTH - cli_log_length).
			IF logStart < 0 SET logStart TO 0.
			SET logPart TO cli_log:SUBLIST(logStart, cli_log_length).
			SET cli_logBuffer TO renderbox("Log", logPart).
			SET cli_log TO logPart.
			SET cli_log_updated TO FALSE.
		}
		PRINT cli_logBuffer AT (0,row).
	}
}

FUNCTION renderBox {
	PARAMETER title IS "".
	PARAMETER content IS LIST().

	SET output TO "".

	SET output TO ("┏──" + title + repeatString("─", (displayWidth-title:LENGTH-4)) + "┓").
	FOR entry IN CONTENT {
		SET output TO (output + "┃" + entry + repeatString(" ", displayWidth-2-entry:LENGTH) + "┃").
	}
	SET output TO (output + ("┗" + repeatString("─", (displayWidth-2)) + "┛") ).

	RETURN output.
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
	PARAMETER value IS "Separator".
	PARAMETER title IS "Value".
	PARAMETER min IS 0.
	PARAMETER max IS 1.

	SET gauge TO LEXICON().
	gauge:ADD("value", value).
	gauge:ADD("title", title).
	gauge:ADD("min", min).
	gauge:ADD("max", max).

	cli_gauges:ADD(gauge).
}

FUNCTION cli_render_gauges{
	SET gaugewidth TO ROUND(displayWidth/2)-4.
	SET out TO LIST().
	FOR gauge IN cli_gauges{
		IF gauge["value"] <> "Separator" {
			SET value TO gauge["value"]:CALL.
			SET postscript TO "".
			IF gauge["min"] = 0 AND gauge["max"] = 1{
				SET postscript TO (ROUND(value,2)*100) +"%".
			}
			SET meterFill  TO (ROUND(gaugewidth*(value/(gauge["max"]-gauge["min"])))).
			SET meterEmpty TO (ROUND(gaugewidth*(1-(value/(gauge["max"]-gauge["min"]))))).
			SET str TO "┃" + repeatString("█", meterFill ) + repeatString(" ", meterEmpty) + "┃ " + gauge["title"]+ " "+postscript.
			out:ADD(str).
		}
		ELSE out:ADD(" "+gauge["title"]).
	}
	RETURN out.
}

FUNCTION cli_print {
	PARAMETER out.
	IF cli_displayActive {
		cli_log:ADD(out).
		SET cli_log_updated TO TRUE.
		SET cli_latest_log TO out.
		updateDisplay().
	}
	ELSE PRINT out.
}