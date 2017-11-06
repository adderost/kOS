//CONFIG
SET resources_percentElectriccharge TO 0.
SET resources_percentLiquidfuel TO 0.
SET resources_percentOxidizer TO 0.
SET resources_percentMonopropellant TO 0.

SET resources_electricIndex TO 0.
SET resources_liquidIndex TO 0.
SET resources_oxideIndex TO 0.
SET resources_monoIndex TO 0.

LOCK resources_numAvailRsrc TO SHIP:RESOURCES:LENGTH.

//DEPENDENCIES

//MODULE
ON resources_numAvailRsrc {
	resources_updateResourcelist().
	RETURN TRUE.
}

ON hasModule("cli_display") {
	IF hasModule("cli_display"){
		cli_add_gauge(getresources_percentElectriccharge@, "Electric charge").
		cli_add_gauge(getresources_percentLiquidfuel@, "Liquid fuel").
		cli_add_gauge(getresources_percentOxidizer@, "Oxidizer").
		cli_add_gauge(getresources_percentMonopropellant@, "Monopropellant").
	}
	ELSE RETURN TRUE.
}

FUNCTION getresources_percentElectriccharge {
	IF resources_electricIndex > -1 RETURN resources_percentElectriccharge.
	ELSE RETURN 0.
}

FUNCTION getresources_percentLiquidfuel {
	IF resources_liquidIndex > -1 RETURN resources_percentLiquidfuel.
	ELSE RETURN 0.
}

FUNCTION getresources_percentOxidizer {
	IF resources_oxideIndex > -1 RETURN resources_percentOxidizer.
	ELSE RETURN 0.
}

FUNCTION getresources_percentMonopropellant {
	IF resources_monoIndex > -1 RETURN resources_percentMonopropellant.
	ELSE RETURN 0.
}

FUNCTION resources_updateResourcelist{
	SET resourceIterator TO 0.
	PRINT ship:resources.
	SET resources_electricIndex TO -1.
	SET resources_liquidIndex TO -1.
	SET resources_oxideIndex TO -1.
	SET resources_monoIndex TO -1.

	FOR resource IN SHIP:RESOURCES{
		IF resource:NAME = "electriccharge" SET resources_electricIndex TO resourceIterator.
		IF resource:NAME = "liquidfuel" SET resources_liquidIndex TO resourceIterator.
		IF resource:NAME = "oxidizer" SET resources_oxideIndex TO resourceIterator.
		IF resource:NAME = "monopropellant" SET resources_monoIndex TO resourceIterator.
		SET resourceIterator TO resourceIterator + 1.
	}

	IF resources_electricIndex > -1 LOCK resources_percentElectriccharge TO (SHIP:RESOURCES[resources_electricIndex]:amount / SHIP:RESOURCES[resources_electricIndex]:capacity).
	IF resources_liquidIndex > -1 LOCK resources_percentLiquidfuel TO (SHIP:RESOURCES[resources_liquidIndex]:amount / SHIP:RESOURCES[resources_liquidIndex]:capacity).
	IF resources_oxideIndex > -1 LOCK resources_percentOxidizer TO (SHIP:RESOURCES[resources_oxideIndex]:amount / SHIP:RESOURCES[resources_oxideIndex]:capacity).
	IF resources_monoIndex > -1 LOCK resources_percentMonopropellant TO (SHIP:RESOURCES[resources_monoIndex]:amount / SHIP:RESOURCES[resources_monoIndex]:capacity).
}

