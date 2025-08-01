
/*
	run_armor_check(a,b)
	args
	a:def_zone		- What part is getting hit, if null will check entire body
	b:attack_flag	- What type of attack, bullet, laser, energy, melee
	c:armour_pen	- How much armor to ignore.
	d:absorb_text	- Custom text to send to the player when the armor fully absorbs an attack.
	e:soften_text	- Similar to absorb_text, custom text to send to the player when some damage is reduced.

	Returns
	A number between 0 and 100, with higher numbers resulting in less damage taken.
*/
/mob/living/proc/run_armor_check(var/def_zone = null, var/attack_flag = "melee", var/armour_pen = 0, var/absorb_text = null, var/soften_text = null)
	if(GLOB.Debug2)
		to_world_log("## DEBUG: getarmor() was called.")

	if(armour_pen >= 100)
		return 0 //might as well just skip the processing

	var/armor = getarmor(def_zone, attack_flag)
	if(armor)
		var/armor_variance_range = round(armor * 0.25) //Armor's effectiveness has a +25%/-25% variance.
		var/armor_variance = rand(-armor_variance_range, armor_variance_range) //Get a random number between -25% and +25% of the armor's base value
		if(GLOB.Debug2)
			to_world_log("## DEBUG: The range of armor variance is [armor_variance_range].  The variance picked by RNG is [armor_variance].")

		armor = min(armor + armor_variance, 100)	//Now we calcuate damage using the new armor percentage.
		armor = max(armor - armour_pen, 0)			//Armor pen makes armor less effective.
		if(armor >= 100)
			if(absorb_text)
				to_chat(src, span_danger("[absorb_text]"))
			else
				to_chat(src, span_danger("Your armor absorbs the blow!"))

		else if(armor > 0)
			if(soften_text)
				to_chat(src, span_danger("[soften_text]"))
			else
				to_chat(src, span_danger("Your armor softens the blow!"))
		if(GLOB.Debug2)
			to_world_log("## DEBUG: Armor when [src] was attacked was [armor].")
	return armor

/*
	//Old armor code here.
	if(armour_pen >= 100)
		return 0 //might as well just skip the processing

	var/armor = getarmor(def_zone, attack_flag)
	var/absorb = 0

	//Roll armour
	if(prob(armor))
		absorb += 1
	if(prob(armor))
		absorb += 1

	//Roll penetration
	if(prob(armour_pen))
		absorb -= 1
	if(prob(armour_pen))
		absorb -= 1

	if(absorb >= 2)
		if(absorb_text)
			show_message("[absorb_text]")
		else
			show_message(span_warning("Your armor absorbs the blow!"))
		return 2
	if(absorb == 1)
		if(absorb_text)
			show_message("[soften_text]",4)
		else
			show_message(span_warning("Your armor softens the blow!"))
		return 1
	return 0
*/

//Certain pieces of armor actually absorb flat amounts of damage from income attacks
/mob/living/proc/get_armor_soak(var/def_zone = null, var/attack_flag = "melee", var/armour_pen = 0)
	var/soaked = getsoak(def_zone, attack_flag)
	//5 points of armor pen negate one point of soak
	if(armour_pen)
		soaked = max(soaked - (armour_pen/5), 0)
	return soaked

//if null is passed for def_zone, then this should return something appropriate for all zones (e.g. area effect damage)
/mob/living/proc/getarmor(var/def_zone, var/type)
	return 0

/mob/living/proc/getsoak(var/def_zone, var/type)
	return 0

// Clicking with an empty hand
/mob/living/attack_hand(mob/living/L)
	..()
	if(istype(L) && L.a_intent != I_HELP)
		if(ai_holder) // Using disarm, grab, or harm intent is considered a hostile action to the mob's AI.
			ai_holder.react_to_attack(L)
	if(touch_reaction_flags & SPECIES_TRAIT_THORNS)
		if(src != L)
			L.apply_damage(3, BRUTE)
			L.visible_message( \
				span_warning("[L] is hurt by sharp body parts when touching [src]!"), \
				span_warning("[src] is covered in sharp bits and it hurt when you touched them!"), )

