/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	icon = 'icons/effects/effects.dmi'	//We have an ultra-complex update icons that overlays everything, don't load some stupid random male human
	icon_state = "nothing"

	has_huds = TRUE 					//We do have HUDs (like health, wanted, status, not inventory slots)


	vore_capacity = 3
	vore_capacity_ex = list("stomach" = 3, "taur belly" = 3)
	vore_fullness_ex = list("stomach" = 0, "taur belly" = 0)
	vore_icon_bellies = list("stomach", "taur belly")
	var/struggle_anim_stomach = FALSE
	var/struggle_anim_taur = FALSE

	var/embedded_flag					//To check if we've need to roll for damage on movement while an item is imbedded in us.
	var/obj/item/rig/wearing_rig // This is very not good, but it's much much better than calling get_rig() every update_canmove() call.
	var/last_push_time					//For human_attackhand.dm, keeps track of the last use of disarm

	var/spitting = 0 					//Spitting and spitting related things. Any human based ranged attacks, be it innate or added abilities.
	var/spit_projectile = null			//Projectile type.
	var/spit_name = null 				//String
	var/last_spit = 0 					//Timestamp.

	var/can_defib = 1					//Horrible damage (like beheadings) will prevent defibbing organics.
	var/active_regen = FALSE //Used for the regenerate proc in human_powers.dm
	var/active_regen_delay = 300
	var/last_breath_sound				//Allows us to store the value across proc calls per-mob.
	var/list/teleporters = list() //Used for lleill abilities

	var/rest_dir = 0					//To lay down in a specific direction
	var/list/datum/genetics/side_effect/genetic_side_effects = list()	//For any genetic side effects we currently have.

/mob/living/carbon/human/Initialize(mapload, var/new_species = null)
	if(!dna)
		dna = new /datum/dna(null)
		// Species name is handled by set_species()

	if(!species)
		if(new_species)
			set_species(new_species)
		else
			set_species()

	if(species)
		real_name = species.get_random_name(gender)
		name = real_name
		if(mind)
			mind.name = real_name

	nutrition = rand(200,400)

	GLOB.human_mob_list |= src

	. = ..()

	hide_underwear.Cut()
	for(var/category in global_underwear.categories_by_name)
		hide_underwear[category] = FALSE

	if(dna)
		dna.ready_dna(src)
		dna.real_name = real_name
		sync_dna_traits(FALSE) // Traitgenes Sync traits to genetics if needed
		sync_organ_dna()
	initialize_vessel()
	regenerate_icons()

	AddComponent(/datum/component/personal_crafting)
	AddComponent(/datum/component/hose_connector/inflation) // Comment out to disable all human mob inflation mechanics

	// Chicken Stuff
	var/animal = pick("cow","chicken_brown", "chicken_black", "chicken_white", "chick", "mouse_brown", "mouse_gray", "mouse_white", "lizard", "cat2", "goose", "penguin")
	var/image/img = image('icons/mob/animal.dmi', src, animal)
	img.override = TRUE
	add_alt_appearance("animals", img, displayTo = GLOB.alt_farmanimals)

/mob/living/carbon/human/Destroy()
	GLOB.human_mob_list -= src
	QDEL_NULL_LIST(organs)
	if(nif)
		QDEL_NULL(nif)
	GLOB.alt_farmanimals -= src
	worn_clothing.Cut()

	if(stored_blob)
		stored_blob.drop_l_hand()
		stored_blob.drop_r_hand()
		QDEL_NULL(stored_blob)

	if(vessel)
		QDEL_NULL(vessel)
	. = ..()

/mob/living/carbon/human/get_status_tab_items()
	. = ..()
	. += ""
	. += "Intent: [a_intent]"
	. += "Move Mode: [m_intent]"
	if(emergency_shuttle)
		var/eta_status = emergency_shuttle.get_status_panel_eta()
		if(eta_status)
			. += "[eta_status]"

	if (internal)
		if (!internal.air_contents)
			qdel(internal)
		else
			. += "Internal Atmosphere Info: [internal.name]"
			. += "Tank Pressure: [internal.air_contents.return_pressure()]"
			. += "Distribution Pressure: [internal.distribute_pressure]"

	var/obj/item/organ/internal/xenos/plasmavessel/P = internal_organs_by_name[O_PLASMA] //Xenomorphs. Mech.
	if(P)
		. += "Phoron Stored: [P.stored_plasma]/[P.max_plasma]"


	if(back && istype(back,/obj/item/rig))
		var/obj/item/rig/suit = back
		var/cell_status = "ERROR"
		if(suit.cell) cell_status = "[suit.cell.charge]/[suit.cell.maxcharge]"
		. += "Suit charge: [cell_status]"

	var/datum/component/antag/changeling/comp = is_changeling(src)
	if(comp)
		. += "Chemical Storage: [comp.chem_charges]"
		. += "Genetic Damage Time: [comp.geneticdamage]"
		. += "Re-Adaptations: [comp.readapts]/[comp.max_readapts]"
	if(species)
		species.get_status_tab_items(src)


/mob/proc/RigPanel(var/obj/item/rig/R)
	if(R && !R.canremove && R.installed_modules.len)
		var/list/L = list()
		var/cell_status = R.cell ? "[R.cell.charge]/[R.cell.maxcharge]" : "ERROR"
		L[++L.len] = list("Suit charge: [cell_status]", null, null, null, null)
		for(var/obj/item/rig_module/module in R.installed_modules)
		{
			for(var/atom/movable/stat_rig_module/SRM in module.stat_modules)
				if(SRM.CanUse())
					L[++L.len] = list(SRM.module.interface_name,null,null,SRM.name,REF(SRM))
		}
		misc_tabs["Hardsuit Modules"] = L

/mob/living/update_misc_tabs()
	..()
	if(get_rig_stats)
		var/obj/item/rig/rig = get_rig()
		if(rig)
			RigPanel(rig)

/mob/living/carbon/human/update_misc_tabs()
	..()
	if(species)
		species.update_misc_tabs(src)

	if(istype(back,/obj/item/rig))
		var/obj/item/rig/R = back
		RigPanel(R)

	else if(istype(belt,/obj/item/rig))
		var/obj/item/rig/R = belt
		RigPanel(R)

/mob/living/carbon/human/ex_act(severity)
	if(!blinded)
		flash_eyes()

	for(var/datum/modifier/M in modifiers)
		if(!isnull(M.explosion_modifier))
			severity = CLAMP(severity + M.explosion_modifier, 1, 4)

	severity = round(severity)

	if(severity > 3)
		return

	var/shielded = 0
	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			if (!prob(getarmor(null, "bomb")))
				gib()
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)
			//return
//				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				//user.throw_at(target, 200, 4)

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

			if (!get_ear_protection() >= 2)
				ear_damage += 30
				ear_deaf += 120
				// deaf_loop.start() // Used downstream
			if (prob(70) && !shielded)
				Paralyse(10)

		if(3.0)
			b_loss += 30
			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/2
			if (!get_ear_protection() >= 2)
				ear_damage += 15
				ear_deaf += 60
				// deaf_loop.start() // Used downstream
			if (prob(50) && !shielded)
				Paralyse(10)

	var/blastsoak = getsoak(null, "bomb")

	b_loss = max(1, b_loss - blastsoak)
	f_loss = max(1, f_loss - blastsoak)

	var/update = 0

	// focus most of the blast on one organ
	var/obj/item/organ/external/take_blast = pick(organs)
	update |= take_blast.take_damage(b_loss * 0.9, f_loss * 0.9, used_weapon = "Explosive blast")

	// distribute the remaining 10% on all limbs equally
	b_loss *= 0.1
	f_loss *= 0.1

	var/weapon_message = "Explosive Blast"

	for(var/obj/item/organ/external/temp in organs)
		switch(temp.organ_tag)
			if(BP_HEAD)
				update |= temp.take_damage(b_loss * 0.2, f_loss * 0.2, used_weapon = weapon_message)
			if(BP_TORSO)
				update |= temp.take_damage(b_loss * 0.4, f_loss * 0.4, used_weapon = weapon_message)
			else
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
	if(update)	UpdateDamageIcon()

/mob/living/carbon/human/proc/implant_loyalty(override = FALSE) // Won't override by default.
	if(!CONFIG_GET(flag/use_loyalty_implants) && !override) return // Nuh-uh.

	var/obj/item/implant/loyalty/L = new/obj/item/implant/loyalty(src)
	if(L.handle_implant(src, BP_HEAD))
		L.post_implant(src)

/mob/living/carbon/human/proc/is_loyalty_implanted()
	for(var/L in src.contents)
		if(istype(L, /obj/item/implant/loyalty))
			for(var/obj/item/organ/external/O in src.organs)
				if(L in O.implants)
					return 1
	return 0

/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0

/mob/living/carbon/human/var/co2overloadtime = null
/mob/living/carbon/human/var/temperature_resistance = T0C+75

