/mob/living/carbon/Life(delta_time = SSMOBS_DT, times_fired)

	if(notransform)
		return

	//SKYRAT EDIT ADDITION
	if(isopenturf(loc))
		var/turf/open/my_our_turf = loc
		if(my_our_turf.pollution)
			my_our_turf.pollution.touch_act(src)
	//SKYRAT EDIT END

	if(damageoverlaytemp)
		damageoverlaytemp = 0
		update_damage_hud()

	if(IS_IN_STASIS(src))
		. = ..()
		reagents.handle_stasis_chems(src, delta_time, times_fired)
	else
		//Reagent processing needs to come before breathing, to prevent edge cases.
		handle_organs(delta_time, times_fired)

		. = ..()
		if(QDELETED(src))
			return

		if(.) //not dead
			handle_blood(delta_time, times_fired)

		if(stat != DEAD)
			handle_brain_damage(delta_time, times_fired)

	if(stat == DEAD)
		stop_sound_channel(CHANNEL_HEARTBEAT)
	else
		var/bprv = handle_bodyparts(delta_time, times_fired)
		if(bprv & BODYPART_LIFE_UPDATE_HEALTH)
			update_stamina() //needs to go before updatehealth to remove stamcrit
			updatehealth()

	check_cremation(delta_time, times_fired)

	if(. && mind) //. == not dead
		for(var/key in mind.addiction_points)
			var/datum/addiction/addiction = SSaddiction.all_addictions[key]
			addiction.process_addiction(src, delta_time, times_fired)
	if(stat != DEAD)
		return 1

///////////////
// BREATHING //
///////////////

//Start of a breath chain, calls breathe()
/mob/living/carbon/handle_breathing(delta_time, times_fired)
	var/next_breath = 4
	var/obj/item/organ/internal/lungs/L = getorganslot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/internal/heart/H = getorganslot(ORGAN_SLOT_HEART)
	if(L)
		if(L.damage > L.high_threshold)
			next_breath--
	if(H)
		if(H.damage > H.high_threshold)
			next_breath--

	if((times_fired % next_breath) == 0 || failed_last_breath)
		breathe(delta_time, times_fired) //Breathe per 4 ticks if healthy, down to 2 if our lungs or heart are damaged, unless suffocating
		if(failed_last_breath)
			add_mood_event("suffocation", /datum/mood_event/suffocation)
		else
			clear_mood_event("suffocation")
	else
		if(isobj(loc))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src,0)

//Second link in a breath chain, calls check_breath()
/mob/living/carbon/proc/breathe(delta_time, times_fired)
	var/obj/item/organ/internal/lungs = getorganslot(ORGAN_SLOT_LUNGS)
	if(SEND_SIGNAL(src, COMSIG_CARBON_ATTEMPT_BREATHE) & COMSIG_CARBON_BLOCK_BREATH)
		return

	SEND_SIGNAL(src, COMSIG_CARBON_PRE_BREATHE)

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(!getorganslot(ORGAN_SLOT_BREATHING_TUBE))
		if(health <= HEALTH_THRESHOLD_FULLCRIT || (pulledby?.grab_state >= GRAB_KILL) || (lungs?.organ_flags & ORGAN_FAILING))
			losebreath++  //You can't breath at all when in critical or when being choked, so you're going to miss a breath

		else if(health <= crit_threshold)
			losebreath += 0.25 //You're having trouble breathing in soft crit, so you'll miss a breath one in four times

	//Suffocate
	if(losebreath >= 1) //You've missed a breath, take oxy damage
		losebreath--
		if(prob(10))
			emote("gasp")
		if(isobj(loc))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src,0)
	else
		//Breathe from internal
		breath = get_breath_from_internal(BREATH_VOLUME)

		if(isnull(breath)) //in case of 0 pressure internals

			if(isobj(loc)) //Breathe from loc as object
				var/obj/loc_as_obj = loc
				breath = loc_as_obj.handle_internal_lifeform(src, BREATH_VOLUME)

			else if(isturf(loc)) //Breathe from loc as turf
				//SKYRAT EDIT ADDITION
				//Underwater breathing
				var/turf/our_turf = loc
				if(our_turf.liquids && !HAS_TRAIT(src, TRAIT_NOBREATH) && ((body_position == LYING_DOWN && our_turf.liquids.liquid_state >= LIQUID_STATE_WAIST) || (body_position == STANDING_UP && our_turf.liquids.liquid_state >= LIQUID_STATE_FULLTILE)))
					//Officially trying to breathe underwater
					if(HAS_TRAIT(src, TRAIT_WATER_BREATHING))
						failed_last_breath = FALSE
						clear_alert("not_enough_oxy")
						return FALSE
					adjustOxyLoss(3)
					failed_last_breath = TRUE
					if(oxyloss <= OXYGEN_DAMAGE_CHOKING_THRESHOLD && stat == CONSCIOUS)
						to_chat(src, "<span class='userdanger'>You hold in your breath!</span>")
					else
						//Try and drink water
						var/datum/reagents/tempr = our_turf.liquids.take_reagents_flat(CHOKE_REAGENTS_INGEST_ON_BREATH_AMOUNT)
						tempr.trans_to(src, tempr.total_volume, methods = INGEST)
						qdel(tempr)
						visible_message("<span class='warning'>[src] chokes on water!</span>", \
									"<span class='userdanger'>You're choking on water!</span>")
					return FALSE
				if(isopenturf(our_turf))
					var/turf/open/open_turf = our_turf
					if(open_turf.pollution)
						if(next_smell <= world.time)
							next_smell = world.time + SMELL_COOLDOWN
							open_turf.pollution.smell_act(src)
						open_turf.pollution.breathe_act(src)
				//SKYRAT EDIT END
				var/breath_moles = 0
				if(environment)
					breath_moles = environment.total_moles()*BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)
		else //Breathe from loc as obj again
			if(isobj(loc))
				var/obj/loc_as_obj = loc
				loc_as_obj.handle_internal_lifeform(src,0)

	check_breath(breath)

	if(breath)
		loc.assume_air(breath)

