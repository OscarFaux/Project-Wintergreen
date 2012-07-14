/mob/living/silicon/robot/Login(var/syndie = 0)
	..()
	regenerate_icons()

	if(!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	if(real_name == "Cyborg")
		ident = rand(1, 999)
		real_name += " "
		real_name += "-[ident]"
		name = real_name
	/*if(!connected_ai)
		for(var/mob/living/silicon/ai/A in world)
			connected_ai = A
			A.connected_robots += src
			break
	*/
	if(!started)
		if(!syndie)
			if (client)
				connected_ai = activeais()
			if (connected_ai)
				connected_ai.connected_robots += src
	//			laws = connected_ai.laws //The borg inherits its AI's laws
				laws = new /datum/ai_laws
				lawsync()
				src << "<b>Unit slaved to [connected_ai.name], downloading laws.</b>"
				lawupdate = 1
			else
				laws = new /datum/ai_laws/asimov
				lawupdate = 0
				src << "<b>Unable to locate an AI, reverting to standard Asimov laws.</b>"
		else
			laws = new /datum/ai_laws/antimov
			lawupdate = 0
			scrambledcodes = 1
			src << "Follow your laws."
			cell.maxcharge = 25000
			cell.charge = 25000
			module = new /obj/item/weapon/robot_module/syndicate(src)
			hands.icon_state = "standard"
			icon_state = "secborg"
			modtype = "Synd"

		radio = new /obj/item/device/radio(src)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.network = "SS13"
	if(!cell)
		var/obj/item/weapon/cell/C = new(src)
		C.charge = 1500
		cell = C
	if(mind)
		ticker.mode.remove_revolutionary(mind)
	started = 1

	return