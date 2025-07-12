// Project Wintergreen: Water Pressure System Scaffold

#define NORTH 1
#define SOUTH 2
#define EAST 4
#define WEST 8

// Subsystem constants fallback
#define INIT_ORDER_LATE 999
#define SS_BACKGROUND 1
#define SS_NO_FIRE_FIRST_TICK 2
#define INITIALIZE_SUCCESS 1

/area/var/flooded = FALSE

/atom/var/pressure_threshold
/obj/structure/window/var/cracking = FALSE
/obj/structure/window/var/time_to_fail

/datum/controller/subsystem/pressure
	name = "Pressure"
	init_order = INIT_ORDER_LATE
	wait = 20
	priority = 50
	flags = SS_BACKGROUND | SS_NO_FIRE_FIRST_TICK

	var/list/pressure_boundaries = list()

/datum/controller/subsystem/pressure/Initialize()
	..
	for(var/turf/simulated/wall/W in world)
		if(is_external_wall(W))
			W.pressure_threshold = 404
			pressure_boundaries += W
	for(var/obj/structure/window/Win in world)
		if(is_external_window(Win))
			Win.pressure_threshold = 303
			Win.time_to_fail = 100
			pressure_boundaries += Win
	return INITIALIZE_SUCCESS

/datum/controller/subsystem/pressure/fire()
	for(var/atom/A in pressure_boundaries.Copy())
		if(!A || QDELETED(A) || A.gc_destroyed)
			pressure_boundaries.Remove(A)
			continue

		var/turf/T = get_turf(A)
		var/depth = get_adjacent_water_depth(T)
		if(!depth)
			continue

		var/pressure = depth * 101
		var/int_pressure = 101
		var/diff = pressure - int_pressure

		if(A.pressure_threshold && diff > A.pressure_threshold)
			if(istype(A, /obj/structure/window))
				var/obj/structure/window/W = A
				if(!W.cracking)
					W.cracking = TRUE
					// playsound(W, 'sound/effects/glass_crack.ogg', 100, TRUE)
					spawn(W.time_to_fail)
						if(W && !QDELETED(W))
							handle_blowout(W, depth)
							pressure_boundaries.Remove(W)
				continue
			handle_blowout(A, depth)
			pressure_boundaries.Remove(A)

/proc/is_external_wall(turf/T)
	for(var/dir in list(NORTH, SOUTH, EAST, WEST))
		var/turf/adj = get_step(T, dir)
		if(istype(adj, /turf/simulated/floor/water))
			return TRUE
	return FALSE

/proc/is_external_window(obj/O)
	var/turf/T = get_turf(O)
	for(var/dir in list(NORTH, SOUTH, EAST, WEST))
		var/turf/adj = get_step(T, dir)
		if(istype(adj, /turf/simulated/floor/water))
			return TRUE
	return FALSE

/proc/get_adjacent_water_depth(turf/T)
	for(var/dir in list(NORTH, SOUTH, EAST, WEST))
		var/turf/adj = get_step(T, dir)
		if(istype(adj, /turf/simulated/floor/water))
			var/turf/simulated/floor/water/water_adj = adj
			return water_adj.depth
	return 0

/proc/handle_blowout(atom/loc, depth)
	var/area/floodArea = get_area(loc)
	if(floodArea)
		floodArea.flooded = TRUE

		for(var/turf/T in floodArea)
			if(!istype(T, /turf/simulated/floor/water))
				var/turf/simulated/floor/water/newTurf = new /turf/simulated/floor/water/underwater(T.loc)
				newTurf.depth = depth
				qdel(T)

		for(var/mob/living/M in floodArea)
			M.adjustBruteLoss(rand(10, 30))

		for(var/obj/structure/window/Win in floodArea)
			if(prob(50))
				qdel(Win)

		world << "<span class='alert'>[floodArea.name] is rapidly flooding as water bursts in!</span>"
		// playsound(world, 'sound/machines/alert1.ogg', 100, TRUE)
