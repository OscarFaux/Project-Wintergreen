///////////////////////////////////////////////////////////////////////////////////
/// Micro/Macro chemicals

/decl/chemical_reaction/instant/sizeoxadone
	name = REAGENT_SIZEOXADONE
	id = REAGENT_ID_SIZEOXADONE
	result = REAGENT_ID_SIZEOXADONE
	required_reagents = list("clonexadone" = 1, "tramadol" = 3, REAGENT_ID_PHORON = 1)
	catalysts = list(REAGENT_ID_PHORON = 5)
	result_amount = 5

/decl/chemical_reaction/instant/macrocillin
	name = REAGENT_MACROCILLIN
	id = REAGENT_ID_MACROCILLIN
	result = REAGENT_ID_MACROCILLIN
	// POLARISTODO requires_heating = 1
	required_reagents = list(REAGENT_ID_SIZEOXADONE = 20, "diethylamine" = 20)
	result_amount = 1

/decl/chemical_reaction/instant/microcillin
	name = REAGENT_MICROCILLIN
	id = REAGENT_ID_MICROCILLIN
	result = REAGENT_ID_MICROCILLIN
	// POLARISTODO requires_heating = 1
	required_reagents = list(REAGENT_ID_SIZEOXADONE = 20, REAGENT_ID_SODIUMCHLORIDE = 20)
	result_amount = 1

/decl/chemical_reaction/instant/normalcillin
	name = REAGENT_NORMALCILLIN
	id = REAGENT_ID_NORMALCILLIN
	result = REAGENT_ID_NORMALCILLIN
	// POLARISTODO requires_heating = 1
	required_reagents = list(REAGENT_ID_SIZEOXADONE = 20, "leporazine" = 20)
	result_amount = 1

/decl/chemical_reaction/instant/dontcrossthebeams
	name = "Don't Cross The Beams"
	id = "dontcrossthebeams"
	result = null
	required_reagents = list(REAGENT_ID_MICROCILLIN = 1, REAGENT_ID_MACROCILLIN = 1)

/decl/chemical_reaction/instant/dontcrossthebeams/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/weapons/gauss_shoot.ogg', 50, 1)
	var/datum/effect/effect/system/grav_pull/s = new /datum/effect/effect/system/grav_pull
	s.set_up(3, 3, location)
	s.start()
	holder.clear_reagents()

///////////////////////////////////////////////////////////////////////////////////
/// TF chemicals
/decl/chemical_reaction/instant/amorphorovir
	name = REAGENT_AMORPHOROVIR
	id = REAGENT_ID_AMORPHOROVIR
	result = REAGENT_ID_AMORPHOROVIR
	required_reagents = list("cryptobiolin" = 30, "biomass" = 30, "hyperzine" = 20)
	catalysts = list(REAGENT_ID_PHORON = 5)
	result_amount = 1

/decl/chemical_reaction/instant/androrovir
	name = REAGENT_ANDROROVIR
	id = REAGENT_ID_ANDROROVIR
	result = REAGENT_ID_ANDROROVIR
	required_reagents = list(REAGENT_ID_AMORPHOROVIR = 1, "bicaridine" = 20, REAGENT_ID_IRON = 20, REAGENT_ID_ETHANOL = 20)
	result_amount = 1

/decl/chemical_reaction/instant/gynorovir
	name = REAGENT_GYNOROVIR
	id = REAGENT_ID_GYNOROVIR
	result = REAGENT_ID_GYNOROVIR
	required_reagents = list(REAGENT_ID_AMORPHOROVIR = 1, "inaprovaline" = 20, REAGENT_ID_SILICON = 20, REAGENT_ID_SUGAR = 20)
	result_amount = 1

/decl/chemical_reaction/instant/androgynorovir
	name = REAGENT_ANDROGYNOROVIR
	id = REAGENT_ID_ANDROGYNOROVIR
	result = REAGENT_ID_ANDROGYNOROVIR
	required_reagents = list(REAGENT_ID_AMORPHOROVIR = 1, "anti_toxin" = 20, REAGENT_ID_FLUORINE = 20, REAGENT_ID_TUNGSTEN = 20)
	result_amount = 1

/decl/chemical_reaction/instant/androrovir_bootleg
	name = "Bootleg Androrovir"
	id = "androrovir_bootleg"
	result = REAGENT_ID_ANDROROVIR
	required_reagents = list(REAGENT_ID_AMORPHOROVIR = 1, "protein" = 10, "capsaicin" = 10)
	result_amount = 1

/decl/chemical_reaction/instant/gynorovir_bootleg
	name = "Bootleg Gynorovir"
	id = "gynorovir_bootleg"
	result = REAGENT_ID_GYNOROVIR
	required_reagents = list(REAGENT_ID_AMORPHOROVIR = 1, "soymilk" = 10, REAGENT_ID_SUGAR = 10)
	result_amount = 1

