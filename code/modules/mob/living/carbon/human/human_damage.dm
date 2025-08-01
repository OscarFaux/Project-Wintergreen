//Updates the mob's health from organs and mob damage variables
/mob/living/carbon/human/updatehealth()
	var/huskmodifier = 2.5 // With 1.5, you need 250 burn instead of 200 to husk a human.

	if(SEND_SIGNAL(src, COMSIG_UPDATE_HEALTH) & COMSIG_UPDATE_HEALTH_GOD_MODE)
		health = getMaxHealth()
		set_stat(CONSCIOUS)
		return

	var/total_burn  = 0
	var/total_brute = 0
	for(var/obj/item/organ/external/O in organs)	//hardcoded to streamline things a bit
		if((O.robotic >= ORGAN_ROBOT) && !O.vital)
			continue //*non-vital* robot limbs don't count towards shock and crit
		total_brute += O.brute_dam
		total_burn  += O.burn_dam

	health = getMaxHealth() - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute
	//TODO: fix husking
	if( ((getMaxHealth() - total_burn) < (-getMaxHealth()) * huskmodifier) && stat == DEAD)
		ChangeToHusk()
	if(health <= -getMaxHealth()) //die only once
		death()
		return
	handle_shock()
	handle_pain()
	return

/mob/living/carbon/human/adjustBrainLoss(var/amount)

	if(SEND_SIGNAL(src, COMSIG_TAKING_BRAIN_DAMAGE, amount) & COMSIG_CANCEL_BRAIN_DAMAGE)
		return 0	// Cancelled by a component

	if(should_have_organ(O_BRAIN))
		var/obj/item/organ/internal/brain/sponge = internal_organs_by_name[O_BRAIN]
		if(sponge)
			sponge.take_damage(amount)
			brainloss = sponge.damage
		else
			brainloss = 200
	else
		brainloss = 0

/mob/living/carbon/human/setBrainLoss(var/amount)

	if(SEND_SIGNAL(src, COMSIG_TAKING_BRAIN_DAMAGE, amount) & COMSIG_CANCEL_BRAIN_DAMAGE)
		return 0	// Cancelled by a component

	if(should_have_organ(O_BRAIN))
		var/obj/item/organ/internal/brain/sponge = internal_organs_by_name[O_BRAIN]
		if(sponge)
			sponge.damage = min(max(amount, 0),(getMaxHealth()*2))
			brainloss = sponge.damage
		else
			brainloss = 200
	else
		brainloss = 0

/mob/living/carbon/human/getBrainLoss()

	if(SEND_SIGNAL(src, COMSIG_CHECK_FOR_GODMODE) & COMSIG_GODMODE_CANCEL) //I don't want to go in and do HUD stuff imediately, so... no.
		return 0	// Cancelled by a component

	if(should_have_organ(O_BRAIN))
		var/obj/item/organ/internal/brain/sponge = internal_organs_by_name[O_BRAIN]
		if(sponge)
			brainloss = min(sponge.damage,getMaxHealth()*2)
		else
			brainloss = 200
	else
		brainloss = 0
	return brainloss

//These procs fetch a cumulative total damage from all organs
/mob/living/carbon/human/getBruteLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in organs)
		if(O.robotic >= ORGAN_ROBOT && !O.vital)
			continue //*non-vital*robot limbs don't count towards death, or show up when scanned
		amount += O.brute_dam
	return amount

/mob/living/carbon/human/getShockBruteLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in organs)
		if(O.robotic >= ORGAN_ROBOT)
			continue //robot limbs don't count towards shock and crit
		amount += O.brute_dam
	return amount

/mob/living/carbon/human/getActualBruteLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in organs) // Unlike the above, robolimbs DO count.
		amount += O.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in organs)
		if(O.robotic >= ORGAN_ROBOT && !O.vital)
			continue //*non-vital*robot limbs don't count towards death, or show up when scanned
		amount += O.burn_dam
	return amount