/mob/living/bullet_act(var/obj/item/projectile/P, var/def_zone)

	if(ai_holder && P.firer)
		ai_holder.react_to_attack(P.firer)

	//Armor
	var/soaked = get_armor_soak(def_zone, P.check_armour, P.armor_penetration)
	var/absorb = run_armor_check(def_zone, P.check_armour, P.armor_penetration)
	var/proj_sharp = is_sharp(P)
	var/proj_edge = has_edge(P)

	if ((proj_sharp || proj_edge) && (soaked >= round(P.damage*0.8)))
		proj_sharp = 0
		proj_edge = 0

	if ((proj_sharp || proj_edge) && prob(getarmor(def_zone, P.check_armour)))
		proj_sharp = 0
		proj_edge = 0

	//Stun Beams
	if(P.taser_effect)
		stun_effect_act(0, P.agony, def_zone, P)
		if(!P.nodamage)
			apply_damage(P.damage, P.damage_type, def_zone, absorb, soaked, 0, sharp=proj_sharp, edge=proj_edge, used_weapon=P, projectile=TRUE)
		qdel(P)
		return

	if(!P.nodamage)
		apply_damage(P.damage, P.damage_type, def_zone, absorb, soaked, 0, sharp=proj_sharp, edge=proj_edge, used_weapon=P, projectile=TRUE)
	P.on_hit(src, absorb, soaked, def_zone)

	if(absorb == 100)
		return 2
	else if (absorb >= 0)
		return 1
	else
		return 0

//	return absorb

//Handles the effects of "stun" weapons
/mob/living/proc/stun_effect_act(var/stun_amount, var/agony_amount, var/def_zone, var/used_weapon=null)
	flash_pain()

	if (stun_amount)
		Stun(stun_amount)
		Weaken(stun_amount)
		apply_effect(STUTTER, stun_amount)
		apply_effect(EYE_BLUR, stun_amount)

	if (agony_amount)
		apply_damage(agony_amount, HALLOSS, def_zone, 0, used_weapon=used_weapon)
		apply_effect(STUTTER, agony_amount/10)
		apply_effect(EYE_BLUR, agony_amount/10)