/decl/chemical_reaction/instant/androgynorovir_bootleg
	name = "Bootleg Androgynorovir"
	id = "androgynorovir_bootleg"
	result = REAGENT_ID_ANDROGYNOROVIR
	required_reagents = list(REAGENT_ID_AMORPHOROVIR = 1, "cola" = 10, "berryjuice" = 10)
	result_amount = 1

///////////////////////////////////////////////////////////////////////////////////
/// Miscellaneous Reactions

/decl/chemical_reaction/instant/foam/softdrink
	required_reagents = list("cola" = 1, "mint" = 1)

/decl/chemical_reaction/instant/firefightingfoam //TODO: Make it so we can add this to the foam tanks to refill them
    name = REAGENT_FIREFOAM
    id = "firefighting foam"
    result = REAGENT_ID_FIREFOAM
    required_reagents = list(REAGENT_ID_WATER = 1)
    catalysts = list(REAGENT_ID_FLUORINE = 10)
    result_amount = 1

/decl/chemical_reaction/instant/firefightingfoamqol //Please don't abuse this and make us remove it. Seriously.
    name = "Firefighting Foam EZ"
    id = "firefighting foam ez"
    result = REAGENT_ID_FIREFOAM
    required_reagents = list(REAGENT_ID_WATER = 1)
    catalysts = list(REAGENT_ID_FIREFOAM = 5)
    inhibitors = list(REAGENT_ID_FLUORINE = 0.01)
    result_amount = 1

///////////////////////////////////////////////////////////////////////////////////
/// Vore Drugs

/decl/chemical_reaction/instant/ickypak
	name = REAGENT_ICKYPAK
	id = REAGENT_ID_ICKYPAK
	result = REAGENT_ID_ICKYPAK
	required_reagents = list("hyperzine" = 4, "fluorosurfactant" = 1)
	result_amount = 5

/decl/chemical_reaction/instant/unsorbitol
	name = REAGENT_UNSORBITOL
	id = REAGENT_ID_UNSORBITOL
	result = REAGENT_ID_UNSORBITOL
	required_reagents = list("mutagen" = 3, "lipozine" = 2)
	result_amount = 5

///////////////////////////////////////////////////////////////////////////////////
/// Other Drugs
/decl/chemical_reaction/instant/adranol
	name = "Adranol"
	id = "adranol"
	result = "adranol"
	required_reagents = list("milk" = 2, REAGENT_ID_HYDROGEN = 1, REAGENT_ID_POTASSIUM = 1)
	result_amount = 3

/decl/chemical_reaction/instant/vermicetol
	name = "Vermicetol"
	id = "vermicetol"
	result = "vermicetol"
	required_reagents = list("bicaridine" = 2, REAGENT_ID_SHOCKCHEM = 1, REAGENT_ID_PHORON = 0.1)
	catalysts = list(REAGENT_ID_PHORON = 5)
	result_amount = 3

/decl/chemical_reaction/instant/prussian_blue
	name = "Prussian Blue"
	id = "prussian_blue"
	result = "prussian_blue"
	required_reagents = list(REAGENT_ID_CARBON = 3, REAGENT_ID_IRON = 1, REAGENT_ID_NITROGEN = 3)
	result_amount = 7

/decl/chemical_reaction/instant/lipozilase
	name = "Lipozilase"
	id = "Lipozilase"
	result = "lipozilase"
	required_reagents = list("lipozine" = 1, "diethylamine" = 1)
	result_amount = 2

/decl/chemical_reaction/instant/lipostipo
	name = "Lipostipo"
	id = "Lipostipo"
	result = "lipostipo"
	required_reagents = list("lipozine" = 1, REAGENT_ID_NUTRIMENT = 1, REAGENT_ID_FLUORINE = 1)
	result_amount = 3

///////////////////////////////////////////////////////////////////////////////////
/// Reagent colonies.
/decl/chemical_reaction/instant/meatcolony
	name = "protein"
	id = REAGENT_ID_MEATCOLONY
	result = "protein"
	required_reagents = list(REAGENT_ID_MEATCOLONY = 5, "virusfood" = 5)
	result_amount = 60

/decl/chemical_reaction/instant/plantcolony
	name = REAGENT_ID_NUTRIMENT
	id = REAGENT_ID_PLANTCOLONY
	result = REAGENT_ID_NUTRIMENT
	required_reagents = list(REAGENT_ID_PLANTCOLONY = 5, "virusfood" = 5)
	result_amount = 60

///////////////////////////////////////////////////////////////////////////////////
/// Upstream Adjustments
/decl/chemical_reaction/instant/biomass
	result_amount = 6	// Roughly 120u per phoron sheet

///////////////////////////////
//SLIME-RELATED BELOW HERE///////
///////////////////////////////
/decl/chemical_reaction/instant/slimeify
	name = REAGENT_ADVMUTATIONTOXIN
	id = "advmutationtoxin2"
	result = REAGENT_ID_ADVMUTATIONTOXIN
	required_reagents = list(REAGENT_ID_PHORON = 15, "slimejelly" = 15, "mutationtoxin" = 15) //In case a xenobiologist wants to become a fully fledged slime person.
	result_amount = 1
