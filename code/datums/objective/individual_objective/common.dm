/datum/individual_objective/upgrade//work
	name = "Upgrade"
	desc =  "Its time to improve your meat with shiny chrome. Gain new bionics, implant, or any mutation."
	allow_cruciform = FALSE

/datum/individual_objective/upgrade/assign()
	..()
	RegisterSignal(mind_holder, COMSIG_HUMAN_ROBOTIC_MODIFICATION, .proc/completed)

/datum/individual_objective/upgrade/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_HUMAN_ROBOTIC_MODIFICATION)
	..()

/datum/individual_objective/inspiration//work
	name = "Triumph of the Spirit"
	desc =  "Observer at least one positive breakdown. Inspiring!"
	var/breakdown_type = /datum/breakdown/positive

/datum/individual_objective/inspiration/assign()
	..()
	RegisterSignal(mind_holder, COMSIG_HUMAN_BREAKDOWN, .proc/task_completed)

/datum/individual_objective/inspiration/task_completed(mob/living/L, datum/breakdown/breakdown)
	//if(istype(breakdown, breakdown_type) && L != mind_holder)//uncoment
	if(istype(breakdown, breakdown_type))//delete
		completed()

/datum/individual_objective/inspiration/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_HUMAN_BREAKDOWN)
	..()

/datum/individual_objective/derange//work but limit it to more of the one player
	name = "Derange"
	limited_antag = TRUE
	var/mob/living/carbon/human/target

/datum/individual_objective/derange/assign()
	..()
	var/list/valid_targets = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		valid_targets += H
	target = pick(valid_targets)
	desc = "[target] really pisses you off, ensure that they will get \
			a mental breakdown. Characters from your own faction are blacklisted"
	RegisterSignal(mind_holder, COMSIG_HUMAN_BREAKDOWN, .proc/task_completed)

/datum/individual_objective/derange/task_completed(mob/living/L, datum/breakdown/breakdown)
	if(L == target)
		completed()

/datum/individual_objective/derange/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_HUMAN_BREAKDOWN)
	..()

#define MOB_ADD_DRUG 1
#define ON_MOB_DRUG 2
#define MOB_DELETE_DRUG 3

/datum/individual_objective/addict//work
	name = "Oil the Cogs"
	based_time = TRUE
	var/list/drugs = list()
	var/timer
	units_requested = 3 MINUTES//change to 5

/datum/individual_objective/addict/assign()
	..()
	timer = world.time
	desc = "Stay intoxicated by alcohol or recreational drugs for [unit2time(units_requested)] minutes"
	RegisterSignal(mind_holder, COMSIGN_CARBON_HAPPY, .proc/task_completed)

/datum/individual_objective/addict/task_completed(datum/reagent/happy, signal)
	if(!drugs.len)
		timer = world.time
	if(!(happy.id in drugs))
		if(signal != MOB_DELETE_DRUG)
			drugs += happy.id
	else if(signal == MOB_DELETE_DRUG)
		drugs -= happy.id
	else if(signal == ON_MOB_DRUG)
		units_completed += abs(world.time - timer)
		timer = world.time
	if(check_for_completion())
		completed()

/datum/individual_objective/addict/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIGN_CARBON_HAPPY)
	..()

/datum/individual_objective/gift//test requiered
	name = "Gift"
	desc = "You feel a need to leave a mark in other people lives. Ensure that at \
			least someone will level up with oddity that you touched"

/datum/individual_objective/gift/assign()
	..()
	RegisterSignal(mind_holder, COMSIG_HUMAN_LEVEL_UP, .proc/task_completed)

/datum/individual_objective/gift/task_completed(mob/living/carbon/human/H, obj/item/O)
	//if(mind_holder == H) return //coment for rest for test
	var/full_print = mind_holder.get_full_print()
	if(full_print in O.fingerprints)
		completed()

/datum/individual_objective/gift/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_HUMAN_LEVEL_UP)
	..()

/datum/individual_objective/protector//work
	name = "Protector"
	var/mob/living/carbon/human/target
	var/timer
	units_requested = 3 MINUTES//change to 15
	based_time = TRUE
	var/health_threshold = 50

/datum/individual_objective/protector/assign()
	..()
	var/list/valid_targets = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		valid_targets += H
	target = pick(valid_targets)//todo: no mind.current
	desc = "Ensure that [target] will not get their health slowered to [health_threshold] and below \
			for [unit2time(units_requested)] minutes. Timer resets if sanity reaches the threshold."
	timer = world.time
	RegisterSignal(target, COMSIGN_HUMAN_HEALTH, .proc/task_completed)

