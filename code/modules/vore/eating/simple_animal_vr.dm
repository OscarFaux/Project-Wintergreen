///////////////////// Simple Animal /////////////////////
/mob/living/simple_animal
	var/swallowTime = 30 				//How long it takes to eat its prey in 1/10 of a second. The default is 3 seconds.
	var/list/prey_excludes = list()		//For excluding people from being eaten.

//
// Simple nom proc for if you get ckey'd into a simple_animal mob! Avoids grabs.
//
/mob/living/simple_animal/proc/animal_nom(var/mob/living/T in living_mobs(1))
	set name = "Animal Nom"
	set category = "IC"
	set desc = "Since you can't grab, you get a verb!"

	if (stat != CONSCIOUS)
		return
	if (istype(src,/mob/living/simple_animal/mouse) && T.ckey == null)
		return
	if (client && IsAdvancedToolUser())
		to_chat(src,"<span class='warning'>Put your hands to good use instead!</span>")
		return
	feed_grabbed_to_self(src,T)
	update_icon()
	return

//
// Simple proc for animals to have their digestion toggled on/off externally
//
/mob/living/simple_animal/verb/toggle_digestion()
	set name = "Toggle Animal's Digestion"
	set desc = "Enables digestion on this mob for 20 minutes."
	set category = "OOC"
	set src in oview(1)

	var/mob/living/carbon/human/user = usr
	if(!istype(user) || user.stat) return

	var/datum/belly/B = vore_organs[vore_selected]
	if(retaliate || (hostile && faction != user.faction))
		user << "<span class='warning'>This predator isn't friendly, and doesn't give a shit about your opinions of it digesting you.</span>"
		return
	if(B.digest_mode == "Hold")
		var/confirm = alert(user, "Enabling digestion on [name] will cause it to digest all stomach contents. Using this to break OOC prefs is against the rules. Digestion will reset after 20 minutes.", "Enabling [name]'s Digestion", "Enable", "Cancel")
		if(confirm == "Enable")
			B.digest_mode = "Digest"
			spawn(12000) //12000=20 minutes
				if(src)	B.digest_mode = vore_default_mode
	else
		var/confirm = alert(user, "This mob is currently set to process all stomach contents. Do you want to disable this?", "Disabling [name]'s Digestion", "Disable", "Cancel")
		if(confirm == "Disable")
			B.digest_mode = "Hold"

/mob/living/simple_animal/proc/away_from_players()
	//Reduces the amount of logging spam by only allowing procs to continue if they have a player nearby to listen.
	//A return of 0 means that it is not away from players.
	// This is a stripped down version of the proc get_mobs_and_objs_in_view_fast()
	var/turf/T = get_turf(src)
	if(!T) return 1 // If the turf doesn't exist, we don't want the proc running regardless

	// Quickly grabs the mob's hearing range to check from
	var/list/hear = dview(world.view,T,INVISIBILITY_MAXIMUM)
	var/list/hearturfs = list()
	for(var/thing in hear)
		if(istype(thing,/mob))
			hearturfs += get_turf(thing)

	//Check each player to see if they're inside said 'hearing range' turfs
	for(var/mob in player_list)
		if(!istype(mob, /mob))
			crash_with("There is a null or non-mob reference inside player_list.")
			continue
		if(get_turf(mob) in hearturfs)
			return 0
	return 1


mob/living/simple_animal/custom_emote()
	if (away_from_players()) return
	. = ..()

mob/living/simple_animal/say()
	if (away_from_players()) return
	. = ..()

/mob/living/simple_animal/attackby(var/obj/item/O, var/mob/user)
	if (istype(O, /obj/item/weapon/newspaper) && !(ckey || (hostile && faction != user.faction)) && isturf(user.loc))
		if (retaliate && prob(vore_pounce_chance/2)) // This is a gamble!
			user.Weaken(5) //They get tackled anyway whether they're edible or not.
			user.visible_message("<span class='danger'>\the [user] swats \the [src] with \the [O] and promptly gets tackled!</span>!")
			if (will_eat(user))
				stop_automated_movement = 1
				animal_nom(user)
				update_icon()
				stop_automated_movement = 0
			else if (!target_mob) // no using this to clear a retaliate mob's target
				target_mob = user //just because you're not tasty doesn't mean you get off the hook. A swat for a swat.
				AttackTarget()
				LoseTarget() // only make one attempt at an attack rather than going into full rage mode
		else
			user.visible_message("<span class='info'>\the [user] swats \the [src] with \the [O]!</span>!")
			for(var/I in vore_organs)
				var/datum/belly/B = vore_organs[I]
				B.release_all_contents(include_absorbed = TRUE) // Until we can get a mob version of unsorbitol or whatever, release absorbed too
			for(var/mob/living/L in living_mobs(0)) //add everyone on the tile to the do-not-eat list for a while
				if(!(L in prey_excludes)) // Unless they're already on it, just to avoid fuckery.
					prey_excludes += L
					spawn(3600)
						if(src && L)
							prey_excludes -= L
	else
		..()

