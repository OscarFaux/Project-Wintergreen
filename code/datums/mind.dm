/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.
	Guidelines for using minds properly:
	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse
	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:
			mind.transfer_to(new_mob)
	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.
	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.
	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.
			new_mob.key = key
		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.
*/

/datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/living/current
	var/mob/living/original	//TODO: remove.not used in any meaningful way ~Carn. First I'll need to tweak the way silicon-mobs handle minds.
	var/active = 0

	var/memory

	var/assigned_role
	var/special_role

	var/datum/antag_holder/antag_holder

	var/role_alt_title

	var/datum/job/assigned_job

	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/datum/faction/faction 			//associated faction

	var/rev_cooldown = 0
	var/tcrystals = 0
	var/list/purchase_log = list()
	var/used_TC = 0

	var/list/learned_recipes //List of learned recipe TYPES.

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1

	//put this here for easier tracking ingame
	var/datum/money_account/initial_account

	//used for antag tcrystal trading, more info in code\game\objects\items\telecrystals.dm
	var/accept_tcrystals = 0

	//used for optional self-objectives that antagonists can give themselves, which are displayed at the end of the round.
	var/ambitions

	//used to store what traits the player had picked out in their preferences before joining, in text form.
	var/list/traits = list()

	var/datum/religion/my_religion

/datum/mind/New(var/key)
	src.key = key
	purchase_log = list()
	antag_holder = new
	..()

/datum/mind/proc/transfer_to(mob/living/new_character, force = FALSE)
	if(!istype(new_character))
		to_world_log("## DEBUG: transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform Carn")
	var/datum/component/antag/changeling/comp
	if(current)
		comp = is_changeling(current)			//remove ourself from our old body's mind variable
		if(comp)
			current.remove_changeling_powers()
			remove_verb(current, /mob/proc/EvolutionMenu)
		current.mind = null

	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.current = null

	current = new_character		//link ourself to our new body
	new_character.mind = src	//and link our new body to ourself

	if(comp)
		new_character.make_changeling()

	if(active || force)
		new_character.key = key		//now transfer the key to link the client to our new body

	if(new_character.client)
		new_character.client.init_verbs() // re-initialize character specific verbs

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/datum/mind/proc/show_memory(mob/recipient)
	var/output = span_bold("[current.real_name]'s Memory") + "<HR>"
	output += memory

	if(objectives.len>0)
		output += "<HR><B>Objectives:</B>"

		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			output += span_bold("Objective #[obj_count]") + ": [objective.explanation_text]"
			obj_count++

	if(ambitions)
		output += "<HR><B>Ambitions:</B> [ambitions]<br>"

	var/datum/browser/popup = new(recipient, "memory", "Memory")
	popup.set_content(output)
	popup.open()

