/obj/machinery/microwave
	name = "Microwave"
	desc = "Studies are inconclusive on whether pressing your face against the glass is harmful."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	layer = 2.9
	density = TRUE
	anchored = TRUE
	unacidable = TRUE
	use_power = USE_POWER_IDLE
	idle_power_usage = 5
	active_power_usage = 2000
	clicksound = "button"
	clickvol = "30"
	flags = OPENCONTAINER | NOREACT
	circuit = /obj/item/circuitboard/microwave
	var/operating = 0 // Is it on?
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/circuit_item_capacity = 1 //how many items does the circuit add to max number of items
	var/item_level = 0 // items microwave can handle, 0 foodstuff, 1 materials

	var/global/max_n_of_items = 20
	var/appliancetype = MICROWAVE
	var/datum/looping_sound/microwave/soundloop


//see code/modules/food/recipes_microwave.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/microwave/Initialize(mapload)
	. = ..()

	reagents = new/datum/reagents(100)
	reagents.my_atom = src

	default_apply_parts()

	if(!LAZYLEN(GLOB.available_recipes))
		for(var/datum/recipe/typepath as anything in subtypesof(/datum/recipe))
			if((initial(typepath.appliance) & appliancetype))
				GLOB.available_recipes += new typepath

		for (var/datum/recipe/recipe in GLOB.available_recipes)
			for (var/item in recipe.items)
				GLOB.acceptable_items |= item
			for (var/reagent in recipe.reagents)
				GLOB.acceptable_reagents |= reagent
		// This will do until I can think of a fun recipe to use dionaea in -
		// will also allow anything using the holder item to be microwaved into
		// impure carbon. ~Z
		GLOB.acceptable_items |= /obj/item/holder
		GLOB.acceptable_items |= /obj/item/reagent_containers/food/snacks/grown
		GLOB.acceptable_items |= /obj/item/soulstone
		GLOB.acceptable_items |= /obj/item/fuel_assembly/supermatter

	soundloop = new(list(src), FALSE)

/obj/machinery/microwave/Destroy()
	if(paicard)
		ejectpai() // Lets not delete the pAI.
	QDEL_NULL(soundloop)
	return ..()

/*******************
*   Item Adding
********************/

