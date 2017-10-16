SET opState TO 0.
SET lastOutput TO 0.
SET timeout TO 0.
SET opsDone TO FALSE.
output("CHECKING FOR SAVED STATE").
IF core:volume:exists("/opsData/state.sav"){
	output("SAVED STATE FOUND!").
	SET opState TO OPEN("/opsData/state.sav"):readall:string:TONUMBER(0).
}
output("OPSTATE IS SET TO "+opState).
UNTIL opsDone	{
	SET newTime TO ROUND(timer).
	IF core:volume:exists("/opsData/state.sav")	{
		OPEN("/opsData/state.sav"):clear.
		OPEN("/opsData/state.sav"):write(opState:TOSTRING).
	}
	ELSE CREATE("/opsData/state.sav").
	IF opState = 0{
		output("LIFTOFF").
		SET opState TO 1.
		SET timeout TO timer + 3.
		STAGE.
	}
	IF opState = 1 AND round(ship:availablethrust,2) < 5 AND timer > timeout{
		output("FLAMEOUT STAGE 1").
		SET opState TO 2.
		SET timeout TO timer+2.
	}
	IF opState = 2 AND timeout < timer{
		output("SEPARATION STAGE 1").
		SET opState TO 3.
		SET timeout TO timer + 3.
		STAGE.
	}
	IF opState = 3 AND timer >= timeout AND ship_pitch < 58{
		output("IGNITION STAGE 2").
		SET opState TO 4.
		STAGE.
	}
	IF opState = 4 AND round(ship:availablethrust,2) < 5{
		output("FLAMEOUT STAGE 2").
		SET opState TO 5.
	}
	IF opState = 5 AND ship:altitude > 50000{
		output("SHED FAIRINGS").
		SET opState TO 6.
		STAGE.
	}
	IF opState = 6 AND ship:altitude > 70000{
		output("SEPARATION STAGE 2").
		SET opState TO 7.
		STAGE.
	}
	IF opState = 7 AND ETA:APOAPSIS < 60{
		output("PREPARE TO FIRE STAGE 3").
		SET opState TO 8.
		SET timeout TO timer+1.
		STAGE.
	}
	IF opState = 8 AND timer >= timeout AND ship:verticalspeed > 0{
		output("ATTEMPTING TO CIRCULARIZE").
		SET opState TO 9.
		LOCK STEERING TO getDirectionToHorizon().
		LOCK THROTTLE TO ((40-ETA:APOAPSIS)/20).
	}
	IF opState = 9 AND (ETA:APOAPSIS > ETA:PERIAPSIS) AND ship:periapsis < 70000{
		LOCK THROTTLE TO 1.
	}
	IF opState = 9 AND round(ship:availablethrust,2) < 5 AND ship:periapsis < 70000 {
		output("ORBITAL INSERTION FAILED! ABORT").
		SET THROTTLE TO 0.
		UNLOCK THROTTLE.
		UNLOCK STEERING.
		SET opsDone TO true.
	}
	IF opState = 9 AND (ABS(ship:apoapsis - ship:periapsis) < 1500) AND ship:periapsis > 70000{
		output("ORBIT ACHIEVED. DEPLOYING COMMS").
		SET opState TO 10.
		LOCK THROTTLE TO 0.
		UNLOCK THROTTLE.
		UNLOCK STEERING.
		SET THROTTLE TO 0.
		TOGGLE AG10.
		SET timeout TO timer+10.
	}
	IF opState = 10 AND timer > timeout {
		output("OPS-EXECUTION DONE - WILL START PINGING").
		SET lastOutput TO newTime.
		SET opState TO 11.
	}
	IF opState = 11 AND newTime > (lastOutput + 60) {
		output("PING! Altitude:" +ROUND(ship:altitude)+"m Time: "+newTime).
		SET lastOutput TO newTime.
	}
	wait 0.
}