/mob/living/carbon/proc/has_smoke_protection()
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return TRUE
	return FALSE


//Third link in a breath chain, calls handle_breath_temperature()
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		failed_last_breath = FALSE
		clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return FALSE

	var/obj/item/organ/internal/lungs = getorganslot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		adjustOxyLoss(2)

	//CRIT
	if(!breath || (breath.total_moles() == 0) || !lungs)
		if(reagents.has_reagent(/datum/reagent/medicine/epinephrine, needs_metabolizing = TRUE) && lungs)
			return FALSE
		adjustOxyLoss(1)

		failed_last_breath = TRUE
		throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
		return FALSE
	
	var/safe_oxy_min = 16
	var/safe_co2_max = 10
	var/safe_plas_max = 0.05
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/oxygen_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	var/list/breath_gases = breath.gases
	breath.assert_gases(/datum/gas/oxygen, /datum/gas/plasma, /datum/gas/carbon_dioxide, /datum/gas/nitrous_oxide, /datum/gas/bz)
	var/O2_partialpressure = (breath_gases[/datum/gas/oxygen][MOLES]/breath.total_moles())*breath_pressure
	var/Plasma_partialpressure = (breath_gases[/datum/gas/plasma][MOLES]/breath.total_moles())*breath_pressure
	var/CO2_partialpressure = (breath_gases[/datum/gas/carbon_dioxide][MOLES]/breath.total_moles())*breath_pressure


	//OXYGEN
	if(O2_partialpressure < safe_oxy_min) //Not enough oxygen
		if(prob(20))
			emote("gasp")
		if(O2_partialpressure > 0)
			var/ratio = 1 - O2_partialpressure/safe_oxy_min
			adjustOxyLoss(min(5*ratio, 3))
			failed_last_breath = TRUE
			oxygen_used = breath_gases[/datum/gas/oxygen][MOLES]*ratio
		else
			adjustOxyLoss(3)
			failed_last_breath = TRUE
		throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)

	else //Enough oxygen
		failed_last_breath = FALSE
		if(health >= crit_threshold)
			adjustOxyLoss(-5)
		oxygen_used = breath_gases[/datum/gas/oxygen][MOLES]
		clear_alert(ALERT_NOT_ENOUGH_OXYGEN)

	breath_gases[/datum/gas/oxygen][MOLES] -= oxygen_used
	breath_gases[/datum/gas/carbon_dioxide][MOLES] += oxygen_used

	//CARBON DIOXIDE
	if(CO2_partialpressure > safe_co2_max)
		if(!co2overloadtime)
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Unconscious(60)
			adjustOxyLoss(3)
			if(world.time - co2overloadtime > 300)
				adjustOxyLoss(8)
		if(prob(20))
			emote("cough")

	else
		co2overloadtime = 0

	//PLASMA
	if(Plasma_partialpressure > safe_plas_max)
		var/ratio = (breath_gases[/datum/gas/plasma][MOLES]/safe_plas_max) * 10
		adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		throw_alert(ALERT_TOO_MUCH_PLASMA, /atom/movable/screen/alert/too_much_plas)
	else
		clear_alert(ALERT_TOO_MUCH_PLASMA)

	//NITROUS OXIDE
	if(breath_gases[/datum/gas/nitrous_oxide])
		var/SA_partialpressure = (breath_gases[/datum/gas/nitrous_oxide][MOLES]/breath.total_moles())*breath_pressure
		if(SA_partialpressure > SA_para_min)
			throw_alert(ALERT_TOO_MUCH_N2O, /atom/movable/screen/alert/too_much_n2o)
			clear_mood_event("chemical_euphoria")
			Unconscious(60)
			if(SA_partialpressure > SA_sleep_min)
				Sleeping(max(AmountSleeping() + 40, 200))
		else if(SA_partialpressure > 0.01)
			clear_alert(ALERT_TOO_MUCH_N2O)
			if(prob(20))
				emote(pick("giggle","laugh"))
			add_mood_event("chemical_euphoria", /datum/mood_event/chemical_euphoria)
		else
			clear_mood_event("chemical_euphoria")
			clear_alert(ALERT_TOO_MUCH_N2O)
	else
		clear_mood_event("chemical_euphoria")
		clear_alert(ALERT_TOO_MUCH_N2O)

	//BZ (Facepunch port of their Agent B)
	if(breath_gases[/datum/gas/bz])
		var/bz_partialpressure = (breath_gases[/datum/gas/bz][MOLES]/breath.total_moles())*breath_pressure
		if(bz_partialpressure > 1)
			adjust_hallucinations(20 SECONDS)
		else if(bz_partialpressure > 0.01)
			adjust_hallucinations(10 SECONDS)

	//NITRIUM
	if(breath_gases[/datum/gas/nitrium])
		var/nitrium_partialpressure = (breath_gases[/datum/gas/nitrium][MOLES]/breath.total_moles())*breath_pressure
		if(nitrium_partialpressure > 0.5)
			adjustFireLoss(nitrium_partialpressure * 0.15)
		if(nitrium_partialpressure > 5)
			adjustToxLoss(nitrium_partialpressure * 0.05)

	//FREON
	if(breath_gases[/datum/gas/freon])
		var/freon_partialpressure = (breath_gases[/datum/gas/freon][MOLES]/breath.total_moles())*breath_pressure
		adjustFireLoss(freon_partialpressure * 0.25)

	//MIASMA
	if(breath_gases[/datum/gas/miasma])
		var/miasma_partialpressure = (breath_gases[/datum/gas/miasma][MOLES]/breath.total_moles())*breath_pressure

		if(prob(1 * miasma_partialpressure))
			var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(2,3)
			miasma_disease.name = "Unknown"
			ForceContractDisease(miasma_disease, TRUE, TRUE)

		//Miasma side effects
		switch(miasma_partialpressure)
			if(0.25 to 5)
				// At lower pp, give out a little warning
				clear_mood_event("smell")
				if(prob(5))
					to_chat(src, span_notice("There is an unpleasant smell in the air."))
			if(5 to 20)
				//At somewhat higher pp, warning becomes more obvious
				if(prob(15))
					to_chat(src, span_warning("You smell something horribly decayed inside this room."))
					add_mood_event("smell", /datum/mood_event/disgust/bad_smell)
			if(15 to 30)
				//Small chance to vomit. By now, people have internals on anyway
				if(prob(5))
					to_chat(src, span_warning("The stench of rotting carcasses is unbearable!"))
					add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
					vomit()
			if(30 to INFINITY)
				//Higher chance to vomit. Let the horror start
				if(prob(25))
					to_chat(src, span_warning("The stench of rotting carcasses is unbearable!"))
					add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
					vomit()
			else
				clear_mood_event("smell")

	//Clear all moods if no miasma at all
	else
		clear_mood_event("smell")

	breath.garbage_collect()

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

	return TRUE

//Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	// The air you breathe out should match your body temperature
	breath.temperature = bodytemperature

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if(internal.loc != src && !(wear_mask.clothing_flags & MASK_EXTEND_RANGE)) //SKYRAT EDIT ANESTHETIC MACHINE. ORIGNIAL CODE: if(internal.loc != src)
			internal = null
		else if ((!wear_mask || !(wear_mask.clothing_flags & MASKINTERNALS)) && !getorganslot(ORGAN_SLOT_BREATHING_TUBE))
			internal = null
		else
			. = internal.remove_air_volume(volume_needed)
			if(!.)
				return FALSE //to differentiate between no internals and active, but empty internals

/mob/living/carbon/proc/handle_blood(delta_time, times_fired)
	return

/mob/living/carbon/proc/handle_bodyparts(delta_time, times_fired)
	if(stam_regen_start_time <= world.time)
		if(HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA))
			. |= BODYPART_LIFE_UPDATE_HEALTH //make sure we remove the stamcrit
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		. |= limb.on_life(delta_time, times_fired)

/mob/living/carbon/proc/handle_organs(delta_time, times_fired)
	if(stat == DEAD)
		if(reagents.has_reagent(/datum/reagent/toxin/formaldehyde, 1) || reagents.has_reagent(/datum/reagent/cryostylane)) // No organ decay if the body contains formaldehyde.
			return
		for(var/obj/item/organ/internal/organ as anything in internal_organs)
			// On-death is where organ decay is handled
			organ.on_death(delta_time, times_fired)
			// We need to re-check the stat every organ, as one of our others may have revived us
			if(stat != DEAD)
				break
		return

	// NOTE: internal_organs_slot is sorted by GLOB.organ_process_order on insertion
	for(var/slot in internal_organs_slot)
		// We don't use getorganslot here because we know we have the organ we want, since we're iterating the list containing em already
		// This code is hot enough that it's just not worth the time
		var/obj/item/organ/internal/organ = internal_organs_slot[slot]
		if(organ?.owner) // This exist mostly because reagent metabolization can cause organ reshuffling
			organ.on_life(delta_time, times_fired)


