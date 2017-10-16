function ship_pitch {
  return 90 - vang(ship:up:vector, ship:facing:forevector).
}
function getDirectionToHorizon {
	return(ship:prograde - R(0, (ship_pitch()*2), 0)).
}