/datum/mind/proc/edit_memory()
	if(!ticker || !ticker.mode)
		tgui_alert_async(usr, "Not before round-start!", "Alert")
		return

	var/out = span_bold("[name]") + "[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"
	out += "Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>"
	out += "Assigned role: [assigned_role]. <a href='byond://?src=\ref[src];[HrefToken()];role_edit=1'>Edit</a><br>"
	out += "<hr>"
	out += "Factions and special roles:<br><table>"
	for(var/antag_type in GLOB.all_antag_types)
		var/datum/antagonist/antag = GLOB.all_antag_types[antag_type]
		out += "[antag.get_panel_entry(src)]"
	out += "</table><hr>"
	out += span_bold("Objectives") + "</br>"

	if(objectives && objectives.len)
		var/num = 1
		for(var/datum/objective/O in objectives)
			out += span_bold("Objective #[num]:") + " [O.explanation_text] "
			if(O.completed)
				out += "([span_green("complete")])"
			else
				out += "([span_red("incomplete")])"
			out += " <a href='byond://?src=\ref[src];[HrefToken()];obj_completed=\ref[O]'>\[toggle\]</a>"
			out += " <a href='byond://?src=\ref[src];[HrefToken()];obj_delete=\ref[O]'>\[remove\]</a><br>"
			num++
		out += "<br><a href='byond://?src=\ref[src];[HrefToken()];obj_announce=1'>\[announce objectives\]</a>"

	else
		out += "None."
	out += "<br><a href='byond://?src=\ref[src];[HrefToken()];obj_add=1'>\[add\]</a><br><br>"
	out += span_bold("Ambitions:") + " [ambitions ? ambitions : "None"] <a href='byond://?src=\ref[src];[HrefToken()];amb_edit=\ref[src]'>\[edit\]</a></br>"

	var/datum/browser/popup = new(usr, "edit_memory[src]", "Edit Memory")
	popup.set_content(out)
	popup.open()

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN|R_FUN|R_EVENT))	return

	if(href_list["add_antagonist"])
		var/datum/antagonist/antag = GLOB.all_antag_types[href_list["add_antagonist"]]
		if(antag)
			if(antag.add_antagonist(src, 1, 1, 0, 1, 1)) // Ignore equipment and role type for this.
				log_admin("[key_name_admin(usr)] made [key_name(src)] into a [antag.role_text].")
			else
				to_chat(usr, span_warning("[src] could not be made into a [antag.role_text]!"))

	else if(href_list["remove_antagonist"])
		var/datum/antagonist/antag = GLOB.all_antag_types[href_list["remove_antagonist"]]
		if(antag) antag.remove_antagonist(src)

	else if(href_list["equip_antagonist"])
		var/datum/antagonist/antag = GLOB.all_antag_types[href_list["equip_antagonist"]]
		if(antag) antag.equip(src.current)

	else if(href_list["unequip_antagonist"])
		var/datum/antagonist/antag = GLOB.all_antag_types[href_list["unequip_antagonist"]]
		if(antag) antag.unequip(src.current)

	else if(href_list["move_antag_to_spawn"])
		var/datum/antagonist/antag = GLOB.all_antag_types[href_list["move_antag_to_spawn"]]
		if(antag) antag.place_mob(src.current)

	else if (href_list["role_edit"])
		var/new_role = tgui_input_list(usr, "Select new role", "Assigned role", assigned_role, GLOB.joblist)
		if (!new_role) return
		assigned_role = new_role

	else if (href_list["memory_edit"])
		var/new_memo = sanitize(tgui_input_text(usr, "Write new memory", "Memory", memory, multiline = TRUE, prevent_enter = TRUE))
		if (isnull(new_memo)) return
		memory = new_memo

	else if (href_list["amb_edit"])
		var/datum/mind/mind = locate(href_list["amb_edit"])
		if(!mind)
			return
		var/new_ambition = tgui_input_text(usr, "Enter a new ambition", "Memory", mind.ambitions, multiline = TRUE, prevent_enter = TRUE)
		if(isnull(new_ambition))
			return
		if(mind)
			mind.ambitions = sanitize(new_ambition)
			to_chat(mind.current, span_warning("Your ambitions have been changed by higher powers, they are now: [mind.ambitions]"))
		log_and_message_admins("made [key_name(mind.current)]'s ambitions be '[mind.ambitions]'.")

	else if (href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if (href_list["obj_edit"])
			objective = locate(href_list["obj_edit"])
			if (!objective) return
			objective_pos = objectives.Find(objective)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"

		var/list/choices = list("assassinate", "debrain", "protect", "prevent", "harm", "brig", "hijack", "escape", "survive", "steal", "mercenary", "capture", "absorb", "custom")
		var/new_obj_type = tgui_input_list(usr, "Select objective type:", "Objective type", choices, def_value)
		if (!new_obj_type) return

		var/datum/objective/new_objective = null

		switch (new_obj_type)
			if ("assassinate","protect","debrain", "harm", "brig")
				//To determine what to name the objective in explanation text.
				var/objective_type_capital = uppertext(copytext(new_obj_type, 1,2))//Capitalize first letter.
				var/objective_type_text = copytext(new_obj_type, 2)//Leave the rest of the text.
				var/objective_type = "[objective_type_capital][objective_type_text]"//Add them together into a text string.

				var/list/possible_targets = list("Free objective")
				for(var/datum/mind/possible_target in ticker.minds)
					if ((possible_target != src) && ishuman(possible_target.current))
						possible_targets += possible_target.current

				var/mob/def_target = null
				var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)
				if (objective&&(objective.type in objective_list) && objective.target)
					def_target = objective.target.current

				var/new_target = tgui_input_list(usr, "Select target:", "Objective target", possible_targets, def_target)
				if (!new_target) return

				var/objective_path = text2path("/datum/objective/[new_obj_type]")
				var/mob/living/M = new_target
				if (!istype(M) || !M.mind || new_target == "Free objective")
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = null
					new_objective.explanation_text = "Free objective"
				else
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = M.mind
					new_objective.explanation_text = "[objective_type] [M.real_name], the [M.mind.special_role ? M.mind:special_role : M.mind:assigned_role]."

			if ("prevent")
				new_objective = new /datum/objective/block
				new_objective.owner = src

			if ("hijack")
				new_objective = new /datum/objective/hijack
				new_objective.owner = src

			if ("escape")
				new_objective = new /datum/objective/escape
				new_objective.owner = src

			if ("survive")
				new_objective = new /datum/objective/survive
				new_objective.owner = src

			if ("mercenary")
				new_objective = new /datum/objective/nuclear
				new_objective.owner = src

			if ("steal")
				if (!istype(objective, /datum/objective/steal))
					new_objective = new /datum/objective/steal
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/steal = new_objective
				if (!steal.select_target())
					return

			if("capture","absorb", "vore")
				var/def_num
				if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
					def_num = objective.target_amount

				var/target_number = tgui_input_number(usr, "Input target number:", "Objective", def_num)
				if (isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
					return

				switch(new_obj_type)
					if("capture")
						new_objective = new /datum/objective/capture
						new_objective.explanation_text = "Accumulate [target_number] capture points."
					if("absorb")
						new_objective = new /datum/objective/absorb
						new_objective.explanation_text = "Absorb [target_number] compatible genomes."
					if("vore")
						new_objective = new /datum/objective/vore
						new_objective.explanation_text = "Devour [target_number] [target_number == 1 ? "person" : "people"]. What happens to them after you do that is irrelevant."
				new_objective.owner = src
				new_objective.target_amount = target_number

			if ("custom")
				var/expl = sanitize(tgui_input_text(usr, "Custom objective:", "Objective", objective ? objective.explanation_text : ""))
				if (!expl) return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if (!new_objective) return

		if (objective)
			objectives -= objective
			objectives.Insert(objective_pos, new_objective)
		else
			objectives += new_objective

	else if (href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))	return
		objectives -= objective

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))	return
		objective.completed = !objective.completed

	else if(href_list["implant"])
		var/mob/living/carbon/human/H = current

		BITSET(H.hud_updateflag, IMPLOYAL_HUD)   // updates that players HUD images so secHUD's pick up they are implanted or not.

		switch(href_list["implant"])
			if("remove")
				for(var/obj/item/implant/loyalty/I in H.contents)
					for(var/obj/item/organ/external/organs in H.organs)
						if(I in organs.implants)
							qdel(I)
							break
				to_chat(H, span_notice(span_large(span_bold("Your loyalty implant has been deactivated."))))
				log_admin("[key_name_admin(usr)] has de-loyalty implanted [current].")
			if("add")
				to_chat(H, span_danger(span_large("You somehow have become the recepient of a loyalty transplant, and it just activated!")))
				H.implant_loyalty(override = TRUE)
				log_admin("[key_name_admin(usr)] has loyalty implanted [current].")

	else if (href_list["silicon"])
		BITSET(current.hud_updateflag, SPECIALROLE_HUD)
		switch(href_list["silicon"])

			if("unemag")
				var/mob/living/silicon/robot/R = current
				if (istype(R))
					R.emagged = 0
					if (R.activated(R.module.emag))
						R.module_active = null
					if(R.module_state_1 == R.module.emag)
						R.module_state_1 = null
						R.contents -= R.module.emag
					else if(R.module_state_2 == R.module.emag)
						R.module_state_2 = null
						R.contents -= R.module.emag
					else if(R.module_state_3 == R.module.emag)
						R.module_state_3 = null
						R.contents -= R.module.emag
					log_admin("[key_name_admin(usr)] has unemag'ed [R].")

			if("unemagcyborgs")
				if (isAI(current))
					var/mob/living/silicon/ai/ai = current
					for (var/mob/living/silicon/robot/R in ai.connected_robots)
						R.emagged = 0
						if (R.module)
							if (R.activated(R.module.emag))
								R.module_active = null
							if(R.module_state_1 == R.module.emag)
								R.module_state_1 = null
								R.contents -= R.module.emag
							else if(R.module_state_2 == R.module.emag)
								R.module_state_2 = null
								R.contents -= R.module.emag
							else if(R.module_state_3 == R.module.emag)
								R.module_state_3 = null
								R.contents -= R.module.emag
					log_admin("[key_name_admin(usr)] has unemag'ed [ai]'s Cyborgs.")

	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/W in current)
					current.drop_from_inventory(W)
			if("takeuplink")
				take_uplink()
				memory = null//Remove any memory they may have had.
			if("crystals")
				if (check_rights_for(usr.client, R_FUN))
				//	var/obj/item/uplink/hidden/suplink = find_syndicate_uplink() No longer needed, uses stored in mind
					var/crystals
					crystals = tcrystals
					crystals = tgui_input_number(usr, "Amount of telecrystals for [key]", crystals)
					if (!isnull(crystals))
						tcrystals = crystals

	else if (href_list["obj_announce"])
		var/obj_count = 1
		to_chat(current, span_blue("Your current objectives:"))
		for(var/datum/objective/objective in objectives)
			to_chat(current, span_bold("Objective #[obj_count]") + ": [objective.explanation_text]")
			obj_count++
	edit_memory()

