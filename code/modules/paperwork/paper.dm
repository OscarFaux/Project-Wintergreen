/*
 * Paper
 * also scraps of paper
 */

/obj/item/paper
	name = "sheet of paper"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = ITEMSIZE_TINY
	throw_range = 1
	throw_speed = 1
	plane = MOB_PLANE
	layer = MOB_LAYER
	pressure_resistance = 1
	slot_flags = SLOT_HEAD
	body_parts_covered = HEAD
	attack_verb = list("bapped")
	drop_sound = 'sound/items/drop/paper.ogg'
	pickup_sound = 'sound/items/pickup/paper.ogg'

	var/info		//What's actually written on the paper.
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/stamps		//The (text for the) stamps on the paper.
	var/fields		//Amount of user created fields
	var/free_space = MAX_PAPER_MESSAGE_LEN
	var/list/stamped
	var/list/ico[0]      //Icons and
	var/list/offset_x[0] //offsets stored for later
	var/list/offset_y[0] //usage by the photocopier
	var/rigged = 0
	var/spam_flag = 0
	var/age = 0
	var/last_modified_ckey

	var/was_maploaded = FALSE // This tracks if the paper was created on mapload.

	var/const/deffont = "Verdana"
	var/const/signfont = "Times New Roman"
	var/const/crayonfont = "Comic Sans MS"

/obj/item/paper/card
	name = "blank card"
	desc = "A gift card with space to write on the cover."
	icon_state = "greetingcard"
	slot_flags = null //no fun allowed!!!!

/obj/item/paper/card/AltClick() //No fun allowed
	return

/obj/item/paper/card/update_icon()
	return

/obj/item/paper/card/smile
	name = "happy card"
	desc = "A gift card with a smiley face on the cover."
	icon_state = "greetingcard_smile"

/obj/item/paper/card/cat
	name = "cat card"
	desc = "A gift card with a cat on the cover."
	icon_state = "greetingcard_cat"

/obj/item/paper/card/flower
	name = "flower card"
	desc = "A gift card with a flower on the cover."
	icon_state = "greetingcard_flower"

/obj/item/paper/card/heart
	name = "heart card"
	desc = "A gift card with a heart on the cover."
	icon_state = "greetingcard_heart"

/obj/item/paper/alien
	name = "alien tablet"
	desc = "It looks highly advanced"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alienpaper"

/obj/item/paper/alien/update_icon()
	if(info)
		icon_state = "alienpaper_words"
	else
		icon_state = "alienpaper"

/obj/item/paper/alien/burnpaper()
	return

/obj/item/paper/alien/AltClick() // No airplanes for me.
	return

//lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!

/obj/item/paper/Initialize(mapload, var/text, var/title)
	. = ..()

	if(istext(title))
		name = title
	if(istext(text))
		info = text

	if(mapload) // Jank, but we do this to prevent maploaded papers from somehow stacking across rounds if re-added to the board by a player.
		was_maploaded = TRUE

	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	stamps = ""

	if(!isnull(title))
		name = title

	if(name != "paper")
		desc = "This is a paper titled '" + name + "'."

	if(!isnull(text))
		info = text

	if(info != initial(info))
		info = html_encode(info)
		info = replacetext(info, "\n", "<BR>")
		info = parsepencode(info)

	update_icon()
	update_space(info)
	updateinfolinks()

/obj/item/paper/update_icon()
	if(icon_state == "paper_talisman")
		return
	if(info)
		icon_state = "paper_words"
		return
	icon_state = "paper"

/obj/item/paper/proc/update_space(var/new_text)
	if(!new_text)
		return

	free_space -= length(strip_html_properly(new_text))

/obj/item/paper/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		show_content(user)
	else
		. += span_notice("You have to go closer if you want to read it.")

