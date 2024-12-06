// These reactions happen instantaneously, when added to a container that has all other necessary reagents
// They are a subtype of chemical_reaction so that such containers can iterate over only these reactions, and not have to skip other reaction types

/* Common reactions */

/decl/chemical_reaction/instant/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	result = "inaprovaline"
	required_reagents = list(REAGENT_ID_OXYGEN = 1, REAGENT_ID_CARBON = 1, REAGENT_ID_SUGAR = 1)
	result_amount = 3

/decl/chemical_reaction/instant/dylovene
	name = "Dylovene"
	id = "anti_toxin"
	result = "anti_toxin"
	required_reagents = list(REAGENT_ID_SILICON = 1, REAGENT_ID_POTASSIUM = 1, REAGENT_ID_NITROGEN = 1)
	result_amount = 3

/decl/chemical_reaction/instant/carthatoline
	name = "Carthatoline"
	id = "carthatoline"
	result = "carthatoline"
	required_reagents = list("anti_toxin" = 1, REAGENT_ID_CARBON = 2, REAGENT_ID_PHORON = 0.1)
	catalysts = list(REAGENT_ID_PHORON = 1)
	result_amount = 2

/decl/chemical_reaction/instant/paracetamol
	name = "Paracetamol"
	id = "paracetamol"
	result = "paracetamol"
	required_reagents = list("inaprovaline" = 1, REAGENT_ID_NITROGEN = 1, REAGENT_ID_WATER = 1)
	result_amount = 2

/decl/chemical_reaction/instant/tramadol
	name = "Tramadol"
	id = "tramadol"
	result = "tramadol"
	required_reagents = list("paracetamol" = 1, REAGENT_ID_ETHANOL = 1, REAGENT_ID_OXYGEN = 1)
	result_amount = 3

/decl/chemical_reaction/instant/oxycodone
	name = "Oxycodone"
	id = "oxycodone"
	result = "oxycodone"
	required_reagents = list(REAGENT_ID_ETHANOL = 1, "tramadol" = 1)
	catalysts = list(REAGENT_ID_PHORON = 5)
	result_amount = 1

/decl/chemical_reaction/instant/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	result = "sterilizine"
	required_reagents = list(REAGENT_ID_ETHANOL = 1, "anti_toxin" = 1, REAGENT_ID_CHLORINE = 1)
	result_amount = 3

/decl/chemical_reaction/instant/silicate
	name = "Silicate"
	id = "silicate"
	result = "silicate"
	required_reagents = list(REAGENT_ID_ALUMINIUM = 1, REAGENT_ID_SILICON = 1, REAGENT_ID_OXYGEN = 1)
	result_amount = 3

/decl/chemical_reaction/instant/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	result = "mutagen"
	required_reagents = list(REAGENT_ID_RADIUM = 1, REAGENT_ID_PHOSPHORUS = 1, REAGENT_ID_CHLORINE = 1)
	result_amount = 3

/decl/chemical_reaction/instant/water
	name = REAGENT_WATER
	id = REAGENT_ID_WATER
	result = REAGENT_ID_WATER
	required_reagents = list(REAGENT_ID_OXYGEN = 1, REAGENT_ID_HYDROGEN = 2)
	result_amount = 1

/decl/chemical_reaction/instant/thermite
	name = "Thermite"
	id = "thermite"
	result = "thermite"
	required_reagents = list(REAGENT_ID_ALUMINIUM = 1, REAGENT_ID_IRON = 1, REAGENT_ID_OXYGEN = 1)
	result_amount = 3

/decl/chemical_reaction/instant/bliss
	name = REAGENT_BLISS
	id = REAGENT_ID_BLISS
	result = REAGENT_ID_BLISS
	required_reagents = list(REAGENT_ID_MERCURY = 1, REAGENT_ID_SUGAR = 1, REAGENT_ID_LITHIUM = 1)
	result_amount = 3

/decl/chemical_reaction/instant/lube
	name = "Space Lube"
	id = "lube"
	result = "lube"
	required_reagents = list(REAGENT_ID_WATER = 1, REAGENT_ID_SILICON = 1, REAGENT_ID_OXYGEN = 1)
	result_amount = 4

/decl/chemical_reaction/instant/pacid
	name = REAGENT_PACID
	id = REAGENT_ID_PACID
	result = REAGENT_ID_PACID
	required_reagents = list(REAGENT_ID_SACID = 1, REAGENT_ID_CHLORINE = 1, REAGENT_ID_POTASSIUM = 1)
	result_amount = 3

/decl/chemical_reaction/instant/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	result = "synaptizine"
	required_reagents = list(REAGENT_ID_SUGAR = 1, REAGENT_ID_LITHIUM = 1, REAGENT_ID_WATER = 1)
	result_amount = 3

/decl/chemical_reaction/instant/hyronalin
	name = "Hyronalin"
	id = "hyronalin"
	result = "hyronalin"
	required_reagents = list(REAGENT_ID_RADIUM = 1, "anti_toxin" = 1)
	result_amount = 2

/decl/chemical_reaction/instant/arithrazine
	name = "Arithrazine"
	id = "arithrazine"
	result = "arithrazine"
	required_reagents = list("hyronalin" = 1, REAGENT_ID_HYDROGEN = 1)
	result_amount = 2

/decl/chemical_reaction/instant/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	result = "impedrezene"
	required_reagents = list(REAGENT_ID_MERCURY = 1, REAGENT_ID_OXYGEN = 1, REAGENT_ID_SUGAR = 1)
	result_amount = 2