/mob/living/carbon/human/getShockFireLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in organs)
		if(O.robotic >= ORGAN_ROBOT)
			continue //robot limbs don't count towards shock and crit
		amount += O.burn_dam
	return amount

/mob/living/carbon/human/getActualFireLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in organs) // Unlike the above, robolimbs DO count.
		amount += O.burn_dam
	return amount

//'include_robo' only applies to healing, for legacy purposes, as all damage typically hurts both types of organs
/mob/living/carbon/human/adjustBruteLoss(var/amount,var/include_robo)
	if(SEND_SIGNAL(src, COMSIG_TAKING_BRUTE_DAMAGE, amount) & COMSIG_CANCEL_BRUTE_DAMAGE)
		return 0	// Cancelled by a component
	amount = amount*species.brute_mod
	if(amount > 0)
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_damage_percent))
				if(M.energy_based)
					M.energy_source.use(M.damage_cost*amount)
				amount *= M.incoming_damage_percent
			if(!isnull(M.incoming_brute_damage_percent))
				if(M.energy_based)
					M.energy_source.use(M.damage_cost*amount)
				amount *= M.incoming_brute_damage_percent
		if(nif && nif.flag_check(NIF_C_BRUTEARMOR,NIF_FLAGS_COMBAT)){amount *= 0.7} //VOREStation Edit - NIF mod for damage resistance for this type of damage
		take_overall_damage(amount, 0)
	else
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_healing_percent))
				amount *= M.incoming_healing_percent
		heal_overall_damage(-amount, 0, include_robo)
	BITSET(hud_updateflag, HEALTH_HUD)

//'include_robo' only applies to healing, for legacy purposes, as all damage typically hurts both types of organs
/mob/living/carbon/human/adjustFireLoss(var/amount,var/include_robo)
	amount = amount*species.burn_mod
	if(amount > 0)
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_damage_percent))
				if(M.energy_based)
					M.energy_source.use(M.damage_cost*amount)
				amount *= M.incoming_damage_percent
			if(!isnull(M.incoming_fire_damage_percent))
				if(M.energy_based)
					M.energy_source.use(M.damage_cost*amount)
				amount *= M.incoming_fire_damage_percent
		if(nif && nif.flag_check(NIF_C_BURNARMOR,NIF_FLAGS_COMBAT)){amount *= 0.7} //VOREStation Edit - NIF mod for damage resistance for this type of damage
		take_overall_damage(0, amount)
	else
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_healing_percent))
				amount *= M.incoming_healing_percent
		heal_overall_damage(0, -amount, include_robo)
	BITSET(hud_updateflag, HEALTH_HUD)

/mob/living/carbon/human/proc/adjustBruteLossByPart(var/amount, var/organ_name, var/obj/damage_source = null)
	amount = amount*species.brute_mod
	if (organ_name in organs_by_name)
		var/obj/item/organ/external/O = get_organ(organ_name)

		if(amount > 0)
			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_damage_percent))
					if(M.energy_based)
						M.energy_source.use(M.damage_cost*amount)
					amount *= M.incoming_damage_percent
				if(!isnull(M.incoming_brute_damage_percent))
					if(M.energy_based)
						M.energy_source.use(M.damage_cost*amount)
					amount *= M.incoming_brute_damage_percent
			if(nif && nif.flag_check(NIF_C_BRUTEARMOR,NIF_FLAGS_COMBAT)){amount *= 0.7} //VOREStation Edit - NIF mod for damage resistance for this type of damage
			O.take_damage(amount, 0, sharp=is_sharp(damage_source), edge=has_edge(damage_source), used_weapon=damage_source)
		else
			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_healing_percent))
					amount *= M.incoming_healing_percent
			//if you don't want to heal robot organs, they you will have to check that yourself before using this proc.
			O.heal_damage(-amount, 0, internal=0, robo_repair=(O.robotic >= ORGAN_ROBOT))

	BITSET(hud_updateflag, HEALTH_HUD)

