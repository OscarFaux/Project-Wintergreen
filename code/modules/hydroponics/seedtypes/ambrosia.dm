//Ambrosia/varieties.
/datum/seed/ambrosia
	name = "ambrosia"
	seed_name = "ambrosia vulgaris"
	display_name = "ambrosia vulgaris"
	kitchen_tag = "ambrosia"
	mutants = list("ambrosiadeus")
	chems = list(REAGENT_ID_NUTRIMENT = list(1), REAGENT_ID_AMBROSIAEXTRACT = list(1,8), REAGENT_ID_KELOTANE = list(1,8,1), REAGENT_ID_BICARIDINE = list(1,10,1))

/datum/seed/ambrosia/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,6)
	set_trait(TRAIT_POTENCY,5)
	set_trait(TRAIT_PRODUCT_ICON,"ambrosia")
	set_trait(TRAIT_PRODUCT_COLOUR,"#9FAD55")
	set_trait(TRAIT_PLANT_ICON,"ambrosia")
	set_trait(TRAIT_IDEAL_LIGHT, 6)

/datum/seed/ambrosia/deus
	name = "ambrosiadeus"
	seed_name = "ambrosia deus"
	display_name = "ambrosia deus"
	kitchen_tag = "ambrosiadeus"
	mutants = list("ambrosiainfernus", "ambrosiagaia")
	chems = list(REAGENT_ID_NUTRIMENT = list(1), REAGENT_ID_BICARIDINE = list(1,8), REAGENT_ID_SYNAPTIZINE = list(1,8,1), REAGENT_ID_HYPERZINE = list(1,10,1), REAGENT_ID_AMBROSIAEXTRACT = list(1,10))

/datum/seed/ambrosia/deus/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#A3F0AD")
	set_trait(TRAIT_PLANT_COLOUR,"#2A9C61")

/datum/seed/ambrosia/infernus
	name = "ambrosiainfernus"
	seed_name = "ambrosia infernus"
	display_name = "ambrosia infernus"
	kitchen_tag = "ambrosiainfernus"
	mutants = null
	chems = list(REAGENT_ID_NUTRIMENT = list(1,3), REAGENT_ID_OXYCODONE = list(1,8), REAGENT_ID_IMPEDREZENE = list(1,10), REAGENT_ID_MINDBREAKER = list(1,10), REAGENT_ID_AMBROSIAEXTRACT = list(1,10))

/datum/seed/ambrosia/infernus/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#dc143c")
	set_trait(TRAIT_PLANT_COLOUR,"#b22222")

/datum/seed/ambrosia/gaia
	name = "ambrosiagaia"
	seed_name = "ambrosia gaia"
	display_name = "ambrosia gaia"
	kitchen_tag = "ambrosiagaia"
	mutants = null
	chems = list (REAGENT_ID_EARTHSBLOOD = list(3,5), REAGENT_ID_NUTRIMENT = list(1,3))

/datum/seed/ambrosia/gaia/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,0)
	set_trait(TRAIT_MATURATION,10)
	set_trait(TRAIT_WATER_CONSUMPTION,6)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION,6)
	set_trait(TRAIT_WEED_TOLERANCE,1)
	set_trait(TRAIT_TOXINS_TOLERANCE,1)
	set_trait(TRAIT_PEST_TOLERANCE,1)
	set_trait(TRAIT_BIOLUM,1)
	set_trait(TRAIT_BIOLUM_COLOUR,"#ffb500")
	set_trait(TRAIT_PRODUCT_COLOUR, "#ffee00")
	set_trait(TRAIT_PLANT_COLOUR,"#f3ba2b")