/mob/living/proc/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0, var/def_zone = null, var/stun = 1)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()

	if(LAZYLEN(modifiers))
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.emp_modifier))
				severity = CLAMP(severity + M.emp_modifier, 1, 5)

	if(severity == 5)	// Effectively nullified.
		return

	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/mob/living/blob_act(var/obj/structure/blob/B)
	if(stat == DEAD || faction == B.faction)
		return

	var/damage = rand(30, 40)
	var/armor_pen = 0
	var/armor_check = "melee"
	var/damage_type = BRUTE
	var/attack_message = "The blob attacks you!"
	var/attack_verb = "attacks"
	var/def_zone = pick(BP_HEAD, BP_TORSO, BP_GROIN, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

	if(B && B.overmind)
		var/datum/blob_type/blob = B.overmind.blob_type

		damage = rand(blob.damage_lower, blob.damage_upper)
		armor_check = blob.armor_check
		armor_pen = blob.armor_pen
		damage_type = blob.damage_type

		attack_message = "[blob.attack_message][isSynthetic() ? "[blob.attack_message_synth]":"[blob.attack_message_living]"]"
		attack_verb = blob.attack_verb
		B.overmind.blob_type.on_attack(B, src, def_zone)

	if( (damage_type == TOX || damage_type == OXY) && isSynthetic()) // Borgs and FBPs don't really handle tox/oxy damage the same way other mobs do.
		damage_type = BRUTE
		damage *= 0.66 // Take 2/3s as much damage.

	visible_message(span_danger("\The [B] [attack_verb] \the [src]!"), span_danger("[attack_message]!"))
	playsound(src, 'sound/effects/attackblob.ogg', 50, 1)

	//Armor
	var/soaked = get_armor_soak(def_zone, armor_check, armor_pen)
	var/absorb = run_armor_check(def_zone, armor_check, armor_pen)

	if(ai_holder)
		ai_holder.react_to_attack(B)

	apply_damage(damage, damage_type, def_zone, absorb, soaked)

/mob/living/proc/resolve_item_attack(obj/item/I, mob/living/user, var/target_zone)
	return target_zone

//Called when the mob is hit with an item in combat. Returns the blocked result
/mob/living/proc/hit_with_weapon(obj/item/I, mob/living/user, var/effective_force, var/hit_zone)
	visible_message(span_danger("[src] has been [LAZYLEN(I.attack_verb) ? pick(I.attack_verb) : "attacked"] with [I.name] by [user]!"))

	if(ai_holder)
		ai_holder.react_to_attack(user)

	var/soaked = get_armor_soak(hit_zone, "melee")
	var/blocked = run_armor_check(hit_zone, "melee")

	standard_weapon_hit_effects(I, user, effective_force, blocked, soaked, hit_zone)

	if(I.damtype == BRUTE && prob(33)) // Added blood for whacking non-humans too
		var/turf/simulated/location = get_turf(src)
		if(istype(location)) location.add_blood_floor(src)

	return blocked

//returns 0 if the effects failed to apply for some reason, 1 otherwise.
/mob/living/proc/standard_weapon_hit_effects(obj/item/I, mob/living/user, var/effective_force, var/blocked, var/soaked, var/hit_zone)
	if(!effective_force || blocked >= 100)
		return 0
	//Apply weapon damage
	var/weapon_sharp = is_sharp(I)
	var/weapon_edge = has_edge(I)

	if(getsoak(hit_zone, "melee",) - (I.armor_penetration/5) > round(effective_force*0.8)) //soaking a hit turns sharp attacks into blunt ones
		weapon_sharp = 0
		weapon_edge = 0

	if(prob(max(getarmor(hit_zone, "melee") - I.armor_penetration, 0))) //melee armour provides a chance to turn sharp/edge weapon attacks into blunt ones
		weapon_sharp = 0
		weapon_edge = 0

	apply_damage(effective_force, I.damtype, hit_zone, blocked, soaked, sharp=weapon_sharp, edge=weapon_edge, used_weapon=I)

	return 1

//this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM as mob|obj,var/speed = THROWFORCE_SPEED_DIVISOR)//Standardization and logging -Sieve
	if(is_incorporeal())
		return
	if(istype(AM,/obj/))
		var/obj/O = AM
		if(stat != DEAD && istype(O,/obj/item) && trash_catching && vore_selected) //ported from chompstation
			var/obj/item/I = O
			if(adminbus_trash || is_type_in_list(I, GLOB.edible_trash) && I.trash_eatable && !is_type_in_list(I, GLOB.item_vore_blacklist))
				visible_message(span_vwarning("[I] is thrown directly into [src]'s [lowertext(vore_selected.name)]!"))
				I.throwing = 0
				I.forceMove(vore_selected)
				return
		var/dtype = O.damtype
		var/throw_damage = O.throwforce*(speed/THROWFORCE_SPEED_DIVISOR)

		var/miss_chance = 15
		if (O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			miss_chance = max(15*(distance-2), 0)

		if (prob(miss_chance))
			visible_message(span_notice("\The [O] misses [src] narrowly!"))
			return

		src.visible_message(span_filter_warning("[span_red("[src] has been hit by [O].")]"))
		var/armor = run_armor_check(null, "melee")
		var/soaked = get_armor_soak(null, "melee")


		apply_damage(throw_damage, dtype, null, armor, soaked, is_sharp(O), has_edge(O), O)

		O.throwing = 0		//it hit, so stop moving

		if(ismob(O.thrower))
			var/mob/M = O.thrower
			var/client/assailant = M.client
			if(assailant)
				add_attack_logs(M,src,"Hit by thrown [O.name]")
			if(ai_holder)
				ai_holder.react_to_attack(O.thrower)

		// Begin BS12 momentum-transfer code.
		var/mass = 1.5
		if(istype(O, /obj/item))
			var/obj/item/I = O
			mass = I.w_class/THROWNOBJ_KNOCKBACK_DIVISOR
		var/momentum = speed*mass

		if(O.throw_source && momentum >= THROWNOBJ_KNOCKBACK_SPEED)
			var/dir = get_dir(O.throw_source, src)

			visible_message(span_filter_warning("[span_red("[src] staggers under the impact!")]"),span_filter_warning("[span_red("You stagger under the impact!")]"))
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(!O || !src) return

			if(O.sharp) //Projectile is suitable for pinning.
				if(soaked >= round(throw_damage*0.8))
					return

				//Handles embedding for non-humans and simple_animals.
				embed(O)

				var/turf/T = near_wall(dir,2)

				if(T)
					src.loc = T
					visible_message(span_warning("[src] is pinned to the wall by [O]!"),span_warning("You are pinned to the wall by [O]!"))
					src.anchored = TRUE
					src.pinned += O

	//VORESTATION EDIT START - Allows for thrown vore!
	//Throwing a prey into a pred takes priority. After that it checks to see if the person being thrown is a pred.
	if(isliving(AM))
		var/mob/living/thrown_mob = AM

		if(!allowmobvore && isanimal(thrown_mob) && !thrown_mob.ckey) //Does the person being hit not allow mob vore and the perrson being thrown a simple_mob?
			return
		if(!thrown_mob.allowmobvore && isanimal(src) && !ckey) //Does the person being thrown not allow mob vore and is the person being hit (us) a simple_mob?
			return

		// PERSON BEING HIT: CAN BE DROP PRED, ALLOWS THROW VORE.
		// PERSON BEING THROWN: DEVOURABLE, ALLOWS THROW VORE, CAN BE DROP PREY.
		if((can_be_drop_pred && throw_vore) && (thrown_mob.devourable && thrown_mob.throw_vore && thrown_mob.can_be_drop_prey)) //Prey thrown into pred.
			if(!vore_selected)
				return
			vore_selected.nom_mob(thrown_mob) //Eat them!!!
			visible_message(span_vwarning("[thrown_mob] is thrown right into [src]'s [lowertext(vore_selected.name)]!"))
			if(thrown_mob.loc != vore_selected)
				thrown_mob.forceMove(vore_selected) //Double check. Should never happen but...Weirder things have happened!
			on_throw_vore_special(TRUE, thrown_mob)
			add_attack_logs(thrown_mob.thrower,src,"Devoured [thrown_mob.name] via throw vore.")
			return //We can stop here. We don't need to calculate damage or anything else. They're eaten.

		// PERSON BEING HIT: CAN BE DROP PREY, ALLOWS THROW VORE, AND IS DEVOURABLE.
		// PERSON BEING THROWN: CAN BE DROP PRED, ALLOWS THROW VORE.
		else if((can_be_drop_prey && throw_vore && devourable) && (thrown_mob.can_be_drop_pred && thrown_mob.throw_vore) && thrown_mob.vore_selected) //Pred thrown into prey.
			if(!thrown_mob.vore_selected)
				return
			visible_message(span_vwarning("[src] suddenly slips inside of [thrown_mob]'s [lowertext(thrown_mob.vore_selected.name)] as [thrown_mob] flies into them!"))
			thrown_mob.vore_selected.nom_mob(src) //Eat them!!!
			if(src.loc != thrown_mob.vore_selected)
				src.forceMove(thrown_mob.vore_selected) //Double check. Should never happen but...Weirder things have happened!
			add_attack_logs(thrown_mob.LAssailant,src,"Was Devoured by [thrown_mob.name] via throw vore.")
			return
	//VORESTATION EDIT END - Allows for thrown vore!

/mob/living/proc/on_throw_vore_special(var/pred = TRUE, var/mob/living/target)
	return

/mob/living/proc/embed(var/obj/O, var/def_zone=null)
	O.loc = src
	src.embedded += O
	add_verb(src, /mob/proc/yank_out_object)
	throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)

//This is called when the mob is thrown into a dense turf
/mob/living/proc/turf_collision(var/turf/T, var/speed)
	src.take_organ_damage(12)	// used to be 5 * speed. That's a default of 25 and I dont see anything ever changing the "speed" value.
	//src.Weaken(3)				// That is absurdly high so im just setting it to a flat 12 with a bit of stun ontop. //Stun is too dangerous
	playsound(src, get_sfx("punch"), 50) //ouch sound

/mob/living/proc/near_wall(var/direction,var/distance=1)
	var/turf/T = get_step(get_turf(src),direction)
	var/turf/last_turf = src.loc
	var/i = 1

	while(i>0 && i<=distance)
		if(T.density) //Turf is a wall!
			return last_turf
		i++
		last_turf = T
		T = get_step(T,direction)

	return 0

// End BS12 momentum-transfer code.

/mob/living/attack_generic(var/mob/user, var/damage, var/attack_message)
	if(istype(user,/mob/living))
		var/mob/living/L = user
		if(touch_reaction_flags & SPECIES_TRAIT_THORNS)
			if((src != L))
				L.apply_damage(3, BRUTE)
				L.visible_message( \
					span_warning("[L] is hurt by sharp body parts when touching [src]!"), \
					span_warning("[src] is covered in sharp bits and it hurt when you touched them!"), )

	if(!damage)
		return

	adjustBruteLoss(damage)
	add_attack_logs(user,src,"Generic attack (probably animal)", admin_notify = FALSE) //Usually due to simple_mob attacks
	if(ai_holder)
		ai_holder.react_to_attack(user)
	src.visible_message(span_danger("[user] has [attack_message] [src]!"))
	user.do_attack_animation(src)
	spawn(1) updatehealth()
	return 1

/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire)
		on_fire = 1
		new/obj/effect/dummy/lighting_obj/moblight/fire(src)
		throw_alert("fire", /obj/screen/alert/fire)
		update_fire()

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		for(var/obj/effect/dummy/lighting_obj/moblight/fire/F in src)
			qdel(F)
		clear_alert("fire")
		update_fire()

	if(has_modifier_of_type(/datum/modifier/fire))
		remove_modifiers_of_type(/datum/modifier/fire)