/mob/living/carbon/human/proc/adjustFireLossByPart(var/amount, var/organ_name, var/obj/damage_source = null)
	amount = amount*species.burn_mod
	if (organ_name in organs_by_name)
		var/obj/item/organ/external/O = get_organ(organ_name)

		if(amount > 0)
			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_damage_percent))
					if(M.energy_based)
						M.energy_source.use(M.damage_cost*amount)
					amount *= M.incoming_damage_percent
				if(!isnull(M.incoming_fire_damage_percent))
					if(M.energy_based)
						M.energy_source.use(M.damage_cost*amount)
					amount *= M.incoming_fire_damage_percent
			if(nif && nif.flag_check(NIF_C_BURNARMOR,NIF_FLAGS_COMBAT)){amount *= 0.7} //VOREStation Edit - NIF mod for damage resistance for this type of damage
			O.take_damage(0, amount, sharp=is_sharp(damage_source), edge=has_edge(damage_source), used_weapon=damage_source)
		else
			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_healing_percent))
					amount *= M.incoming_healing_percent
			//if you don't want to heal robot organs, they you will have to check that yourself before using this proc.
			O.heal_damage(0, -amount, internal=0, robo_repair=(O.robotic >= ORGAN_ROBOT))

	BITSET(hud_updateflag, HEALTH_HUD)

/mob/living/carbon/human/Stun(amount)
	if(HULK in mutations)	return
	..()

/mob/living/carbon/human/Weaken(amount)
	if(HULK in mutations)	return
	..()

/mob/living/carbon/human/Paralyse(amount)
	if(HULK in mutations)	return
	// Notify our AI if they can now control the suit.
	if(wearing_rig && !stat && paralysis < amount) //We are passing out right this second.
		wearing_rig.notify_ai(span_danger("Warning: user consciousness failure. Mobility control passed to integrated intelligence system."))
	..()

/mob/living/carbon/human/proc/Stasis(amount)
	if((species.flags & NO_DNA) || isSynthetic())
		in_stasis = 0
	else
		in_stasis = amount

/mob/living/carbon/human/proc/getStasis()
	if((species.flags & NO_DNA) || isSynthetic())
		return 0

	return in_stasis

/// This determines if, RIGHT NOW, the life() tick is being skipped due to stasis
/mob/proc/inStasisNow() // For components to be more easily compatible with both simple and human mobs, only humans can stasis.
	return FALSE

/mob/living/carbon/human/inStasisNow()
	var/stasisValue = getStasis()
	if(stasisValue && (life_tick % stasisValue))
		return 1

	return 0

/mob/living/carbon/human/getCloneLoss()
	if((species.flags & NO_DNA) || isSynthetic())
		cloneloss = 0
	return ..()

/mob/living/carbon/human/setCloneLoss(var/amount)
	if((species.flags & NO_DNA) || isSynthetic())
		cloneloss = 0
	else
		..()

/mob/living/carbon/human/adjustCloneLoss(var/amount)
	..()

	if((species.flags & NO_DNA) || isSynthetic())
		cloneloss = 0
		return

	var/heal_prob = max(0, 80 - getCloneLoss())
	var/mut_prob = min(80, getCloneLoss()+10)
	if (amount > 0)
		if (prob(mut_prob))
			var/list/obj/item/organ/external/candidates = list()
			for (var/obj/item/organ/external/O in organs)
				if(!(O.status & ORGAN_MUTATED))
					candidates |= O
			if (candidates.len)
				var/obj/item/organ/external/O = pick(candidates)
				O.mutate()
				to_chat(src, span_notice("Something is not right with your [O.name]..."))
				return
	else
		if (prob(heal_prob))
			for (var/obj/item/organ/external/O in organs)
				if (O.status & ORGAN_MUTATED)
					O.unmutate()
					to_chat(src, span_notice("Your [O.name] is shaped normally again."))
					return

	if (getCloneLoss() < 1)
		for (var/obj/item/organ/external/O in organs)
			if (O.status & ORGAN_MUTATED)
				O.unmutate()
				to_chat(src, span_notice("Your [O.name] is shaped normally again."))
	BITSET(hud_updateflag, HEALTH_HUD)

