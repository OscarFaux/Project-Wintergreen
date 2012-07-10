/mob/living/carbon/human/gib()
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src

	flick("gibbed-h", animation)
	hgibs(loc, viruses, dna)

	spawn(15)
		if(animation)	del(animation)
		if(src)			del(src)

/mob/living/carbon/human/dust()
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src

	flick("dust-h", animation)
	new /obj/effect/decal/remains/human(loc)

	spawn(15)
		if(animation)	del(animation)
		if(src)			del(src)


/mob/living/carbon/human/death(gibbed)

	if(halloss > 0 && (!gibbed))
		halloss = 0
		return

	if(src.stat == 2)
		return

	if(src.healths)
		src.healths.icon_state = "health5"

	src.stat = 2
	src.dizziness = 0
	src.jitteriness = 0

	tension_master.death(src)

	if (!gibbed)
		emote("deathgasp") //let the world KNOW WE ARE DEAD

		//For ninjas exploding when they die./N
		if (istype(wear_suit, /obj/item/clothing/suit/space/space_ninja)&&wear_suit:s_initialized)
			src << browse(null, "window=spideros")//Just in case.
			var/location = loc
			explosion(location, 1, 2, 3, 4)

		canmove = 0
		if(src.client)
			src.blind.layer = 0
		lying = 1
		var/h = src.hand
		hand = 0
		drop_item()
		hand = 1
		drop_item()
		hand = h
		//This is where the suicide assemblies checks would go

		if (client)
			//world <<"Woo, there's a client!"
			spawn(10)
				if(client && src.stat == 2)
					//world <<"You're sooooooo dead, let's ghost!"
					client.verbs += /client/proc/ghost

	tod = worldtime2text() //weasellos time of death patch
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)
	sql_report_death(src)

	//Calls the rounds wincheck, mainly for wizard, malf, and changeling now
	ticker.mode.check_win()
	//Traitor's dead! Oh no!
	/* --Admins do not need to know when people die. This was a relic of the singletraitor times where a traitor dying meant there were no antagonists left ~Erro
	if (ticker.mode.name == "traitor" && src.mind && src.mind.special_role == "traitor")
		message_admins("\red Traitor [key_name_admin(src)] has died.")
		log_game("Traitor [key_name(src)] has died.")
	*/
	return ..(gibbed)

/mob/living/carbon/human/proc/ChangeToHusk()
	if(HUSK in src.mutations)
		return
	mutations.Add(HUSK)
	real_name = "Unknown"
	update_body(0)
	update_mutantrace()
	return

/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	mutations.Add(NOCLONE)
	return