/decl/chemical_reaction/instant/kelotane
	name = "Kelotane"
	id = "kelotane"
	result = "kelotane"
	required_reagents = list(REAGENT_ID_SILICON = 1, REAGENT_ID_CARBON = 1)
	result_amount = 2
	log_is_important = 1

/decl/chemical_reaction/instant/peridaxon
	name = "Peridaxon"
	id = "peridaxon"
	result = "peridaxon"
	required_reagents = list("bicaridine" = 2, "clonexadone" = 2)
	catalysts = list(REAGENT_ID_PHORON = 5)
	result_amount = 2

/decl/chemical_reaction/instant/osteodaxon
	name = "Osteodaxon"
	id = "osteodaxon"
	result = "osteodaxon"
	required_reagents = list("bicaridine" = 2, REAGENT_ID_PHORON = 0.1, "carpotoxin" = 1)
	catalysts = list(REAGENT_ID_PHORON = 5)
	inhibitors = list("clonexadone" = 1) // Messes with cryox
	result_amount = 2

/decl/chemical_reaction/instant/respirodaxon
	name = "Respirodaxon"
	id = "respirodaxon"
	result = "respirodaxon"
	required_reagents = list("dexalinp" = 2, "biomass" = 2, REAGENT_ID_PHORON = 1)
	catalysts = list(REAGENT_ID_PHORON = 5)
	inhibitors = list("dexalin" = 1)
	result_amount = 2

/decl/chemical_reaction/instant/gastirodaxon
	name = "Gastirodaxon"
	id = "gastirodaxon"
	result = "gastirodaxon"
	required_reagents = list("carthatoline" = 1, "biomass" = 2, REAGENT_ID_TUNGSTEN = 2)
	catalysts = list(REAGENT_ID_PHORON = 5)
	inhibitors = list(REAGENT_ID_LITHIUM = 1)
	result_amount = 3

/decl/chemical_reaction/instant/hepanephrodaxon
	name = "Hepanephrodaxon"
	id = "hepanephrodaxon"
	result = "hepanephrodaxon"
	required_reagents = list("carthatoline" = 2, "biomass" = 2, REAGENT_ID_LITHIUM = 1)
	catalysts = list(REAGENT_ID_PHORON = 5)
	inhibitors = list(REAGENT_ID_TUNGSTEN = 1)
	result_amount = 2

/decl/chemical_reaction/instant/cordradaxon
	name = "Cordradaxon"
	id = "cordradaxon"
	result = "cordradaxon"
	required_reagents = list("potassium_chlorophoride" = 1, "biomass" = 2, "bicaridine" = 2)
	catalysts = list(REAGENT_ID_PHORON = 5)
	inhibitors = list("clonexadone" = 1)
	result_amount = 2

/decl/chemical_reaction/instant/virus_food
	name = "Virus Food"
	id = "virusfood"
	result = "virusfood"
	required_reagents = list(REAGENT_ID_WATER = 1, "milk" = 1)
	result_amount = 5

/decl/chemical_reaction/instant/leporazine
	name = "Leporazine"
	id = "leporazine"
	result = "leporazine"
	required_reagents = list(REAGENT_ID_SILICON = 1, REAGENT_ID_COPPER = 1)
	catalysts = list(REAGENT_ID_PHORON = 5)
	result_amount = 2

/decl/chemical_reaction/instant/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	result = "cryptobiolin"
	required_reagents = list(REAGENT_ID_POTASSIUM = 1, REAGENT_ID_OXYGEN = 1, REAGENT_ID_SUGAR = 1)
	result_amount = 3

/decl/chemical_reaction/instant/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	result = "tricordrazine"
	required_reagents = list("inaprovaline" = 1, "anti_toxin" = 1)
	result_amount = 2

/decl/chemical_reaction/instant/alkysine
	name = "Alkysine"
	id = "alkysine"
	result = "alkysine"
	required_reagents = list(REAGENT_ID_CHLORINE = 1, REAGENT_ID_NITROGEN = 1, "anti_toxin" = 1)
	result_amount = 2

/decl/chemical_reaction/instant/dexalin
	name = "Dexalin"
	id = "dexalin"
	result = "dexalin"
	required_reagents = list(REAGENT_ID_OXYGEN = 2, REAGENT_ID_PHORON = 0.1)
	catalysts = list(REAGENT_ID_PHORON = 1)
	inhibitors = list(REAGENT_ID_WATER = 1) // Messes with cryox
	result_amount = 1

/decl/chemical_reaction/instant/dermaline
	name = "Dermaline"
	id = "dermaline"
	result = "dermaline"
	required_reagents = list(REAGENT_ID_OXYGEN = 1, REAGENT_ID_PHOSPHORUS = 1, "kelotane" = 1)
	result_amount = 3

/decl/chemical_reaction/instant/dexalinp
	name = "Dexalin Plus"
	id = "dexalinp"
	result = "dexalinp"
	required_reagents = list("dexalin" = 1, REAGENT_ID_CARBON = 1, REAGENT_ID_IRON = 1)
	result_amount = 3

/decl/chemical_reaction/instant/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	result = "bicaridine"
	required_reagents = list("inaprovaline" = 1, REAGENT_ID_CARBON = 1)
	inhibitors = list(REAGENT_ID_SUGAR = 1) // Messes up with inaprovaline
	result_amount = 2

/decl/chemical_reaction/instant/myelamine
	name = "Myelamine"
	id = "myelamine"
	result = "myelamine"
	required_reagents = list("bicaridine" = 1, REAGENT_ID_IRON = 2, REAGENT_ID_SPIDERTOXIN = 1)
	result_amount = 2