// Defined here solely to take species flags into account without having to recast at mob/living level.
/mob/living/carbon/human/getOxyLoss()
	if(!should_have_organ(O_LUNGS))
		oxyloss = 0
	return ..()

/mob/living/carbon/human/adjustOxyLoss(var/amount)
	if(!should_have_organ(O_LUNGS))
		oxyloss = 0
	else
		amount = amount*species.oxy_mod
		..(amount)

/mob/living/carbon/human/setOxyLoss(var/amount)
	if(!should_have_organ(O_LUNGS))
		oxyloss = 0
	else
		..()

/mob/living/carbon/human/adjustHalLoss(var/amount)
	if(species.flags & NO_PAIN)
		halloss = 0
	else
		if(amount > 0)	//only multiply it by the mod if it's positive, or else it takes longer to fade too!
			amount = amount*species.pain_mod
		..(amount)

/mob/living/carbon/human/setHalLoss(var/amount)
	if(species.flags & NO_PAIN)
		halloss = 0
	else
		..()

/mob/living/carbon/human/getToxLoss()
	if(species.flags & NO_POISON)
		toxloss = 0
	return ..()

/mob/living/carbon/human/adjustToxLoss(var/amount)
	if(species.flags & NO_POISON)
		toxloss = 0
	else
		amount = amount*species.toxins_mod
		..(amount)

/mob/living/carbon/human/setToxLoss(var/amount)
	if(species.flags & NO_POISON)
		toxloss = 0
	else
		..()

////////////////////////////////////////////

//Returns a list of damaged organs
/mob/living/carbon/human/proc/get_damaged_organs(var/brute, var/burn)
	var/list/obj/item/organ/external/parts = list()
	for(var/obj/item/organ/external/O in organs)
		if((brute && O.brute_dam) || (burn && O.burn_dam))
			parts += O
	return parts

//Returns a list of damageable organs
/mob/living/carbon/human/proc/get_damageable_organs()
	var/list/obj/item/organ/external/parts = list()
	for(var/obj/item/organ/external/O in organs)
		if(O.is_damageable())
			parts += O
	return parts

//Returns a list of fracturable organs
/mob/living/carbon/human/proc/get_fracturable_organs()
	var/list/obj/item/organ/external/parts = list()
	for(var/obj/item/organ/external/O in organs)
		if(O.is_fracturable())
			parts += O
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_organ_damage(var/brute, var/burn)
	var/list/obj/item/organ/external/parts = get_damaged_organs(brute,burn)
	if(!parts.len)	return
	var/obj/item/organ/external/picked = pick(parts)
	if(picked.heal_damage(brute,burn))
		UpdateDamageIcon()
		BITSET(hud_updateflag, HEALTH_HUD)
	updatehealth()


/*
In most cases it makes more sense to use apply_damage() instead! And make sure to check armour if applicable.
*/
//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_organ_damage(var/brute, var/burn, var/sharp = FALSE, var/edge = FALSE)
	var/list/obj/item/organ/external/parts = get_damageable_organs()
	if(!parts.len)	return
	var/obj/item/organ/external/picked = pick(parts)
	if(picked.take_damage(brute,burn,sharp,edge))
		UpdateDamageIcon()
		BITSET(hud_updateflag, HEALTH_HUD)
	updatehealth()