/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
	fire_stacks = CLAMP(fire_stacks + add_fire_stacks, FIRE_MIN_STACKS, FIRE_MAX_STACKS)

/mob/living/proc/handle_fire()
	if(fire_stacks < 0)
		fire_stacks = min(0, ++fire_stacks) //If we've doused ourselves in water to avoid fire, dry off slowly

	if(fire_stacks > 0)
		fire_stacks = max(0, (fire_stacks-0.1))	//Should slowly burn out

	if(!on_fire)
		return 1
	else if(fire_stacks <= 0)
		ExtinguishMob() //Fire's been put out.
		return 1

	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.gas[GAS_O2] < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return 1

	var/turf/location = get_turf(src)
	location.hotspot_expose(fire_burn_temperature(), 50, 1)

//altered this to cap at the temperature of the fire causing it, using the same 1:1500 value as /mob/living/carbon/human/handle_fire() in human/life.dm
/mob/living/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature)
		if(fire_stacks < exposed_temperature/1500) // Subject to balance
			adjust_fire_stacks(2)
	else
		adjust_fire_stacks(2)
	IgniteMob()

//Share fire evenly between the two mobs
//Called in MobCollide() and Crossed()
/mob/living/proc/spread_fire(mob/living/L)
	return
// This is commented out pending discussion on Polaris.  If you're a downsteam and you want people to spread fire by touching each other, feel free to uncomment this.
/*
	if(!istype(L))
		return
	var/L_old_on_fire = L.on_fire

	if(on_fire) //Only spread fire stacks if we're on fire
		fire_stacks /= 2
		L.fire_stacks += fire_stacks
		if(L.IgniteMob())
			message_admins("[key_name(src)] bumped into [key_name(L)] and set them on fire.")

	if(L_old_on_fire) //Only ignite us and gain their stacks if they were onfire before we bumped them
		L.fire_stacks /= 2
		fire_stacks += L.fire_stacks
		IgniteMob()
*/