/decl/chemical_reaction/instant/hyperzine
	name = "Hyperzine"
	id = "hyperzine"
	result = "hyperzine"
	required_reagents = list(REAGENT_ID_SUGAR = 1, REAGENT_ID_PHOSPHORUS = 1, REAGENT_ID_SULFUR = 1)
	result_amount = 3

/decl/chemical_reaction/instant/stimm
	name = "Stimm"
	id = "stimm"
	result = "stimm"
	required_reagents = list("left4zed" = 1, REAGENT_ID_FUEL = 1)
	catalysts = list(REAGENT_ID_FUEL = 5)
	result_amount = 2

/decl/chemical_reaction/instant/ryetalyn
	name = "Ryetalyn"
	id = "ryetalyn"
	result = "ryetalyn"
	required_reagents = list("arithrazine" = 1, REAGENT_ID_CARBON = 1)
	result_amount = 2

/decl/chemical_reaction/instant/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	result = "cryoxadone"
	required_reagents = list("dexalin" = 1, REAGENT_ID_WATER = 1, REAGENT_ID_OXYGEN = 1)
	result_amount = 3

/decl/chemical_reaction/instant/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	result = "clonexadone"
	required_reagents = list("cryoxadone" = 1, REAGENT_ID_SODIUM = 1, REAGENT_ID_PHORON = 0.1)
	catalysts = list(REAGENT_ID_PHORON = 5)
	result_amount = 2

/decl/chemical_reaction/instant/mortiferin
	name = "Mortiferin"
	id = "mortiferin"
	result = "mortiferin"
	required_reagents = list("cryptobiolin" = 1, "clonexadone" = 1, "corophizine" = 1)
	result_amount = 2
	catalysts = list(REAGENT_ID_PHORON = 5)

/decl/chemical_reaction/instant/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	result = "spaceacillin"
	required_reagents = list("cryptobiolin" = 1, "inaprovaline" = 1)
	result_amount = 2

/decl/chemical_reaction/instant/corophizine
	name = "Corophizine"
	id = "corophizine"
	result = "corophizine"
	required_reagents = list("spaceacillin" = 1, REAGENT_ID_CARBON = 1, REAGENT_ID_PHORON = 0.1)
	catalysts = list(REAGENT_ID_PHORON = 5)
	result_amount = 2

/decl/chemical_reaction/instant/immunosuprizine
	name = "Immunosuprizine"
	id = "immunosuprizine"
	result = "immunosuprizine"
	required_reagents = list("corophizine" = 1, REAGENT_ID_TUNGSTEN = 1, REAGENT_ID_SACID = 1)
	catalysts = list(REAGENT_ID_PHORON = 5)
	result_amount = 2

/decl/chemical_reaction/instant/imidazoline
	name = "imidazoline"
	id = "imidazoline"
	result = "imidazoline"
	required_reagents = list(REAGENT_ID_CARBON = 1, REAGENT_ID_HYDROGEN = 1, "anti_toxin" = 1)
	result_amount = 2

/decl/chemical_reaction/instant/ethylredoxrazine
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	result = "ethylredoxrazine"
	required_reagents = list(REAGENT_ID_OXYGEN = 1, "anti_toxin" = 1, REAGENT_ID_CARBON = 1)
	result_amount = 3

/decl/chemical_reaction/instant/calciumcarbonate
	name = "Calcium Carbonate"
	id = "calciumcarbonate"
	result = "calciumcarbonate"
	required_reagents = list(REAGENT_ID_OXYGEN = 3, REAGENT_ID_CALCIUM = 1, REAGENT_ID_CARBON = 1)
	result_amount = 2

/decl/chemical_reaction/instant/soporific
	name = "Soporific"
	id = "stoxin"
	result = "stoxin"
	required_reagents = list("chloralhydrate" = 1, REAGENT_ID_SUGAR = 4)
	inhibitors = list(REAGENT_ID_PHOSPHORUS) // Messes with the smoke
	result_amount = 5

/decl/chemical_reaction/instant/chloralhydrate
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	result = "chloralhydrate"
	required_reagents = list(REAGENT_ID_ETHANOL = 1, REAGENT_ID_CHLORINE = 3, REAGENT_ID_WATER = 1)
	result_amount = 1

/decl/chemical_reaction/instant/potassium_chloride
	name = "Potassium Chloride"
	id = "potassium_chloride"
	result = "potassium_chloride"
	required_reagents = list(REAGENT_ID_SODIUMCHLORIDE = 1, REAGENT_ID_POTASSIUM = 1)
	result_amount = 2

/decl/chemical_reaction/instant/potassium_chlorophoride
	name = "Potassium Chlorophoride"
	id = "potassium_chlorophoride"
	result = "potassium_chlorophoride"
	required_reagents = list("potassium_chloride" = 1, REAGENT_ID_PHORON = 1, "chloralhydrate" = 1)
	result_amount = 4

/decl/chemical_reaction/instant/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	result = "zombiepowder"
	required_reagents = list("carpotoxin" = 5, "stoxin" = 5, REAGENT_ID_COPPER = 5)
	result_amount = 2

/decl/chemical_reaction/instant/carpotoxin
	name = "Carpotoxin"
	id = "carpotoxin"
	result = "carpotoxin"
	required_reagents = list(REAGENT_ID_SPIDERTOXIN = 2, "biomass" = 1, "sifsap" = 2)
	catalysts = list("sifsap" = 10)
	inhibitors = list(REAGENT_ID_RADIUM = 1)
	result_amount = 2

/decl/chemical_reaction/instant/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	result = "mindbreaker"
	required_reagents = list(REAGENT_ID_SILICON = 1, REAGENT_ID_HYDROGEN = 1, "anti_toxin" = 1)
	result_amount = 3