/datum/individual_objective/protector/task_completed(health)
	if(health < health_threshold)
		units_completed = 0
		timer = world.time
		return
	var/n_timer = world.time
	if(n_timer > timer)
		units_completed += n_timer - timer
		timer = world.time
	if(check_for_completion())
		completed()

/datum/individual_objective/protector/completed()
	if(completed) return
	UnregisterSignal(target, COMSIGN_HUMAN_HEALTH)
	..()

/datum/individual_objective/helper//work
	name = "Helping Hand"
	var/mob/living/carbon/human/target
	var/timer
	units_requested = 3 MINUTES//change to 15
	based_time = TRUE
	var/sanity_threshold = 50

/datum/individual_objective/helper/assign()
	..()
	var/list/valid_targets = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		valid_targets += H
	target = pick(valid_targets)//todo: no mind.current
	desc = "Ensure that [target] will not get their sanity lowered to [sanity_threshold] and below \
			for [unit2time(units_requested)] minutes. Timer resets if sanity reaches the threshold"
	timer = world.time
	RegisterSignal(target, COMSIG_HUMAN_SANITY, .proc/task_completed)

/datum/individual_objective/helper/task_completed(sanity)
	if(sanity < sanity_threshold)
		units_completed = 0
		timer = world.time
		return
	var/n_timer = world.time
	if(n_timer > timer)
		units_completed += n_timer - timer
		timer = world.time
	if(check_for_completion())
		completed()

/datum/individual_objective/helper/completed()
	if(completed) return
	UnregisterSignal(target, COMSIG_HUMAN_SANITY)
	..()

/datum/individual_objective/obsession//work
	name = "Obsessive Observation"
	var/mob/living/carbon/human/target
	var/timer
	units_requested = 3 MINUTES//change to 5
	based_time = TRUE

/datum/individual_objective/obsession/assign()
	..()
	var/list/valid_targets = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		valid_targets += H
	target = pick(valid_targets)//todo: no mind.current
	desc = "There is something interesting in [target]. For [unit2time(units_requested)] minutes, you need \
			to keep eye contact with them, and keep them in your view. Cameras will not work"
	timer = world.time
	RegisterSignal(mind_holder, COMSIG_MOB_LIFE, .proc/task_completed)

/datum/individual_objective/obsession/task_completed()
	if(target in view(mind_holder))
		units_completed += abs(world.time - timer)
		timer = world.time
	else
		timer = world.time
		units_completed = 0
	if(check_for_completion())
		completed()

/datum/individual_objective/obsession/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_MOB_LIFE)
	..()

/datum/individual_objective/greed//work
	name = "Greed"
	units_requested = 2 MINUTES//change to 10
	based_time = TRUE
	limited_antag = TRUE
	var/obj/item/target
	var/timer

/datum/individual_objective/greed/assign()
	..()
	target = pick_faction_item(mind_holder, TRUE)
	desc = "Acquire and hold \the [target] for [unit2time(units_requested)] minutes."
	timer = world.time
	RegisterSignal(mind_holder, COMSIG_MOB_LIFE, .proc/task_completed)

/datum/individual_objective/greed/task_completed()
	var/find = FALSE
	for(var/obj/item/I in mind_holder.GetAllContents())
		if(target.type == I.type)
			units_completed += abs(world.time - timer)
			timer = world.time
			find = TRUE
	if(!find)
		timer = world.time
		units_completed = 0
	if(check_for_completion())
		completed()

/datum/individual_objective/greed/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_MOB_LIFE)
	..()

/datum/individual_objective/collenction//work
	name = "Collection"
	var/obj/item/target

/datum/individual_objective/collenction/proc/pick_candidates()
	return pickweight(list(
		/obj/item/weapon/gun/projectile/revolver/deckard,
		/obj/item/weapon/gun/energy/ionrifle,
		/obj/item/weapon/gun/projectile/automatic/ak47/fs,
		/obj/item/weapon/gun/energy/retro,
		/obj/item/weapon/gun/projectile/shotgun/doublebarrel/sawn
		))

/datum/individual_objective/collenction/assign()
	..()
	target = pick_candidates()
	target = new target()
	desc = "Get your hands on a [target.name]"
	RegisterSignal(mind_holder, COMSING_HUMAN_EQUITP, .proc/task_completed)

/datum/individual_objective/collenction/task_completed(obj/item/W)
	if(W.type == target.type)
		completed()
	else
		for(var/obj/item/I in mind_holder.GetAllContents())
			if(I.type == target.type)
				completed()

/datum/individual_objective/collenction/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSING_HUMAN_EQUITP)
	..()