// called when something steps onto a human
// this handles mobs on fire - mulebot and vehicle code has been relocated to /mob/living/Crossed()
/mob/living/carbon/human/Crossed(var/atom/movable/AM)
	if(AM.is_incorporeal())
		return

	spread_fire(AM)

	..() // call parent because we moved behavior to parent

// Get rank from ID, ID inside PDA, PDA, ID in wallet, etc.
/mob/living/carbon/human/proc/get_authentification_rank(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/pda/pda = wear_id
	if (istype(pda))
		if (pda.id)
			return pda.id.rank ? pda.id.rank : if_no_job
		else
			return pda.ownrank ? pda.ownrank : if_no_job
	else
		var/obj/item/card/id/id = get_idcard()
		if(id)
			return id.rank ? id.rank : if_no_job
		else
			return if_no_id

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/pda/pda = wear_id
	if (istype(pda))
		if (pda.id)
			return pda.id.assignment
		else
			return pda.ownjob ? pda.ownjob : if_no_job
	else
		var/obj/item/card/id/id = get_idcard()
		if(id)
			return id.assignment ? id.assignment : if_no_job
		else
			return if_no_id

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/obj/item/pda/pda = wear_id
	if (istype(pda))
		if (pda.id)
			return pda.id.registered_name
		else
			return pda.owner ? pda.owner : if_no_id
	else
		var/obj/item/card/id/id = get_idcard()
		if(id)
			return id.registered_name
		else
			return if_no_id

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/get_visible_name()
	var/datum/component/shadekin/SK = get_shadekin_component()
	if(SK && SK.in_phase)
		return "Something"	// Something
	if(wear_mask && (wear_mask.flags_inv&HIDEFACE))	//Wearing a mask which hides our face, use id-name if possible
		return get_id_name("Unknown")
	if(head && (head.flags_inv&HIDEFACE))
		return get_id_name("Unknown")		//Likewise for hats
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if((face_name == "Unknown") && id_name && (id_name != face_name))
		return "[face_name] (as [id_name])"
	return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/obj/item/organ/external/head = get_organ(BP_HEAD)
	if(!head || head.disfigured || head.is_stump() || !real_name || (HUSK in mutations) )	//disfigured. use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(var/if_no_id = "Unknown")
	. = if_no_id
	if(istype(wear_id,/obj/item/pda))
		var/obj/item/pda/P = wear_id
		return P.owner ? P.owner : if_no_id
	if(wear_id)
		var/obj/item/card/id/I = wear_id.GetID()
		if(I)
			return I.registered_name
	return

//gets ID card object from special clothes slot or null.
/mob/living/carbon/human/proc/get_idcard()
	if(wear_id)
		return wear_id.GetID()

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0, var/def_zone = null, var/stun)

	if(SEND_SIGNAL(src, COMSIG_BEING_ELECTROCUTED, shock_damage, source, siemens_coeff, def_zone, stun) & COMPONENT_CARBON_CANCEL_ELECTROCUTE)
		return 0	// Cancelled by a component

	if (!def_zone)
		def_zone = pick(BP_L_HAND, BP_R_HAND)

	if(species.siemens_coefficient == -1)
		if(stored_shock_by_ref["\ref[src]"])
			stored_shock_by_ref["\ref[src]"] += shock_damage
		else
			stored_shock_by_ref["\ref[src]"] = shock_damage
		return

	var/obj/item/organ/external/affected_organ = get_organ(check_zone(def_zone))
	siemens_coeff = siemens_coeff * get_siemens_coefficient_organ(affected_organ)
	if(fire_stacks < 0) // Water makes you more conductive.
		siemens_coeff *= 1.5

	return ..(shock_damage, source, siemens_coeff, def_zone)