/decl/chemical_reaction/instant/lipozine
	name = "Lipozine"
	id = "Lipozine"
	result = "lipozine"
	required_reagents = list(REAGENT_ID_SODIUMCHLORIDE = 1, REAGENT_ID_ETHANOL = 1, REAGENT_ID_RADIUM = 1)
	result_amount = 3

/decl/chemical_reaction/instant/surfactant
	name = "Foam surfactant"
	id = "foam surfactant"
	result = "fluorosurfactant"
	required_reagents = list(REAGENT_ID_FLUORINE = 2, REAGENT_ID_CARBON = 2, REAGENT_ID_SACID = 1)
	result_amount = 5

/decl/chemical_reaction/instant/ammonia
	name = "Ammonia"
	id = "ammonia"
	result = "ammonia"
	required_reagents = list(REAGENT_ID_HYDROGEN = 3, REAGENT_ID_NITROGEN = 1)
	inhibitors = list(REAGENT_ID_PHORON = 1) // Messes with lexorin
	result_amount = 3

/decl/chemical_reaction/instant/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	result = "diethylamine"
	required_reagents = list ("ammonia" = 1, REAGENT_ID_ETHANOL = 1)
	result_amount = 2

/decl/chemical_reaction/instant/left4zed
	name = "Left4Zed"
	id = "left4zed"
	result = "left4zed"
	required_reagents = list ("diethylamine" = 2, "mutagen" = 1)
	result_amount = 3

/decl/chemical_reaction/instant/robustharvest
	name = "RobustHarvest"
	id = "robustharvest"
	result = "robustharvest"
	required_reagents = list ("ammonia" = 1, REAGENT_ID_CALCIUM = 1, "neurotoxic_protein" = 1)
	result_amount = 3

/decl/chemical_reaction/instant/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	result = "cleaner"
	required_reagents = list("ammonia" = 1, REAGENT_ID_WATER = 1)
	result_amount = 2

/decl/chemical_reaction/instant/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	result = "plantbgone"
	required_reagents = list("toxin" = 1, REAGENT_ID_WATER = 4)
	result_amount = 5

/decl/chemical_reaction/instant/foaming_agent
	name = "Foaming Agent"
	id = "foaming_agent"
	result = "foaming_agent"
	required_reagents = list(REAGENT_ID_LITHIUM = 1, REAGENT_ID_HYDROGEN = 1)
	result_amount = 1

/decl/chemical_reaction/instant/glycerol
	name = "Glycerol"
	id = "glycerol"
	result = "glycerol"
	required_reagents = list("cornoil" = 3, REAGENT_ID_SACID = 1)
	result_amount = 1

/decl/chemical_reaction/instant/sodiumchloride
	name = "Sodium Chloride"
	id = REAGENT_ID_SODIUMCHLORIDE
	result = REAGENT_ID_SODIUMCHLORIDE
	required_reagents = list(REAGENT_ID_SODIUM = 1, REAGENT_ID_CHLORINE = 1)
	result_amount = 2

/decl/chemical_reaction/instant/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	result = "condensedcapsaicin"
	required_reagents = list("capsaicin" = 2)
	catalysts = list(REAGENT_ID_PHORON = 5)
	result_amount = 1

/decl/chemical_reaction/instant/coolant
	name = "Coolant"
	id = "coolant"
	result = "coolant"
	required_reagents = list(REAGENT_ID_TUNGSTEN = 1, REAGENT_ID_OXYGEN = 1, REAGENT_ID_WATER = 1)
	result_amount = 3
	log_is_important = 1

/decl/chemical_reaction/instant/rezadone
	name = "Rezadone"
	id = "rezadone"
	result = "rezadone"
	required_reagents = list("carpotoxin" = 1, "cryptobiolin" = 1, REAGENT_ID_COPPER = 1)
	result_amount = 3

/decl/chemical_reaction/instant/lexorin
	name = "Lexorin"
	id = "lexorin"
	result = "lexorin"
	required_reagents = list(REAGENT_ID_PHORON = 1, REAGENT_ID_HYDROGEN = 1, REAGENT_ID_NITROGEN = 1)
	result_amount = 3

/decl/chemical_reaction/instant/methylphenidate
	name = REAGENT_METHYLPHENIDATE
	id = REAGENT_ID_METHYLPHENIDATE
	result = REAGENT_ID_METHYLPHENIDATE
	required_reagents = list("mindbreaker" = 1, REAGENT_ID_HYDROGEN = 1)
	result_amount = 3

/decl/chemical_reaction/instant/citalopram
	name = REAGENT_CITALOPRAM
	id = REAGENT_ID_CITALOPRAM
	result = REAGENT_ID_CITALOPRAM
	required_reagents = list("mindbreaker" = 1, REAGENT_ID_CARBON = 1)
	result_amount = 3

/decl/chemical_reaction/instant/paroxetine
	name = REAGENT_PAROXETINE
	id = REAGENT_ID_PAROXETINE
	result = REAGENT_ID_PAROXETINE
	required_reagents = list("mindbreaker" = 1, REAGENT_ID_OXYGEN = 1, "inaprovaline" = 1)
	result_amount = 3

/decl/chemical_reaction/instant/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	result = "neurotoxin"
	required_reagents = list("gargleblaster" = 1, "stoxin" = 1)
	result_amount = 2

/decl/chemical_reaction/instant/luminol
	name = "Luminol"
	id = "luminol"
	result = "luminol"
	required_reagents = list(REAGENT_ID_HYDROGEN = 2, REAGENT_ID_CARBON = 2, "ammonia" = 2)
	result_amount = 6

/* Solidification */