//Heal MANY external organs, in random order
//'include_robo' only applies to healing, for legacy purposes, as all damage typically hurts both types of organs
/mob/living/carbon/human/heal_overall_damage(var/brute, var/burn, var/include_robo)
	var/list/obj/item/organ/external/parts = get_damaged_organs(brute,burn)

	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/obj/item/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_damage(brute,burn,robo_repair = include_robo)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked
	updatehealth()
	BITSET(hud_updateflag, HEALTH_HUD)
	if(update)	UpdateDamageIcon()

// damage MANY external organs, in random order
/mob/living/carbon/human/take_overall_damage(var/brute, var/burn, var/sharp = FALSE, var/edge = FALSE, var/used_weapon = null)
	var/list/obj/item/organ/external/parts = get_damageable_organs()
	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/obj/item/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.take_damage(brute,burn,sharp,edge,used_weapon)
		brute	-= (picked.brute_dam - brute_was)
		burn	-= (picked.burn_dam - burn_was)

		parts -= picked
	updatehealth()
	BITSET(hud_updateflag, HEALTH_HUD)
	if(update)	UpdateDamageIcon()


////////////////////////////////////////////

/*
This function restores the subjects blood to max.
*/
/mob/living/carbon/human/proc/restore_blood()
	if(!should_have_organ(O_HEART))
		return
	if(vessel.total_volume < species.blood_volume)
		vessel.add_reagent(REAGENT_ID_BLOOD, species.blood_volume - vessel.total_volume)

/*
This function restores all organs.
*/
/mob/living/carbon/human/restore_all_organs(var/ignore_prosthetic_prefs)
	for(var/obj/item/organ/external/current_organ in organs)
		current_organ.rejuvenate(ignore_prosthetic_prefs)

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/obj/item/organ/external/E = get_organ(zone)
	if(istype(E, /obj/item/organ/external))
		if (E.heal_damage(brute, burn))
			UpdateDamageIcon()
			BITSET(hud_updateflag, HEALTH_HUD)
	else
		return 0
	return

/*
/mob/living/carbon/human/proc/get_organ(var/zone)
	if(!zone)
		zone = BP_TORSO
	else if (zone in list( O_EYES, O_MOUTH ))
		zone = BP_HEAD
	return organs_by_name[zone]
*/

