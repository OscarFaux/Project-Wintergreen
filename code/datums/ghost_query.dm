// This is a generic datum used to ask ghosts if they wish to be a specific role, such as a Promethean, an Apprentice, a Xeno, etc.
// Simply instantiate the correct subtype of this datum, call query(), and it will return a list of ghost candidates after a delay.
/datum/ghost_query
	var/list/candidates = list()
	var/finished = FALSE
	var/role_name = "a thing"
	var/question = "Would you like to play as a thing?"
	var/query_sound = 'sound/effects/ghost2.ogg' // A sound file to play to the ghost, to help people who are alt-tabbed know something might interest them.
	var/be_special_flag = 0
	var/list/check_bans = list()
	var/wait_time = 60 SECONDS 	// How long to wait until returning the list of candidates.
	var/cutoff_number = 0		// If above 0, when candidates list reaches this number, further potential candidates are rejected.

/datum/ghost_query/Destroy(force)
	candidates = null
	. = ..()

/// Begin the ghost asking
/datum/ghost_query/proc/query()
	// First, ask all the ghosts who want to be asked.
	for(var/mob/observer/dead/D as anything in GLOB.observer_mob_list)
		if(evaluate_candidate(D))
			ask_question(D)

	// Then wait awhile.
	if(wait_time)
		our_timer(wait_time)
		return

/datum/ghost_query/proc/our_timer(var/current_wait_time)
	if(current_wait_time)
		addtimer(CALLBACK(src, PROC_REF(our_timer), FALSE), current_wait_time, TIMER_DELETE_ME)
	else
		for(var/mob/observer/dead/D as anything in candidates)
			if(!evaluate_candidate(D))
				candidates -= D
		finished = TRUE
		SEND_SIGNAL(src, COMSIG_GHOST_QUERY_COMPLETE)



/// Test a candidate for allowance to join as this
/datum/ghost_query/proc/evaluate_candidate(mob/observer/dead/candidate)
	if(!istype(candidate))
		return FALSE // Changed mobs or something who knows
	if(!candidate.client)
		return FALSE // No client to ask
	if(!candidate.MayRespawn())
		return FALSE // They can't respawn for whatever reason.
	if(be_special_flag && !(candidate.client.prefs.be_special & be_special_flag) )
		return FALSE // They don't want to see the prompt.
	for(var/ban in check_bans)
		if(jobban_isbanned(candidate, ban))
			return FALSE // They're banned from this role.

	return TRUE

/// Send async alerts and ask for responses. Expects you to have tested D for client and type already
/datum/ghost_query/proc/ask_question(var/mob/observer/dead/D)
	if(jobban_isbanned(D, JOB_GHOSTROLES))
		return

	var/client/C = D.client
	window_flash(C)

	if(query_sound)
		SEND_SOUND(C, sound(query_sound))

	tgui_alert_async(D, question, "[role_name] request", list("Yes", "No", "Never for this round"), CALLBACK(src, PROC_REF(get_reply)), wait_time)

/// Process an async alert response
/datum/ghost_query/proc/get_reply(response)
	var/mob/observer/dead/D = usr
	if(!D?.client)
		return

	// Unhandled are "No" and "Nevermind" responses, which should just do nothing

	// This response is always fine, doesn't warrant retesting
	switch(response)
		if("Never for this round")
			if(be_special_flag)
				D.client.prefs.be_special ^= be_special_flag
				to_chat(D, span_notice("You will not be prompted to join similar roles to [role_name] for the rest of this round. Note: If you save your character now, it will save this permanently."))
			else
				to_chat(D, span_warning("This type of ghost-joinable role doesn't have a role type flag associated with it, so I can't prevent future requests, sorry. Bug a dev!"))
		if("Yes")
			if(!evaluate_candidate(D)) // Failed revalidation
				to_chat(D, span_warning("Unfortunately, you no longer qualify for this role. Sorry."))
			else if(finished) // Already finished candidate list
				to_chat(D, span_warning("Unfortunately, you were not fast enough, and there are no more available roles. Sorry."))
			else // Prompt a second time
				tgui_alert_async(D, "Are you sure you want to play as a [role_name]?", "[role_name] request", list("I'm Sure", "Nevermind"), CALLBACK(src, PROC_REF(get_reply)), wait_time SECONDS)

		if("I'm Sure")
			if(!evaluate_candidate(D)) // Failed revalidation
				to_chat(D, span_warning("Unfortunately, you no longer qualify for this role. Sorry."))
			else if(finished) // Already finished candidate list
				to_chat(D, span_warning("Unfortunately, you were not fast enough, and there are no more available roles. Sorry."))
			else // Accept their nomination
				candidates.Add(D)
				if(cutoff_number && candidates.len >= cutoff_number)
					finished = TRUE // Finish now if we're full.