/decl/chemical_reaction/instant/solidification
	name = "Solid Iron"
	id = "solidiron"
	result = null
	required_reagents = list("frostoil" = 5, REAGENT_ID_IRON = REAGENTS_PER_SHEET)
	result_amount = 1
	var/sheet_to_give = /obj/item/stack/material/iron

/decl/chemical_reaction/instant/solidification/on_reaction(var/datum/reagents/holder, var/created_volume)
	new sheet_to_give(get_turf(holder.my_atom), created_volume)
	return


/decl/chemical_reaction/instant/solidification/phoron
	name = "Solid Phoron"
	id = "solidphoron"
	required_reagents = list("frostoil" = 5, REAGENT_ID_PHORON = REAGENTS_PER_SHEET)
	sheet_to_give = /obj/item/stack/material/phoron


/decl/chemical_reaction/instant/solidification/silver
	name = "Solid Silver"
	id = "solidsilver"
	required_reagents = list("frostoil" = 5, "silver" = REAGENTS_PER_SHEET)
	sheet_to_give = /obj/item/stack/material/silver


/decl/chemical_reaction/instant/solidification/gold
	name = "Solid Gold"
	id = "solidgold"
	required_reagents = list("frostoil" = 5, "gold" = REAGENTS_PER_SHEET)
	sheet_to_give = /obj/item/stack/material/gold


/decl/chemical_reaction/instant/solidification/platinum
	name = "Solid Platinum"
	id = "solidplatinum"
	required_reagents = list("frostoil" = 5, "platinum" = REAGENTS_PER_SHEET)
	sheet_to_give = /obj/item/stack/material/platinum


/decl/chemical_reaction/instant/solidification/uranium
	name = "Solid Uranium"
	id = "soliduranium"
	required_reagents = list("frostoil" = 5, "uranium" = REAGENTS_PER_SHEET)
	sheet_to_give = /obj/item/stack/material/uranium


/decl/chemical_reaction/instant/solidification/hydrogen
	name = "Solid Hydrogen"
	id = "solidhydrogen"
	required_reagents = list("frostoil" = 100, REAGENT_ID_HYDROGEN = REAGENTS_PER_SHEET)
	sheet_to_give = /obj/item/stack/material/mhydrogen


// These are from Xenobio.
/decl/chemical_reaction/instant/solidification/steel
	name = "Solid Steel"
	id = "solidsteel"
	required_reagents = list("frostoil" = 5, "steel" = REAGENTS_PER_SHEET)
	sheet_to_give = /obj/item/stack/material/steel


/decl/chemical_reaction/instant/solidification/plasteel
	name = "Solid Plasteel"
	id = "solidplasteel"
	required_reagents = list("frostoil" = 10, "plasteel" = REAGENTS_PER_SHEET)
	sheet_to_give = /obj/item/stack/material/plasteel


/decl/chemical_reaction/instant/plastication
	name = "Plastic"
	id = "solidplastic"
	result = null
	required_reagents = list(REAGENT_ID_PACID = 1, "plasticide" = 2)
	result_amount = 1

/decl/chemical_reaction/instant/plastication/on_reaction(var/datum/reagents/holder, var/created_volume)
	new /obj/item/stack/material/plastic(get_turf(holder.my_atom), created_volume)
	return

/*Carpet Creation*/

/decl/chemical_reaction/instant/carpetify
	name = "Carpet"
	id = "redcarpet"
	result = null
	required_reagents = list("liquidcarpet" = 2, "plasticide" = 1)
	result_amount = 2
	var/carpet_type = /obj/item/stack/tile/carpet

/decl/chemical_reaction/instant/carpetify/on_reaction(var/datum/reagents/holder, var/created_volume)
	new carpet_type(get_turf(holder.my_atom), created_volume)
	return

/decl/chemical_reaction/instant/carpetify/bcarpet
	name = "Black Carpet"
	id = "blackcarpet"
	required_reagents = list("liquidcarpetb" = 2, "plasticide" = 1)
	carpet_type = /obj/item/stack/tile/carpet/bcarpet

/decl/chemical_reaction/instant/carpetify/blucarpet
	name = "Blue Carpet"
	id = "bluecarpet"
	required_reagents = list ("liquidcarpetblu" = 2, "plasticide" = 1)
	carpet_type = /obj/item/stack/tile/carpet/blucarpet

/decl/chemical_reaction/instant/carpetify/turcarpet
	name = "Turquise Carpet"
	id = "turcarpet"
	required_reagents = list("liquidcarpettur" = 2, "plasticide" = 1)
	carpet_type = /obj/item/stack/tile/carpet/turcarpet

/decl/chemical_reaction/instant/carpetify/sblucarpet
	name = "Silver Blue Carpet"
	id = "sblucarpet"
	required_reagents = list("liquidcarpetsblu" = 2, "plasticide" = 1)
	carpet_type = /obj/item/stack/tile/carpet/sblucarpet

/decl/chemical_reaction/instant/carpetify/clowncarpet
	name = "Clown Carpet"
	id = "clowncarpet"
	required_reagents = list("liquidcarpetc" = 2, "plasticide" = 1)
	carpet_type = /obj/item/stack/tile/carpet/gaycarpet

/decl/chemical_reaction/instant/carpetify/pcarpet
	name = "Purple Carpet"
	id = "Purplecarpet"
	required_reagents = list("liquidcarpetp" = 2, "plasticide" = 1)
	carpet_type = /obj/item/stack/tile/carpet/purcarpet

/decl/chemical_reaction/instant/carpetify/ocarpet
	name = "Orange Carpet"
	id = "orangecarpet"
	required_reagents = list("liquidcarpeto" = 2, "plasticide" = 1)
	carpet_type = /obj/item/stack/tile/carpet/oracarpet