/datum/mind/proc/find_syndicate_uplink()
	var/list/L = current.get_contents()
	for (var/obj/item/I in L)
		if (I.hidden_uplink)
			return I.hidden_uplink
	return null

/datum/mind/proc/take_uplink()
	var/obj/item/uplink/hidden/H = find_syndicate_uplink()
	if(H)
		qdel(H)


// check whether this mind's mob has been brigged for the given duration
// have to call this periodically for the duration to work properly
/datum/mind/proc/is_brigged(duration)
	var/turf/T = current.loc
	if(!istype(T))
		brigged_since = -1
		return 0
	var/is_currently_brigged = 0
	if(istype(T.loc,/area/security/brig))
		is_currently_brigged = 1
		for(var/obj/item/card/id/card in current)
			is_currently_brigged = 0
			break // if they still have ID they're not brigged
		for(var/obj/item/pda/P in current)
			if(P.id)
				is_currently_brigged = 0
				break // if they still have ID they're not brigged

	if(!is_currently_brigged)
		brigged_since = -1
		return 0

	if(brigged_since == -1)
		brigged_since = world.time

	return (duration <= world.time - brigged_since)

/datum/mind/proc/reset()
	assigned_role =   null
	special_role =    null
	role_alt_title =  null
	assigned_job =    null
	//faction =       null //Uncommenting this causes a compile error due to 'undefined type', fucked if I know.
	//changeling =    null //TODO: Figure out where this is all used and move it from mind to mob.
	initial_account = null
	objectives =      list()
	special_verbs =   list()
	has_been_rev =    0
	rev_cooldown =    0
	brigged_since =   -1

