SET opState TO 0.
SET lastOutput TO 0.
SET timeout TO timer+5.
SET opsDone TO FALSE.
output("CHECKING FOR SAVED STATE").
IF core:volume:exists("/opsData/state.sav"){
	output("SAVED STATE FOUND!").
	SET opState TO OPEN("/opsData/state.sav"):readall:string:TONUMBER(0).
}
output("OPSTATE IS SET TO "+opState).
output("WILL LAUNCH IN 5 SECONDS").
UNTIL opsDone	{
	SET newTime TO ROUND(timer).
	IF core:volume:exists("/opsData/state.sav")	{
		OPEN("/opsData/state.sav"):clear.
		OPEN("/opsData/state.sav"):write(opState:TOSTRING).
	}
	ELSE CREATE("/opsData/state.sav").
	IF opState = 0 {
		IF timer >= timeout {
			output("LIFTOFF").
			SET opState TO 1.
			SET timeout TO timer + 3.
			STAGE.
		}
	}
	IF opState = 1 AND round(ship:availablethrust,2) < 5 AND timer > timeout{
		output("FLAMEOUT STAGE 1").
		SET opState TO 2.
		SET timeout TO timer+2.
	}
	IF opState = 2 AND timer >= timeout{
		output("SEPARATION STAGE 1").
		SET opState TO 3.
		SET timeout TO timer + 2.
		STAGE.
	}
	IF opState = 3 AND timer >= timeout AND ship_pitch < 60{
		output("IGNITION STAGE 2").
		SET opState TO 4.
		STAGE.
	}
	IF opState = 4 AND round(ship:availablethrust,2) < 5{
		output("FLAMEOUT STAGE 2").
		SET opState TO 5.
	}
	IF opState = 5 AND ship:altitude > 50000{
		output("SEPARATION STAGE 2").
		SET opState TO 6.
		SET timeout TO timer+2.
		STAGE.
	}
	IF opState = 6 AND timer >= timeout AND ship:altitude > 55000{
		output("SHED FAIRINGS AND ORIENT TO PROGRADE").
		SET opState TO 7.
		RCS ON.
		LOCK STEERING TO SHIP:PROGRADE.
		SET THROTTLE TO 0.
		STAGE.
	}
	IF opState = 7 AND ship:altitude > 70000{
		output("IGNITE ORBITAL ENGINE").
		LIGHTS ON.
		TOGGLE AG10.
		SET opState TO 8.
		SET timeout TO timer+1.
		STAGE.
	}
	IF opState = 8 AND timer >= timeout{
		output("RAISE APOAPSIS TO 250KM").
		SET opState TO 9.
		LOCK THROTTLE TO 1.
		SET timeout TO timer+5.
	}
	IF opState = 9 AND (SHIP:APOAPSIS >=250000){
		output("TARGET ALTITUDE REACHED").
		UNLOCK THROTTLE.
		LOCK STEERING TO getDirectionToHorizon().
		SET THROTTLE TO 0.
		SET timeout TO timer+3.
		IF SHIP:PERIAPSIS < 20000{
			SET opstate TO 10.
		}
		ELSE{
			SET opstate TO 13.
		}
	}
	
	IF opState = 10 AND timer >= timeout AND PERIAPSIS < 30000 AND ETA:APOAPSIS < 30{
		LOCK THROTTLE TO  (10 - ETA:APOAPSIS / 5).
	}
	IF opState = 10 AND ((PERIAPSIS > 20000) OR (ETA:PERIAPSIS < ETA:APOAPSIS)) {
		output("PREPARING TO DUMP ORBITAL ENGINE").
		UNLOCK THROTTLE.
		SET THROTTLE TO 0.
		SET timeout	TO timer+3.
		SET opState TO 12.
	}

	IF opState = 12 AND timer >= timeout{	
		output("SEPARATION ORBITAL ENGINE").
		stage.
		RCS ON.
		LOCK STEERING TO getDirectionToHorizon().
		SET opState TO 14.
	}

	IF opState = 14 AND ETA:APOAPSIS < 10{
		SET SHIP:CONTROL:FORE TO 1.
		SET opState TO 15.
	}

	IF opState = 15 AND (SHIP:APOAPSIS - SHIP:PERIAPSIS) < 1000{
		output("ORBITAL INSERTION DONE!").
		SET SHIP:CONTROL:NEUTRALIZE to TRUE.
		SET opState TO 20.
	}

	IF opstate = 20{
		UNLOCK THROTTLE.
		SET THROTTLE TO 0.
		UNLOCK STEERING.
		RCS OFF.
		SET opsDone TO true.
		output("OPS DONE. END PROGRAM").
	}

	wait 0.
}