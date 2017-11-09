//CONFIG

//DEPENDENCIES

//MODULE
FUNCTION telemetry_degAboveHorizon {	//Returns how many degrees above horizon the vessel is facing
  return 90 - vang(ship:up:vector, ship:facing:forevector).
}
function telemetry_getVectorToHorizon {	//Returns a vector towards the horizon. Roll and Yaw unchanged
	return(ship:prograde - R(0, (telemetry_degAboveHorizon()*2), 0)).
}