//Antagonist role check
/mob/living/proc/check_special_role(role)
	if(mind)
		if(!role)
			return mind.special_role
		else
			return (mind.special_role == role) ? 1 : 0
	else
		return 0

/datum/mind/proc/get_ghost(even_if_they_cant_reenter)
	for(var/mob/observer/dead/G in GLOB.player_list)
		if(G.mind == src)
			if(G.can_reenter_corpse || even_if_they_cant_reenter)
				return G
			break

/datum/mind/proc/grab_ghost(force)
	var/mob/observer/dead/G = get_ghost(even_if_they_cant_reenter = force)
	. = G
	if(G)
		G.reenter_corpse()

//Initialisation procs
/mob/living/proc/mind_initialize()
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		mind.original = src
		if(ticker)
			ticker.minds += mind
		else
			to_world_log("## DEBUG: mind_initialize(): No ticker ready yet! Please inform Carn")
	if(!mind.name)	mind.name = real_name
	mind.current = src
	if(player_is_antag(mind))
		add_verb(src.client, /client/proc/aooc)

//HUMAN
/mob/living/carbon/human/mind_initialize()
	. = ..()
	if(!mind.assigned_role)
		mind.assigned_role = JOB_ALT_VISITOR	//defualt //VOREStation Edit - Visitor not Assistant

//slime
/mob/living/simple_mob/slime/mind_initialize()
	. = ..()
	mind.assigned_role = JOB_SLIME

/mob/living/carbon/alien/larva/mind_initialize()
	. = ..()
	mind.special_role = JOB_LARVA

//AI
/mob/living/silicon/ai/mind_initialize()
	. = ..()
	mind.assigned_role = JOB_AI

//BORG
/mob/living/silicon/robot/mind_initialize()
	. = ..()
	mind.assigned_role = JOB_CYBORG

//PAI
/mob/living/silicon/pai/mind_initialize()
	. = ..()
	mind.assigned_role = JOB_PAI
	mind.special_role = ""

//Animals
/mob/living/simple_mob/mind_initialize()
	. = ..()
	mind.assigned_role = JOB_SIMPLE_MOB

/mob/living/simple_mob/animal/passive/dog/corgi/mind_initialize()
	. = ..()
	mind.assigned_role = JOB_CORGI

/mob/living/simple_mob/construct/shade/mind_initialize()
	. = ..()
	mind.assigned_role = JOB_SHADE
	mind.special_role = JOB_CULTIST

/mob/living/simple_mob/construct/artificer/mind_initialize()
	. = ..()
	mind.assigned_role = JOB_ARTIFICER
	mind.special_role = JOB_CULTIST

/mob/living/simple_mob/construct/wraith/mind_initialize()
	. = ..()
	mind.assigned_role = JOB_WRAITH
	mind.special_role = JOB_CULTIST

/mob/living/simple_mob/construct/juggernaut/mind_initialize()
	. = ..()
	mind.assigned_role = JOB_JUGGERNAUT
	mind.special_role = JOB_CULTIST