/mob/living/carbon/handle_diseases(delta_time, times_fired)
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(DT_PROB(D.infectivity, delta_time))
			D.spread()

		if(stat != DEAD || D.process_dead)
			D.stage_act(delta_time, times_fired)

/mob/living/carbon/handle_wounds(delta_time, times_fired)
	for(var/thing in all_wounds)
		var/datum/wound/W = thing
		if(W.processes) // meh
			W.handle_process(delta_time, times_fired)

/mob/living/carbon/handle_mutations(time_since_irradiated, delta_time, times_fired)
	if(!dna?.temporary_mutations.len)
		return

	for(var/mut in dna.temporary_mutations)
		if(dna.temporary_mutations[mut] < world.time)
			if(mut == UI_CHANGED)
				if(dna.previous["UI"])
					dna.unique_identity = merge_text(dna.unique_identity,dna.previous["UI"])
					updateappearance(mutations_overlay_update=1)
					dna.previous.Remove("UI")
				dna.temporary_mutations.Remove(mut)
				continue
			if(mut == UF_CHANGED)
				if(dna.previous["UF"])
					dna.unique_features = merge_text(dna.unique_features,dna.previous["UF"])
					updateappearance(mutcolor_update=1, mutations_overlay_update=1)
					dna.previous.Remove("UF")
				dna.temporary_mutations.Remove(mut)
				continue
			if(mut == UE_CHANGED)
				if(dna.previous["name"])
					real_name = dna.previous["name"]
					name = real_name
					dna.previous.Remove("name")
				if(dna.previous["UE"])
					dna.unique_enzymes = dna.previous["UE"]
					dna.previous.Remove("UE")
				if(dna.previous["blood_type"])
					dna.blood_type = dna.previous["blood_type"]
					dna.previous.Remove("blood_type")
				dna.temporary_mutations.Remove(mut)
				continue
	for(var/datum/mutation/human/HM in dna.mutations)
		if(HM?.timeout)
			dna.remove_mutation(HM.type)

