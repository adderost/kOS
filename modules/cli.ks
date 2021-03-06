//CONFIG	
LOCK cli_width TO terminal:width.
SET cli_height TO 20.

//DEPENDENCIES
needModule("string").
needModule("scheduler").
needModule("comms").

//VARIABLES
SET cli_displayActive TO FALSE.
SET cli_numUpdates TO 0.
SET cli_gauges TO LIST().
SET cli_log TO LIST().

SET cli_log_updated TO FALSE.
SET cli_log_length TO 0.

SET cli_logBuffer TO "".
SET cli_gaugeBuffer TO "".

//MODULE
FUNCTION cli_display_start {
	IF NOT cli_displayActive{
		SET cli_displayActive TO TRUE.
		clearscreen.
		scheduler_add_everySecond("cli_display_update", cli_display_update@).
	}
}

FUNCTION cli_display_stop {
	SET cli_displayActive TO FALSE.
	scheduler_remove_everySecond("cli_display_update").
	clearscreen.
}

FUNCTION cli_display_update {
	SET cli_numUpdates TO cli_numUpdates + 1.
	SET iterator TO 0.
	SET row TO 0.

	IF comms_hasSignalKSC() OR comms_hasLocalControl() {
		IF ( MOD(cli_numUpdates, 10) = 0 OR cli_gaugeBuffer = "") {	//RENDER GAUGES EVERY TEN SECONDS. 
			SET gauges TO cli_renderBox("System info", cli_render_gauges()).
			IF gauges <> cli_gaugeBuffer {
				SET cli_gaugeBuffer TO gauges.	
			}
		}
		SET row TO cli_print_lines_at(cli_gaugeBuffer, row).

		SET new_log_length TO (cli_height - row).
		IF new_log_length <> cli_log_length SET cli_log_updated TO TRUE.
		SET cli_log_length TO new_log_length.

		IF cli_log_updated AND cli_log_length > 0 AND cli_log:LENGTH > 0 {

			SET logStart TO (cli_log:LENGTH - cli_log_length).
			IF logStart < 0 SET logStart TO 0.

			SET logPart TO cli_log:SUBLIST(logStart, cli_log_length).
			SET cli_logBuffer TO cli_renderBox("Log", logPart).
			SET cli_log_updated TO FALSE.
		}
		SET row TO cli_print_lines_at(cli_logBuffer, row).
	}
}

FUNCTION cli_renderBox {
	PARAMETER title IS "".
	PARAMETER content IS LIST().

	SET output TO "".

	SET output TO ("┏──" + title + string_repeat("─", (cli_width-title:LENGTH-4)) + "┓").
	FOR entry IN content {
		IF ( entry:LENGTH > cli_width-2 ) SET newLine TO ( "┃" + entry:SUBSTRING(0,cli_width-2) + string_repeat(" ", cli_width-2-(entry:LENGTH)) + "┃").
		ELSE SET newLine TO ( "┃" + entry + string_repeat(" ", cli_width-2-(entry:LENGTH)) + "┃").
		SET output TO output + newLine.
	}
	SET output TO (output + ("┗" + string_repeat("─", (cli_width-2)) + "┛") ).

	RETURN output.
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
	SET gaugewidth TO ROUND(cli_width/2)-4.
	SET out TO LIST().
	FOR gauge IN cli_gauges{
		IF gauge["value"] <> "Separator" {
			SET value TO gauge["value"]:CALL.
			SET postscript TO "".
			IF gauge["min"] = 0 AND gauge["max"] = 1{
				SET postscript TO (ROUND(value,2)*100) +"%".
			}
			SET meterFill  TO (FLOOR(gaugewidth*(value/(gauge["max"]-gauge["min"])))).
			SET meterEmpty TO (CEILING(gaugewidth*(1-(value/(gauge["max"]-gauge["min"]))))).
			SET str TO "┃" + string_repeat("█", meterFill ) + string_repeat(" ", meterEmpty) + "┃ " + gauge["title"]+ " "+postscript.
			out:ADD(str).
		}
		ELSE out:ADD(" "+gauge["title"]).
	}
	RETURN out.
}

FUNCTION cli_print {
	PARAMETER out.

	IF cli_displayActive {
		SET out TO out:REPLACE("	", "").
		cli_log:ADD(out).
		SET cli_log_updated TO TRUE.
	}
	ELSE PRINT out.
}

FUNCTION cli_print_lines_at {
	PARAMETER out.
	PARAMETER line IS 0.

	IF cli_displayActive {
		UNTIL out:LENGTH <= 0 {
			IF out:LENGTH > cli_width {
				PRINT out:SUBSTRING(0,cli_width+1) AT(0, line).
				SET out TO out:SUBSTRING(cli_width, out:LENGTH - cli_width).
				SET line TO line + 1.
			}
			ELSE {
				PRINT out AT(0,line).
				SET out TO "".
				SET line TO line + 1.
			}
		}
	}
	RETURN line.
}