/decl/chemical_reaction/instant/concrete
	name = "Concrete"
	id = "concretereagent"
	required_reagents = list(REAGENT_ID_CALCIUM = 2, "silicate" = 2, REAGENT_ID_WATER = 2)
	result_amount = 1

/decl/chemical_reaction/instant/concrete/on_reaction(var/datum/reagents/holder, var/created_volume)
	new /obj/item/stack/material/concrete(get_turf(holder.my_atom), created_volume)
	return

/* Grenade reactions */

/decl/chemical_reaction/instant/explosion_potassium
	name = "Explosion"
	id = "explosion_potassium"
	result = null
	required_reagents = list(REAGENT_ID_WATER = 1, REAGENT_ID_POTASSIUM = 1)
	result_amount = 2
	mix_message = null

/decl/chemical_reaction/instant/explosion_potassium/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/10, 1), holder.my_atom, 0, 0)
	if(isliving(holder.my_atom))
		e.amount *= 0.5
		var/mob/living/L = holder.my_atom
		if(L.stat != DEAD)
			e.amount *= 0.5
	//VOREStation Add Start
	else
		holder.clear_reagents() //No more powergaming by creating a tiny amount of this
	//VORESTation Add End
	e.start()
	//holder.clear_reagents() //VOREStation Removal
	return

/decl/chemical_reaction/instant/flash_powder
	name = "Flash powder"
	id = "flash_powder"
	result = null
	required_reagents = list(REAGENT_ID_ALUMINIUM = 1, REAGENT_ID_POTASSIUM = 1, REAGENT_ID_SULFUR = 1 )
	result_amount = null

/decl/chemical_reaction/instant/flash_powder/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, location)
	s.start()
	for(var/mob/living/carbon/M in viewers(world.view, location))
		switch(get_dist(M, location))
			if(0 to 3)
				if(hasvar(M, "glasses"))
					if(istype(M:glasses, /obj/item/clothing/glasses/sunglasses))
						continue

				M.flash_eyes()
				M.Weaken(15)

			if(4 to 5)
				if(hasvar(M, "glasses"))
					if(istype(M:glasses, /obj/item/clothing/glasses/sunglasses))
						continue

				M.flash_eyes()
				M.Stun(5)

/decl/chemical_reaction/instant/emp_pulse
	name = "EMP Pulse"
	id = "emp_pulse"
	result = null
	required_reagents = list("uranium" = 1, REAGENT_ID_IRON = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	result_amount = 2

/decl/chemical_reaction/instant/emp_pulse/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 24), round(created_volume / 20), round(created_volume / 18), round(created_volume / 14), 1)
	//VOREStation Edit Start
	if(!isliving(holder.my_atom)) //No more powergaming by creating a tiny amount of this
		holder.clear_reagents()
	//VOREStation Edit End
	return

/decl/chemical_reaction/instant/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	result = "nitroglycerin"
	required_reagents = list("glycerol" = 1, REAGENT_ID_PACID = 1, REAGENT_ID_SACID = 1)
	result_amount = 2
	log_is_important = 1

/decl/chemical_reaction/instant/nitroglycerin/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/2, 1), holder.my_atom, 0, 0)
	if(isliving(holder.my_atom))
		e.amount *= 0.5
		var/mob/living/L = holder.my_atom
		if(L.stat!=DEAD)
			e.amount *= 0.5
	//VOREStation Add Start
	else
		holder.clear_reagents() //No more powergaming by creating a tiny amount of this
	//VOREStation Add End
	e.start()

	//holder.clear_reagents() //VOREStation Removal
	return

/decl/chemical_reaction/instant/napalm
	name = "Napalm"
	id = "napalm"
	result = null
	required_reagents = list(REAGENT_ID_ALUMINIUM = 1, REAGENT_ID_PHORON = 1, REAGENT_ID_SACID = 1 )
	result_amount = 1

/decl/chemical_reaction/instant/napalm/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/location = get_turf(holder.my_atom.loc)
	for(var/turf/simulated/floor/target_tile in range(0,location))
		target_tile.assume_gas(GAS_VOLATILE_FUEL, created_volume, 400+T0C)
		spawn (0) target_tile.hotspot_expose(700, 400)
	holder.del_reagent("napalm")
	return

/decl/chemical_reaction/instant/chemsmoke
	name = "Chemsmoke"
	id = "chemsmoke"
	result = null
	required_reagents = list(REAGENT_ID_POTASSIUM = 1, REAGENT_ID_SUGAR = 1, REAGENT_ID_PHOSPHORUS = 1)
	result_amount = 0.4

/decl/chemical_reaction/instant/chemsmoke/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
	S.attach(location)
	S.set_up(holder, created_volume, 0, location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
		S.start()
	//VOREStation Edit Start
	if(!isliving(holder.my_atom)) //No more powergaming by creating a tiny amount of this
		holder.clear_reagents()
	//VOREStation Edit End
	return

/decl/chemical_reaction/instant/foam
	name = "Foam"
	id = "foam"
	result = null
	required_reagents = list("fluorosurfactant" = 1, REAGENT_ID_WATER = 1)
	result_amount = 2
	mix_message = "The solution violently bubbles!"

/decl/chemical_reaction/instant/foam/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, span_warning("The solution spews out foam!"))

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 0)
	s.start()
	//VOREStation Edit Start
	if(!isliving(holder.my_atom)) //No more powergaming by creating a tiny amount of this
		holder.clear_reagents()
	//VOREStation Edit End
	return

/decl/chemical_reaction/instant/metalfoam
	name = "Metal Foam"
	id = "metalfoam"
	result = null
	required_reagents = list(REAGENT_ID_ALUMINIUM = 3, "foaming_agent" = 1, REAGENT_ID_PACID = 1)
	result_amount = 5