// This updates all special effects that really should be status effect datums: Druggy, Hallucinations, Drunkenness, Mute, etc..
/mob/living/carbon/handle_status_effects(delta_time, times_fired)
	..()

	var/restingpwr = 0.5 + 2 * resting

	if(drowsyness)
		adjust_drowsyness(-1 * restingpwr * delta_time)
		blur_eyes(1 * delta_time)
		if(DT_PROB(2.5, delta_time))
			AdjustSleeping(10 SECONDS)

/// Base carbon environment handler, adds natural stabilization
/mob/living/carbon/handle_environment(datum/gas_mixture/environment, delta_time, times_fired)
	var/areatemp = get_temperature(environment)

	if(stat != DEAD) // If you are dead your body does not stabilize naturally
		natural_bodytemperature_stabilization(environment, delta_time, times_fired)

	if(!on_fire || areatemp > bodytemperature) // If we are not on fire or the area is hotter
		adjust_bodytemperature((areatemp - bodytemperature), use_insulation=TRUE, use_steps=TRUE)

/**
 * Used to stabilize the body temperature back to normal on living mobs
 *
 * Arguments:
 * - [environemnt][/datum/gas_mixture]: The environment gas mix
 * - delta_time: The amount of time that has elapsed since the last tick
 * - times_fired: The number of times SSmobs has ticked
 */
/mob/living/carbon/proc/natural_bodytemperature_stabilization(datum/gas_mixture/environment, delta_time, times_fired)
	var/areatemp = get_temperature(environment)
	var/body_temperature_difference = get_body_temp_normal() - bodytemperature
	var/natural_change = 0

	// We are very cold, increase body temperature
	if(bodytemperature <= BODYTEMP_COLD_DAMAGE_LIMIT)
		natural_change = max((body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR), \
			BODYTEMP_AUTORECOVERY_MINIMUM)

	// we are cold, reduce the minimum increment and do not jump over the difference
	else if(bodytemperature > BODYTEMP_COLD_DAMAGE_LIMIT && bodytemperature < get_body_temp_normal())
		natural_change = max(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, \
			min(body_temperature_difference, BODYTEMP_AUTORECOVERY_MINIMUM / 4))

	// We are hot, reduce the minimum increment and do not jump below the difference
	else if(bodytemperature > get_body_temp_normal() && bodytemperature <= BODYTEMP_HEAT_DAMAGE_LIMIT)
		natural_change = min(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, \
			max(body_temperature_difference, -(BODYTEMP_AUTORECOVERY_MINIMUM / 4)))

	// We are very hot, reduce the body temperature
	else if(bodytemperature >= BODYTEMP_HEAT_DAMAGE_LIMIT)
		natural_change = min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)

	var/thermal_protection = 1 - get_insulation_protection(areatemp) // invert the protection
	if(areatemp > bodytemperature) // It is hot here
		if(bodytemperature < get_body_temp_normal())
			// Our bodytemp is below normal we are cold, insulation helps us retain body heat
			// and will reduce the heat we lose to the environment
			natural_change = (thermal_protection + 1) * natural_change
		else
			// Our bodytemp is above normal and sweating, insulation hinders out ability to reduce heat
			// but will reduce the amount of heat we get from the environment
			natural_change = (1 / (thermal_protection + 1)) * natural_change
	else // It is cold here
		if(!on_fire) // If on fire ignore ignore local temperature in cold areas
			if(bodytemperature < get_body_temp_normal())
				// Our bodytemp is below normal, insulation helps us retain body heat
				// and will reduce the heat we lose to the environment
				natural_change = (thermal_protection + 1) * natural_change
			else
				// Our bodytemp is above normal and sweating, insulation hinders out ability to reduce heat
				// but will reduce the amount of heat we get from the environment
				natural_change = (1 / (thermal_protection + 1)) * natural_change

	// Apply the natural stabilization changes
	adjust_bodytemperature(natural_change * delta_time)

/**
 * Get the insulation that is appropriate to the temperature you're being exposed to.
 * All clothing, natural insulation, and traits are combined returning a single value.
 *
 * required temperature The Temperature that you're being exposed to
 *
 * return the percentage of protection as a value from 0 - 1
**/
/mob/living/carbon/proc/get_insulation_protection(temperature)
	return (temperature > bodytemperature) ? get_heat_protection(temperature) : get_cold_protection(temperature)

