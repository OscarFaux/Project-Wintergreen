/mob/living/carbon/alien/humanoid/hunter/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien hunter")
		name = text("alien hunter ([rand(1, 1000)])")
	real_name = name
	verbs -= /mob/living/carbon/alien/humanoid/verb/corrode

/mob/living/carbon/alien/humanoid/hunter

	updatehealth()
		if(nodamage)
			health = 150
			stat = CONSCIOUS
		else
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
			health = 150 - getOxyLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()


	handle_regular_hud_updates()

		..() //-Yvarov

		if (healths)
			if (stat != 2)
				switch(health)
					if(150 to INFINITY)
						healths.icon_state = "health0"
					if(100 to 150)
						healths.icon_state = "health1"
					if(50 to 100)
						healths.icon_state = "health2"
					if(25 to 50)
						healths.icon_state = "health3"
					if(0 to 25)
						healths.icon_state = "health4"
					else
						healths.icon_state = "health5"
			else
				healths.icon_state = "health6"


	handle_environment()
		if(m_intent == "run" || resting)
			//If there are alien weeds on the ground then heal if needed or give some toxins
			if(locate(/obj/effect/alien/weeds) in loc)
				if(health >= 150)
					adjustToxLoss(5)
				else
					adjustBruteLoss(-5)
					adjustFireLoss(-5)
		else
			adjustToxLoss(-5)


//Hunter verbs
/*
/mob/living/carbon/alien/humanoid/hunter/verb/invis()
	set name = "Invisibility (50)"
	set desc = "Makes you invisible for 15 seconds"
	set category = "Alien"

	if(alien_invis)
		update_icons()
	else
		if(powerc(50))
			adjustToxLoss(-50)
			alien_invis = 1.0
			update_icons()
			src << "\green You are now invisible."
			for(var/mob/O in oviewers(src, null))
				O.show_message(text("\red <B>[src] fades into the surroundings!</B>"), 1)
			spawn(250)
				if(!isnull(src))//Don't want the game to runtime error when the mob no-longer exists.
					alien_invis = 0.0
					update_icons()
					src << "\green You are no longer invisible."
	return
*/
/mob/living/carbon/alien/humanoid/hunter/verb/regurgitate()
	set name = "Regurgitate"
	set desc = "Empties the contents of your stomach"
	set category = "Alien"

	if(powerc())
		if(stomach_contents.len)
			for(var/mob/M in src)
				if(M in stomach_contents)
					stomach_contents.Remove(M)
					M.loc = loc
					Paralyse(10)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\green <B>[src] hurls out the contents of their stomach!</B>"), 1)
	return