/mob/living/carbon/human/apply_damage(var/damage = 0, var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/soaked = 0, var/sharp = FALSE, var/edge = FALSE, var/obj/used_weapon = null, var/projectile = FALSE)
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE, damage, damagetype, def_zone, blocked, soaked, sharp, edge, used_weapon, projectile)
	if(GLOB.Debug2)
		to_world_log("## DEBUG: human/apply_damage() was called on [src], with [damage] damage, an armor value of [blocked], and a soak value of [soaked].")
	var/obj/item/organ/external/organ = null
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)	def_zone = ran_zone(def_zone)
		organ = get_organ(check_zone(def_zone))

	for(var/datum/modifier/M in modifiers) //MODIFIER STUFF. It's best to do this RIGHT before armor is calculated, so it's done here! This is the 'forcefield' defence.
		if(damagetype == BRUTE && (!isnull(M.effective_brute_resistance)))
			if(M.energy_based)
				M.energy_source.use(M.damage_cost * damage)
			damage = damage * M.effective_brute_resistance
			continue
		if((damagetype == BURN || damagetype == ELECTROCUTE) && (!isnull(M.effective_fire_resistance)))
			if(M.energy_based)
				M.energy_source.use(M.damage_cost * damage)
			damage = damage * M.effective_fire_resistance
			continue
		if(damagetype == TOX && (!isnull(M.effective_tox_resistance)))
			if(M.energy_based)
				M.energy_source.use(M.damage_cost * damage)
			damage = damage * M.effective_tox_resistance
			continue
		if(damagetype == OXY && (!isnull(M.effective_oxy_resistance)))
			if(M.energy_based)
				M.energy_source.use(M.damage_cost * damage)
			damage = damage * M.effective_oxy_resistance
			continue
		if(damagetype == CLONE && (!isnull(M.effective_clone_resistance)))
			if(M.energy_based)
				M.energy_source.use(M.damage_cost * damage)
			damage = damage * M.effective_clone_resistance
			continue
		if(damagetype == HALLOSS && (!isnull(M.effective_hal_resistance)))
			if(M.energy_based)
				M.energy_source.use(M.damage_cost * damage)
			damage = damage * M.effective_hal_resistance
			continue
		if(damagetype == SEARING && (!isnull(M.effective_fire_resistance) || !isnull(M.effective_brute_resistance)))
			if(M.energy_based)
				M.energy_source.use(M.damage_cost * damage)
			var/damage_mitigation = 0//Used for dual calculations.
			if(!isnull(M.effective_fire_resistance))
				damage_mitigation += round((1/3)*damage * M.effective_fire_resistance)
			if(!isnull(M.effective_brute_resistance))
				damage_mitigation += round((2/3)*damage * M.effective_brute_resistance)
			damage -= damage_mitigation
			continue
		if(damagetype == BIOACID && (isSynthetic() && (!isnull(M.effective_fire_resistance))) || (!isSynthetic() && M.effective_tox_resistance))
			if(isSynthetic())
				damage = damage * M.effective_fire_resistance
			else
				damage = damage * M.effective_tox_resistance
			continue
	//Handle other types of damage
	if((damagetype != BRUTE) && (damagetype != BURN))
		if(damagetype == HALLOSS)
			if((damage > 25 && prob(20)) || (damage > 50 && prob(60)))
				if(organ && organ.organ_can_feel_pain() && !isbelly(loc) && !istype(loc, /obj/item/dogborg/sleeper)) //VOREStation Add
					emote("scream")
		..(damage, damagetype, def_zone, blocked, soaked)
		return 1

	//Handle BRUTE and BURN damage
	handle_suit_punctures(damagetype, damage, def_zone)

	if(blocked >= 100)
		return 0

	if(soaked >= damage)
		return 0

	if(!organ)	return 0

	if(blocked)
		blocked = (100-blocked)/100
		damage = (damage * blocked)

	if(soaked)
		damage -= soaked

	if(GLOB.Debug2)
		to_world_log("## DEBUG: [src] was hit for [damage].")

	switch(damagetype)
		if(BRUTE)
			damageoverlaytemp = 20
			if(nif && nif.flag_check(NIF_C_BRUTEARMOR,NIF_FLAGS_COMBAT)){damage *= 0.7}
			damage = damage*species.brute_mod

			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_damage_percent))
					if(M.energy_based)
						M.energy_source.use(M.damage_cost*damage)
					damage *= M.incoming_damage_percent
				if(!isnull(M.incoming_brute_damage_percent))
					if(M.energy_based)
						M.energy_source.use(M.damage_cost*damage)
					damage *= M.incoming_brute_damage_percent

			if(organ.take_damage(damage, 0, sharp, edge, used_weapon, projectile=projectile))
				UpdateDamageIcon()
		if(BURN)
			damageoverlaytemp = 20
			if(nif && nif.flag_check(NIF_C_BURNARMOR,NIF_FLAGS_COMBAT)){damage *= 0.7}
			damage = damage*species.burn_mod

			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_damage_percent))
					if(M.energy_based)
						M.energy_source.use(M.damage_cost*damage)
					damage *= M.incoming_damage_percent
				if(!isnull(M.incoming_brute_damage_percent))
					if(M.energy_based)
						M.energy_source.use(M.damage_cost*damage)
					damage *= M.incoming_fire_damage_percent

			if(organ.take_damage(0, damage, sharp, edge, used_weapon, projectile=projectile))
				UpdateDamageIcon()

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().
	updatehealth()
	BITSET(hud_updateflag, HEALTH_HUD)
	SEND_SIGNAL(src, COMSIG_MOB_AFTER_APPLY_DAMAGE, damage, damagetype, def_zone, blocked, soaked, sharp, edge, used_weapon, projectile)
	return 1