/decl/chemical_reaction/instant/metalfoam/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, span_warning("The solution spews out a metalic foam!"))

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 1)
	s.start()
	return

/decl/chemical_reaction/instant/ironfoam
	name = "Iron Foam"
	id = "ironlfoam"
	result = null
	required_reagents = list(REAGENT_ID_IRON = 3, "foaming_agent" = 1, REAGENT_ID_PACID = 1)
	result_amount = 5

/decl/chemical_reaction/instant/ironfoam/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, span_warning("The solution spews out a metalic foam!"))

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 2)
	s.start()
	return

/* Paint */

/decl/chemical_reaction/instant/red_paint
	name = "Red paint"
	id = "red_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "marker_ink_red" = 1)
	result_amount = 5

/decl/chemical_reaction/instant/red_paint/send_data()
	return "#FE191A"

/decl/chemical_reaction/instant/orange_paint
	name = "Orange paint"
	id = "orange_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "marker_ink_orange" = 1)
	result_amount = 5

/decl/chemical_reaction/instant/orange_paint/send_data()
	return "#FFBE4F"

/decl/chemical_reaction/instant/yellow_paint
	name = "Yellow paint"
	id = "yellow_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "marker_ink_yellow" = 1)
	result_amount = 5

/decl/chemical_reaction/instant/yellow_paint/send_data()
	return "#FDFE7D"

/decl/chemical_reaction/instant/green_paint
	name = "Green paint"
	id = "green_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "marker_ink_green" = 1)
	result_amount = 5

/decl/chemical_reaction/instant/green_paint/send_data()
	return "#18A31A"

/decl/chemical_reaction/instant/blue_paint
	name = "Blue paint"
	id = "blue_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "marker_ink_blue" = 1)
	result_amount = 5

/decl/chemical_reaction/instant/blue_paint/send_data()
	return "#247CFF"

/decl/chemical_reaction/instant/purple_paint
	name = "Purple paint"
	id = "purple_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "marker_ink_purple" = 1)
	result_amount = 5

/decl/chemical_reaction/instant/purple_paint/send_data()
	return "#CC0099"

/decl/chemical_reaction/instant/grey_paint //mime
	name = "Grey paint"
	id = "grey_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "marker_ink_grey" = 1)
	result_amount = 5

/decl/chemical_reaction/instant/grey_paint/send_data()
	return "#808080"

/decl/chemical_reaction/instant/brown_paint
	name = "Brown paint"
	id = "brown_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "marker_ink_brown" = 1)
	result_amount = 5

/decl/chemical_reaction/instant/brown_paint/send_data()
	return "#846F35"

/decl/chemical_reaction/instant/blood_paint
	name = "Blood paint"
	id = "blood_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, REAGENT_ID_BLOOD = 2)
	result_amount = 5

/decl/chemical_reaction/instant/blood_paint/send_data(var/datum/reagents/T)
	var/t = T.get_data(REAGENT_ID_BLOOD)
	if(t && t["blood_colour"])
		return t["blood_colour"]
	return "#FE191A" // Probably red

/decl/chemical_reaction/instant/milk_paint
	name = "Milk paint"
	id = "milk_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "milk" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/milk_paint/send_data()
	return "#F0F8FF"

/decl/chemical_reaction/instant/orange_juice_paint
	name = "Orange juice paint"
	id = "orange_juice_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "orangejuice" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/orange_juice_paint/send_data()
	return "#E78108"

/decl/chemical_reaction/instant/tomato_juice_paint
	name = "Tomato juice paint"
	id = "tomato_juice_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "tomatojuice" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/tomato_juice_paint/send_data()
	return "#731008"

/decl/chemical_reaction/instant/lime_juice_paint
	name = "Lime juice paint"
	id = "lime_juice_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "limejuice" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/lime_juice_paint/send_data()
	return "#365E30"

/decl/chemical_reaction/instant/carrot_juice_paint
	name = "Carrot juice paint"
	id = "carrot_juice_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "carrotjuice" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/carrot_juice_paint/send_data()
	return "#973800"

/decl/chemical_reaction/instant/berry_juice_paint
	name = "Berry juice paint"
	id = "berry_juice_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "berryjuice" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/berry_juice_paint/send_data()
	return "#990066"

/decl/chemical_reaction/instant/grape_juice_paint
	name = "Grape juice paint"
	id = "grape_juice_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "grapejuice" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/grape_juice_paint/send_data()
	return "#863333"

/decl/chemical_reaction/instant/poisonberry_juice_paint
	name = "Poison berry juice paint"
	id = "poisonberry_juice_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "poisonberryjuice" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/poisonberry_juice_paint/send_data()
	return "#863353"

/decl/chemical_reaction/instant/watermelon_juice_paint
	name = "Watermelon juice paint"
	id = "watermelon_juice_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "watermelonjuice" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/watermelon_juice_paint/send_data()
	return "#B83333"

/decl/chemical_reaction/instant/lemon_juice_paint
	name = "Lemon juice paint"
	id = "lemon_juice_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "lemonjuice" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/lemon_juice_paint/send_data()
	return "#AFAF00"

/decl/chemical_reaction/instant/banana_juice_paint
	name = "Banana juice paint"
	id = "banana_juice_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "banana" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/banana_juice_paint/send_data()
	return "#C3AF00"

/decl/chemical_reaction/instant/potato_juice_paint
	name = "Potato juice paint"
	id = "potato_juice_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, "potatojuice" = 5)
	result_amount = 5

/decl/chemical_reaction/instant/potato_juice_paint/send_data()
	return "#302000"