/obj/machinery/microwave/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.broken > 0)
		if(src.broken == 2 && O.has_tool_quality(TOOL_SCREWDRIVER)) // If it's broken and they're using a screwdriver
			user.visible_message( \
				span_infoplain(span_bold("\The [user]") + " starts to fix part of the microwave."), \
				span_notice("You start to fix part of the microwave.") \
			)
			playsound(src, O.usesound, 50, 1)
			if (do_after(user,20 * O.toolspeed))
				user.visible_message( \
					span_infoplain(span_bold("\The [user]") + " fixes part of the microwave."), \
					span_notice("You have fixed part of the microwave.") \
				)
				src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && O.has_tool_quality(TOOL_WRENCH)) // If it's broken and they're doing the wrench
			user.visible_message( \
				span_infoplain(span_bold("\The [user]") + " starts to fix part of the microwave."), \
				span_notice("You start to fix part of the microwave.") \
			)
			if (do_after(user,20 * O.toolspeed))
				user.visible_message( \
					span_infoplain(span_bold("\The [user]") + " fixes the microwave."), \
					span_notice("You have fixed the microwave.") \
				)
				src.icon_state = "mw"
				src.broken = 0 // Fix it!
				src.dirty = 0 // just to be sure
				src.flags = OPENCONTAINER | NOREACT
		else
			to_chat(user, span_warning("It's broken!"))
			return 1

	else if(src.dirty==100) // The microwave is all dirty so can't be used!
		if(istype(O, /obj/item/reagent_containers/spray/cleaner) || istype(O, /obj/item/soap)) // If they're trying to clean it then let them
			user.visible_message( \
				span_infoplain(span_bold("\The [user]") + " starts to clean the microwave."), \
				span_notice("You start to clean the microwave.") \
			)
			if (do_after(user,20))
				user.visible_message( \
					span_notice("\The [user] has cleaned the microwave."), \
					span_notice("You have cleaned the microwave.") \
				)
				src.dirty = 0 // It's clean!
				src.broken = 0 // just to be sure
				src.icon_state = "mw"
				src.flags = OPENCONTAINER | NOREACT
				SStgui.update_uis(src)
		else //Otherwise bad luck!!
			to_chat(user, span_warning("It's dirty!"))
			return 1
	else if(is_type_in_list(O,GLOB.acceptable_items))
		var/list/workingList = cookingContents()
		if(workingList.len>=(max_n_of_items + circuit_item_capacity))	//Adds component_parts to the maximum number of items. changed 1 to actually just be the circuit item capacity var.
			to_chat(user, span_warning("This [src] is full of ingredients, you cannot put more."))
			return 1
		if(istype(O, /obj/item/stack) && O:get_amount() > 1) // This is bad, but I can't think of how to change it
			var/obj/item/stack/S = O
			new O.type (src)
			S.use(1)
			user.visible_message( \
				span_notice("\The [user] has added one of [O] to \the [src]."), \
				span_notice("You add one of [O] to \the [src]."))
			update_static_data_for_all_viewers()
			return
		else
		//	user.remove_from_mob(O)	//This just causes problems so far as I can tell. -Pete - Man whoever you are, it's been years. o7
			user.drop_from_inventory(O,src)
			user.visible_message( \
				span_notice("\The [user] has added \the [O] to \the [src]."), \
				span_notice("You add \the [O] to \the [src]."))
			update_static_data_for_all_viewers()
			return
	else if (istype(O,/obj/item/storage/bag/plants)) // There might be a better way about making plant bags dump their contents into a microwave, but it works.
		var/obj/item/storage/bag/plants/bag = O
		var/failed = 1
		for(var/obj/item/G in O.contents)
			if(!G.reagents || !G.reagents.total_volume)
				continue
			failed = 0
			if(contents.len>=(max_n_of_items + component_parts.len + circuit_item_capacity))
				to_chat(user, span_warning("This [src] is full of ingredients, you cannot put more."))
				return 0
			else
				bag.remove_from_storage(G, src)
				contents += G
				if(contents.len>=(max_n_of_items + component_parts.len + circuit_item_capacity))
					break

		if(failed)
			to_chat(user, "Nothing in the plant bag is usable.")
			return 0

		if(!O.contents.len)
			to_chat(user, "You empty \the [O] into \the [src].")
		else
			to_chat(user, "You fill \the [src] from \the [O].")

		SStgui.update_uis(src)
		update_static_data_for_all_viewers()
		return 0

	else if(istype(O,/obj/item/reagent_containers/glass) || \
			istype(O,/obj/item/reagent_containers/food/drinks) || \
			istype(O,/obj/item/reagent_containers/food/condiment) \
		)
		if (!O.reagents)
			return 1
		for (var/datum/reagent/R in O.reagents.reagent_list)
			if (!(R.id in GLOB.acceptable_reagents))
				to_chat(user, span_warning("Your [O] contains components unsuitable for cookery."))
				return 1
		// gotta let afterattack resolve
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, update_static_data_for_all_viewers)), 1 SECOND)
		return
	else if(istype(O,/obj/item/grab))
		var/obj/item/grab/G = O
		to_chat(user, span_warning("This is ridiculous. You can not fit \the [G.affecting] in this [src]."))
		return 1
	else if(O.has_tool_quality(TOOL_SCREWDRIVER))
		default_deconstruction_screwdriver(user, O)
		return
	else if(O.has_tool_quality(TOOL_CROWBAR))
		if(default_deconstruction_crowbar(user, O))
			return
		else
			user.visible_message( \
				span_notice("\The [user] begins [src.anchored ? "unsecuring" : "securing"] the microwave."), \
				span_notice("You attempt to [src.anchored ? "unsecure" : "secure"] the microwave.")
				)
			if (do_after(user,20/O.toolspeed))
				user.visible_message( \
				span_notice("\The [user] [src.anchored ? "unsecures" : "secures"] the microwave."), \
				span_notice("You [src.anchored ? "unsecure" : "secure"] the microwave.")
				)
				src.anchored = !src.anchored
			else
				to_chat(user, span_notice("You decide not to do that."))
	else if(default_part_replacement(user, O))
		return
	else if(istype(O, /obj/item/paicard))
		if(!paicard)
			insertpai(user, O)
	else
		to_chat(user, span_warning("You have no idea what you can cook with this [O]."))
	..()
	SStgui.update_uis(src)

/obj/machinery/microwave/tgui_status(mob/user)
	if(user == paicard?.pai)
		return STATUS_INTERACTIVE
	. = ..()

/obj/machinery/microwave/tgui_state(mob/user)
	return GLOB.tgui_physical_state

/obj/machinery/microwave/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machinery/microwave/attack_hand(mob/user as mob)
	if(user.a_intent == I_GRAB)
		if(paicard)
			ejectpai(user)
			return
	user.set_machine(src)
	tgui_interact(user)