/mob/living/carbon/human/Topic(href, href_list)
	if (href_list["mach_close"]) // This is horrible.
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)

	if(href_list["item"])
		log_runtime(EXCEPTION("Warning: human/Topic was called with item [href_list["item"]], but the item Topic is deprecated!"))
		// handle_strip(href_list["item"],usr)

	if (href_list["criminal"])
		if(hasHUD(usr,"security"))

			var/modified = 0
			var/perpname = "wot"
			var/obj/item/card/id/I = GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name

			if(perpname)
				for (var/datum/data/record/E in GLOB.data_core.general)
					if (E.fields["name"] == perpname)
						for (var/datum/data/record/R in GLOB.data_core.security)
							if (R.fields["id"] == E.fields["id"])

								var/setcriminal = tgui_input_list(usr, "Specify a new criminal status for this person.", "Security HUD", list("None", "*Arrest*", "Incarcerated", "Parolled", "Released", "Cancel"))

								if(hasHUD(usr, "security"))
									if(setcriminal != "Cancel")
										R.fields["criminal"] = setcriminal
										modified = 1

										spawn()
											BITSET(hud_updateflag, WANTED_HUD)
											if(ishuman(usr))
												var/mob/living/carbon/human/U = usr
												U.handle_hud_list()
											if(istype(usr,/mob/living/silicon/robot))
												var/mob/living/silicon/robot/U = usr
												U.handle_regular_hud_updates()

			if(!modified)
				to_chat(usr, span_filter_notice("[span_red("Unable to locate a data core entry for this person.")]"))

	if (href_list["secrecord"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			var/obj/item/card/id/I = GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
			for (var/datum/data/record/E in GLOB.data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								var/list/security_hud_text = list()
								security_hud_text += span_bold("Name:") + " [R.fields["name"]]	" + span_bold("Criminal Status:") + " [R.fields["criminal"]]"
								security_hud_text += span_bold("Species:") + " [R.fields["species"]]"
								security_hud_text += span_bold("Minor Crimes:") + " [R.fields["mi_crim"]]"
								security_hud_text += span_bold("Details:") + " [R.fields["mi_crim_d"]]"
								security_hud_text += span_bold("Major Crimes:") + " [R.fields["ma_crim"]]"
								security_hud_text += span_bold("Details:") + " [R.fields["ma_crim_d"]]"
								security_hud_text += span_bold("Notes:") + " [R.fields["notes"]]"
								security_hud_text += "<a href='byond://?src=\ref[src];secrecordComment=`'>\[View Comment Log\]</a>"
								to_chat(usr, span_filter_notice("[jointext(security_hud_text, "<br>")]"))
								read = 1

			if(!read)
				to_chat(usr, span_filter_notice("[span_red("Unable to locate a data core entry for this person.")]"))

	if (href_list["secrecordComment"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			var/obj/item/card/id/I = GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
			for (var/datum/data/record/E in GLOB.data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, "[R.fields[text("com_[]", counter)]]")
									counter++
								if (counter == 1)
									to_chat(usr, span_filter_notice("No comment found."))
								to_chat(usr, span_filter_notice("<a href='byond://?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>"))

			if(!read)
				to_chat(usr, span_filter_notice("[span_red("Unable to locate a data core entry for this person.")]"))

	if (href_list["secrecordadd"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/obj/item/card/id/I = GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
			for (var/datum/data/record/E in GLOB.data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								var/t1 = sanitize(tgui_input_text(usr, "Add Comment:", "Sec. records", null, null, multiline = TRUE, prevent_enter = TRUE))
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"security")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(ishuman(usr))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [GLOB.game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [GLOB.game_year]<BR>[t1]")

	if (href_list["medical"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/modified = 0

			var/obj/item/card/id/I = GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name

			for (var/datum/data/record/E in GLOB.data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.data_core.general)
						if (R.fields["id"] == E.fields["id"])

							var/setmedical = tgui_input_list(usr, "Specify a new medical status for this person.", "Medical HUD", list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel"))

							if(hasHUD(usr,"medical"))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = 1
									if(GLOB.PDA_Manifest.len)
										GLOB.PDA_Manifest.Cut()

									spawn()
										if(ishuman(usr))
											var/mob/living/carbon/human/U = usr
											U.handle_regular_hud_updates()
										if(istype(usr,/mob/living/silicon/robot))
											var/mob/living/silicon/robot/U = usr
											U.handle_regular_hud_updates()

			if(!modified)
				to_chat(usr, span_filter_notice("[span_red("Unable to locate a data core entry for this person.")]"))

	if (href_list["medrecord"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			var/obj/item/card/id/I = GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
			for (var/datum/data/record/E in GLOB.data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								var/list/medical_hud_text = list()
								medical_hud_text += span_bold("Name:") + " [R.fields["name"]]	" + span_bold("Blood Type:") + " [R.fields["b_type"]]	" + span_bold("Blood Basis:") + " [R.fields["blood_reagent"]]"
								medical_hud_text += span_bold("Species:") + " [R.fields["species"]]"
								medical_hud_text += span_bold("DNA:") + " [R.fields["b_dna"]]"
								medical_hud_text += span_bold("Minor Disabilities:") + " [R.fields["mi_dis"]]"
								medical_hud_text += span_bold("Details:") + " [R.fields["mi_dis_d"]]"
								medical_hud_text += span_bold("Major Disabilities:") + " [R.fields["ma_dis"]]"
								medical_hud_text += span_bold("Details:") + " [R.fields["ma_dis_d"]]"
								medical_hud_text += span_bold("Notes:") + " [R.fields["notes"]]"
								medical_hud_text += "<a href='byond://?src=\ref[src];medrecordComment=`'>\[View Comment Log\]</a>"
								to_chat(usr, span_filter_notice("[jointext(medical_hud_text, "<br>")]"))
								read = 1

			if(!read)
				to_chat(usr, span_filter_notice("[span_red("Unable to locate a data core entry for this person.")]"))

	if (href_list["medrecordComment"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			var/obj/item/card/id/I = GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
			for (var/datum/data/record/E in GLOB.data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, "[R.fields[text("com_[]", counter)]]")
									counter++
								if (counter == 1)
									to_chat(usr, span_filter_notice("No comment found."))
								to_chat(usr, span_filter_notice("<a href='byond://?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>"))

			if(!read)
				to_chat(usr, span_filter_notice("[span_red("Unable to locate a data core entry for this person.")]"))

	if (href_list["medrecordadd"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/obj/item/card/id/I = GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
			for (var/datum/data/record/E in GLOB.data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								var/t1 = sanitize(tgui_input_text(usr, "Add Comment:", "Med. records", null, null, multiline = TRUE, prevent_enter = TRUE))
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"medical")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(ishuman(usr))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [GLOB.game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [GLOB.game_year]<BR>[t1]")

	if (href_list["emprecord"])
		if(hasHUD(usr,"best"))
			var/perpname = "wot"
			var/read = 0

			var/obj/item/card/id/I = GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
			for (var/datum/data/record/E in GLOB.data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.data_core.general)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"best"))
								var/list/emp_hud_text = list()
								emp_hud_text += span_bold("Name:") + " [R.fields["name"]]"
								emp_hud_text += span_bold("Species:") + " [R.fields["species"]]"
								emp_hud_text += span_bold("Assignment:") + " [R.fields["real_rank"]] ([R.fields["rank"]])"
								emp_hud_text += span_bold("Home System:") + " [R.fields["home_system"]]"
								emp_hud_text += span_bold("Birthplace:") + " [R.fields["birthplace"]]"
								emp_hud_text += span_bold("Citizenship:") + " [R.fields["citizenship"]]"
								emp_hud_text += span_bold("Primary Employer:") + " [R.fields["personal_faction"]]"
								emp_hud_text += span_bold("Religious Beliefs:") + " [R.fields["religion"]]"
								emp_hud_text += span_bold("Known Languages:") + " [R.fields["languages"]]"
								emp_hud_text += span_bold("Notes:") + " [R.fields["notes"]]"
								emp_hud_text += "<a href='byond://?src=\ref[src];emprecordComment=`'>\[View Comment Log\]</a>"
								to_chat(usr, span_filter_notice("[jointext(emp_hud_text, "<br>")]"))
								read = 1

			if(!read)
				to_chat(usr, span_filter_notice("[span_red("Unable to locate a data core entry for this person.")]"))

	if (href_list["emprecordComment"])
		if(hasHUD(usr,"best"))
			var/perpname = "wot"
			var/read = 0

			var/obj/item/card/id/I = GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
			for (var/datum/data/record/E in GLOB.data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.data_core.general)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"best"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, "[R.fields[text("com_[]", counter)]]")
									counter++
								if (counter == 1)
									to_chat(usr, span_filter_notice("No comment found."))
								to_chat(usr, span_filter_notice("<a href='byond://?src=\ref[src];emprecordadd=`'>\[Add comment\]</a>"))

			if(!read)
				to_chat(usr, span_filter_notice("[span_red("Unable to locate a data core entry for this person.")]"))

	if (href_list["emprecordadd"])
		if(hasHUD(usr,"best"))
			var/perpname = "wot"
			var/obj/item/card/id/I = GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
			for (var/datum/data/record/E in GLOB.data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.data_core.general)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"best"))
								var/t1 = sanitize(tgui_input_text(usr, "Add Comment:", "Emp. records", null, null, multiline = TRUE, prevent_enter = TRUE))
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"best")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(ishuman(usr))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [GLOB.game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [GLOB.game_year]<BR>[t1]")

	if (href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		src.examinate(I)

	if (href_list["lookitem_desc_only"])
		var/obj/item/I = locate(href_list["lookitem_desc_only"])
		if(!I)
			return
		usr.examinate(I, 1)

	if (href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		src.examinate(M)

	if (href_list["flavor_change"])
		switch(href_list["flavor_change"])
			if("done")
				src << browse(null, "window=flavor_changes")
				return
			if("general")
				var/msg = strip_html_simple(tgui_input_text(usr,"Update the general description of your character. This will be shown regardless of clothing.","Flavor Text",html_decode(flavor_texts[href_list["flavor_change"]]), multiline = TRUE, prevent_enter = TRUE))	//Separating out OOC notes
				if(msg)
					flavor_texts[href_list["flavor_change"]] = msg
					set_flavor()
				return
			else
				var/msg = strip_html_simple(tgui_input_text(usr,"Update the flavor text for your [href_list["flavor_change"]].","Flavor Text",html_decode(flavor_texts[href_list["flavor_change"]]), multiline = TRUE, prevent_enter = TRUE))
				if(msg)
					flavor_texts[href_list["flavor_change"]] = msg
					set_flavor()
				return
	..()
	return

///eyecheck()
///Returns a number between -1 to 2
/mob/living/carbon/human/eyecheck()

	var/obj/item/organ/internal/eyes/I

	if(internal_organs_by_name[O_EYES]) // Eyes are fucked, not a 'weak point'.
		I = internal_organs_by_name[O_EYES]
		if(I.is_broken())
			return FLASH_PROTECTION_MAJOR
	else if(!species.dispersed_eyes) // They can't be flashed if they don't have eyes, or widespread sensing surfaces.
		return FLASH_PROTECTION_MAJOR

	var/number = get_equipment_flash_protection()
	if(I)
		number = I.get_total_protection(number)
		I.additional_flash_effects(number)
	return number

/mob/living/carbon/human/flash_eyes(var/intensity = FLASH_PROTECTION_MODERATE, override_blindness_check = FALSE, affect_silicon = FALSE, visual = FALSE, type = /obj/screen/fullscreen/flash)
	if(internal_organs_by_name[O_EYES]) // Eyes are fucked, not a 'weak point'.
		var/obj/item/organ/internal/eyes/I = internal_organs_by_name[O_EYES]
		I.additional_flash_effects(intensity)
	return ..()

#define add_clothing_protection(A)	\
	var/obj/item/clothing/C = A; \
	flash_protection += C.flash_protection; \

/mob/living/carbon/human/proc/get_equipment_flash_protection()
	var/flash_protection = 0

	if(istype(src.head, /obj/item/clothing/head))
		add_clothing_protection(head)
	if(istype(src.glasses, /obj/item/clothing/glasses))
		add_clothing_protection(glasses)
	if(istype(src.wear_mask, /obj/item/clothing/mask))
		add_clothing_protection(wear_mask)

	return flash_protection

#undef add_clothing_protection

//Used by various things that knock people out by applying blunt trauma to the head.
//Checks that the species has a "head" (brain containing organ) and that hit_zone refers to it.
/mob/living/carbon/human/proc/headcheck(var/target_zone, var/brain_tag = O_BRAIN)

	var/obj/item/organ/affecting = internal_organs_by_name[brain_tag]

	target_zone = check_zone(target_zone)
	if(!affecting || affecting.parent_organ != target_zone)
		return 0

	//if the parent organ is significantly larger than the brain organ, then hitting it is not guaranteed
	var/obj/item/organ/parent = get_organ(target_zone)
	if(!parent)
		return 0

	if(parent.w_class > affecting.w_class + 1)
		return prob(100 / 2**(parent.w_class - affecting.w_class - 1))

	return 1

/mob/living/carbon/human/IsAdvancedToolUser(var/silent)
	if(get_feralness())
		to_chat(src, span_warning("Your primitive mind can't grasp the concept of that thing."))
		return 0
	if(species.has_fine_manipulation)
		return 1
	if(!silent)
		to_chat(src, span_warning("You don't have the dexterity to use that!"))
	return 0

/mob/living/carbon/human/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves)))
		return 1

	if( (src.l_hand && !src.l_hand.abstract) || (src.r_hand && !src.r_hand.abstract) )
		return 1

	return 0


/mob/living/carbon/human/proc/check_dna()
	dna.check_integrity(src)
	return

/mob/living/carbon/human/get_species()
	if(!species)
		set_species()
	return species.name

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		var/datum/gender/T = GLOB.gender_datums[get_visible_gender()]
		visible_message(span_filter_notice("[span_red("\The [src] begins playing [T.his] ribcage like a xylophone. It's quite spooky.")]"),span_notice("You begin to play a spooky refrain on your ribcage."),span_filter_notice("[span_red("You hear a spooky xylophone melody.")]"))
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(src, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/proc/check_has_mouth()
	return 1

/mob/living/carbon/human/check_has_mouth()
	// Todo, check stomach organ when implemented.
	var/obj/item/organ/external/head/H = get_organ(BP_HEAD)
	if(!H || !H.can_intake_reagents)
		return 0
	return 1

/mob/living/carbon/human/proc/morph()
	set name = "Morph"
	set category = "Superpower"

	if(stat!=CONSCIOUS)
		reset_view(0)
		remoteview_target = null
		return

	if(!(mMorph in mutations))
		remove_verb(src, /mob/living/carbon/human/proc/morph)
		return

	var/new_facial = tgui_color_picker(src, "Please select facial hair color.", "Character Generation",rgb(r_facial,g_facial,b_facial))
	if(new_facial)
		r_facial = hex2num(copytext(new_facial, 2, 4))
		g_facial = hex2num(copytext(new_facial, 4, 6))
		b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = tgui_color_picker(src, "Please select hair color.", "Character Generation",rgb(r_hair,g_hair,b_hair))
	if(new_facial)
		r_hair = hex2num(copytext(new_hair, 2, 4))
		g_hair = hex2num(copytext(new_hair, 4, 6))
		b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = tgui_color_picker(src, "Please select eye color.", "Character Generation",rgb(r_eyes,g_eyes,b_eyes))
	if(new_eyes)
		r_eyes = hex2num(copytext(new_eyes, 2, 4))
		g_eyes = hex2num(copytext(new_eyes, 4, 6))
		b_eyes = hex2num(copytext(new_eyes, 6, 8))
		update_eyes()

	// hair
	var/list/all_hairs = subtypesof(/datum/sprite_accessory/hair)
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		qdel(H) // delete the hair after it's all done

	var/new_style = tgui_input_list(src, "Please select hair style", "Character Generation", hairs)

	// if new style selected (not cancel)
	if (new_style)
		h_style = new_style

	// facial hair
	var/list/all_fhairs = subtypesof(/datum/sprite_accessory/facial_hair)
	var/list/fhairs = list()

	for(var/x in all_fhairs)
		var/datum/sprite_accessory/facial_hair/H = new x
		fhairs.Add(H.name)
		qdel(H)

	new_style = tgui_input_list(src, "Please select facial style", "Character Generation", fhairs)

	if(new_style)
		f_style = new_style

	var/new_gender = tgui_alert(src, "Please select gender.", "Character Generation", list("Male", "Female", "Neutral"))
	if (new_gender)
		if(new_gender == "Male")
			gender = MALE
		else if(new_gender == "Female")
			gender = FEMALE
		else
			gender = NEUTER
	regenerate_icons()
	check_dna()
	var/datum/gender/T = GLOB.gender_datums[get_visible_gender()]
	visible_message(span_notice("\The [src] morphs and changes [T.his] appearance!"), span_notice("You change your appearance!"), span_filter_notice("[span_red("Oh, god!  What the hell was that?  It sounded like flesh getting squished and bone ground into a different shape!")]"))

/mob/living/carbon/human/proc/remotesay()
	set name = "Project mind"
	set category = "Abilities.Superpower"

	if(stat!=CONSCIOUS)
		reset_view(0)
		remoteview_target = null
		return

	if(!(mRemotetalk in src.mutations))
		remove_verb(src, /mob/living/carbon/human/proc/remotesay)
		return
	var/list/creatures = list()
	for(var/mob/living/carbon/h in GLOB.mob_list)
		if(h == src) // Don't target self
			continue
		creatures += h
	var/mob/target = tgui_input_list(src, "Who do you want to project your mind to?", "Project Mind", creatures)
	if (isnull(target))
		return

	var/say = sanitize(tgui_input_text(src, "What do you wish to say?"))
	if(mRemotetalk in target.mutations)
		target.show_message(span_filter_say("[span_blue("You hear [src.real_name]'s voice: [say]")]"))
	else
		target.show_message(span_filter_say("[span_blue("You hear a voice that seems to echo around the room: [say]")]"))
	src.show_message(span_filter_say("[span_blue("You project your mind into [target.real_name]: [say]")]"))
	log_say("(TPATH to [key_name(target)]) [say]",src)
	for(var/mob/observer/dead/G in GLOB.mob_list)
		G.show_message(span_filter_say(span_italics("Telepathic message from " + span_bold("[src]") + " to " + span_bold("[target]") + ": [say]")))

/mob/living/carbon/human/proc/remoteobserve()
	set name = "Remote View"
	set category = "Abilities.Superpower"

	if(stat!=CONSCIOUS)
		remoteview_target = null
		reset_view(0)
		return

	if(!(mRemote in src.mutations))
		remoteview_target = null
		reset_view(0)
		remove_verb(src, /mob/living/carbon/human/proc/remoteobserve)
	if(client.eye != client.mob)
		reset_view(0)
		return

	var/list/mob/creatures = list()

	var/turf/current = get_turf(src) // Needs to be on station or same z to perform telepathy
	for(var/mob/living/carbon/h in GLOB.mob_list)
		var/turf/temp_turf = get_turf(h)
		if(!istype(temp_turf,/turf/)) // Nullcheck fix
			continue
		if(h == src) // Traitgenes edit - Don't target self
			continue
		if(!((temp_turf.z in using_map.station_levels) || current.z == temp_turf.z) || h.stat!=CONSCIOUS) // Needs to be on station or same z to perform telepathy
			continue
		creatures += h

	var/mob/target = input ("Who do you want to project your mind to?") as mob in creatures

	if (target)
		remoteview_target = target
		reset_view(target)
	else
		remoteview_target = null
		reset_view(0)

/mob/living/carbon/human/get_visible_gender(mob/user, force)
	switch(force)
		if(VISIBLE_GENDER_FORCE_PLURAL)
			return PLURAL
		if(VISIBLE_GENDER_FORCE_IDENTIFYING)
			return get_gender()
		if(VISIBLE_GENDER_FORCE_BIOLOGICAL)
			return gender
		else
			if(((wear_mask?.flags_inv & HIDEFACE) || (head?.flags_inv & HIDEMASK) || (head?.flags_inv & HIDEFACE)) && (wear_suit?.flags_inv & HIDEJUMPSUIT))
				return PLURAL
			if(species?.ambiguous_genders && user)
				if(ishuman(user))
					var/mob/living/carbon/human/human = user
					if(!istype(human.species, species))
						return PLURAL
				else if(!isobserver(user) && !issilicon(user))
					return PLURAL
			return get_gender()

/mob/living/carbon/human/proc/increase_germ_level(n)
	if(gloves)
		gloves.germ_level += n
	else
		germ_level += n

/mob/living/carbon/human/revive()

	if(should_have_organ(O_HEART))
		vessel.add_reagent(REAGENT_ID_BLOOD,species.blood_volume-vessel.total_volume)
		fixblood()

	species.create_organs(src) // Reset our organs/limbs.
	restore_all_organs()       // Reapply robotics/amputated status from preferences.

	if(!client || !key) //Don't boot out anyone already in the mob.
		for (var/obj/item/organ/internal/brain/H in GLOB.all_brain_organs)
			if(H.brainmob)
				if(H.brainmob.real_name == src.real_name)
					if(H.brainmob.mind)
						H.brainmob.mind.transfer_to(src)
						qdel(H)

	// Traitgenes Disable all traits currently active, before prefs.copy_to() is applied, as it refreshes the traits list!
	for(var/datum/gene/trait/gene in GLOB.dna_genes)
		if(gene.name in active_genes)
			gene.deactivate(src)
			active_genes -= gene.name

	// Reapply markings/appearance from prefs for player mobs
	if(client) //just to be sure
		client.prefs.copy_to(src)
		if(dna)
			dna.ResetUIFrom(src)
			sync_dna_traits(TRUE) // Traitgenes Sync traits to genetics if needed
			sync_organ_dna()
	initialize_vessel()

	losebreath = 0

	..()

/mob/living/carbon/human/proc/is_lung_ruptured()
	var/obj/item/organ/internal/lungs/L = internal_organs_by_name[O_LUNGS]
	return L && L.is_bruised()

/mob/living/carbon/human/proc/rupture_lung(var/gradual)
	var/obj/item/organ/internal/lungs/L = internal_organs_by_name[O_LUNGS]

	if(L)
		if(gradual && (L.damage < (L.min_bruised_damage-1))) //We do slow ticking damage up to 9. After 9, we rupture completely.
			L.damage++
		else
			L.rupture()

/*
/mob/living/carbon/human/verb/simulate()
	set name = "sim"
	set background = 1

	var/damage = tgui_input_number(src, "Wound damage","Wound damage")

	var/germs = 0
	var/tdamage = 0
	var/ticks = 0
	while (germs < 2501 && ticks < 100000 && round(damage/10)*20)
		log_misc("VIRUS TESTING: [ticks] : germs [germs] tdamage [tdamage] prob [round(damage/10)*20]")
		ticks++
		if (prob(round(damage/10)*20))
			germs++
		if (germs == 100)
			to_world("Reached stage 1 in [ticks] ticks")
		if (germs > 100)
			if (prob(10))
				damage++
				germs++
		if (germs == 1000)
			to_world("Reached stage 2 in [ticks] ticks")
		if (germs > 1000)
			damage++
			germs++
		if (germs == 2500)
			to_world("Reached stage 3 in [ticks] ticks")
	to_world("Mob took [tdamage] tox damage")
*/
//returns 1 if made bloody, returns 0 otherwise

/mob/living/carbon/human/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0
	//if this blood isn't already in the list, add it
	if(istype(M))
		add_blooddna(M.dna,M)
	hand_blood_color = blood_color
	update_bloodied()
	add_verb(src, /mob/living/carbon/human/proc/bloody_doodle)
	return 1 //we applied blood to the item

/mob/living/carbon/human/proc/get_full_print()
	if(!dna ||!dna.uni_identity)
		return
	return md5(dna.uni_identity)

/mob/living/carbon/human/wash(clean_types)
	. = ..()

	LAZYCLEARLIST(body_writing)

	//Always do hands (or whatever's on our hands)
	if(gloves)
		gloves.wash(clean_types)
		update_inv_gloves()
		gloves.germ_level = 0
	else
		bloody_hands = 0
		germ_level = 0

	if(shoes)
		shoes.wash(clean_types)
		update_inv_shoes()
		shoes.germ_level = 0
	else if(feet_blood_color || LAZYLEN(feet_blood_DNA))
		LAZYCLEARLIST(feet_blood_DNA)
		feet_blood_DNA = null
		feet_blood_color = null

	update_bloodied()

/mob/living/carbon/human/get_visible_implants(var/class = 0)

	var/list/visible_implants = list()
	for(var/obj/item/organ/external/organ in src.organs)
		for(var/obj/item/O in organ.implants)
			if(!istype(O,/obj/item/implant) && (O.w_class > class) && !istype(O,/obj/item/material/shard/shrapnel) && !istype(O,/obj/item/nif))
				visible_implants += O

	return(visible_implants)

/mob/living/carbon/human/embedded_needs_process()
	for(var/obj/item/organ/external/organ in src.organs)
		for(var/obj/item/O in organ.implants)
			if(!istype(O, /obj/item/implant)) //implant type items do not cause embedding effects, see handle_embedded_objects()
				return 1
	return 0

/mob/living/carbon/human/proc/handle_embedded_objects()

	for(var/obj/item/organ/external/organ in src.organs)
		if(organ.splinted) //Splints prevent movement.
			continue
		for(var/obj/item/O in organ.implants)
			if(!istype(O,/obj/item/implant) && prob(5)) //Moving with things stuck in you could be bad.
				// All kinds of embedded objects cause bleeding.
				if(!can_feel_pain(organ.organ_tag))
					to_chat(src, span_warning("You feel [O] moving inside your [organ.name]."))
				else
					var/msg = pick( \
						span_warning("A spike of pain jolts your [organ.name] as you bump [O] inside."), \
						span_warning("Your movement jostles [O] in your [organ.name] painfully."), \
						span_warning("Your movement jostles [O] in your [organ.name] painfully."))
					custom_pain(msg, 40)

				organ.take_damage(rand(1,3), 0, 0)
				if(!(organ.robotic >= ORGAN_ROBOT) && (should_have_organ(O_HEART))) //There is no blood in protheses.
					organ.status |= ORGAN_BLEEDING

/mob/living/carbon/human/verb/check_pulse()
	set category = "Object"
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if(usr.stat || usr.restrained() || !isliving(usr)) return

	var/datum/gender/TU = GLOB.gender_datums[usr.get_visible_gender()]
	var/datum/gender/T = GLOB.gender_datums[get_visible_gender()]

	if(usr == src)
		self = 1
	if(!self)
		usr.visible_message(span_notice("[usr] kneels down, puts [TU.his] hand on [src]'s wrist and begins counting [T.his] pulse."),\
		span_filter_notice("You begin counting [src]'s pulse."))
	else
		usr.visible_message(span_notice("[usr] begins counting [T.his] pulse."),\
		span_filter_notice("You begin counting your pulse."))

	if(src.pulse)
		to_chat(usr, span_notice("[self ? "You have a" : "[src] has a"] pulse! Counting..."))
	else
		to_chat(usr, span_danger("[src] has no pulse!"))	//it is REALLY UNLIKELY that a dead person would check his own pulse
		return

	to_chat(usr, span_filter_notice("You must[self ? "" : " both"] remain still until counting is finished."))
	if(do_mob(usr, src, 60))
		var/message = span_notice("[self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)].")
		to_chat(usr,message)
	else
		to_chat(usr, span_warning("You failed to check the pulse. Try again."))

/mob/living/carbon/human/proc/set_species(var/new_species)

	if(!dna)
		if(!new_species)
			new_species = SPECIES_HUMAN
	else
		if(!new_species)
			new_species = dna.species
		else
			dna.species = new_species

	// No more invisible screaming wheelchairs because of set_species() typos.
	if(!GLOB.all_species[new_species])
		new_species = SPECIES_HUMAN

	if(species)

		if(species.name && species.name == new_species && species.name != "Custom Species")
			return
		if(species.language)
			remove_language(species.language)
		if(species.default_language)
			remove_language(species.default_language)
		for(var/datum/language/L in species.assisted_langs)
			remove_language(L)
		// Clear out their species abilities.
		species.remove_inherent_verbs(src)
		holder_type = null
		hunger_rate = initial(hunger_rate)

	species = GLOB.all_species[new_species]

	if(species.language)
		add_language(species.language)

	if(species.default_language)
		add_language(species.default_language)

	if(species.icon_scale_x != DEFAULT_ICON_SCALE_X || species.icon_scale_y != DEFAULT_ICON_SCALE_Y)
		update_transform()

	if(species.base_color)
		//Apply color.
		r_skin = hex2num(copytext(species.base_color,2,4))
		g_skin = hex2num(copytext(species.base_color,4,6))
		b_skin = hex2num(copytext(species.base_color,6,8))
	else
		r_skin = 0
		g_skin = 0
		b_skin = 0

	if(species.holder_type)
		holder_type = species.holder_type

	if(!(gender in species.genders))
		gender = species.genders[1]

	//icon_state = lowertext(species.name) //Necessary?

	species.handle_post_spawn(src)

	species.create_organs(src)

	species.apply_components(src)

	maxHealth = species.total_health
	hunger_rate = species.hunger_factor

	default_pixel_x = initial(pixel_x) + species.pixel_offset_x //For giving datum/species ways to change 64x64 sprite offsets
	default_pixel_y = initial(pixel_y) + species.pixel_offset_y
	pixel_x = default_pixel_x
	pixel_y = default_pixel_y
	center_offset = species.center_offset

	if(vessel)
		initialize_vessel()

	// Rebuild the HUD. If they aren't logged in then login() should reinstantiate it for them.
	update_hud()

	//A slew of bits that may be affected by our species change
	regenerate_icons()

	if(species)
		return 1
	else
		return 0

/mob/living/carbon/human/proc/initialize_vessel() //This needs fixing. For some reason mob species is not immediately set in set_species.
	SHOULD_NOT_OVERRIDE(TRUE)
	make_blood()
	if(vessel.total_volume < species.blood_volume)
		vessel.maximum_volume = species.blood_volume
		vessel.add_reagent(REAGENT_ID_BLOOD, species.blood_volume - vessel.total_volume)
	else if(vessel.total_volume > species.blood_volume)
		vessel.remove_reagent(REAGENT_ID_BLOOD,vessel.total_volume - species.blood_volume) //This one should stay remove_reagent to work even lack of a O_heart
		vessel.maximum_volume = species.blood_volume
	fixblood()
	species.update_attack_types() //Required for any trait that updates unarmed_types in setup.
	species.update_vore_belly_def_variant()

/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC.Game"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if (src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	if (!bloody_hands)
		remove_verb(src, /mob/living/carbon/human/proc/bloody_doodle)

	if (src.gloves)
		to_chat(src, span_warning("Your [src.gloves] are getting in the way."))
		return

	var/turf/simulated/T = src.loc
	if (!istype(T)) //to prevent doodling out of mechs and lockers
		to_chat(src, span_warning("You cannot reach the floor."))
		return

	var/direction = tgui_input_list(src,"Which way?","Tile selection", list("Here","North","South","East","West"))
	if (direction != "Here")
		T = get_step(T,text2dir(direction))
	if (!istype(T))
		to_chat(src, span_warning("You cannot doodle there."))
		return

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, span_warning("There is no space to write on!"))
		return

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = sanitize(tgui_input_text(src, "Write a message. It cannot be longer than [max_length] characters.","Blood writing", ""))

	if (message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if (length(message) > max_length)
			message += "-"
			to_chat(src, span_warning("You ran out of blood to write with!"))

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.basecolor = (hand_blood_color) ? hand_blood_color : "#A10808"
		W.update_icon()
		W.message = message
		W.add_fingerprint(src)

/mob/living/carbon/human/can_inject(var/mob/user, var/error_msg, var/target_zone, var/ignore_thickness = FALSE)
	. = 1

	if(!target_zone)
		if(!user)
			target_zone = pick(BP_TORSO,BP_TORSO,BP_TORSO,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_HEAD)
		else
			target_zone = user.zone_sel.selecting

	var/obj/item/organ/external/affecting = get_organ(target_zone)
	var/fail_msg
	if(!affecting)
		. = 0
		fail_msg = "They are missing that limb."
	else if (affecting.robotic == ORGAN_ROBOT)
		. = 0
		fail_msg = "That limb is robotic."
	else if (affecting.robotic >= ORGAN_LIFELIKE)
		. = 0
		fail_msg = "Your needle refuses to penetrate more than a short distance..."
	else if ((species.flags & THICK_SKIN) && prob(70 - round(affecting.brute_dam + affecting.burn_dam / 2)))	// Allows transplanted limbs with thick skin to maintain their resistance.
		. = 0
		fail_msg = "Your needle fails to penetrate \the [affecting]'s thick hide..."
	else
		switch(target_zone)
			if(BP_HEAD)
				if(head && (head.item_flags & THICKMATERIAL) && !ignore_thickness)
					. = 0
			else
				if(wear_suit && (wear_suit.item_flags & THICKMATERIAL) && !ignore_thickness)
					. = 0
	if(!. && error_msg && user)
		if(!fail_msg)
			fail_msg = "There is no exposed flesh or thin material [target_zone == BP_HEAD ? "on their head" : "on their body"] to inject into."
		to_chat(user, span_warning("[fail_msg]"))

/mob/living/carbon/human/print_flavor_text(var/shrink = 1)
	var/list/equipment = list(src.head,src.wear_mask,src.glasses,src.w_uniform,src.wear_suit,src.gloves,src.shoes)
	var/head_exposed = 1
	var/face_exposed = 1
	var/eyes_exposed = 1
	var/torso_exposed = 1
	var/arms_exposed = 1
	var/legs_exposed = 1
	var/hands_exposed = 1
	var/feet_exposed = 1

	for(var/obj/item/clothing/C in equipment)
		if(C.body_parts_covered & HEAD)
			head_exposed = 0
		if(C.body_parts_covered & FACE)
			face_exposed = 0
		if(C.body_parts_covered & EYES)
			eyes_exposed = 0
		if(C.body_parts_covered & UPPER_TORSO)
			torso_exposed = 0
		if(C.body_parts_covered & ARMS)
			arms_exposed = 0
		if(C.body_parts_covered & HANDS)
			hands_exposed = 0
		if(C.body_parts_covered & LEGS)
			legs_exposed = 0
		if(C.body_parts_covered & FEET)
			feet_exposed = 0

	flavor_text = ""
	for (var/T in flavor_texts)
		if(flavor_texts[T] && flavor_texts[T] != "")
			if((T == "general") || (T == "head" && head_exposed) || (T == "face" && face_exposed) || (T == "eyes" && eyes_exposed) || (T == "torso" && torso_exposed) || (T == "arms" && arms_exposed) || (T == "hands" && hands_exposed) || (T == "legs" && legs_exposed) || (T == "feet" && feet_exposed))
				flavor_text += flavor_texts[T]
				flavor_text += "\n\n"
	if(!shrink)
		return flavor_text
	else
		return ..()

/mob/living/carbon/human/has_brain()
	if(internal_organs_by_name[O_BRAIN])
		var/obj/item/organ/brain = internal_organs_by_name[O_BRAIN]
		if(brain && istype(brain))
			return 1
	return 0

/mob/living/carbon/human/has_eyes()
	if(internal_organs_by_name[O_EYES])
		var/obj/item/organ/eyes = internal_organs_by_name[O_EYES]
		if(eyes && istype(eyes) && !(eyes.status & ORGAN_CUT_AWAY))
			return 1
	return 0

/mob/living/carbon/human/slip(var/slipped_on, stun_duration=8)
	var/list/equipment = list(src.w_uniform,src.wear_suit,src.shoes)
	var/footcoverage_check = FALSE
	for(var/obj/item/clothing/C in equipment)
		if(C.body_parts_covered & FEET)
			footcoverage_check = TRUE
			break
	if(lying)
		playsound(src, 'sound/misc/slip.ogg', 25, 1, -1)
		drop_both_hands()
		return 0
	if((species.flags & NO_SLIP && !footcoverage_check) || (shoes && (shoes.item_flags & NOSLIP))) //Footwear negates a species' natural traction.
		return 0
	if(..(slipped_on,stun_duration))
		drop_both_hands()
		return 1

/mob/living/carbon/human/proc/relocate()
	set category = "Object"
	set name = "Relocate Joint"
	set desc = "Pop a joint back into place. Extremely painful."
	set src in view(1)

	if(!isliving(usr) || !usr.checkClickCooldown())
		return

	usr.setClickCooldown(20)

	if(usr.stat > 0)
		to_chat(usr, span_filter_notice("You are unconcious and cannot do that!"))
		return

	if(usr.restrained())
		to_chat(usr, span_filter_notice("You are restrained and cannot do that!"))
		return

	var/mob/S = src
	var/mob/U = usr
	var/self = null
	if(S == U)
		self = 1 // Removing object from yourself.

	var/list/limbs = list()
	for(var/limb in organs_by_name)
		var/obj/item/organ/external/current_limb = organs_by_name[limb]
		if(current_limb && current_limb.dislocated > 0 && !current_limb.is_parent_dislocated()) //if the parent is also dislocated you will have to relocate that first
			limbs |= current_limb
	var/obj/item/organ/external/current_limb = tgui_input_list(usr, "Which joint do you wish to relocate?", "Joint Choice", limbs)

	if(!current_limb)
		return

	if(self)
		to_chat(src, span_warning("You brace yourself to relocate your [current_limb.joint]..."))
	else
		to_chat(U, span_warning("You begin to relocate [S]'s [current_limb.joint]..."))

	if(!do_after(U, 30))
		return
	if(!current_limb || !S || !U)
		return

	if(self)
		to_chat(src, span_danger("You pop your [current_limb.joint] back in!"))
	else
		to_chat(U, span_danger("You pop [S]'s [current_limb.joint] back in!"))
		to_chat(S, span_danger("[U] pops your [current_limb.joint] back in!"))
	current_limb.relocate()

/mob/living/carbon/human/drop_from_inventory(var/obj/item/W, var/atom/target = null)
	if(W in organs)
		return FALSE
	if(isnull(target) && istype( src.loc,/obj/structure/disposalholder))
		return remove_from_mob(W, src.loc)
	return ..()

/mob/living/carbon/human/reset_view(atom/A, update_hud = 1)
	..()
	if(update_hud)
		handle_regular_hud_updates()

/mob/living/carbon/human/Check_Shoegrip()
	if(shoes && (shoes.item_flags & NOSLIP) && istype(shoes, /obj/item/clothing/shoes/magboots))  //magboots + dense_object = no floating
		return 1
	if(flying) // Checks to see if they have wings and are flying.
		return 1
	return 0

//Puts the item into our active hand if possible. returns 1 on success.
/mob/living/carbon/human/put_in_active_hand(var/obj/item/W)
	return (hand ? put_in_l_hand(W) : put_in_r_hand(W))

//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/living/carbon/human/put_in_inactive_hand(var/obj/item/W)
	return (hand ? put_in_r_hand(W) : put_in_l_hand(W))

/mob/living/carbon/human/put_in_hands(var/obj/item/W)
	if(!W)
		return 0
	if(put_in_active_hand(W))
		update_inv_l_hand()
		update_inv_r_hand()
		return 1
	else if(put_in_inactive_hand(W))
		update_inv_l_hand()
		update_inv_r_hand()
		return 1
	else
		return ..()

/mob/living/carbon/human/put_in_l_hand(var/obj/item/W)
	if(!..() || l_hand)
		return 0
	W.forceMove(src)
	l_hand = W
	W.equipped(src,slot_l_hand)
	W.add_fingerprint(src)
	update_inv_l_hand()
	return 1

/mob/living/carbon/human/put_in_r_hand(var/obj/item/W)
	if(!..() || r_hand)
		return 0
	W.forceMove(src)
	r_hand = W
	W.equipped(src,slot_r_hand)
	W.add_fingerprint(src)
	update_inv_r_hand()
	return 1

/mob/living/carbon/human/can_stand_overridden()
	if(wearing_rig && wearing_rig.ai_can_move_suit(check_for_ai = 1))
		// Actually missing a leg will screw you up. Everything else can be compensated for.
		for(var/limbcheck in list(BP_L_LEG,BP_R_LEG))
			var/obj/item/organ/affecting = get_organ(limbcheck)
			if(!affecting)
				return 0
		return 1
	return 0

/mob/living/carbon/human/verb/toggle_underwear()
	set name = "Toggle Underwear"
	set desc = "Shows/hides selected parts of your underwear."
	set category = "Object"

	if(stat) return
	var/datum/category_group/underwear/UWC = tgui_input_list(usr, "Choose underwear:", "Show/hide underwear", global_underwear.categories)
	if(!UWC) return
	var/datum/category_item/underwear/UWI = all_underwear[UWC.name]
	if(!UWI || UWI.name == "None")
		to_chat(src, span_notice("You do not have [UWC.gender==PLURAL ? "[UWC.display_name]" : "a [UWC.display_name]"]."))
		return
	hide_underwear[UWC.name] = !hide_underwear[UWC.name]
	update_underwear(1)
	to_chat(src, span_notice("You [hide_underwear[UWC.name] ? "take off" : "put on"] your [UWC.display_name]."))
	return

/mob/living/carbon/human/verb/pull_punches()
	set name = "Pull Punches"
	set desc = "Try not to hurt them."
	set category = "IC.Game"

	if(stat) return
	pulling_punches = !pulling_punches
	to_chat(src, span_notice("You are now [pulling_punches ? "pulling your punches" : "not pulling your punches"]."))
	return

/mob/living/carbon/human/should_have_organ(var/organ_check)

	var/obj/item/organ/external/affecting
	if(organ_check in list(O_HEART, O_LUNGS))
		affecting = organs_by_name[BP_TORSO]
	else if(organ_check in list(O_LIVER, O_KIDNEYS))
		affecting = organs_by_name[BP_GROIN]

	if(affecting && (affecting.robotic >= ORGAN_ROBOT))
		return 0
	return (species && species.has_organ[organ_check])

/// Checks our organs and sees if we are missing anything vital, or if it is too heavily damaged
/// Returns two values:
/// FALSE if all our vital organs are intact
/// Or the name of the organ if we are missing a vital organ / it is damaged beyond repair.
/mob/living/carbon/human/proc/check_vital_organs()
	for(var/organ_tag in species.has_organ)
		var/obj/item/organ/O = species.has_organ[organ_tag]
		var/name = initial(O.name)
		var/vital = initial(O.vital) //check for vital organs
		if(vital)
			O = internal_organs_by_name[organ_tag]
			if(!O)
				return name
			if(O.damage > O.max_damage)
				return name
	return FALSE

/mob/living/carbon/human/can_feel_pain(var/obj/item/organ/check_organ)
	if(isSynthetic())
		return 0
	if(!digest_pain && (isbelly(src.loc) || istype(src.loc, /turf/simulated/floor/water/digestive_enzymes)))
		var/obj/belly/b = src.loc
		if(b.digest_mode == DM_DIGEST || b.digest_mode == DM_SELECT)
			return FALSE
	for(var/datum/modifier/M in modifiers)
		if(M.pain_immunity == TRUE)
			return 0
	if(check_organ)
		if(!istype(check_organ))
			return 0
		return check_organ.organ_can_feel_pain()
	return !(species.flags & NO_PAIN)

/mob/living/carbon/human/is_sentient()
	if(get_FBP_type() == FBP_DRONE)
		return FALSE
	return ..()

/mob/living/carbon/human/is_muzzled()
	return (wear_mask && (istype(wear_mask, /obj/item/clothing/mask/muzzle) || istype(src.wear_mask, /obj/item/grenade)))

/mob/living/carbon/human/get_fire_icon_state()
	return species.fire_icon_state

// Called by job_controller.  Makes drones start with a permit, might be useful for other people later too.
/mob/living/carbon/human/equip_post_job()
	var/braintype = get_FBP_type()
	if(braintype == FBP_DRONE)
		var/turf/T = get_turf(src)
		var/obj/item/clothing/accessory/permit/drone/permit = new(T)
		permit.set_name(real_name)
		equip_to_appropriate_slot(permit) // If for some reason it can't find room, it'll still be on the floor.

/mob/living/carbon/human/proc/update_icon_special() //For things such as teshari hiding and whatnot.
	if(status_flags & HIDING) // Hiding? Carry on.
		if(stat == DEAD || paralysis || weakened || stunned || restrained() || buckled || LAZYLEN(grabbed_by) || has_buckled_mobs()) //stunned/knocked down by something that isn't the rest verb? Note: This was tried with INCAPACITATION_STUNNED, but that refused to work. //VORE EDIT: Check for has_buckled_mobs() (taur riding)
			reveal(null)
		else
			layer = HIDING_LAYER

/mob/living/carbon/human/examine_icon()
	var/icon/I = get_cached_examine_icon(src)
	if(!I)
		I = getFlatIcon(src, defdir = SOUTH, no_anim = TRUE, force_south = TRUE)
		set_cached_examine_icon(src, I, 50 SECONDS)
	return I

/mob/living/carbon/human/proc/get_display_species()
	//Shows species in tooltip
	if(src.custom_species)
		return custom_species
	//Beepboops get special text if obviously beepboop
	if(looksSynthetic())
		if(gender == MALE)
			return "Android"
		else if(gender == FEMALE)
			return "Gynoid"
		else
			return "Synthetic"
	//Else species name
	if(species)
		return species.get_examine_name()
	//Else CRITICAL FAILURE!
	return ""

/mob/living/carbon/human/get_nametag_name(mob/user)
	return name //Could do fancy stuff here?

/mob/living/carbon/human/get_nametag_desc(mob/user)
	var/msg = ""
	if(hasHUD(user,"security"))
		//Try to find their name
		var/perpname
		var/obj/item/card/id/I = GetIdCard()
		if(I)
			perpname = I.registered_name
		else
			perpname = name
		//Try to find their record
		var/criminal = "None"
		if(perpname)
			var/datum/data/record/G = find_general_record("name", perpname)
			if(G)
				var/datum/data/record/S = find_security_record("id", G.fields["id"])
				if(S)
					criminal = S.fields["criminal"]
		//If it's interesting, append
		if(criminal != "None")
			msg += "([criminal]) "

	if(hasHUD(user,"medical"))
		msg += "(Health: [round((health/getMaxHealth())*100)]%) "

	msg += get_display_species()
	return msg

/mob/living/carbon/human/reduce_cuff_time()
	if(istype(gloves, /obj/item/clothing/gloves/gauntlets/rig))
		return 2
	return ..()

/mob/living/carbon/human/pull_damage()
	if(((health - halloss) <= CONFIG_GET(number/health_threshold_softcrit)))
		for(var/name in organs_by_name)
			var/obj/item/organ/external/e = organs_by_name[name]
			if(!e)
				continue
			if((e.status & ORGAN_BROKEN && (!e.splinted || ((e.splinted in e.contents) && prob(30))) || e.status & ORGAN_BLEEDING) && (getBruteLoss() + getFireLoss() >= 100))
				return 1
	else
		return ..()

// Drag damage is handled in a parent
/mob/living/carbon/human/dragged(var/mob/living/dragger, var/oldloc)
	var/area/A = get_area(src)
	if(lying && !buckled && A.get_gravity() && prob(getBruteLoss() * 200 / maxHealth))
		var/bloodtrail = 1
		if(species?.flags & NO_BLOOD)
			bloodtrail = 0
		else
			var/blood_volume = vessel.get_reagent_amount(REAGENT_ID_BLOOD)
			if(blood_volume < species?.blood_volume*species?.blood_level_fatal)
				bloodtrail = 0	//Most of it's gone already, just leave it be
			else
				remove_blood(1)
		if(bloodtrail)
			if(istype(loc, /turf/simulated))
				var/turf/T = loc
				T.add_blood(src)
	. = ..()

// Tries to turn off item-based things that let you see through walls, like mesons.
// Certain stuff like genetic xray vision is allowed to be kept on.
/mob/living/carbon/human/disable_spoiler_vision()
	// Glasses.
	if(istype(glasses, /obj/item/clothing/glasses))
		var/obj/item/clothing/glasses/goggles = glasses
		if(goggles.active && (goggles.vision_flags & (SEE_TURFS|SEE_OBJS)))
			goggles.toggle_active(src)
			to_chat(src, span_warning("Your [goggles.name] have suddenly turned off!"))

	// RIGs.
	var/obj/item/rig/rig = get_rig()
	if(istype(rig) && rig.visor?.active && rig.visor.vision?.glasses)
		var/obj/item/clothing/glasses/rig_goggles = rig.visor.vision.glasses
		if(rig_goggles.vision_flags & (SEE_TURFS|SEE_OBJS))
			rig.visor.deactivate()
			to_chat(src, span_warning("\The [rig]'s visor has shuddenly deactivated!"))

/mob/living/carbon/human/get_mob_riding_slots()
	return list(back, head, wear_suit)

/mob/living/carbon/human/verb/flip_lying()
	set name = "Flip Resting Direction"
	set category = "Abilities.General"
	set desc = "Switch your horizontal direction while prone."

	if(stat || paralysis || weakened || stunned || world.time < last_special)
		to_chat(src, span_warning("You can't do that in your current state."))
		return

	if(isnull(rest_dir))
		rest_dir = FALSE
	rest_dir = !rest_dir
	update_transform(TRUE)

/mob/living/carbon/human/get_digestion_nutrition_modifier()
	return species.digestion_nutrition_modifier

/mob/living/carbon/human/get_digestion_efficiency_modifier()
	return species.digestion_efficiency

/mob/living/carbon/human/verb/hide_headset()
	set name = "Show/Hide Headset"
	set category = "IC.Settings"
	set desc = "Toggle headset worn icon visibility."
	hide_headset = !hide_headset
	update_inv_ears()

/mob/living/carbon/human/verb/hide_glasses()
	set name = "Show/Hide Glasses"
	set category = "IC.Settings"
	set desc = "Toggle glasses worn icon visibility."
	hide_glasses = !hide_glasses
	update_inv_glasses()

///mob/living/carbon/human/vv_edit_var(var_name, var_value)
//	if(var_name == NAMEOF(src, mob_height))
//		// you wanna edit this one not that one
//		var_name = NAMEOF(src, base_mob_height)
//	. = ..()
//	if(!.)
//		return .
//	if(var_name == NAMEOF(src, base_mob_height))
//		update_mob_height()

/mob/living/carbon/human/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	//VV_DROPDOWN_OPTION(VV_HK_COPY_OUTFIT, "Copy Outfit")
	//VV_DROPDOWN_OPTION(VV_HK_MOD_MUTATIONS, "Add/Remove Mutation")
	//VV_DROPDOWN_OPTION(VV_HK_MOD_QUIRKS, "Add/Remove Quirks")
	VV_DROPDOWN_OPTION(VV_HK_SET_SPECIES, "Set Species")
	VV_DROPDOWN_OPTION(VV_HK_TURN_MONKEY, "Make Monkey")
	VV_DROPDOWN_OPTION(VV_HK_TURN_ALIEN, "Make Alien")
	VV_DROPDOWN_OPTION(VK_HK_TURN_SKELETON, "Make Skeleton")
	VV_DROPDOWN_OPTION(VK_HK_TURN_AI, "Make AI")
	VV_DROPDOWN_OPTION(VK_HK_TURN_ROBOT, "Make Robot")

	//VV_DROPDOWN_OPTION(VV_HK_PURRBATION, "Toggle Purrbation")
	//VV_DROPDOWN_OPTION(VV_HK_APPLY_DNA_INFUSION, "Apply DNA Infusion")
	//VV_DROPDOWN_OPTION(VV_HK_TURN_INTO_MMI, "Turn into MMI")

/mob/living/carbon/human/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	/*
	if(href_list[VV_HK_COPY_OUTFIT])
		if(!check_rights(R_SPAWN))
			return
		copy_outfit()

	if(href_list[VV_HK_MOD_MUTATIONS])
		if(!check_rights(R_SPAWN))
			return
		var/list/options = list("Clear"="Clear")
		for(var/x in subtypesof(/datum/mutation))
			var/datum/mutation/mut = x
			var/name = initial(mut.name)
			options[dna.check_mutation(mut) ? "[name] (Remove)" : "[name] (Add)"] = mut
		var/result = tgui_input_list(usr, "Choose mutation to add/remove","Mutation Mod", sort_list(options))
		if(result)
			if(result == "Clear")
				for(var/datum/mutation/mutation as anything in dna.mutations)
					dna.remove_mutation(mutation, mutation.sources)
			else
				var/mut = options[result]
				if(dna.check_mutation(mut))
					var/datum/mutation/mutation = dna.get_mutation(mut)
					dna.remove_mutation(mut, mutation.sources)
				else
					dna.add_mutation(mut, MUTATION_SOURCE_VV)

	if(href_list[VV_HK_MOD_QUIRKS])
		if(!check_rights(R_SPAWN))
			return
		var/list/options = list("Clear"="Clear")
		for(var/type in subtypesof(/datum/quirk))
			var/datum/quirk/quirk_type = type
			if(initial(quirk_type.abstract_parent_type) == type)
				continue
			var/qname = initial(quirk_type.name)
			options[has_quirk(quirk_type) ? "[qname] (Remove)" : "[qname] (Add)"] = quirk_type
		var/result = tgui_input_list(usr, "Choose quirk to add/remove","Quirk Mod", sort_list(options))
		if(result)
			if(result == "Clear")
				for(var/datum/quirk/q in quirks)
					remove_quirk(q.type)
			else
				var/T = options[result]
				if(has_quirk(T))
					remove_quirk(T)
				else
					add_quirk(T)
	*/

	if(href_list[VV_HK_SET_SPECIES])
		if(!check_rights(R_SPAWN))
			return
		var/result = tgui_input_list(usr, "Please choose a new species", "Species", sortTim(GLOB.all_species, GLOBAL_PROC_REF(cmp_text_asc)))
		if(result)
			var/newtype = GLOB.all_species[result]
			admin_ticket_log("[key_name_admin(usr)] has modified the bodyparts of [src] to [result]")
			set_species(newtype)

	if(href_list[VV_HK_TURN_MONKEY])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = src
		if(!istype(H))
			to_chat(src, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(tgui_alert(src, "Confirm mob type change?","Confirm", list("Transform", "Cancel")) != "Transform")
			return
		if(!H)
			to_chat(src, "Mob doesn't exist anymore")
			return

		log_admin("[key_name(usr)] attempting to monkeyize [key_name(H)]")
		message_admins(span_blue("[key_name_admin(usr)] attempting to monkeyize [key_name_admin(H)]"), 1)
		H.monkeyize()

	if(href_list[VV_HK_TURN_ALIEN])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = src
		if(!istype(H))
			to_chat(src, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(tgui_alert(src, "Confirm mob type change?","Confirm",list("Transform", "Cancel")) != "Transform")
			return
		if(!H)
			to_chat(src, "Mob doesn't exist anymore")
			return

		usr.client.cmd_admin_alienize(H)

	if(href_list[VK_HK_TURN_SKELETON])
		if(!check_rights(R_FUN))
			return

		var/mob/living/carbon/human/H = src
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		H.ChangeToSkeleton()
		href_list[VV_HK_DATUM_REFRESH] = "\ref[src]"


	if(href_list[VK_HK_TURN_AI])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = src
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(tgui_alert(usr, "Confirm mob type change?", "Confirm", list("Transform", "Cancel")) != "Transform")
			return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		message_admins(span_red("Admin [key_name_admin(usr)] AIized [key_name_admin(H)]!"), 1)
		log_admin("[key_name(usr)] AIized [key_name(H)]")
		H.AIize()

	if(href_list[VK_HK_TURN_ROBOT])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = src
		if(!istype(H))
			to_chat(src, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(tgui_alert(src, "Confirm mob type change?", "Confirm", list("Transform", "Cancel")) != "Transform")	return
		if(!H)
			to_chat(src, "Mob doesn't exist anymore")
			return

		usr.client.cmd_admin_robotize(H)

	/*
	if(href_list[VV_HK_PURRBATION])
		if(!check_rights(R_SPAWN))
			return
		if(!ishuman(src))
			to_chat(usr, "This can only be done to human species at the moment.")
			return
		var/success = purrbation_toggle(src)
		if(success)
			to_chat(usr, "Put [src] on purrbation.")
			log_admin("[key_name(usr)] has put [key_name(src)] on purrbation.")
			var/msg = span_notice("[key_name_admin(usr)] has put [key_name(src)] on purrbation.")
			message_admins(msg)
			admin_ticket_log(src, msg)
		else
			to_chat(usr, "Removed [src] from purrbation.")
			log_admin("[key_name(usr)] has removed [key_name(src)] from purrbation.")
			var/msg = span_notice("[key_name_admin(usr)] has removed [key_name(src)] from purrbation.")
			message_admins(msg)
			admin_ticket_log(src, msg)

	if(href_list[VV_HK_APPLY_DNA_INFUSION])
		if(!check_rights(R_SPAWN))
			return
		if(!ishuman(src))
			to_chat(usr, "This can only be done to human species.")
			return
		var/result = usr.client.grant_dna_infusion(src)
		if(result)
			to_chat(usr, "Successfully applied DNA Infusion [result] to [src].")
			log_admin("[key_name(usr)] has applied DNA Infusion [result] to [key_name(src)].")
		else
			to_chat(usr, "Failed to apply DNA Infusion to [src].")
			log_admin("[key_name(usr)] failed to apply a DNA Infusion to [key_name(src)].")

	if(href_list[VV_HK_TURN_INTO_MMI])
		if(!check_rights(R_DEBUG))
			return

		var/result = tgui_alert(usr, "This will delete the mob, are you sure?", "Turn into MMI", list("Yes", "No"))
		if(result != "Yes")
			return

		var/obj/item/organ/brain/target_brain = get_organ_slot(ORGAN_SLOT_BRAIN)

		if(isnull(target_brain))
			to_chat(usr, "This mob has no brain to insert into an MMI.")
			return

		var/obj/item/mmi/new_mmi = new(get_turf(src))

		target_brain.Remove(src)
		new_mmi.force_brain_into(target_brain)

		to_chat(usr, "Turned [src] into an MMI.")
		log_admin("[key_name(usr)] turned [key_name_and_tag(src)] into an MMI.")

		qdel(src)
	*/
