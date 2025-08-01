/client/proc/aooc(msg as text)
	set category = "OOC.Chat"
	set name = "AOOC"
	set desc = "Antagonist OOC"

	var/is_admin = check_rights(R_ADMIN|R_MOD|R_EVENT, show_msg = 0)
	var/is_antag = usr.mind && usr.mind.special_role

	if(!is_antag && !is_admin) // Non-antagonists and non-admins have no business using this.
		to_chat(usr, span_warning("Sorry, but only certain antagonists or administrators can use this verb."))
		return

	else if(is_antag && !is_admin) // Is an antag, and not an admin, meaning we need to check if their antag type allows AOOC.
		var/datum/antagonist/A = get_antag_data(usr.mind.special_role)
		if(!A || !A.can_speak_aooc || !A.can_hear_aooc)
			to_chat(usr, span_warning("Sorry, but your antagonist type is not allowed to speak in AOOC."))
			return

	msg = sanitize(msg)
	if(!msg)
		return

	// Name shown to admins.
	var/display_name = src.key
	if(holder)
		if(holder.fakekey)
			display_name = usr.client.holder.fakekey

	// Name shown to other players.  Admins whom are not also antags have their rank displayed.
	var/player_display = (is_admin && !is_antag) ? "[display_name]([usr.client.holder.rank_names()])" : display_name

	for(var/mob/M in GLOB.mob_list)
		if(check_rights_for(M.client, R_ADMIN|R_MOD|R_EVENT)) // Staff can see AOOC unconditionally, and with more details.
			to_chat(M, span_ooc(span_aooc("[create_text_tag("aooc", "Antag-OOC:", M.client)] <EM>[get_options_bar(src, 0, 1, 1)]([admin_jump_link(usr, check_rights_for(M.client, R_HOLDER))]):</EM> " + span_message("[msg]"))))
		else if(M.client) // Players can only see AOOC if observing, or if they are an antag type allowed to use AOOC.
			var/datum/antagonist/A = null
			if(M.mind) // Observers don't have minds, but they should still see AOOC.
				A = get_antag_data(M.mind.special_role)
			if((M.mind && M.mind.special_role && A && A.can_hear_aooc) || isobserver(M)) // Antags must have their type be allowed to AOOC to see AOOC.  This prevents, say, ERT from seeing AOOC.
				to_chat(M, span_ooc(span_aooc("[create_text_tag("aooc", "Antag-OOC:", M.client)] <EM>[player_display]:</EM> " + span_message("[msg]"))))

	log_aooc(msg,src)
