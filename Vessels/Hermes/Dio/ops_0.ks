//CONFIG
SET LKOC_t0 TO 0.
SET LKOC_lasttimer TO 0.
SET LKOC_timeout TO 0.
SET LKOC_finalApo TO 0.
SET LKOC_ApPeDiff TO 0.
LOCK LKOC_timer TO round(time:seconds).

//DEPENDENCIES
needModule("operations").
needModule("log").
needModule("telemetry").

//MODULE
FUNCTION LKOC_Countdown {
	IF (time:seconds > LKOC_t0){
		log_output("Ignition", "Ascent.log").
		SET LKOC_timeout TO LKOC_timer+3.
		operations_add(LKOC_Stage1@).
		SET THROTTLE TO 0.
		STAGE.
	}
	ELSE {
		IF (LKOC_timer <> LKOC_lasttimer){
			SET LKOC_lasttimer TO LKOC_timer.
			log_output("Waiting for T","Ascent.log").
		}
		operations_add(LKOC_Countdown@).
	}
}

FUNCTION LKOC_Stage1 {
	IF ( LKOC_timer > LKOC_timeout AND (ROUND(ship:availablethrust,2) < 5) ) {
		log_output("Flameout stage 1", "Ascent.log").
		SET LKOC_timeout TO LKOC_timer+3.
		operations_add(LKOC_Separation_Stage1@).
	}
	ELSE operations_add(LKOC_Stage1@).
}

FUNCTION LKOC_Separation_Stage1 {
	IF (LKOC_timer > LKOC_timeout) {
		log_output("Separation stage 1", "Ascent.log").
		SET LKOC_timeout TO LKOC_timer+2.
		operations_add(LKOC_Ignition_Stage2@).
		STAGE.
	}
	ELSE operations_add(LKOC_Separation_Stage1@).
}

FUNCTION LKOC_Ignition_Stage2 {
	IF (LKOC_timer > LKOC_timeout AND telemetry_degAboveHorizon() < 60) {
		log_output("Ignition stage 2", "Ascent.log").
		SET LKOC_timeout TO LKOC_timer+2.
		operations_add(LKOC_Stage2@).
		STAGE.
	}
	ELSE operations_add(LKOC_Ignition_Stage2@).
}

FUNCTION LKOC_Stage2 {
	IF (LKOC_timer > LKOC_timeout AND ROUND(ship:availablethrust,2) < 5) {
		log_output("Flameout stage 2", "Ascent.log").
		operations_add(LKOC_Separation_Stage2@).
	}
	ELSE operations_add(LKOC_Stage2@).
}

FUNCTION LKOC_Separation_Stage2 {
	IF ship:altitude > 50000 {
		log_output("Separation stage 2", "Ascent.log").
		SET LKOC_timeout TO LKOC_timer+2.
		operations_add(LKOC_Shed_Fairings@).
		STAGE.
	}
	ELSE operations_add(LKOC_Separation_Stage2@).
}

FUNCTION LKOC_Shed_Fairings {
	IF (LKOC_timer > LKOC_timeout AND ship:altitude > 55000) {
		log_output("Shed fairings and turn prograde", "Ascent.log").
		operations_add(LKOC_Ignition_Stage3@).
		RCS ON.
		LOCK STEERING TO SHIP:PROGRADE.
		SET THROTTLE TO 0.
		STAGE.
	}
	ELSE operations_add(LKOC_Shed_Fairings@).
}

FUNCTION LKOC_Ignition_Stage3 {
	IF (ship:altitude > 70000) {
		log_output("Ignition stage 3", "Ascent.log").
		SET LKOC_timeout TO LKOC_timer + 1.
		operations_add(LKOC_Raise_apoapsis@).
		LIGHTS ON.
		TOGGLE AG10.
		STAGE.
	}
	ELSE operations_add(LKOC_Ignition_Stage3@).
}

