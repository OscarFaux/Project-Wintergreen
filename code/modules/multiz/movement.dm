/mob/verb/up()
	set name = "Move Upwards"
	set category = "IC"

	if(zMove(UP))
		to_chat(src, "<span class='notice'>You move upwards.</span>")

/mob/verb/down()
	set name = "Move Down"
	set category = "IC"

	if(zMove(DOWN))
		to_chat(src, "<span class='notice'>You move down.</span>")

/mob/proc/zMove(direction)
	if(eyeobj)
		return eyeobj.zMove(direction)
	if(!can_ztravel())
		to_chat(src, "<span class='warning'>You lack means of travel in that direction.</span>")
		return

	var/turf/start = loc
	if(!istype(start))
		to_chat(src, "<span class='notice'>You are unable to move from here.</span>")
		return 0
		
	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	if(!destination)
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")
		return 0
	
	if(!start.CanZPass(src, direction))
		to_chat(src, "<span class='warning'>\The [start] is in the way.</span>")
		return 0

	if(!destination.CanZPass(src, direction))
		to_chat(src, "<span class='warning'>\The [destination] blocks your way.</span>")
		return 0

	var/area/area = get_area(src)
	if(direction == UP && area.has_gravity)
		var/obj/structure/lattice/lattice = locate() in destination.contents
		if(lattice)
			var/pull_up_time = max(5 SECONDS + (src.movement_delay() * 10), 1)
			to_chat(src, "<span class='notice'>You grab \the [lattice] and start pulling yourself upward...</span>")
			destination.audible_message("<span class='notice'>You hear something climbing up \the [lattice].</span>")
			if(do_after(src, pull_up_time))
				to_chat(src, "<span class='notice'>You pull yourself up.</span>")
			else
				to_chat(src, "<span class='warning'>You gave up on pulling yourself up.</span>")
				return 0
		else
			to_chat(src, "<span class='warning'>Gravity stops you from moving upward.</span>")
			return 0

	for(var/atom/A in destination)
		if(!A.CanPass(src, start, 1.5, 0))
			to_chat(src, "<span class='warning'>\The [A] blocks you.</span>")
			return 0
	Move(destination)
	return 1

/mob/observer/zMove(direction)
	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	if(destination)
		forceMove(destination)
	else
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")

/mob/observer/eye/zMove(direction)
	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	if(destination)
		setLoc(destination)
	else
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")

/mob/proc/can_ztravel()
	return 0

/mob/observer/can_ztravel()
	return 1

/mob/living/carbon/human/can_ztravel()
	if(incapacitated())
		return 0

	if(Process_Spacemove())
		return 1

	if(Check_Shoegrip())	//scaling hull with magboots
		for(var/turf/simulated/T in trange(1,src))
			if(T.density)
				return 1

/mob/living/silicon/robot/can_ztravel()
	if(incapacitated() || is_dead())
		return 0

	if(Process_Spacemove()) //Checks for active jetpack
		return 1

	for(var/turf/simulated/T in trange(1,src)) //Robots get "magboots"
		if(T.density)
			return 1

// TODO - Leshana Experimental

//Execution by grand piano!
/atom/movable/proc/get_fall_damage()
	return 42

//If atom stands under open space, it can prevent fall, or not
/atom/proc/can_prevent_fall(var/atom/movable/mover, var/turf/coming_from)
	return (!CanPass(mover, coming_from))

////////////////////////////



//FALLING STUFF

//Holds fall checks that should not be overriden by children
/atom/movable/proc/fall()
	if(!isturf(loc))
		return

	var/turf/below = GetBelow(src)
	if(!below)
		return

	var/turf/T = loc
	if(!T.CanZPass(src, DOWN) || !below.CanZPass(src, DOWN))
		return

	// No gravity in space, apparently.
	var/area/area = get_area(src)
	if(!area.has_gravity())
		return

	if(throwing)
		return

	if(can_fall())
		handle_fall(below)
		// TODO - handle fall on damage!

//For children to override
/atom/movable/proc/can_fall()
	if(anchored)
		return FALSE

	// See if something in current turf prevents us from falling out of it
	// TODO - Make this more generic
	if(locate(/obj/structure/lattice, loc))
		return FALSE
	if(locate(/obj/structure/catwalk, loc))
		return FALSE

	// See if something in turf below prevents us from falling into it.
	// TODO - Investigate - Doesn't this actually check if these atoms would prevent moving up INTO our current location!? Granted thats probably the same thing but still...
	var/turf/below = GetBelow(src)
	for(var/atom/A in below)
		if(!A.CanPass(src, src.loc))
			return FALSE

	return TRUE

/obj/effect/can_fall()
	return FALSE

/obj/effect/decal/cleanable/can_fall()
	return TRUE

/obj/item/pipe/can_fall()
	. = ..()

	if(anchored)
		return FALSE

	var/turf/below = GetBelow(src)
	if((locate(/obj/structure/disposalpipe/up) in below) || locate(/obj/machinery/atmospherics/pipe/zpipe/up in below))
		return FALSE

/mob/living/simple_animal/parrot/can_fall() // Poly can fly.
	return FALSE

/mob/living/simple_animal/hostile/carp/can_fall() // So can carp apparently.
	return FALSE

/atom/movable/proc/handle_fall(var/turf/landing)
	// Say something before it falls!
	var/turf/oldloc = loc
	// Now lets move there!
	Move(landing)

	// Detect if we made a soft landing.
	// TODO - Do this less snowflaky than hard coding stairs!
	if(locate(/obj/structure/stairs) in landing)
		return 1

	if(isopenspace(oldloc))
		visible_message("\The [src] falls down through \the [landing]!", "You hear something falling through the air.")
	// TODO - Detect if it will stop here becuase it lands on a catwalk or something
	if(isopenspace(landing))
		visible_message("\The [src] falls from the deck above through \the [landing]!", "You hear a whoosh of displaced air.")
		return 1 // Don't hit the open space - TODO-its not quite this simple ~Leshana
	else
		visible_message("\The [src] falls from the deck above and slams into \the [landing]!", "You hear something slam into the deck.")

/mob/living/carbon/human/handle_fall(var/turf/landing)
	if(..())
		return
	to_chat(src, "<span class='danger'>You fall off and hit \the [landing]!</span>")
	playsound(loc, "punch", 25, 1, -1)
	var/damage = 15 // Because wounds heal rather quickly, 15 should be enough to discourage jumping off but not be enough to ruin you, at least for the first time.
	apply_damage(rand(0, damage), BRUTE, BP_HEAD)
	apply_damage(rand(0, damage), BRUTE, BP_TORSO)
	apply_damage(rand(0, damage), BRUTE, BP_L_LEG)
	apply_damage(rand(0, damage), BRUTE, BP_R_LEG)
	apply_damage(rand(0, damage), BRUTE, BP_L_ARM)
	apply_damage(rand(0, damage), BRUTE, BP_R_ARM)
	Weaken(4)
	updatehealth()


// TODO - This is a hack until someone can think of a better way of solving it.
// Issue is that blood splatter is New()'d already in the turf, so Entered() is never called.
// Leshana - This should not be required anymore, we are handling items New()'d into turfs in the open space controller now
// TODO - Test
// /obj/effect/decal/cleanable/initialize()
// 	if(isopenspace(loc))
// 		src.fall()
// 	return ..()