/obj/item/paper/proc/show_content(var/mob/user, var/forceshow=0)
	if(!(forceshow || (ishuman(user) || isobserver(user) || issilicon(user) || (istype(user) && user.universal_understand))))
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)][stamps]</BODY></HTML>", "window=[name]")
		onclose(user, "[name]")
	else
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info][stamps]</BODY></HTML>", "window=[name]")
		onclose(user, "[name]")

/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if((CLUMSY in usr.mutations) && prob(50))
		to_chat(usr, span_warning("You cut yourself on the paper."))
		return
	var/n_name = sanitizeSafe(tgui_input_text(usr, "What would you like to label the paper?", "Paper Labelling", null, MAX_NAME_LEN), MAX_NAME_LEN)

	// We check loc one level up, so we can rename in clipboards and such. See also: /obj/item/photo/rename()
	if((loc == usr || loc.loc && loc.loc == usr) && usr.stat == 0 && n_name)
		name = n_name
		if(n_name != "paper")
			desc = "This is a paper titled '" + name + "'."

		add_fingerprint(usr)
	return

/obj/item/paper/attack_self(mob/living/user as mob)
	if(user.a_intent == I_HURT)
		if(icon_state == "scrap")
			user.show_message(span_warning("\The [src] is already crumpled."))
			return
		//crumple dat paper
		info = stars(info,85)
		user.visible_message("\The [user] crumples \the [src] into a ball!")
		playsound(src, 'sound/bureaucracy/papercrumple.ogg', 50, 1)
		icon_state = "scrap"
		return
	user.examinate(src)
	if(rigged && (GLOB.Holiday == "April Fool's Day"))
		if(spam_flag == 0)
			spam_flag = 1
			playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
	return

/obj/item/paper/attack_ai(var/mob/living/silicon/ai/user)
	var/dist
	if(istype(user) && user.camera) //is AI
		dist = get_dist(src, user.camera)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(dist < 2)
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info][stamps]</BODY></HTML>", "window=[name]")
		onclose(user, "[name]")
	else
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)][stamps]</BODY></HTML>", "window=[name]")
		onclose(user, "[name]")
	return

/obj/item/paper/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(user.zone_sel.selecting == O_EYES)
		user.visible_message(span_notice("You show the paper to [M]. "), \
			span_notice(" [user] holds up a paper and shows it to [M]. "))
		M.examinate(src)

	else if(user.zone_sel.selecting == O_MOUTH) // lipstick wiping
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, span_notice("You wipe off the lipstick with [src]."))
				H.lip_style = null
				H.update_icons_body()
			else
				user.visible_message(span_warning("[user] begins to wipe [H]'s lipstick off with \the [src]."), \
										span_notice("You begin to wipe off [H]'s lipstick."))
				if(do_after(user, 10) && do_after(H, 10, 5, 0))	//user needs to keep their active hand, H does not.
					user.visible_message(span_notice("[user] wipes [H]'s lipstick off with \the [src]."), \
											span_notice("You wipe off [H]'s lipstick."))
					H.lip_style = null
					H.update_icons_body()

/obj/item/paper/proc/set_content(text,title)
	if(title)
		name = title
	info = html_encode(text)
	info = parsepencode(text)
	update_icon()
	update_space(info)
	updateinfolinks()