/*******************
*   Microwave Menu
********************/
/obj/machinery/microwave/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Microwave", name)
		ui.open()

/obj/machinery/microwave/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/kitchen_recipes),
		get_asset_datum(/datum/asset/simple/microwave)
	)

/obj/machinery/microwave/tgui_static_data(mob/user)
	var/list/data = ..()

	var/datum/recipe/recipe = select_recipe(GLOB.available_recipes,src)
	data["recipe"] = recipe ? sanitize_css_class_name("[recipe.type]") : null
	data["recipe_name"] = recipe ? initial(recipe.result:name) : null

	return data

/obj/machinery/microwave/tgui_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = ..()

	data["broken"] = broken
	data["operating"] = operating
	data["dirty"] = dirty == 100
	data["items"] = get_items_list()

	var/list/reagents_data = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		var/display_name = R.name
		if(R.id == REAGENT_ID_CAPSAICIN)
			display_name = "Hotsauce"
		if(R.id == REAGENT_ID_FROSTOIL)
			display_name = "Coldsauce"
		UNTYPED_LIST_ADD(reagents_data, list(
			"name" = display_name,
			"amt" = R.volume,
			"extra" = "unit[R.volume > 1 ? "s" : ""]",
			"color" = R.color,
		))
	data["reagents"] = reagents_data

	return data

/obj/machinery/microwave/proc/get_items_list()
	var/list/data = list()

	var/list/items_counts = list()
	var/list/items_measures = list()
	var/list/items_measures_p = list()
	var/list/icons = list()

	for(var/obj/O in cookingContents())
		var/display_name = O.name
		if(istype(O,/obj/item/reagent_containers/food/snacks/egg))
			items_measures[display_name] = "egg"
			items_measures_p[display_name] = "eggs"
		if(istype(O,/obj/item/reagent_containers/food/snacks/tofu))
			items_measures[display_name] = "tofu chunk"
			items_measures_p[display_name] = "tofu chunks"
		if(istype(O,/obj/item/reagent_containers/food/snacks/meat)) //any meat
			items_measures[display_name] = "slab of meat"
			items_measures_p[display_name] = "slabs of meat"
		if(istype(O,/obj/item/reagent_containers/food/snacks/donkpocket))
			display_name = "Turnovers"
			items_measures[display_name] = "turnover"
			items_measures_p[display_name] = "turnovers"
		if(istype(O,/obj/item/reagent_containers/food/snacks/carpmeat))
			items_measures[display_name] = "fillet of meat"
			items_measures_p[display_name] = "fillets of meat"
		items_counts[display_name]++
		icons[display_name] = list("icon" = O.icon, "icon_state" = O.icon_state)

	for(var/O in items_counts)
		var/N = items_counts[O]
		var/icon = icons[O]
		if(!(O in items_measures))
			data.Add(list(list(
				"name" = capitalize(O),
				"amt" = N,
				"extra" = "[lowertext(O)][N > 1 ? "s" : ""]",
				"icon" = icon,
			)))
		else
			data.Add(list(list(
				"name" = capitalize(O),
				"amt" = N,
				"extra" = N == 1 ? items_measures[O] : items_measures_p[O],
				"icon" = icon,
			)))

	return data

/obj/machinery/microwave/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE

	if(operating)
		return TRUE

	switch(action)
		if("cook")
			cook()
			return TRUE

		if("dispose")
			dispose()
			return TRUE

/***********************************
*   Microwave Menu Handling/Cooking
************************************/