/mob/living/proc/get_cold_protection()
	return 0

/mob/living/proc/get_heat_protection()
	return 0

/mob/living/proc/get_shock_protection()
	return 0

/mob/living/proc/get_water_protection()
	return 1 // Water won't hurt most things.

/mob/living/proc/get_poison_protection()
	return 0

//Finds the effective temperature that the mob is burning at.
/mob/living/proc/fire_burn_temperature()
	if (fire_stacks <= 0)
		return 0

	//Scale quadratically so that single digit numbers of fire stacks don't burn ridiculously hot.
	//lower limit of 700 K, same as matches and roughly the temperature of a cool flame.
	return max(2.25*round(FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE*(fire_stacks/FIRE_MAX_FIRESUIT_STACKS)**2), 700)

// Called when struck by lightning.
/mob/living/proc/lightning_act()
	// The actual damage/electrocution is handled by the tesla_zap() that accompanies this.
	Paralyse(5)
	stuttering += 20
	make_jittery(150)
	emp_act(1)
	to_chat(src, span_critical("You've been struck by lightning!"))

// Called when touching a lava tile.
// Does roughly 70 damage (30 instantly, up to ~40 over time) to unprotected mobs, and 10 to fully protected mobs.
/mob/living/lava_act()
	adjust_fire_stacks(1)
	add_modifier(/datum/modifier/fire/stack_managed/intense, 8 SECONDS) // Around 40 total if left to burn and without fire protection per stack.
	inflict_heat_damage(20) // Another 20, however this is instantly applied to unprotected mobs.
	adjustFireLoss(10) // Lava cannot be 100% resisted with fire protection.