/// This returns the percentage of protection from heat as a value from 0 - 1
/// temperature is the temperature you're being exposed to
/mob/living/carbon/proc/get_heat_protection(temperature)
	return heat_protection

/// This returns the percentage of protection from cold as a value from 0 - 1
/// temperature is the temperature you're being exposed to
/mob/living/carbon/proc/get_cold_protection(temperature)
	return cold_protection

/**
 * Have two mobs share body heat between each other.
 * Account for the insulation and max temperature change range for the mob
 *
 * vars:
 * * M The mob/living/carbon that is sharing body heat
 */
/mob/living/carbon/proc/share_bodytemperature(mob/living/carbon/M)
	var/temp_diff = bodytemperature - M.bodytemperature
	if(temp_diff > 0) // you are warm share the heat of life
		M.adjust_bodytemperature((temp_diff * 0.5), use_insulation=TRUE, use_steps=TRUE) // warm up the giver
		adjust_bodytemperature((temp_diff * -0.5), use_insulation=TRUE, use_steps=TRUE) // cool down the reciver

	else // they are warmer leech from them
		adjust_bodytemperature((temp_diff * -0.5) , use_insulation=TRUE, use_steps=TRUE) // warm up the reciver
		M.adjust_bodytemperature((temp_diff * 0.5), use_insulation=TRUE, use_steps=TRUE) // cool down the giver

/**
 * Adjust the body temperature of a mob
 * expanded for carbon mobs allowing the use of insulation and change steps
 *
 * vars:
 * * amount The amount of degrees to change body temperature by
 * * min_temp (optional) The minimum body temperature after adjustment
 * * max_temp (optional) The maximum body temperature after adjustment
 * * use_insulation (optional) modifies the amount based on the amount of insulation the mob has
 * * use_steps (optional) Use the body temp divisors and max change rates
 * * capped (optional) default True used to cap step mode
 */
/mob/living/carbon/adjust_bodytemperature(amount, min_temp=0, max_temp=INFINITY, use_insulation=FALSE, use_steps=FALSE, capped=TRUE)
	// apply insulation to the amount of change
	if(use_insulation)
		amount *= (1 - get_insulation_protection(bodytemperature + amount))

	// Use the bodytemp divisors to get the change step, with max step size
	if(use_steps)
		amount = (amount > 0) ? (amount / BODYTEMP_HEAT_DIVISOR) : (amount / BODYTEMP_COLD_DIVISOR)
		// Clamp the results to the min and max step size
		if(capped)
			amount = (amount > 0) ? min(amount, BODYTEMP_HEATING_MAX) : max(amount, BODYTEMP_COOLING_MAX)

	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		bodytemperature = clamp(bodytemperature + amount, min_temp, max_temp)


///////////
//Stomach//
///////////

/mob/living/carbon/get_fullness()
	var/fullness = nutrition

	var/obj/item/organ/internal/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(!belly) //nothing to see here if we do not have a stomach
		return fullness

	for(var/bile in belly.reagents.reagent_list)
		var/datum/reagent/bits = bile
		if(istype(bits, /datum/reagent/consumable))
			var/datum/reagent/consumable/goodbit = bile
			fullness += goodbit.nutriment_factor * goodbit.volume / goodbit.metabolization_rate
			continue
		fullness += 0.6 * bits.volume / bits.metabolization_rate //not food takes up space

	return fullness

/mob/living/carbon/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	. = ..()
	if(.)
		return
	var/obj/item/organ/internal/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(!belly)
		return FALSE
	return belly.reagents.has_reagent(reagent, amount, needs_metabolizing)

/////////
//LIVER//
/////////

///Check to see if we have the liver, if not automatically gives you last-stage effects of lacking a liver.

/mob/living/carbon/proc/handle_liver(delta_time, times_fired)
	if(!dna)
		return

	var/obj/item/organ/internal/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
	if(liver)
		return

	reagents.end_metabolization(src, keep_liverless = TRUE) //Stops trait-based effects on reagents, to prevent permanent buffs
	reagents.metabolize(src, delta_time, times_fired, can_overdose=FALSE, liverless = TRUE)

	if(HAS_TRAIT(src, TRAIT_STABLELIVER) || HAS_TRAIT(src, TRAIT_NOMETABOLISM))
		return

	adjustToxLoss(0.6 * delta_time, TRUE,  TRUE)
	adjustOrganLoss(pick(ORGAN_SLOT_HEART, ORGAN_SLOT_LUNGS, ORGAN_SLOT_STOMACH, ORGAN_SLOT_EYES, ORGAN_SLOT_EARS), 0.5* delta_time)

