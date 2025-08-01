/datum/category_item/player_setup_item/general/basic_antagonism
	name = "Basic"
	sort_order = 7

	var/datum/paiCandidate/candidate

/datum/category_item/player_setup_item/general/basic_antagonism/New()
	. = ..()
	candidate = new()

/datum/category_item/player_setup_item/general/basic_antagonism/load_character(list/save_data)
	pref.exploit_record = save_data["exploit_record"]
	pref.antag_faction  = save_data["antag_faction"]
	pref.antag_vis      = save_data["antag_vis"]

/datum/category_item/player_setup_item/general/basic_antagonism/save_character(list/save_data)
	save_data["exploit_record"] = pref.exploit_record
	save_data["antag_faction"]  = pref.antag_faction
	save_data["antag_vis"]      = pref.antag_vis

/datum/category_item/player_setup_item/general/basic_antagonism/load_preferences(datum/json_savefile/savefile)
	if(!candidate)
		candidate = new()

	var/preference_mob = preference_mob()
	if(!preference_mob)// No preference mob - this happens when we're called from client/New() before it calls ..()  (via datum/preferences/New())
		spawn()
			preference_mob = preference_mob()
			if(!preference_mob)
				return
			candidate.savefile_load(preference_mob)
		return

	candidate.savefile_load(preference_mob)

/datum/category_item/player_setup_item/general/basic_antagonism/save_preferences(datum/json_savefile/savefile)
	if(!candidate)
		return

	if(!preference_mob())
		return

	candidate.savefile_save(preference_mob())

/datum/category_item/player_setup_item/general/basic_antagonism/sanitize_character()
	if(!pref.antag_faction) pref.antag_faction = "None"
	if(!pref.antag_vis) pref.antag_vis = "Hidden"

// Moved from /datum/preferences/proc/copy_to()
/datum/category_item/player_setup_item/general/basic_antagonism/copy_to_mob(var/mob/living/carbon/human/character)
	character.exploit_record = pref.exploit_record
	character.antag_faction = pref.antag_faction
	character.antag_vis = pref.antag_vis

/datum/category_item/player_setup_item/general/basic_antagonism/tgui_data(mob/user)
	var/list/data = ..()

	data["antag_faction"] = pref.antag_faction
	data["antag_vis"] = pref.antag_vis
	data["uplink_type"] = pref.read_preference(/datum/preference/choiced/uplinklocation)
	data["record_banned"] = jobban_isbanned(user, "Records")
	if(!jobban_isbanned(user, "Records"))
		data["exploitable_record"] = TextPreview(pref.exploit_record, 40)

	if(!candidate)
		CRASH("[user] pAI prefs have a null candidate var.")

	data["pai_name"] = candidate.name ? candidate.name : "None Set"
	data["pai_desc"] = candidate.description ? TextPreview(candidate.description, 40) : "None Set"
	data["pai_role"] = candidate.role ? TextPreview(candidate.role, 40) : "None Set"
	data["pai_comments"] = candidate.comments ? TextPreview(candidate.comments, 40) : "None Set"

	return data

/datum/category_item/player_setup_item/general/basic_antagonism/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("uplinklocation")
			var/new_uplinklocation = tgui_input_list(user, "Choose your uplink location:", "Character Preference", GLOB.uplink_locations, pref.read_preference(/datum/preference/choiced/uplinklocation))
			if(new_uplinklocation && CanUseTopic(user))
				pref.update_preference_by_type(/datum/preference/choiced/uplinklocation, new_uplinklocation)
			return TOPIC_REFRESH

		if("exploitable_record")
			var/exploitmsg = sanitize(tgui_input_text(user,"Set exploitable information about you here.","Exploitable Information", html_decode(pref.exploit_record), MAX_RECORD_LENGTH, TRUE, prevent_enter = TRUE), MAX_RECORD_LENGTH, extra = 0)
			if(!isnull(exploitmsg) && !jobban_isbanned(user, "Records") && CanUseTopic(user))
				pref.exploit_record = exploitmsg
				return TOPIC_REFRESH

		if("antagfaction")
			var/choice = tgui_input_list(user, "Please choose an antagonistic faction to work for.", "Character Preference", GLOB.antag_faction_choices + list("None","Other"), pref.antag_faction)
			if(!choice || !CanUseTopic(user))
				return TOPIC_NOACTION
			if(choice == "Other")
				var/raw_choice = sanitize(tgui_input_text(user, "Please enter a faction.", "Character Preference", null, MAX_NAME_LEN), MAX_NAME_LEN)
				if(raw_choice)
					pref.antag_faction = raw_choice
			else
				pref.antag_faction = choice
			return TOPIC_REFRESH

		if("antagvis")
			var/choice = tgui_input_list(user, "Please choose an antagonistic visibility level.", "Character Preference", GLOB.antag_visiblity_choices, pref.antag_vis)
			if(!choice || !CanUseTopic(user))
				return TOPIC_NOACTION
			else
				pref.antag_vis = choice
			return TOPIC_REFRESH

		if("option")
			var/t
			switch(params["option"])
				if("name")
					t = sanitizeName(tgui_input_text(user, "Enter a name for your pAI", "Global Preference", candidate.name, MAX_NAME_LEN), MAX_NAME_LEN, 1)
					if(t && CanUseTopic(user))
						candidate.name = t
				if("desc")
					t = tgui_input_text(user, "Enter a description for your pAI", "Global Preference", html_decode(candidate.description), multiline = TRUE, prevent_enter = TRUE)
					if(!isnull(t) && CanUseTopic(user))
						candidate.description = sanitize(t)
				if("role")
					t = tgui_input_text(user, "Enter a role for your pAI", "Global Preference", html_decode(candidate.role))
					if(!isnull(t) && CanUseTopic(user))
						candidate.role = sanitize(t)
				if("ooc")
					t = tgui_input_text(user, "Enter any OOC comments", "Global Preference", html_decode(candidate.comments), multiline = TRUE, prevent_enter = TRUE)
					if(!isnull(t) && CanUseTopic(user))
						candidate.comments = sanitize(t)
			return TOPIC_REFRESH