/obj/machinery/microwave/proc/cook()
	if(stat & (NOPOWER|BROKEN))
		return
	start()
	if(reagents.total_volume==0 && !(locate(/obj) in cookingContents())) //dry run
		if(!wzhzhzh(16)) //VOREStation Edit - Quicker Microwaves (Undone during Auroraport, left note in case of reversion, was 5)
			abort()
			return
		abort()
		return

	var/datum/recipe/recipe = select_recipe(GLOB.available_recipes,src)
	var/obj/cooked
	if(!recipe)
		dirty += 1
		if(prob(max(10,dirty*5)))
			if(!wzhzhzh(16)) //VOREStation Edit - Quicker Microwaves (Undone during Auroraport, left note in case of reversion, was 2)
				abort()
				return
			muck_start()
			wzhzhzh(2) //VOREStation Edit - Quicker Microwaves (Undone during Auroraport, left note in case of reversion, was 2)
			muck_finish()
			cooked = fail()
			cooked.forceMove(src.loc)
		else if(has_extra_item())
			if(!wzhzhzh(16)) //VOREStation Edit - Quicker Microwaves (Undone during Auroraport, left note in case of reversion, was 2)
				abort()
				return
			broke()
			cooked = fail()
			cooked.forceMove(src.loc)
		else
			if(!wzhzhzh(40)) //VOREStation Edit - Quicker Microwaves (Undone during Auroraport, left note in case of reversion, was 5)
				abort()
				return
			stop()
			cooked = fail()
			cooked.forceMove(src.loc)
		return

	//Making multiple copies of a recipe
	var/halftime = round(recipe.time*4/10/2) // VOREStation Edit - Quicker Microwaves (Undone during Auroraport, left note in case of reversion, was round(recipe.time/20/2))
	if(!wzhzhzh(halftime))
		abort()
		return
	recipe.before_cook(src)
	if(!wzhzhzh(halftime))
		abort()
		cooked = fail()
		cooked.forceMove(loc)
		recipe.after_cook(src)
		return

	var/result = recipe.result
	var/valid = 1
	var/list/cooked_items = list()
	var/obj/temp = new /obj(src) //To prevent infinite loops, all results will be moved into a temporary location so they're not considered as inputs for other recipes
	while(valid)
		var/list/things = list()
		things.Add(recipe.make_food(src))
		cooked_items += things
		//Move cooked things to the buffer so they're not considered as ingredients
		for(var/atom/movable/AM in things)
			AM.forceMove(temp)

		valid = 0
		recipe.after_cook(src)
		recipe = select_recipe(GLOB.available_recipes,src)
		if(recipe && recipe.result == result)
			valid = 1
			sleep(2)

	for(var/atom/movable/R as anything in cooked_items)
		R.forceMove(src) //Move everything from the buffer back to the container

	QDEL_NULL(temp)//Delete buffer object

	//Any leftover reagents are divided amongst the foods
	var/total = reagents.total_volume
	for(var/obj/item/reagent_containers/food/snacks/S in cooked_items)
		reagents.trans_to_holder(S.reagents, total/cooked_items.len)

	for(var/obj/item/reagent_containers/food/snacks/S in cookingContents())
		S.cook()

	dispose(0) //clear out anything left
	stop()

	return

/obj/machinery/microwave/proc/wzhzhzh(var/seconds as num) // Whoever named this proc is fucking literally Satan. ~ Z
	for (var/i=1 to seconds)
		if (stat & (NOPOWER|BROKEN))
			return 0
		use_power(active_power_usage)
		sleep(5) //VOREStation Edit - Quicker Microwaves
	return 1

/obj/machinery/microwave/proc/has_extra_item() //- coded to have different microwaves be able to handle different items
	if(item_level == 0)
		for (var/obj/O in cookingContents())
			if ( \
					!istype(O,/obj/item/reagent_containers/food) && \
					!istype(O, /obj/item/grown) \
				)
				return 1
		return 0
	if(item_level == 1)
		for (var/obj/O in cookingContents())
			if ( \
					!istype(O, /obj/item/reagent_containers/food) && \
					!istype(O, /obj/item/grown) && \
					!istype(O, /obj/item/slime_extract) && \
					!istype(O, /obj/item/organ) && \
					!istype(O, /obj/item/stack/material) \
				)
				return 1
		return 0

/obj/machinery/microwave/proc/start()
	src.visible_message(span_notice("The microwave turns on."), span_notice("You hear a microwave."))
	soundloop.start()
	src.operating = TRUE
	src.icon_state = "mw1"
	SStgui.update_uis(src)

/obj/machinery/microwave/proc/abort()
	operating = FALSE // Turn it off again aferwards
	if(icon_state == "mw1")
		icon_state = "mw"
	SStgui.update_uis(src)
	soundloop.stop()

/obj/machinery/microwave/proc/stop()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	operating = FALSE // Turn it off again aferwards
	if(icon_state == "mw1")
		icon_state = "mw"
	SStgui.update_uis(src)
	soundloop.stop()

/obj/machinery/microwave/proc/dispose(var/message = 1)
	for (var/atom/movable/A in cookingContents())
		A.forceMove(loc)
	if (src.reagents.total_volume)
		src.dirty++
	src.reagents.clear_reagents()
	if(message)
		to_chat(usr, span_notice("You dispose of the microwave contents."))
	SStgui.update_uis(src)