/mob/living/carbon/proc/undergoing_liver_failure()
	var/obj/item/organ/internal/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
	if(liver?.organ_flags & ORGAN_FAILING)
		return TRUE

/////////////
//CREMATION//
/////////////
/mob/living/carbon/proc/check_cremation(delta_time, times_fired)
	//Only cremate while actively on fire
	if(!on_fire)
		return

	//Only starts when the chest has taken full damage
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(!(chest.get_damage() >= chest.max_damage))
		return

	//Burn off limbs one by one
	var/obj/item/bodypart/limb
	var/list/limb_list = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/still_has_limbs = FALSE
	for(var/zone in limb_list)
		limb = get_bodypart(zone)
		if(limb)
			still_has_limbs = TRUE
			if(limb.get_damage() >= limb.max_damage)
				limb.cremation_progress += rand(1 * delta_time, 2.5 * delta_time)
				if(limb.cremation_progress >= 100)
					if(IS_ORGANIC_LIMB(limb)) //Non-organic limbs don't burn
						limb.drop_limb()
						limb.visible_message(span_warning("[src]'s [limb.plaintext_zone] crumbles into ash!"))
						qdel(limb)
					else
						limb.drop_limb()
						limb.visible_message(span_warning("[src]'s [limb.plaintext_zone] detaches from [p_their()] body!"))
	if(still_has_limbs)
		return

	//Burn the head last
	var/obj/item/bodypart/head = get_bodypart(BODY_ZONE_HEAD)
	if(head)
		if(head.get_damage() >= head.max_damage)
			head.cremation_progress += rand(1 * delta_time, 2.5 * delta_time)
			if(head.cremation_progress >= 100)
				if(IS_ORGANIC_LIMB(head)) //Non-organic limbs don't burn
					head.drop_limb()
					head.visible_message(span_warning("[src]'s head crumbles into ash!"))
					qdel(head)
				else
					head.drop_limb()
					head.visible_message(span_warning("[src]'s head detaches from [p_their()] body!"))
		return

	//Nothing left: dust the body, drop the items (if they're flammable they'll burn on their own)
	chest.cremation_progress += rand(1 * delta_time, 2.5 * delta_time)
	if(chest.cremation_progress >= 100)
		visible_message(span_warning("[src]'s body crumbles into a pile of ash!"))
		dust(TRUE, TRUE)

////////////////
//BRAIN DAMAGE//
////////////////

/mob/living/carbon/proc/handle_brain_damage(delta_time, times_fired)
	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_life(delta_time, times_fired)

/////////////////////////////////////
//MONKEYS WITH TOO MUCH CHOLOESTROL//
/////////////////////////////////////

/mob/living/carbon/proc/can_heartattack()
	if(!needs_heart())
		return FALSE
	var/obj/item/organ/internal/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(!heart || (heart.organ_flags & ORGAN_SYNTHETIC))
		return FALSE
	return TRUE

/mob/living/carbon/proc/needs_heart()
	if(HAS_TRAIT(src, TRAIT_STABLEHEART))
		return FALSE
	if(dna && dna.species && (NOBLOOD in dna.species.species_traits)) //not all carbons have species!
		return FALSE
	return TRUE

/*
 * The mob is having a heart attack
 *
 * NOTE: this is true if the mob has no heart and needs one, which can be suprising,
 * you are meant to use it in combination with can_heartattack for heart attack
 * related situations (i.e not just cardiac arrest)
 */
/mob/living/carbon/proc/undergoing_cardiac_arrest()
	var/obj/item/organ/internal/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(istype(heart) && heart.beating)
		return FALSE
	else if(!needs_heart())
		return FALSE
	return TRUE

/mob/living/carbon/proc/set_heartattack(status)
	if(!can_heartattack())
		return FALSE

	var/obj/item/organ/internal/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(!istype(heart))
		return

	heart.beating = !status
