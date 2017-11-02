//CONFIG
SET percentElectriccharge TO 0.
SET percentLiquidfuel TO 0.
SET percentOxidizer TO 0.
SET percentMonopropellant TO 0.

SET electricIndex TO 0.
SET liquidIndex TO 0.
SET oxideIndex TO 0.
SET monoIndex TO 0.

//DEPENDENCIES

//MODULE
ON hasModule("cli_display") {
	IF hasModule("cli_display"){
		cli_add_gauge(getPercentElectriccharge@, "Electric charge").
		cli_add_gauge(getPercentLiquidfuel@, "Liquid fuel").
		cli_add_gauge(getPercentOxidizer@, "Oxidizer").
		cli_add_gauge(getpercentMonopropellant@, "Monopropellant").
	}
	ELSE RETURN TRUE.
}

FUNCTION getPercentElectriccharge {
	RETURN percentElectriccharge.
}

FUNCTION getPercentLiquidfuel {
	RETURN percentLiquidfuel.
}

FUNCTION getPercentOxidizer {
	RETURN percentOxidizer.
}

FUNCTION getpercentMonopropellant {
	RETURN percentMonopropellant.
}

SET resourceIterator TO 0.
PRINT ship:resources.
FOR resource IN SHIP:RESOURCES{
	IF resource:NAME = "electriccharge" SET electricIndex TO resourceIterator.

	IF resource:NAME = "liquidfuel" SET liquidIndex TO resourceIterator.

	IF resource:NAME = "oxidizer" SET oxideIndex TO resourceIterator.

	IF resource:NAME = "monopropellant" SET monoIndex TO resourceIterator.

	SET resourceIterator TO resourceIterator + 1.
}

LOCK percentElectriccharge TO (SHIP:RESOURCES[electricIndex]:amount / SHIP:RESOURCES[electricIndex]:capacity).
LOCK percentLiquidfuel TO (SHIP:RESOURCES[liquidIndex]:amount / SHIP:RESOURCES[liquidIndex]:capacity).
LOCK percentOxidizer TO (SHIP:RESOURCES[oxideIndex]:amount / SHIP:RESOURCES[oxideIndex]:capacity).
LOCK percentMonopropellant TO (SHIP:RESOURCES[monoIndex]:amount / SHIP:RESOURCES[monoIndex]:capacity).