/decl/chemical_reaction/instant/carbon_paint
	name = "Carbon paint"
	id = "carbon_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, REAGENT_ID_CARBON = 1)
	result_amount = 5

/decl/chemical_reaction/instant/carbon_paint/send_data()
	return "#333333"

/decl/chemical_reaction/instant/aluminum_paint
	name = "Aluminum paint"
	id = "aluminum_paint"
	result = "paint"
	required_reagents = list("plasticide" = 1, REAGENT_ID_WATER = 3, REAGENT_ID_ALUMINIUM = 1)
	result_amount = 5

/decl/chemical_reaction/instant/aluminum_paint/send_data()
	return "#F0F8FF"

/*Carpet Recoloring*/
/decl/chemical_reaction/instant/carpetdye
	name = "Black Carpet Dyeing"
	id = "carpetdyeblack"
	result = "liquidcarpetb"
	required_reagents = list("liquidcarpet" = 5, REAGENT_ID_CARBON = 1)
	result_amount = 5

/decl/chemical_reaction/instant/carpetdye/blue
	name = "Blue Carpet Dyeing"
	id = "carpetdyeblue"
	result = "liquidcarpetblu"
	required_reagents = list("liquidcarpet" = 5, "frostoil" = 1)

/decl/chemical_reaction/instant/carpetdye/tur
	name = "Turqouise Carpet Dyeing"
	id = "carpetdyetur"
	result = "liquidcarpettur"
	required_reagents = list("liquidcarpet" = 5, REAGENT_ID_WATER = 1)

/decl/chemical_reaction/instant/carpetdye/sblu
	name = "Silver Blue Carpet Dyeing"
	id = "carpetdyesblu"
	result = "liquidcarpetsblu"
	required_reagents = list("liquidcarpet" = 5, "ice" = 1)

/decl/chemical_reaction/instant/carpetdye/clown
	name = "Clown Carpet Dyeing"
	id = "carpetdyeclown"
	result = "liquidcarpetc"
	required_reagents = list("liquidcarpet" = 5, "banana" = 1)

/decl/chemical_reaction/instant/carpetdye/purple
	name = "Purple Carpet Dyeing"
	id = "carpetdyepurple"
	result = "liquidcarpetp"
	required_reagents = list("liquidcarpet" = 5, "berryjuice" = 1)

/decl/chemical_reaction/instant/carpetdye/orange
	name = "Orange Carpet Dyeing"
	id = "carpetdyeorange"
	result = "liquidcarpeto"
	required_reagents = list("liquidcarpet" = 5, "orangejuice" = 1)


//R-UST Port
/decl/chemical_reaction/instant/hydrophoron
	name = "Hydrophoron"
	id = "hydrophoron"
	result = "hydrophoron"
	required_reagents = list(REAGENT_ID_HYDROGEN = 1, REAGENT_ID_PHORON = 1)
	inhibitors = list(REAGENT_ID_NITROGEN = 1) //So it doesn't mess with lexorin
	result_amount = 2

/decl/chemical_reaction/instant/deuterium
	name = "Deuterium"
	id = "deuterium"
	result = "deuterium"
	required_reagents = list("hydrophoron" = 1, REAGENT_ID_WATER = 2)
	result_amount = 3

//Skrellian crap.
/decl/chemical_reaction/instant/talum_quem
	name = REAGENT_TALUMQUEM
	id = REAGENT_ID_TALUMQUEM
	result = REAGENT_ID_TALUMQUEM
	required_reagents = list(REAGENT_ID_BLISS = 2, REAGENT_ID_SUGAR = 1, "amatoxin" = 1)
	result_amount = 4

/decl/chemical_reaction/instant/qerr_quem
	name = REAGENT_QERRQUEM
	id = REAGENT_ID_QERRQUEM
	result = REAGENT_ID_QERRQUEM
	required_reagents = list(REAGENT_ID_NICOTINE = 1, REAGENT_ID_CARBON = 1, REAGENT_ID_SUGAR = 2)
	result_amount = 4

/decl/chemical_reaction/instant/malish_qualem
	name = "Malish-Qualem"
	id = "malish-qualem"
	result = "malish-qualem"
	required_reagents = list("immunosuprizine" = 1, REAGENT_ID_QERRQUEM = 1, "inaprovaline" = 1)
	catalysts = list(REAGENT_ID_PHORON = 5)
	result_amount = 2

// Biomass, for cloning and bioprinters
/decl/chemical_reaction/instant/biomass
	name = "Biomass"
	id = "biomass"
	result = "biomass"
	required_reagents = list("protein" = 1, REAGENT_ID_SUGAR = 1, REAGENT_ID_PHORON = 1)
	result_amount = 1	// Roughly 20u per phoron sheet

// Neutralization.

/decl/chemical_reaction/instant/neutralize_neurotoxic_protein
	name = "Neutralize Toxic Proteins"
	id = "neurotoxic_protein_neutral"
	result = "protein"
	required_reagents = list("anti_toxin" = 1, "neurotoxic_protein" = 2)
	result_amount = 2

/decl/chemical_reaction/instant/neutralize_carpotoxin
	name = "Neutralize Carpotoxin"
	id = "carpotoxin_neutral"
	result = "protein"
	required_reagents = list("enzyme" = 1, "carpotoxin" = 1, "sifsap" = 1)
	result_amount = 1

/decl/chemical_reaction/instant/neutralize_spidertoxin
	name = "Neutralize Spidertoxin"
	id = "spidertoxin_neutral"
	result = "protein"
	required_reagents = list("enzyme" = 1, REAGENT_ID_SPIDERTOXIN = 1, "sifsap" = 1)
	result_amount = 1