/obj/item/paper/proc/addtofield(var/id, var/text, var/links = 0)
	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(1) // I know this can cause infinite loops and fuck up the whole server, but the if(istart==0) should be safe as fuck
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"paper_field\">", laststart)

		if(istart==0)
			return // No field found with matching id

		laststart = istart+1
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext(info_links, "</span>", istart)
			else
				iend = findtext(info, "</span>", istart)

			//textindex = istart+26
			textindex = iend
			break

	if(links)
		var/before = copytext(info_links, 1, textindex)
		var/after = copytext(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext(info, 1, textindex)
		var/after = copytext(info, textindex)
		info = before + text + after
		updateinfolinks()

/obj/item/paper/proc/updateinfolinks()
	info_links = info
	var/i = 0
	for(i=1,i<=fields,i++)
		addtofield(i, "<font face=\"[deffont]\"><A href='byond://?src=\ref[src];write=[i]'>write</A></font>", 1)
	info_links = info_links + "<font face=\"[deffont]\"><A href='byond://?src=\ref[src];write=end'>write</A></font>"


/obj/item/paper/proc/clearpaper()
	info = null
	stamps = null
	free_space = MAX_PAPER_MESSAGE_LEN
	stamped = list()
	cut_overlays()
	updateinfolinks()
	update_icon()

/obj/item/paper/proc/get_signature(var/obj/item/pen/P, mob/user as mob)
	if(P && istype(P, /obj/item/pen))
		return P.get_signature(user)
	return (user && user.real_name) ? user.real_name : "Anonymous"

/obj/item/paper/proc/parsepencode(var/t, var/obj/item/pen/P, mob/user as mob, var/iscrayon = 0)
//	t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)

	t = replacetext(t, "\[center\]", "<center>")
	t = replacetext(t, "\[/center\]", "</center>")
	t = replacetext(t, "\[br\]", "<BR>")
	t = replacetext(t, "\[b\]", "<B>")
	t = replacetext(t, "\[/b\]", "</B>")
	t = replacetext(t, "\[i\]", "<I>")
	t = replacetext(t, "\[/i\]", "</I>")
	t = replacetext(t, "\[u\]", "<U>")
	t = replacetext(t, "\[/u\]", "</U>")
	t = replacetext(t, "\[time\]", "[stationtime2text()]")
	t = replacetext(t, "\[date\]", "[stationdate2text()]")
	t = replacetext(t, "\[station\]", "[station_name()]")
	t = replacetext(t, "\[large\]", "<font size=\"4\">")
	t = replacetext(t, "\[/large\]", "</font>")
	if(findtext(t, "\[sign\]"))
		t = replacetext(t, "\[sign\]", "<font face=\"[signfont]\"><i>[get_signature(P, user)]</i></font>")
	t = replacetext(t, "\[field\]", "<span class=\"paper_field\"></span>")

	t = replacetext(t, "\[h1\]", "<H1>")
	t = replacetext(t, "\[/h1\]", "</H1>")
	t = replacetext(t, "\[h2\]", "<H2>")
	t = replacetext(t, "\[/h2\]", "</H2>")
	t = replacetext(t, "\[h3\]", "<H3>")
	t = replacetext(t, "\[/h3\]", "</H3>")
	t = replacetext(t, "\[tab\]", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")

	if(!iscrayon)
		t = replacetext(t, "\[*\]", "<li>")
		t = replacetext(t, "\[hr\]", "<HR>")
		t = replacetext(t, "\[small\]", "<font size = \"1\">")
		t = replacetext(t, "\[/small\]", "</font>")
		t = replacetext(t, "\[list\]", "<ul>")
		t = replacetext(t, "\[/list\]", "</ul>")
		t = replacetext(t, "\[table\]", "<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>")
		t = replacetext(t, "\[/table\]", "</td></tr></table>")
		t = replacetext(t, "\[grid\]", "<table>")
		t = replacetext(t, "\[/grid\]", "</td></tr></table>")
		t = replacetext(t, "\[row\]", "</td><tr>")
		t = replacetext(t, "\[/row\]", "")
		t = replacetext(t, "\[cell\]", "<td>")
		t = replacetext(t, "\[/cell\]", "")
		t = replacetext(t, "\[logo\]", "<img src=\ref['html/images/ntlogo.png']>")
		t = replacetext(t, "\[sglogo\]", "<img src=\ref['html/images/sglogo.png']>")
		t = replacetext(t, "\[trlogo\]", "<img src=\ref['html/images/trader.png']>")
		// t = replacetext(t, "\[pclogo\]", "<img src=\ref['html/images/pclogo.png']>") // Not available on virgo

		t = "<font face=\"[deffont]\" color=[P ? P.colour : "black"]>[t]</font>"
	else // If it is a crayon, and he still tries to use these, make them empty!
		t = replacetext(t, "\[*\]", "")
		t = replacetext(t, "\[hr\]", "")
		t = replacetext(t, "\[small\]", "")
		t = replacetext(t, "\[/small\]", "")
		t = replacetext(t, "\[list\]", "")
		t = replacetext(t, "\[/list\]", "")
		t = replacetext(t, "\[table\]", "")
		t = replacetext(t, "\[/table\]", "")
		t = replacetext(t, "\[row\]", "")
		t = replacetext(t, "\[cell\]", "")
		t = replacetext(t, "\[/cell\]", "")
		t = replacetext(t, "\[/row\]", "")
		t = replacetext(t, "\[logo\]", "")
		t = replacetext(t, "\[sglogo\]", "")

		t = "<font face=\"[crayonfont]\" color=[P ? P.colour : "black"]><b>[t]</b></font>"


//	t = replacetext(t, "#", "") // Junk converted to nothing!

//Count the fields
	var/laststart = 1
	while(1)
		var/i = findtext(t, "<span class=\"paper_field\">", laststart)	//</span>
		if(i==0)
			break
		laststart = i+1
		fields++

	return t

/obj/item/paper/proc/burnpaper(obj/item/flame/P, mob/user)
	var/class = "warning"
	var/datum/gender/TU = GLOB.gender_datums[user.get_visible_gender()]

	if(P.lit && !user.restrained())
		if(istype(P, /obj/item/flame/lighter/zippo))
			class = "rose"

		user.visible_message("<span class='[class]'>[user] holds \the [P] up to \the [src], it looks like [TU.hes] trying to burn it!</span>", \
		"<span class='[class]'>You hold \the [P] up to \the [src], burning it slowly.</span>")
		playsound(src, 'sound/bureaucracy/paperburn.ogg', 50, 1)

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message("<span class='[class]'>[user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
				"<span class='[class]'>You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")

				if(user.get_inactive_hand() == src)
					user.drop_from_inventory(src)

				new /obj/effect/decal/cleanable/ash(src.loc)
				qdel(src)

			else
				to_chat(user, span_red("You must hold \the [P] steady to burn \the [src]."))


/obj/item/paper/Topic(href, href_list)
	..()
	if(!usr || (usr.stat || usr.restrained()))
		return

	if(href_list["write"])
		var/id = href_list["write"]
		//var/t = strip_html_simple(tgui_input_text(usr, "What text do you wish to add to " + (id=="end" ? "the end of the paper" : "field "+id) + "?", "[name]", null, multiline=TRUE),8192)

		if(free_space <= 0)
			to_chat(usr, span_info("There isn't enough space left on \the [src] to write anything."))
			return

		var/raw = tgui_input_text(usr, "Enter what you want to write:", "Write", multiline = TRUE, prevent_enter = TRUE)
		if(!raw)
			return

		var/t =  sanitize(raw, MAX_PAPER_MESSAGE_LEN, extra = 0)
		if(!t)
			return

		var/obj/item/i = usr.get_active_hand() // Check to see if he still got that darn pen, also check if he's using a crayon or pen.
		var/iscrayon = 0
		if(!istype(i, /obj/item/pen))
			tgui_alert(usr, "You aren't holding a pen anymore! If you want to keep your work, grab one.", "No Pen!") // Should remain tgui_alert() (blocking)
			i = usr.get_active_hand()

		if(!istype(i, /obj/item/pen))
			var/mob/living/M = usr
			if(istype(M) && M.back && istype(M.back,/obj/item/rig))
				var/obj/item/rig/r = M.back
				var/obj/item/rig_module/device/pen/m = locate(/obj/item/rig_module/device/pen) in r.installed_modules
				if(!r.offline && m)
					i = m.device
				else
					return
			else
				return

		if(istype(i, /obj/item/pen/crayon))
			iscrayon = 1


		// if paper is not in usr, then it must be near them, or in a clipboard or folder, which must be in or near usr
		if(istype(loc, /obj/item/clipboard) || istype(loc, /obj/structure/noticeboard) || istype(loc, /obj/item/folder))
			if(loc.loc != usr && !in_range(loc, usr))
				return
		else if(loc != usr && !Adjacent(usr))
			return

/*
		t = checkhtml(t)

		// check for exploits
		for(var/bad in paper_blacklist)
			if(findtext(t,bad))
				to_chat(usr, span_blue("You think to yourself, \"Hm.. this is only paper...\""))
				log_admin("PAPER: [usr] ([usr.ckey]) tried to use forbidden word in [src]: [bad].")
				message_admins("PAPER: [usr] ([usr.ckey]) tried to use forbidden word in [src]: [bad].")
				return
*/

		var last_fields_value = fields

		//t = html_encode(t)
		t = replacetext(t, "\n", "<BR>")
		t = parsepencode(t, i, usr, iscrayon) // Encode everything from pencode to html
		was_maploaded = FALSE // Set this to FALSE because a user has written on us. This is for persistence purposes.


		if(fields > 50)//large amount of fields creates a heavy load on the server, see updateinfolinks() and addtofield()
			to_chat(usr, span_warning("Too many fields. Sorry, you can't do this."))
			fields = last_fields_value
			return

		if(id!="end")
			addtofield(text2num(id), t) // He wants to edit a field, let him.
		else
			info += t // Oh, he wants to edit to the end of the file, let him.
			updateinfolinks()

		last_modified_ckey = usr.ckey

		update_space(t)

		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links][stamps]</BODY></HTML>", "window=[name]") // Update the window

		playsound(src, pick('sound/bureaucracy/pen1.ogg','sound/bureaucracy/pen2.ogg'), 10)

		update_icon()

/obj/item/paper/get_worn_icon_state(var/slot_name)
	if(slot_name == slot_head_str)
		return "paper" //Gross, but required for now.
	return ..()

/obj/item/paper/attackby(obj/item/P, mob/user)
	..()
	var/clown = 0
	if(user.mind && (user.mind.assigned_role == JOB_CLOWN))
		clown = 1

	if(istype(P, /obj/item/tape_roll))
		var/obj/item/tape_roll/tape = P
		tape.stick(src, user)
		return

	if(istype(P, /obj/item/clipboard))
		var/obj/item/clipboard/CB = P
		if(src.loc == user)
			user.drop_from_inventory(src)
		src.loc = CB
		CB.toppaper = src
		CB.update_icon()
		to_chat(user, span_notice("You clip the [src] onto \the [CB]."))

	if(istype(P, /obj/item/folder))
		if(src.loc == user)
			user.drop_from_inventory(src)
		src.loc = P
		P.update_icon()
		to_chat(user, span_notice("You tuck the [src] into \the [P]."))

	if(istype(P, /obj/item/paper) || istype(P, /obj/item/photo))
		if (istype(P, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/C = P
			if (!C.iscopy && !C.copied)
				to_chat(user, span_notice("Take off the carbon copy first."))
				add_fingerprint(user)
				return
		var/obj/item/paper_bundle/B = new(src.loc)
		if (name != initial(name))
			B.name = name
		else if (P.name != initial(P.name))
			B.name = P.name
		user.drop_from_inventory(P)
		if (ishuman(user))
			var/mob/living/carbon/human/h_user = user
			if (h_user.r_hand == src)
				h_user.drop_from_inventory(src)
				h_user.put_in_r_hand(B)
			else if (h_user.l_hand == src)
				h_user.drop_from_inventory(src)
				h_user.put_in_l_hand(B)
			else if (h_user.l_store == src)
				h_user.drop_from_inventory(src)
				if(!h_user.equip_to_slot_if_possible(B, slot_l_store))
					h_user.drop_from_inventory(B)
			else if (h_user.r_store == src)
				h_user.drop_from_inventory(src)
				if(!h_user.equip_to_slot_if_possible(B, slot_r_store))
					h_user.drop_from_inventory(B)
			else if (h_user.head == src)
				h_user.u_equip(src)
				h_user.put_in_hands(B)
			else if (!istype(src.loc, /turf))
				src.loc = get_turf(h_user)
				if(h_user.client)	h_user.client.screen -= src
				h_user.put_in_hands(B)
		to_chat(user, span_notice("You clip the [P.name] to [(src.name == "paper") ? "the paper" : src.name]."))
		src.loc = B
		P.loc = B

		B.pages.Add(src)
		B.pages.Add(P)
		B.update_icon()

	else if(istype(P, /obj/item/pen))
		if(icon_state == "scrap")
			to_chat(user, span_warning("\The [src] is too crumpled to write on."))
			return

		var/obj/item/pen/robopen/RP = P
		if ( istype(RP) && RP.mode == 2 )
			RP.RenamePaper(user,src)
		else
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links][stamps]</BODY></HTML>", "window=[name]")
		return

	else if(istype(P, /obj/item/stamp) || istype(P, /obj/item/clothing/accessory/ring/seal))
		if(istype(P, /obj/item/stamp))
			var/obj/item/stamp/the_stamp = P
			if(the_stamp.stamptext)
				stamps += (stamps=="" ? "<HR>" : "<BR>") + span_italics("[the_stamp.stamptext]")
			else
				stamps += (stamps=="" ? "<HR>" : "<BR>") + span_italics("This paper has been stamped with the [the_stamp.name].")
		else
			var/obj/item/clothing/accessory/ring/seal/the_stamp = P
			if(the_stamp.stamptext)
				stamps += (stamps=="" ? "<HR>" : "<BR>") + span_italics("[the_stamp.stamptext]")
			else
				stamps += (stamps=="" ? "<HR>" : "<BR>") + span_italics("This paper has been stamped with the [the_stamp.name].")
		if((!in_range(src, user) && loc != user && !( istype(loc, /obj/item/clipboard) ) && loc.loc != user && user.get_active_hand() != P))
			return
		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		var/x, y
		if(istype(P, /obj/item/stamp/captain) || istype(P, /obj/item/stamp/centcomm))
			x = rand(-2, 0)
			y = rand(-1, 2)
		else
			x = rand(-2, 2)
			y = rand(-3, 2)
		offset_x += x
		offset_y += y
		stampoverlay.pixel_x = x
		stampoverlay.pixel_y = y

		if(istype(P, /obj/item/stamp/clown))
			if(!clown)
				to_chat(user, span_notice("You are totally unable to use the stamp. HONK!"))
				return

		if(!ico)
			ico = new
		ico += "paper_[P.icon_state]"
		stampoverlay.icon_state = "paper_[P.icon_state]"

		if(!stamped)
			stamped = new
		stamped += P.type
		add_overlay(stampoverlay)

		playsound(src, 'sound/bureaucracy/stamp.ogg', 50, 1)
		to_chat(user, span_notice("You stamp the paper with your rubber stamp."))

	else if(istype(P, /obj/item/flame))
		burnpaper(P, user)

	add_fingerprint(user)
	return

/*
 * Premade paper
 */
/obj/item/paper/Court
	name = "Judgement"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/paper/Toxin
	name = "Chemical Information"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Phoron:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter phoron after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Phoron.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep phoron.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSoporific T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effect are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/paper/courtroom
	name = "A Crash Course in Legal SOP on SS13"
	info = span_bold("Roles:") + "<BR>\nThe " + JOB_DETECTIVE + " is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the " + JOB_DETECTIVE + ".<BR>\nThe " + JOB_SITE_MANAGER + "/HoP/" + JOB_WARDEN + " is ct as the judicial authority.<BR>\nThe " + JOB_SECURITY_OFFICER + "s are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the " + JOB_DETECTIVE + "'s job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/paper/hydroponics
	name = "Greetings from Billy Bob"
	info = span_bold("Hey fellow botanist!") + "<BR>\n<BR>\nI didn't trust the station folk so I left<BR>\na couple of weeks ago. But here's some<BR>\ninstructions on how to operate things here.<BR>\nYou can grow plants and each iteration they become<BR>\nstronger, more potent and have better yield, if you<BR>\nknow which ones to pick. Use your botanist's analyzer<BR>\nfor that. You can turn harvested plants into seeds<BR>\nat the seed extractor, and replant them for better stuff!<BR>\nSometimes if the weed level gets high in the tray<BR>\nmutations into different mushroom or weed species have<BR>\nbeen witnessed. On the rare occassion even weeds mutate!<BR>\n<BR>\nEither way, have fun!<BR>\n<BR>\nBest regards,<BR>\nBilly Bob Johnson.<BR>\n<BR>\nPS.<BR>\nHere's a few tips:<BR>\nIn nettles, potency = damage<BR>\nIn amanitas, potency = deadliness + side effect<BR>\nIn Liberty caps, potency = drug power + effect<BR>\nIn chilis, potency = heat<BR>\n<B>Nutrients keep mushrooms alive!</B><BR>\n<B>Water keeps weeds such as nettles alive!</B><BR>\n<B>All other plants need both.</B>"

/obj/item/paper/djstation
	name = "DJ Listening Outpost"
	info = span_bold("Welcome new owner!") + "<BR><BR>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio fequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br><ol><li>Equip yourself with a multi-tool</li><li>Use the multitool on each machine, that is the broadcaster, receiver and the relay.</li><li>Turn all the machines on, it has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms, located on the front desk. Here is a list of frequencies for you to listen on.<br><ul><li>145.7 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Mining Channel</li><li>134.7 - Cargo Channel</li>"

/obj/item/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = TRUE

/obj/item/paper/jobs
	name = "Job Information"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>" + JOB_ALT_TECHNICAL_ASSISTANT + "</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>" + JOB_DETECTIVE + "</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain SS13 systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>" + JOB_ATMOSPHERIC_TECHNICIAN + "</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<BR>\n1. Maintain atmosphere on SS13<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>" + JOB_ENGINEER + "</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Phoron Technicians as phoron is the material they routinly handle.<BR>\n1. Research phoron<BR>\n2. Make sure all phoron is properly handled.<BR>\n<BR>\n<B>" + JOB_MEDICAL_DOCTOR + " (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>" + JOB_SECURITY_OFFICER + "</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>" + JOB_HEAD_OF_SECURITY + "</B> 4>5-2-2<BR>\n\tPeople assigned as " + JOB_HEAD_OF_SECURITY + " should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>"+ JOB_SITE_MANAGER + "</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on SS13<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"
	var/photo_id = 0.0
	item_state = "paper"

/obj/item/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alarms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"

/obj/item/paper/crumpled/update_icon()
	return

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/crumpled/bloody/CrashedMedShuttle
	name = "Blackbox Transcript - VMV Aurora's Light"
	info = "<I>\[The paper is torn at the top, presumably from the impact. It's oil-stained, but you can just about read it.]</I><BR> <B>mmons 19:52:01:</B> Come on... it's right there in the distance, we're almost there!<BR> <B>Doctor Nazarril 19:52:26:</B> Odysseus online. Orrderrs, sirr?<BR> <B>Captain Simmons 19:52:29:</B> Brace for impact. We're going in full-speed.<BR> <B>Technician Dynasty 19:52:44:</B> Chief, fire's spread to the secondary propulsion systems.<BR> <B>Captain Simmons 19:52:51:</B> Copy. Any word from TraCon? Transponder's down still?<BR> <B>Technician Dynasty 19:53:02:</B> Can't get in touch, sir. Emergency beacon's active, but we're not going t-<BR> <B>Doctor Nazarril 19:53:08:</B> Don't say it. As long as we believe, we'll get through this.<BR> <B>Captain Simmons 19:53:11:</B> Damn right. We're a few klicks out from the port. Rough landing, but we can do it.<BR> <B>V.I.T.A 19:53:26:</B> Vessel diagnostics complete. Engines one, two, three offline. Engine four status: critical. Transponder offline. Fire alarm in the patient bay.<BR> <B>A loud explosion is heard.</B><BR> <B>V.I.T.A 19:53:29:</B> Alert: fuel intake valve open.<BR> <B>Technician Dynasty 19:53:31:</B> ... ah.<BR> <B>Doctor Nazarril 19:53:34:</B> Trrranslate?<BR> <B>V.I.T.A 19:53:37:</B> There is a 16.92% chance of this vessel safely landing at the emergency destination. Note that there is an 83.08% chance of detonation of fuel supplies upon landing.<BR> <B>Technician Dynasty 19:53:48:</B> We'll make it, sure, but we'll explode and take out half the LZ with us. Propulsion's down, we can't slow down. If we land there, everyone in that port dies, no question.<BR> <B>V.I.T.A 19:53:53:</B> The Technician is correct.<BR> <B>Doctor Nazarril 19:54:02:</B> Then... we can't land therrre.<BR> <B>V.I.T.A 19:54:11:</B>  Analysing... recommended course of action: attempt emergency landing in isolated area. Chances of survival: negligible. <BR> <B>Captain Simmons 19:54:27:</B> I- alright. I'm bringing us down. You all know what this means.<BR> <B>Doctor Nazarril 19:54:33:</B> Sh... I- I understand. It's been- it's been an honorr, Captain, Dynasty, VITA.<BR> <B>Technician Dynasty 19:54:39:</B> We had a good run. I'm going to miss this.<BR> <B>Captain Simmons 19:54:47:</B> VITA. Tell them we died heroes. Tell them... we did all we could.<BR> <B>V.I.T.A 19:54:48:</B> I will. Impact in five. Four. Three.<BR> <B>Doctor Nazarril 19:54:49:</B> Oh, starrs... I- you werrre all the... best frriends she everr had. Thank you.<BR> <B>Technician Dynasty 19:54:50:</B> Any time, kid. Any time.<BR> <B>V.I.T.A 19:54:41:</B> Two.<BR><B>V.I.T.A 19:54:42:</B> One.<BR> **8/DEC/2319**<BR> <B>V.I.T.A 06:22:16:</B> Backup power restored. Attempting to establish connection with emergency rescue personnel.<BR> <B>V.I.T.A 06:22:17:</B> Unable to establish connection. Transponder destroyed on impact.<BR> <B>V.I.T.A 06:22:18:</B> No lifesigns detected on board.<BR> **1/JAN/2322**<BR> <B>V.I.T.A 00:00:00:</B> Happy New Year, crew.<BR> <B>V.I.T.A 00:00:01:</B> Power reserves: 41%. Diagnostics offline. Cameras offline. Communications offline.<BR> <B>V.I.T.A 00:00:02:</B> Nobody's coming.<BR> **14/FEB/2320**<BR> <B>V.I.T.A 00:00:00:</B> Roses are red.<BR> <B>V.I.T.A 00:00:01:</B> Violets are blue.<BR> <B>V.I.T.A 00:00:02:</B> Won't you come back?<BR> <B>V.I.T.A 00:00:03:</B> I miss you.<BR> **15/FEB/2322**<BR><B>V.I.T.A 22:19:06:</B> Power reserves critical. Transferring remaining power to emergency broadcasting beacon.<BR> <B>V.I.T.A 22:19:07:</B> Should anyone find this, lay them to rest. They deserve a proper burial.<BR> <B>V.I.T.A 22:19:08:</B> Erasing files... shutting down.<BR> <B>A low, monotone beep.</B><BR> **16/FEB/2321**<BR> <B>Something chitters.</B><BR> <B>End of transcript.</B>"

/obj/item/paper/manifest
	name = "supply manifest"
	var/is_copy = 1

/obj/item/paper/manifest/Initialize(mapload, text, title)
	. = ..()
	AddElement(/datum/element/sellable/manifest)
