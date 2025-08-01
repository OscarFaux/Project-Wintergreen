//Todo: add leather and cloth for arbitrary coloured stools.

/obj/item/stool
	name = "stool"
	desc = "Apply butt."
	icon = 'icons/obj/furniture_vr.dmi' //VOREStation Edit - new Icons
	icon_state = "stool_preview" //set for the map
	randpixel = 0
	center_of_mass_x = 0
	center_of_mass_y = 0
	force = 10
	throwforce = 10
	w_class = ITEMSIZE_HUGE
	var/base_icon = "stool_base"
	var/datum/material/material
	var/datum/material/padding_material

/obj/item/stool/padded
	icon_state = "stool_padded_preview" //set for the map

/obj/item/stool/Initialize(mapload, var/new_material, var/new_padding_material)
	. = ..()
	if(!new_material)
		new_material = MAT_STEEL
	material = get_material_by_name(new_material)
	if(new_padding_material)
		padding_material = get_material_by_name(new_padding_material)
	if(!istype(material))
		return INITIALIZE_HINT_QDEL
	force = round(material.get_blunt_damage()*0.4)
	update_icon()

/obj/item/stool/padded/Initialize(mapload, var/new_material)
	. = ..(mapload, MAT_STEEL, MAT_CARPET)

/obj/item/stool/update_icon()
	// Prep icon.
	icon_state = ""
	cut_overlays()
	// Base icon.
	var/cache_key = "[base_icon]-[material.name]"
	if(isnull(GLOB.stool_cache[cache_key]))
		var/image/I = image(icon, base_icon)
		I.color = material.icon_colour
		GLOB.stool_cache[cache_key] = I
	add_overlay(GLOB.stool_cache[cache_key])
	// Padding overlay.
	if(padding_material)
		var/padding_cache_key = "[base_icon]-padding-[padding_material.name]"
		if(isnull(GLOB.stool_cache[padding_cache_key]))
			var/image/I =  image(icon, "[base_icon]_padding") //VOREStation Edit
			I.color = padding_material.icon_colour
			GLOB.stool_cache[padding_cache_key] = I
		add_overlay(GLOB.stool_cache[padding_cache_key])
	// Strings.
	if(padding_material)
		name = "[padding_material.display_name] [initial(name)]" //this is not perfect but it will do for now.
		desc = "A padded stool. Apply butt. It's made of [material.use_name] and covered with [padding_material.use_name]."
	else
		name = "[material.display_name] [initial(name)]"
		desc = "A stool. Apply butt with care. It's made of [material.use_name]."

/obj/item/stool/proc/add_padding(var/padding_type)
	padding_material = get_material_by_name(padding_type)
	update_icon()

/obj/item/stool/proc/remove_padding()
	if(padding_material)
		padding_material.place_sheet(get_turf(src), 1)
		padding_material = null
	update_icon()

/obj/item/stool/attack(mob/M as mob, mob/user as mob)
	if (prob(5) && isliving(M))
		user.visible_message(span_danger("[user] breaks [src] over [M]'s back!"))
		user.setClickCooldown(user.get_attack_speed())
		user.do_attack_animation(M)

		user.drop_from_inventory(src)

		user.remove_from_mob(src)
		dismantle()
		qdel(src)
		var/mob/living/T = M
		T.Weaken(10)
		T.apply_damage(20)
		return
	..()

/obj/item/stool/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return

/obj/item/stool/proc/dismantle()
	if(material)
		material.place_sheet(get_turf(src), 1)
	if(padding_material)
		padding_material.place_sheet(get_turf(src), 1)
	qdel(src)

/obj/item/stool/attackby(obj/item/W as obj, mob/user as mob)
	if(W.has_tool_quality(TOOL_WRENCH))
		playsound(src, W.usesound, 50, 1)
		dismantle()
		qdel(src)
	else if(istype(W,/obj/item/stack))
		if(padding_material)
			to_chat(user, "\The [src] is already padded.")
			return
		var/obj/item/stack/C = W
		if(C.get_amount() < 1) // How??
			user.drop_from_inventory(C)
			qdel(C)
			return
		var/padding_type //This is awful but it needs to be like this until tiles are given a material var.
		if(istype(W,/obj/item/stack/tile/carpet))
			padding_type = MAT_CARPET
		else if(istype(W,/obj/item/stack/material))
			var/obj/item/stack/material/M = W
			if(M.material && (M.material.flags & MATERIAL_PADDING))
				padding_type = "[M.material.name]"
		if(!padding_type)
			to_chat(user, "You cannot pad \the [src] with that.")
			return
		C.use(1)
		if(!istype(src.loc, /turf))
			user.drop_from_inventory(src)
			src.loc = get_turf(src)
		to_chat(user, "You add padding to \the [src].")
		add_padding(padding_type)
		return
	else if (W.has_tool_quality(TOOL_WIRECUTTER))
		if(!padding_material)
			to_chat(user, "\The [src] has no padding to remove.")
			return
		to_chat(user, "You remove the padding from \the [src].")
		playsound(src, W.usesound, 50, 1)
		remove_padding()
	else
		..()