/obj/machinery/microwave/proc/muck_start()
	playsound(src, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	src.icon_state = "mwbloody1" // Make it look dirty!!

/obj/machinery/microwave/proc/muck_finish()
	src.visible_message(span_warning("The microwave gets covered in muck!"))
	src.dirty = 100 // Make it dirty so it can't be used util cleaned
	src.flags = null //So you can't add condiments
	src.icon_state = "mwbloody0" // Make it look dirty too
	src.operating = 0 // Turn it off again aferwards
	SStgui.update_uis(src)
	soundloop.stop()


/obj/machinery/microwave/proc/broke()
	var/datum/effect/effect/system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	src.icon_state = "mwb" // Make it look all busted up and shit
	src.visible_message(span_warning("The microwave breaks!")) //Let them know they're stupid
	src.broken = 2 // Make it broken so it can't be used util fixed
	src.flags = null //So you can't add condiments
	src.operating = 0 // Turn it off again aferwards
	SStgui.update_uis(src)
	soundloop.stop()
	src.ejectpai() // If it broke, time to yeet the PAI.

/obj/machinery/microwave/proc/fail()
	var/obj/item/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for (var/obj/O in cookingContents() - ffuu)
		amount++
		if(O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if(id)
				amount+=O.reagents.get_reagent_amount(id)
		if(istype(O, /obj/item/holder))
			var/obj/item/holder/H = O
			if(H.held_mob)
				qdel(H.held_mob)
		qdel(O)
	src.reagents.clear_reagents()
	ffuu.reagents.add_reagent(REAGENT_ID_CARBON, amount)
	ffuu.reagents.add_reagent(REAGENT_ID_TOXIN, amount/10)
	return ffuu

/obj/machinery/microwave/verb/Eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject content"
	usr.visible_message(
	span_notice("[usr] tries to open [src] and remove its contents.") ,
	span_notice("You try to open [src] and remove its contents.")
	)

	if(!do_after(usr, 1 SECONDS, target = src))
		return

	if(operating)
		to_chat(usr, span_warning("You can't do that, [src] door is locked!"))
		return

	usr.visible_message(
	span_notice("[usr] opened [src] and has taken out [english_list(cookingContents())].") ,
	span_notice("You have opened [src] and taken out [english_list(cookingContents())].")
	)
	dispose()

/obj/machinery/microwave/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!mover)
		return 1
	if(mover.checkpass(PASSTABLE))
	//Animals can run under them, lots of empty space
		return 1
	return ..()

/obj/machinery/microwave/advanced // specifically for complex recipes
	name = "deluxe microwave"
	icon = 'icons/obj/deluxemicrowave.dmi'
	icon_state = "mw"
	circuit = /obj/item/circuitboard/microwave/advanced
	circuit_item_capacity = 100
	item_level = 1

/obj/machinery/microwave/advanced/Initialize(mapload)
	. = ..()
	reagents.maximum_volume = 1000

/datum/recipe/splat // We use this to handle cooking micros (or mice, etc) in a microwave. Janky but it works better than snowflake code to handle the same thing.
	items = list(
		/obj/item/holder
	)
	result = /obj/effect/decal/cleanable/blood/gibs
	wiki_flag = WIKI_SPOILER

/datum/recipe/splat/before_cook(obj/container)
	if(istype(container, /obj/machinery/microwave))
		var/obj/machinery/microwave/M = container
		M.muck_start()
		playsound(container.loc, 'sound/items/drop/flesh.ogg', 100, 1)
	. = ..()

/datum/recipe/splat/make_food(obj/container)
	for(var/obj/item/holder/H in container)
		if(H.held_mob)
			to_chat(H.held_mob, span_danger("You hear an earsplitting humming and your head aches!"))
			qdel(H.held_mob)
			H.held_mob = null
			qdel(H)

	. = ..()

/datum/recipe/splat/after_cook(obj/container)
	if(istype(container, /obj/machinery/microwave))
		var/obj/machinery/microwave/M = container
		M.muck_finish()
	.  = ..()

/obj/machinery/microwave/proc/cookingContents() //VOREEdit, this is a better way to deal with the contents of a microwave, since the previous method is stupid.
	var/list/workingList = contents.Copy() // Using the copy proc because otherwise the two lists seem to become soul bonded.
	workingList -= component_parts
	workingList -= circuit
	if(paicard)
		workingList -= paicard
	for(var/M in workingList)
		if(istype(M, circuit)) // Yes, we remove circuit twice. Yes, it's necessary. Yes, it's stupid.
			workingList -= M
	return workingList
