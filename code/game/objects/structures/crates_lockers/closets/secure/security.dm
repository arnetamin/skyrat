/obj/structure/closet/secure_closet/captains
	name = "\proper captain's locker"
	req_access = list(ACCESS_CAPTAIN)
	icon_state = "cap"

/obj/structure/closet/secure_closet/captains/PopulateContents()
	..()

	new /obj/item/storage/backpack/captain(src)
	new /obj/item/storage/backpack/satchel/cap(src)
	new /obj/item/storage/backpack/duffelbag/captain(src)
	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/storage/bag/garment/captain(src)
	new /obj/item/computer_disk/command/captain(src)
	new /obj/item/storage/box/silver_ids(src)
	new /obj/item/radio/headset/heads/captain/alt(src)
	new /obj/item/radio/headset/heads/captain(src)
	new /obj/item/storage/belt/sabre(src)
	new /obj/item/storage/box/gunset/pdh_captain(src) // SKYRAT EDIT ADDITION
	new /obj/item/door_remote/captain(src)
	new /obj/item/storage/photo_album/captain(src)

/obj/structure/closet/secure_closet/hop
	name = "\proper head of personnel's locker"
	req_access = list(ACCESS_HOP)
	icon_state = "hop"
	storage_capacity = 40 //SKYRAT EDIT ADDITION