// Normal things.
/datum/ghost_query/promethean
	role_name = "Promethean"
	question = "Someone is requesting a soul for a promethean.  Would you like to play as one?"
	query_sound = 'sound/effects/slime_squish.ogg'
	be_special_flag = BE_ALIEN
	cutoff_number = 1

/datum/ghost_query/posi_brain
	role_name = "Positronic Intelligence"
	question = "Someone has activated a Positronic Brain.  Would you like to play as one?"
	query_sound = 'sound/machines/boobeebeep.ogg'
	be_special_flag = BE_AI
	check_bans = list(JOB_AI, JOB_CYBORG)
	cutoff_number = 1

/datum/ghost_query/drone_brain
	role_name = "Drone Intelligence"
	question = "Someone has activated a Drone AI Chipset.  Would you like to play as one?"
	query_sound = 'sound/machines/boobeebeep.ogg'
	be_special_flag = BE_AI
	check_bans = list(JOB_AI, JOB_CYBORG)
	cutoff_number = 1

// Antags.
/datum/ghost_query/apprentice
	role_name = "Technomancer Apprentice"
	question = "A Technomancer is requesting an Apprentice to help them on their adventure to the facility.  Would you like to play as the Apprentice?"
	be_special_flag = BE_WIZARD
	check_bans = list(JOB_SYNDICATE, JOB_WIZARD)
	cutoff_number = 1

/datum/ghost_query/xeno
	role_name = "Alien"
	question = "An Alien has just been created on the facility.  Would you like to play as them?"
	query_sound = 'sound/voice/hiss5.ogg'
	be_special_flag = BE_ALIEN

/datum/ghost_query/xenomorph_larva
	role_name = "Xenomorph Larva"
	question = "A xenomorph larva is ready to hatch from their egg. Would you like to join the hive?"
	be_special_flag = BE_ALIEN
	check_bans = list(JOB_XENOMORPH)
	cutoff_number = 1


/datum/ghost_query/blob
	role_name = "Blob"
	question = "A rapidly expanding Blob has just appeared on the facility.  Would you like to play as it?"
	be_special_flag = BE_ALIEN
	cutoff_number = 1
	wait_time = 10 SECONDS

/datum/ghost_query/syndicate_drone
	role_name = "Mercenary Drone"
	question = "A team of dubious mercenaries have purchased a powerful drone, and they are attempting to activate it.  Would you like to play as the drone?"
	be_special_flag = BE_AI
	check_bans = list(JOB_AI, JOB_CYBORG, JOB_SYNDICATE)
	cutoff_number = 1

/datum/ghost_query/borer
	role_name = "Cortical Borer"
	question = "A cortical borer has just been created on the facility.  Would you like to play as them?"
	be_special_flag = BE_ALIEN
	check_bans = list(JOB_SYNDICATE, JOB_BORER)
	cutoff_number = 1

// Surface stuff.
/datum/ghost_query/lost_drone
	role_name = "Lost Drone"
	question = "A lost drone onboard has been discovered by a crewmember and they are attempting to reactivate it.  Would you like to play as the drone?"
	be_special_flag = BE_LOSTDRONE	//VOREStation Edit
	check_bans = list(JOB_AI, JOB_CYBORG)
	cutoff_number = 1

/datum/ghost_query/gravekeeper_drone
	role_name = "Gravekeeper Drone"
	question = "A gravekeeper drone is about to reactivate and tend to its gravesite. Would you like to play as the drone?"
	be_special_flag = BE_AI
	check_bans = list(JOB_AI, JOB_CYBORG)
	cutoff_number = 1

/datum/ghost_query/lost_passenger
	role_name = "Lost Passenger"
	question = "A person suspended in cryosleep has been discovered by a crewmember \
	and they are attempting to open the cryopod.  Would you like to play as the occupant?"
	cutoff_number = 1

/datum/ghost_query/stowaway
	role_name = "Stowaway"
	question = "A person suspended in cryosleep has awoken in their pod aboard the station.\
	Would you like to play as the occupant?"
	cutoff_number = 1

/datum/ghost_query/corgi_rune
	role_name = "Dark Creature"
	question = "A curious explorer has touched a mysterious rune. \
	Would you like to play as the creature it summons?"
	be_special_flag = BE_CORGI
	cutoff_number = 1

/datum/ghost_query/cursedblade
	role_name = "Cursed Sword"
	question = "A cursed blade has been discovered by a curious explorer. \
	Would you like to play as the soul imprisoned within?"
	be_special_flag = BE_CURSEDSWORD
	cutoff_number = 1

/datum/ghost_query/shipwreck_survivor
	role_name = "Shipwreck survivor"
	question = "A person suspended in cryosleep has been discovered by a crewmember \
	aboard a wrecked spaceship \
	and they are attempting to open the cryopod.\n \
	Would you like to play as the occupant? \n \
	You MUST NOT use your station character!!!"
	be_special_flag = BE_SURVIVOR
	cutoff_number = 1
