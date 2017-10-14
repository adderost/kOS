//BEGIN FUNCTIONS
function statuswindow{
	
	parameter statusmessage.
	parameter steeringmessage.

	if(screensdrawnsinceredraw >= 30){
		set needFullRedraw to 1.
		set screensdrawnsinceredraw to 0.
	}

	if(needFullRedraw > 0){
		clearscreen.
		print("-==RostX Launchscript v1.0.1700==").
		print("-                                ").
		print("-  Status:     " + ship:status).
		print("-  State :     " + state).
		print("-  Altitude:   " + round(ship:altitude,2)+"m").
		print("-  V Velocity: " + round(ship:verticalspeed,2)+" m/s").
		print("-  H Velocity: " + round(ship:groundspeed,2)+" m/s").
		print("-  SteerLock:  " + steeringmessage).
		print("-").
		print("-  Message:    " + statusmessage).
		print("-================================-").

		set needFullRedraw to 0.
	}
	else{

		print (ship:status) at(15,2).
		print (state) at(15,3).
		print (round(ship:altitude,2)+"m") at(15,4).
		print (round(ship:verticalspeed,2)+" m/s") at(15,5).
		print (round(ship:groundspeed,2)+" m/s") at(15,6).
		print (steeringmessage) at(15,7).
		print (statusmessage) at(15,9).

		set screensdrawnsinceredraw to (screensdrawnsinceredraw + 1).
	}

}

function steerLock{
	parameter do.

	set reqdir to 0.

	//prograde
	if(do = 1){
		set reqdir to ship:prograde.
		lock steering to reqdir.
		set steeringmessage to "Prograde".
	}
	else if(do = 2){
		set reqdir to ship:retrograde.
		lock steering to reqdir.
		set steeringmessage to "Retrograde".
	}
	else{
		unlock steering.
		set reqdir to 0.
		set steeringmessage to "None".
	}
}

//END FUNCTIONS


//Splashscreen


clearscreen.
print("-==RostX Launchscript v1.0.1700==-").
print("-                                -").
print("-          Initializing          -").
print("-                                -").
print("-                                -").
print("-================================-").
wait 1.

//Start doing stuff
set statusmessage to "<N/A>".
set steeringmessage to "<N/A>".

set state to 0.
set endstate to 0.

set timeout to 0.
set launchTime to time:seconds + 3.
set orbitalrocketsstart to 0.
set circularorbitachieved to 0.
set orbitalrocketsend to 0.

set estapoapsis to 0.

set steeringlock to 0.
set needFullRedraw to 1.
set screensdrawnsinceredraw to 1.



until time:seconds >= launchTime {
	clearscreen.
	print("-==RostX Launchscript v1.0.1700==-").
	print("-                                -").
	print("-           Launch in            -").
	print("-           " + round(launchTime - time:seconds, 0) + " seconds            -").
	print("-                                -").
	print("-================================-").
	wait 0.1.
}

//MAIN LOOP
until endstate >= 1{
	steerlock(steeringlock).
	statuswindow(statusmessage, steeringmessage).

	//Time to launch
	if(state = 0){
		set state to 1.
		set statusmessage to "Initial stage fired!".
		stage.
	}

	//Flameout! Wait one second
	if(state = 1){
		if( round(ship:availablethrust,2) < 5){
			set state to 2.
			set statusmessage to "Flameout stage one".
			set timeout to time:seconds+1.
		}
	}

	//Separate stage one
	if(state = 2){
		if(time:seconds >= timeout){
			set state to 3.
			set timeout to 0.
			set statusmessage to "Separation stage one".
			stage.
		}
	}

	//Fire stage two when dropping vertical speed
	if(state = 3){
		if(ship:verticalspeed <= 300){
			set state to 4.
			set statusmessage to "Firing stage two".
			stage.
		}
	}

	//Flameout stage two
	if(state = 4){
		if( round(ship:availablethrust,2) < 5){
			set state to 5.
			set statusmessage to "Flameout stage two".
			set steeringlock to 1.
		}
	}

	//Shed fairings
	if(state = 5){
		if( round(ship:altitude,2) > 60000){
			set state to 6.
			set statusmessage to "Shedding fairings".
			set timeout to time:seconds+5.
			stage.
		}
	}

	//Separate stage two
	if(state = 6){
		if( time:seconds >= timeout){
			set state to 7.
			set statusmessage to "Separation stage two".
			stage.
		}
	}

	//Coast to space
	if(state = 7){
		print ("Estimated Apoapsis: "+round(ship:apoapsis))+"m" at(0,11).
		if(round(ship:altitude) > 70000){
			set state to 8.
			set statusmessage to "Coast to Apoapsis".
			set estapoapsis to ship:apoapsis.
		}
	}

	//Fire orbital rockets
	if(state = 8){
		print ("Estimated Apoapsis: "+round(ship:apoapsis))+"m" at(0,11).
		if(ship:verticalspeed <= 0){
			set state to 9.
			set orbitalrocketsstart to (time:seconds - launchTime).
			set statusmessage to "Firing orbital rockets".
			stage.
		}
	}

	//Flameout orbital insertion rockets.
	//Check if in orbit. If not, jump to atmospheric reentry.
	if(state = 9){
		print ("EST Apoapsis:  "+round(ship:apoapsis)+"m") at(0,11).
		print ("EST Periapsis: "+round(ship:periapsis)+"m") at(0,12).
		if(round(ship:availablethrust,2) < 5){
			
			if(ship:periapsis > 70000){
				set statusmessage to "Flameout OrbRockets - Orbit achieved".
				set steeringlock to 0.
				set state to 10.
			}
			else{
				set statusmessage to "Flameout OrbRockets - Orbit not achieved".
				set state to 13.
			}
			
		}
	}

	if(state = 11){
		if(ship:verticalspeed <= 0){
			set state to 12.
			set statusmessage to "First orbit".
		}
	}

	if(state = 12){
		if(ship:verticalspeed > 0){
			set state to 13.
			set steeringlock to 1.
			set statusmessage to "First orbit - Locking prograde".
		}
	}

	if(state = 13){
		if(ship:verticalspeed <= 0){
			set state to 14.
			set statusmessage to "Deorbiting".
			set timeout to (time:seconds+5).
			stage.
		}
	}

	if(state = 14){
		if(ship:periapsis < 70000){
			if(time:seconds >= timeout){
				set state to 15. 
				set timeout to 0.
				set statusmessage to "Sub orbital trajectory".
				set steeringlock to 2.
			}
		}
	}

	if(state = 15){
		if(ship:altitude < 70000){
			set state to 16.
			set statusmessage to "In atmosphere".
		}
	}

	if(state = 16){
		if(ship:altitude < 10000){
			set state to 17.
			set statusmessage to "Parachute armed".
			set steeringlock to 0.
			stage.
		}
	}

	if(state = 17){
		if( round(max(0.001,((ship:altitude - geoposition:terrainheight)))) < 10){
			set state to 18.
			set statusmessage to "Bracing for impact".
			set timeout to (time:seconds+5).
		}
	}

	if(state = 18){
		if(time:seconds >= timeout){
			set endstate to 1.
			set timeout to 0.
		}
	}

	wait 0.01.
}