/mob/living/carbon/alien/humanoid/queen/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in world)
		if(Q.stat != DEAD)
			name = "alien princess ([rand(1, 1000)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid,/mob/living/carbon/alien/humanoid/proc/neurotoxin,/mob/living/carbon/alien/humanoid/proc/resin)
	verbs -= /mob/living/carbon/alien/humanoid/verb/ventcrawl


/mob/living/carbon/alien/humanoid/queen

	updatehealth()
		if (src.nodamage == 0)
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
			src.health = 250 - src.getOxyLoss() - src.getFireLoss() - src.getBruteLoss()
		else
			src.health = 250
			src.stat = 0

	handle_regular_hud_updates()

		..() //-Yvarov

		if (src.healths)
			if (src.stat != 2)
				switch(health)
					if(250 to INFINITY)
						src.healths.icon_state = "health0"
					if(175 to 250)
						src.healths.icon_state = "health1"
					if(100 to 175)
						src.healths.icon_state = "health2"
					if(50 to 100)
						src.healths.icon_state = "health3"
					if(0 to 50)
						src.healths.icon_state = "health4"
					else
						src.healths.icon_state = "health5"
			else
				src.healths.icon_state = "health6"

	handle_environment()

		//If there are alien weeds on the ground then heal if needed or give some toxins
		if(locate(/obj/effect/alien/weeds) in loc)
			if(health >= 250)
				adjustToxLoss(20)
			else
				adjustBruteLoss(-5)
				adjustFireLoss(-5)


//Queen verbs
/mob/living/carbon/alien/humanoid/queen/verb/lay_egg()

	set name = "Lay Egg (200)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	if(locate(/obj/effect/alien/egg) in get_turf(src))
		src << "There's already an egg here."
		return

	if(powerc(50,1))//Can't plant eggs on spess tiles. That's silly.
		adjustToxLoss(-200)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has laid an egg!</B>"), 1)
		new /obj/effect/alien/egg(loc)
	return


/mob/living/carbon/alien/humanoid/queen/updatehealth()
	if(nodamage)
		health = 250
		stat = CONSCIOUS
	else
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
		health = 250 - getOxyLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
