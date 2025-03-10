/obj/structure/sign/clock
	name = "wall clock"
	desc = "It's your run-of-the-mill wall clock showing both the local Coalition Standard Time and the galactic Treaty Coordinated Time. Perfect for staring at instead of working."
	icon_state = "clock"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/clock, 32)

/obj/structure/sign/clock/examine(mob/user)
	. = ..()
	. += span_info("The current CST (local) time is: [station_time_timestamp()].")
	. += span_info("The current TCT (galactic) time is: [time2text(world.realtime, "hh:mm:ss")].")

/obj/structure/sign/calendar
	name = "wall calendar"
	desc = "It's an old-school wall calendar. Sure, it might be obsolete with modern technology, but it's still hard to imagine an office without one."
	icon_state = "calendar"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/calendar, 32)

/obj/structure/sign/calendar/examine(mob/user)
	. = ..()
	. += span_info("The current date is: [time2text(world.realtime, "DDD, MMM DD")], [CURRENT_STATION_YEAR].")
	if(SSevents.holidays)
		. += span_info("Events:")
		for(var/holidayname in SSevents.holidays)
			. += span_info("[holidayname]")

/**
 * List of delamination counter signs on the map.
 * Required as persistence subsystem loads after the ones present at mapload, and to reset to 0 upon explosion.
 */
GLOBAL_LIST_EMPTY(map_delamination_counters)

/obj/structure/sign/delamination_counter
	name = "delamination counter"
	sign_change_name = "Flip Sign- Supermatter Delamination"
	desc = "A pair of flip signs describe how long it's been since the last delamination incident."
	icon_state = "days_since_explosion"
	is_editable = TRUE
	var/since_last = 0

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/delamination_counter, 32)

/obj/structure/sign/delamination_counter/Initialize(mapload)
	. = ..()
	GLOB.map_delamination_counters += src
	if (!mapload)
		update_count(SSpersistence.rounds_since_engine_exploded)

/obj/structure/sign/delamination_counter/Destroy()
	GLOB.map_delamination_counters -= src
	return ..()

/obj/structure/sign/delamination_counter/proc/update_count(new_count)
	since_last = min(new_count, 99)
	update_appearance()

/obj/structure/sign/delamination_counter/update_overlays()
	. = ..()

	var/ones = since_last % 10
	var/mutable_appearance/ones_overlay = mutable_appearance('icons/obj/signs.dmi', "days_[ones]")
	ones_overlay.pixel_x = 4
	. += ones_overlay

	var/tens = (since_last / 10) % 10
	var/mutable_appearance/tens_overlay = mutable_appearance('icons/obj/signs.dmi', "days_[tens]")
	tens_overlay.pixel_x = -5
	. += tens_overlay

/obj/structure/sign/delamination_counter/examine(mob/user)
	. = ..()
	. += span_info("It has been [since_last] day\s since the last delamination event at a Nanotrasen facility.")
	switch (since_last)
		if (0)
			. += span_info("In case you didn't notice.")
		if(1)
			. += span_info("Let's do better today.")
		if(2 to 5)
			. += span_info("There's room for improvement.")
		if(6 to 10)
			. += span_info("Good work!")
		if(11 to INFINITY)
			. += span_info("Incredible!")
