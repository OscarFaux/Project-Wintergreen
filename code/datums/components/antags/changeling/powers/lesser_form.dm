/datum/power/changeling/lesser_form
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser.  We become a monkey."
	genomecost = 1
	verbpath = /mob/proc/changeling_lesser_form

//Transform into a monkey.
/mob/proc/changeling_lesser_form()
	set category = "Changeling"
	set name = "Lesser Form (1)"

	var/datum/component/antag/changeling/changeling = changeling_power(1,0,0)
	if(!changeling)
		return

	if(has_brain_worms())
		to_chat(src, span_warning("We cannot perform this ability at the present time!"))
		return

	var/mob/living/carbon/human/H = src

	if(!istype(H))
		to_chat(src, span_warning("We must be a humanoid to use thia bility!!"))
		return

	else if(!H.species.primitive_form)
		to_chat(src, span_warning("The species we are currently in the form of does not have a primitive form!"))
		to_chat(src, span_info("NOTE: Species such as Unathi, Tajaran, Akula, and Human have primitive forms. Things such as custom species do not.")) //Let's add a warning...Ideally, we change primitive form to be based off body style, but we still run into the problem of some speices not having them.
		return

	changeling.chem_charges--
	H.remove_changeling_powers()
	H.visible_message(span_warning("[H] transforms!"))
	changeling.geneticdamage = 30
	to_chat(H, span_warning("Our genes cry out!"))
	var/list/implants = list() //Try to preserve implants.
	for(var/obj/item/implant/W in H)
		implants += W
	H.monkeyize()
	feedback_add_details("changeling_powers","LF")
	return 1

//Transform into a human
/mob/proc/changeling_lesser_transform()
	set category = "Changeling"
	set name = "Transform (1)"

	var/datum/component/antag/changeling/changeling = changeling_power(1,1,0)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = tgui_input_list(src, "Select the target DNA:", "Target DNA", names)
	if(!S)
		return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	var/mob/living/carbon/C = src

	changeling.chem_charges--
	C.remove_changeling_powers()
	C.visible_message(span_warning("[C] transforms!"))
	qdel_swap(C.dna, chosen_dna.Clone())

	var/list/implants = list()
	for (var/obj/item/implant/I in C) //Still preserving implants
		implants += I

	C.transforming = 1
	C.canmove = 0
	C.icon = null
	C.cut_overlays()
	C.invisibility = INVISIBILITY_ABSTRACT
	var/atom/movable/overlay/animation = new /atom/movable/overlay( C.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("monkey2h", animation)
	sleep(48)
	qdel(animation)

	for(var/obj/item/W in src)
		C.drop_from_inventory(W)

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )
	if (C.dna.GetUIState(DNA_UI_GENDER))
		O.gender = FEMALE
	else
		O.gender = MALE
	qdel_swap(O.dna, C.dna.Clone())
	QDEL_NULL(C.dna)
	O.real_name = chosen_dna.real_name

	for(var/obj/T in C)
		qdel(T)

	O.loc = C.loc

	O.UpdateAppearance()
	domutcheck(O, null)
	O.setToxLoss(C.getToxLoss())
	O.adjustBruteLoss(C.getBruteLoss())
	O.setOxyLoss(C.getOxyLoss())
	O.adjustFireLoss(C.getFireLoss())
	O.set_stat(C.stat)
	for (var/obj/item/implant/I in implants)
		I.loc = O
		I.implanted = O

	C.mind.transfer_to(O)
	O.make_changeling()
	O.changeling_update_languages(changeling.absorbed_languages)

	feedback_add_details("changeling_powers","LFT")
	qdel(C)
	return 1