FUNCTION LKOC_Raise_apoapsis {
	IF (LKOC_timer > LKOC_timeout AND APOAPSIS < 240000) {
		LOCK THROTTLE TO ((250000 - APOAPSIS)/10000).
		operations_add(LKOC_Raise_apoapsis@).
	}
	ELSE IF (APOAPSIS >= 250000) {
		log_output("Target apoapsis altitude reached", "Ascent.log").
		log_output("Coasting to cicularization", "Ascent.log").
		SET LKOC_finalApo TO APOAPSIS.
		SET LKOC_timeout TO LKOC_timer+3.
		LOCK THROTTLE TO 0.
		UNLOCK THROTTLE.
		SET THROTTLE TO 0.
		LOCK STEERING TO telemetry_getVectorToHorizon().
		operations_add(LKOC_stage3@).
	}
	ELSE IF ( LKOC_timer > LKOC_timeout AND ROUND(ship:availablethrust,2) < 5) {
		log_output("Flameout stage 3 with apoapsis too low... End OPS", "Ascent.log").
		operations_unlock().
	}
	ELSE operations_add(LKOC_Raise_apoapsis@).
}

FUNCTION LKOC_stage3 {
	IF LKOC_timer > LKOC_timeout {
		IF PERIAPSIS > 15000 {
			log_output("Throttle back stage 3", "Ascent.log").
			operations_add(LKOC_Separation_stage3@).
			SET LKOC_timeout TO LKOC_timer+2.
			UNLOCK THROTTLE.
			SET THROTTLE TO 0.
		}
		ELSE IF PERIAPSIS < 30000 AND ETA:APOAPSIS < 30 {
			LOCK STEERING TO telemetry_getVectorToHorizon().
			LOCK THROTTLE TO  (5 - ETA:APOAPSIS / 10).
			operations_add(LKOC_stage3@).
		}
		ELSE operations_add(LKOC_stage3@).
	}
	ELSE operations_add(LKOC_stage3@).
}

FUNCTION LKOC_Separation_stage3 {
	IF (LKOC_timer > LKOC_timeout) {
		log_output("Separation stage 3", "Ascent.log").
		log_output("Continuing circulization with thrusters", "Ascent.log").
		STAGE.
		SET LKOC_timeout TO LKOC_timer +1.
		SET SHIP:CONTROL:NEUTRALIZE to TRUE.
		LOCK STEERING TO telemetry_getVectorToHorizon().
		RCS ON.
		
		operations_add(LKOC_RCS_Circulization@).
	}
	ELSE operations_add(LKOC_Separation_stage3@).
}

FUNCTION LKOC_RCS_Circulization {
	SET LKOC_ApPeDiff TO (APOAPSIS - PERIAPSIS).
	IF LKOC_timer > LKOC_timeout {
		IF ( LKOC_ApPeDiff > 1000 AND ETA:APOAPSIS < 20 ) {
			SET SHIP:CONTROL:FORE TO (6)/ETA:APOAPSIS.
			operations_add(LKOC_RCS_Circulization@).
		}
		ELSE IF ( LKOC_ApPeDiff > 1000 AND ETA:APOAPSIS > 20) {
			SET SHIP:CONTROL:FORE TO 0.
			operations_add(LKOC_RCS_Circulization@).
		}
		ELSE{
			UNLOCK STEERING.
			SET SHIP:CONTROL:NEUTRALIZE to TRUE.
			RCS OFF.
			operations_add(LKOC_End_ascent@).
		}
	}
	ELSE operations_add(LKOC_RCS_Circulization@).
}

FUNCTION LKOC_End_ascent {
	IF( LKOC_timer > LKOC_timeout ) {
		log_output("Ascent/Circulization operations completed.", "Ascent.log").
		operations_unlock().	
	}
}

operations_lock().
IF hasModule("cli") {
	resources_addResourceMonitor().
	cli_display_start().
}
log_output("Initializing LKOC Ascent & Circulization operations", "Ascent.log").
SET LKOC_t0 TO (time:seconds + 10).
time_setT((10 +time)).
operations_add(LKOC_Countdown@).