/obj/structure/closet/secure_closet/hop/PopulateContents()
	..()
	new /obj/item/storage/bag/garment/hop(src)
	new /obj/item/storage/lockbox/medal/service(src)
	new /obj/item/computer_disk/command/hop(src)
	new /obj/item/radio/headset/heads/hop(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/storage/box/gunset/pdh(src) // SKYRAT EDIT ADDITION
	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/door_remote/civilian(src)
	new /obj/item/circuitboard/machine/techfab/department/service(src)
	new /obj/item/storage/photo_album/hop(src)
	new /obj/item/storage/lockbox/medal/hop(src)

/obj/structure/closet/secure_closet/hos
	name = "\proper head of security's locker"
	req_access = list(ACCESS_HOS)
	icon_state = "hos"

/obj/structure/closet/secure_closet/hos/PopulateContents()
	..()

	new /obj/item/computer_disk/command/hos(src)
	new /obj/item/radio/headset/heads/hos(src)
	new /obj/item/storage/bag/garment/hos(src)
	new /obj/item/storage/lockbox/medal/sec(src)
	new /obj/item/megaphone/sec(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/storage/lockbox/loyalty(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/shield/riot/tele(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/circuitboard/machine/techfab/department/security(src)
	new /obj/item/storage/photo_album/hos(src)

/obj/structure/closet/secure_closet/hos/populate_contents_immediate()
	. = ..()

	// Traitor steal objectives
	new /obj/item/gun/energy/e_gun/hos(src)
	new /obj/item/pinpointer/nuke(src)

/obj/structure/closet/secure_closet/warden
	name = "\proper warden's locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "warden"

/obj/structure/closet/secure_closet/warden/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/clothing/suit/armor/vest/warden(src)
	//new /obj/item/clothing/head/hats/warden(src) SKYRAT EDIT REMOVAL
	//new /obj/item/clothing/head/hats/warden/drill(src) SKYRAT EDIT REMOVAL
	new /obj/item/clothing/head/beret/sec/navywarden(src)
	//new /obj/item/clothing/suit/armor/vest/warden/alt(src) //SKYRAT EDIT REMOVAL
	new /obj/item/clothing/under/rank/security/warden/formal(src)
	new /obj/item/clothing/suit/jacket/warden/blue(src) //SKYRAT ADDITION - FORMAL COAT
	//new /obj/item/clothing/under/rank/security/warden/skirt(src) SKYRAT EDIT REMOVAL
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/storage/box/zipties(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/clothing/gloves/krav_maga/sec(src)
	new /obj/item/door_remote/head_of_security(src)


/obj/structure/closet/secure_closet/security
	name = "security officer's locker"
	req_access = list(ACCESS_BRIG)
	icon_state = "sec"

/obj/structure/closet/secure_closet/security/PopulateContents()
	..()
//	new /obj/item/clothing/suit/armor/vest(src) //SKYRAT EDIT REMOVAL
	new /obj/item/clothing/suit/armor/vest/alt/sec(src)
	new /obj/item/clothing/head/security_cap(src) //SKYRAT EDIT ADDITION
	new /obj/item/clothing/head/helmet/sec(src)
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/radio/headset/headset_sec/alt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/flashlight/seclite(src)

/obj/structure/closet/secure_closet/security/sec

/obj/structure/closet/secure_closet/security/sec/PopulateContents()
	..()
	new /obj/item/storage/belt/security/full(src)

// SKYRAT EDIT CHANGE -- GOOFSEC DEP GUARDS
/obj/structure/closet/secure_closet/security/cargo
	name = "\proper customs agent's locker"
	req_access = list(ACCESS_BRIG_ENTRANCE, ACCESS_CARGO)
	icon_state = "qm"
	icon = 'icons/obj/storage/closet.dmi'

/obj/structure/closet/secure_closet/security/cargo/PopulateContents()
	new /obj/item/radio/headset/headset_cargo(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/under/rank/security/officer/blueshirt/skyrat/customs_agent(src)
	new /obj/item/clothing/head/helmet/blueshirt/skyrat/guard(src)
	new /obj/item/clothing/head/beret/sec/cargo(src)
	new /obj/item/clothing/suit/armor/vest/blueshirt/skyrat/customs_agent(src)
	new /obj/item/restraints/handcuffs/cable/orange(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/security/loaded/departmental/cargo(src)
	new /obj/item/clothing/glasses/hud/security(src)
	new /obj/item/clothing/glasses/hud/gun_permit(src)
	new /obj/item/storage/box/gunset/pepperball(src)

/obj/structure/closet/secure_closet/security/engine
	name = "\proper engineering guard's locker"
	req_access = list(ACCESS_BRIG_ENTRANCE, ACCESS_ENGINE_EQUIP)
	icon_state = "eng_secure"
	icon = 'icons/obj/storage/closet.dmi'

/obj/structure/closet/secure_closet/security/engine/PopulateContents()
	new /obj/item/radio/headset/headset_eng(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/under/rank/security/officer/blueshirt/skyrat/engineering_guard(src)
	new /obj/item/clothing/head/helmet/blueshirt/skyrat/guard(src)
	new /obj/item/clothing/head/beret/sec/engineering(src)
	new /obj/item/clothing/suit/armor/vest/blueshirt/skyrat/engineering_guard(src)
	new /obj/item/restraints/handcuffs/cable/yellow(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/security/loaded/departmental/engineering(src)
	new /obj/item/clothing/glasses/hud/security(src)
	new /obj/item/storage/box/gunset/pepperball(src)

/obj/structure/closet/secure_closet/security/science
	name = "\proper science guard's locker"
	req_access = list(ACCESS_BRIG_ENTRANCE, ACCESS_RESEARCH)
	icon_state = "science"
	icon = 'icons/obj/storage/closet.dmi'

/obj/structure/closet/secure_closet/security/science/PopulateContents()
	new /obj/item/radio/headset/headset_sci(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/under/rank/security/officer/blueshirt/skyrat(src)
	new /obj/item/clothing/head/helmet/blueshirt/skyrat(src)
	new /obj/item/clothing/head/beret/sec/science(src)
	new /obj/item/clothing/suit/armor/vest/blueshirt/skyrat(src)
	new /obj/item/restraints/handcuffs/cable/pink(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/security/loaded/departmental/science(src)
	new /obj/item/clothing/glasses/hud/security(src)
	new /obj/item/storage/box/gunset/pepperball(src)

/obj/structure/closet/secure_closet/security/med
	name = "\proper orderly's locker"
	req_access = list(ACCESS_BRIG_ENTRANCE, ACCESS_MEDICAL)
	icon_state = "med_secure"
	icon = 'icons/obj/storage/closet.dmi'

/obj/structure/closet/secure_closet/security/med/PopulateContents()
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/under/rank/security/officer/blueshirt/skyrat/orderly(src)
	new /obj/item/clothing/head/helmet/blueshirt/skyrat/guard(src)
	new /obj/item/clothing/head/beret/sec/medical(src)
	new /obj/item/clothing/suit/armor/vest/blueshirt/skyrat/orderly(src)
	new /obj/item/restraints/handcuffs/cable/blue(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/security/loaded/departmental/medical(src)
	new /obj/item/clothing/glasses/hud/security(src)
	new /obj/item/storage/box/gunset/pepperball(src)
// SKYRAT EDIT CHANGE END -- GOOFSEC DEP GUARDS

/obj/structure/closet/secure_closet/detective
	name = "\improper detective's cabinet"
	req_access = list(ACCESS_DETECTIVE)
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	door_anim_time = 0 // no animation
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'

/obj/structure/closet/secure_closet/detective/PopulateContents()
	..()
	new /obj/item/storage/box/evidence(src)
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/detective_scanner(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/clothing/suit/armor/vest/det_suit(src)
	new /obj/item/storage/belt/holster/detective/full(src)
	new /obj/item/pinpointer/crew(src)
	new /obj/item/binoculars(src)
	new /obj/item/storage/box/rxglasses/spyglasskit(src)

/obj/structure/closet/secure_closet/injection
	name = "lethal injections"
	req_access = list(ACCESS_HOS)

/obj/structure/closet/secure_closet/injection/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/syringe/lethal/execution(src)

/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	req_one_access = list(ACCESS_BRIG)
	anchored = TRUE
	var/id = null

/obj/structure/closet/secure_closet/brig/genpop
	name = "genpop storage locker"
	desc = "Used for storing the belongings of genpop's tourists visiting the locals."

	///Reference to the ID linked to the locker, done by swiping a prisoner ID on it
	var/datum/weakref/assigned_id_ref = null

/obj/structure/closet/secure_closet/brig/genpop/Destroy()
	assigned_id_ref = null
	return ..()

/obj/structure/closet/secure_closet/brig/genpop/examine(mob/user)
	. = ..()
	. += span_notice("<b>Right-click</b> with a Security-level ID to reset [src]'s registered ID.")

/obj/structure/closet/secure_closet/brig/genpop/attackby(obj/item/card/id/advanced/prisoner/used_id, mob/user, params)
	. = ..()
	if(!istype(used_id, /obj/item/card/id/advanced/prisoner))
		return

	if(!assigned_id_ref)
		say("Prisoner ID linked to locker.")
		assigned_id_ref = WEAKREF(used_id)
		name = "genpop storage locker - [used_id.registered_name]"
		return
	var/obj/item/card/id/advanced/prisoner/registered_id = assigned_id_ref.resolve()
	if(used_id == registered_id)
		say("Authorized ID detected. Unlocking locker and resetting ID.")
		locked = FALSE
		assigned_id_ref = null
		name = initial(name)
		update_appearance()

/obj/structure/closet/secure_closet/brig/genpop/attackby_secondary(obj/item/card/id/advanced/used_id, mob/user, params)
	. = ..()

	var/list/id_access = used_id.GetAccess()
	if(assigned_id_ref && (ACCESS_BRIG in id_access))
		say("Authorized ID detected. Unlocking locker and resetting ID.")
		locked = FALSE
		assigned_id_ref = null
		name = initial(name)
		update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/closet/secure_closet/evidence
	anchored = TRUE
	name = "Secure Evidence Closet"
	req_one_access = list("armory","detective")

/obj/structure/closet/secure_closet/brig/PopulateContents()
	..()
	new /obj/item/clothing/under/rank/prisoner( src )
	new /obj/item/clothing/under/rank/prisoner/skirt( src )
	new /obj/item/clothing/shoes/sneakers/orange( src )

/obj/structure/closet/secure_closet/courtroom
	name = "courtroom locker"
	req_access = list(ACCESS_COURT)

/obj/structure/closet/secure_closet/courtroom/PopulateContents()
	..()
	new /obj/item/clothing/shoes/sneakers/brown(src)
	for(var/i in 1 to 3)
		new /obj/item/paper/fluff/jobs/security/court_judgement (src)
	new /obj/item/pen (src)
	new /obj/item/clothing/suit/costume/judgerobe (src)
	new /obj/item/clothing/head/costume/powdered_wig (src)
	new /obj/item/storage/briefcase(src)

/obj/structure/closet/secure_closet/contraband/armory
	anchored = TRUE
	name = "Contraband Locker"
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/contraband/heads
	anchored = TRUE
	name = "Contraband Locker"
	req_access = list(ACCESS_COMMAND)

/obj/structure/closet/secure_closet/armory1
	name = "armory armor locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "armory" // SKYRAT EDIT ADDITION - NEW ICON ADDED IN peacekeeper_lockers.dm

/obj/structure/closet/secure_closet/armory1/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/armor/riot(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/helmet/riot(src)
	for(var/i in 1 to 3)
		new /obj/item/shield/riot(src)

/obj/structure/closet/secure_closet/armory1/populate_contents_immediate()
	. = ..()

	// Traitor steal objective
	new /obj/item/clothing/suit/hooded/ablative(src)

/obj/structure/closet/secure_closet/armory2
	name = "armory ballistics locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "armory" // SKYRAT EDIT ADDITION - NEW ICON ADDED IN peacekeeper_lockers.dm

/obj/structure/closet/secure_closet/armory2/PopulateContents()
	..()
	new /obj/item/storage/box/firingpins(src)
	for(var/i in 1 to 3)
		new /obj/item/storage/box/rubbershot(src)
	for(var/i in 1 to 3)
		new /obj/item/gun/ballistic/shotgun/riot(src)

/obj/structure/closet/secure_closet/armory3
	name = "armory energy gun locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "armory" // SKYRAT EDIT ADDITION - NEW ICON ADDED IN peacekeeper_lockers.dm

/obj/structure/closet/secure_closet/armory3/PopulateContents()
	..()
	new /obj/item/storage/box/firingpins(src)
	new /obj/item/gun/energy/ionrifle(src)
	for(var/i in 1 to 3)
		new /obj/item/gun/energy/e_gun(src)
	for(var/i in 1 to 3)
		new /obj/item/gun/energy/laser(src)
	for(var/i in 1 to 3)
		new /obj/item/gun/energy/laser/thermal(src)

/obj/structure/closet/secure_closet/tac
	name = "armory tac locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "tac"

/obj/structure/closet/secure_closet/tac/PopulateContents()
	..()
	new /obj/item/gun/ballistic/automatic/wt550(src)
	new /obj/item/clothing/head/helmet/alt(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/clothing/suit/armor/bulletproof(src)

/obj/structure/closet/secure_closet/labor_camp_security
	name = "labor camp security locker"
	req_access = list(ACCESS_SECURITY)
	icon_state = "sec"

/obj/structure/closet/secure_closet/labor_camp_security/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/helmet/sec(src)
	new /obj/item/clothing/under/rank/security/officer(src)
	new /obj/item/clothing/under/rank/security/officer/skirt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/flashlight/seclite(src)
