//CONFIG
SET LKOC_timeout TO 0.
SET LKOC_TargetPeriod TO 2700. //45 minutes on the dot.
SET LKOC_PeriodTolerance TO 0.001.	//Well not on the dot...
LOCK LKOC_timer TO round(time:seconds).
SET LKOC_timeout TO 0.


//DEPENDENCIES
needModule("operations").
needModule("log").
needModule("telemetry").

//MODULE
FUNCTION LKOC_Periodisation_initcheck {
	IF APOAPSIS >= 250000 AND PERIAPSIS > 200000 {
		log_output("Initial parameters accepted", "Periodisation.log").
		LKOC_SET_RSCTHRUSTLIMIT().
		operations_add(LKOC_BeginPeriodisation@).
	}
	ELSE {
		log_output("Initial parameters rejected. Will abort", "Periodisation.log").
		operations_add(LKOC_End_Periodisation@).
	}
}

FUNCTION LKOC_BeginPeriodisation {
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	LOCK STEERING TO telemetry_getVectorToHorizon().
	RCS ON.

	log_output("Current period: "+ROUND(SHIP:ORBIT:PERIOD, 4) + " Target period: "+LKOC_TargetPeriod, "Periodisation.log").

	IF SHIP:ORBIT:PERIOD > (LKOC_TargetPeriod+LKOC_PeriodTolerance) {
		operations_add(LKOC_Periodisation_descelerate@).
		log_output("Will descelerate", "Periodisation.log").	
	}
	ELSE IF SHIP:ORBIT:PERIOD < (LKOC_TargetPeriod-LKOC_PeriodTolerance) {
		operations_add(LKOC_Periodisation_accelerate@).
		log_output("Will Accelerate", "Periodisation.log").
	}
	ELSE{
		operations_add(LKOC_End_Periodisation@).
	}
}	


FUNCTION LKOC_Periodisation_accelerate {
	IF LKOC_timer > LKOC_timeout {
		IF SHIP:ORBIT:PERIOD < LKOC_TargetPeriod {
			SET SHIP:CONTROL:FORE TO 0.001.
			operations_add(LKOC_Periodisation_accelerate@).
		}
		ELSE operations_add(LKOC_BeginPeriodisation@).
	}
}

FUNCTION LKOC_Periodisation_descelerate {
	IF LKOC_timer > LKOC_timeout {
		IF SHIP:ORBIT:PERIOD > LKOC_TargetPeriod {
			SET SHIP:CONTROL:FORE TO -0.1.
			operations_add(LKOC_Periodisation_descelerate@).
		}
		ELSE operations_add(LKOC_BeginPeriodisation@).
	}
}


FUNCTION LKOC_End_Periodisation {
	IF( LKOC_timer > LKOC_timeout ) {
		RCS OFF.
		UNLOCK STEERING.
		LKOC_RESET_RSCTHRUSTLIMIT().
		log_output("Periodisation operations completed.", "Periodisation.log").
		operations_unlock().	
	}
}

FUNCTION LKOC_SET_RSCTHRUSTLIMIT{
	log_output("Limiting RCS-Thrust", "Periodisation.log").
	SET rcsParts to SHIP:partsnamed("linearRcs").
	FOR part IN rcsParts {
		part:getModule("ModuleRCSFX"):SETFIELD("thrust limiter", 10).
	}
}

FUNCTION LKOC_RESET_RSCTHRUSTLIMIT{
	log_output("Unlimiting RCS-Thrust", "Periodisation.log").
	SET rcsParts to SHIP:partsnamed("linearRcs").
	FOR part IN rcsParts {
		part:getModule("ModuleRCSFX"):SETFIELD("thrust limiter", 100).
	}
}

operations_lock().
IF hasModule("cli") {
	cli_display_start().
}
log_output("Initializing LKOC Orbital Period adjustment", "Periodisation.log").
operations_add(LKOC_Periodisation_initcheck@).