/mob/living/proc/reagent_permeability()
	return 1


// Returns a number to determine if something is harder or easier to hit than normal.
/mob/living/proc/get_evasion()
	var/result = evasion // First we get the 'base' evasion.  Generally this is zero.
	for(var/datum/modifier/M in modifiers)
		if(!isnull(M.evasion))
			result += M.evasion
	return result

/mob/living/proc/get_accuracy_penalty()
	// Certain statuses make it harder to score a hit.
	var/accuracy_penalty = 0
	if(eye_blind)
		accuracy_penalty += 75
	if(eye_blurry)
		accuracy_penalty += 30
	if(confused)
		accuracy_penalty += 45

	return accuracy_penalty

// Applies direct "cold" damage while checking protection against the cold.
/mob/living/proc/inflict_cold_damage(amount)
	amount *= 1 - get_cold_protection(50) // Within spacesuit protection.
	if(amount > 0)
		adjustFireLoss(amount)

// Ditto, but for "heat".
/mob/living/proc/inflict_heat_damage(amount)
	amount *= 1 - get_heat_protection(10000) // Within firesuit protection.
	if(amount > 0)
		adjustFireLoss(amount)

// and one for electricity because why not
/mob/living/proc/inflict_shock_damage(amount)
	electrocute_act(amount, null, 1 - get_shock_protection(), pick(BP_HEAD, BP_TORSO, BP_GROIN))

// also one for water (most things resist it entirely, except for slimes)
/mob/living/proc/inflict_water_damage(amount)
	amount *= 1 - get_water_protection()
	if(amount > 0)
		adjustToxLoss(amount)

// one for abstracted away ""poison"" (mostly because simplemobs shouldn't handle reagents)
/mob/living/proc/inflict_poison_damage(amount)
	if(isSynthetic())
		return
	amount *= 1 - get_poison_protection()
	if(amount > 0)
		adjustToxLoss(amount)

/mob/living/proc/can_inject(var/mob/user, var/error_msg, var/target_zone, var/ignore_thickness = FALSE)
	return 1

/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter.zone_sel.selecting
	if ((t in list( O_EYES, O_MOUTH )))
		t = BP_HEAD
	var/obj/item/organ/external/def_zone = ran_zone(t)
	return def_zone

// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(var/brute, var/burn, var/emp=0)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn, var/used_weapon = null)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

/mob/living/proc/restore_all_organs()
	return

/mob/living/proc/is_mouth_covered(head_only = FALSE, mask_only = FALSE)
	return FALSE

/mob/living/extrapolator_act(mob/living/user, obj/item/extrapolator/extrapolator, dry_run)
	. = ..()
	EXTRAPOLATOR_ACT_ADD_DISEASES(., viruses)
