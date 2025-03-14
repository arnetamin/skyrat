//include unit test files in this module in this ifdef
//Keep this sorted alphabetically

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// For advanced cases, fail unconditionally but don't return (so a test can return multiple results)
#define TEST_FAIL(reason) (Fail(reason || "No reason", __FILE__, __LINE__))

/// Asserts that a condition is true
/// If the condition is not true, fails the test
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that a parameter is not null
#define TEST_ASSERT_NOTNULL(a, reason) if (isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that a parameter is null
#define TEST_ASSERT_NULL(a, reason) if (!isnull(a)) { return Fail("Expected null value but received [a]: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that the two parameters passed are equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Asserts that the two parameters passed are not equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_NOTEQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs == rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to not be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// *Only* run the test provided within the parentheses
/// This is useful for debugging when you want to reduce noise, but should never be pushed
/// Intended to be used in the manner of `TEST_FOCUS(/datum/unit_test/math)`
#define TEST_FOCUS(test_path) ##test_path { focus = TRUE; }

/// Logs a noticable message on GitHub, but will not mark as an error.
/// Use this when something shouldn't happen and is of note, but shouldn't block CI.
/// Does not mark the test as failed.
#define TEST_NOTICE(source, message) source.log_for_test((##message), "notice", __FILE__, __LINE__)

/// Constants indicating unit test completion status
#define UNIT_TEST_PASSED 0
#define UNIT_TEST_FAILED 1
#define UNIT_TEST_SKIPPED 2

#define TEST_PRE 0
#define TEST_DEFAULT 1
/// This should be one of the last tests to run, because we run it for a little bit over 30 seconds by design and we want to run all of the tests that take a trivial amount of time to complete beforehand.
#define TEST_MONKEY_BUSINESS 10
/// This must be the last test to run due to the inherent nature of the test iterating every single tangible atom in the game and qdeleting all of them (while taking long sleeps to make sure the garbage collector fires properly) taking a large amount of time.
#define TEST_CREATE_AND_DESTROY INFINITY

/// Change color to red on ANSI terminal output, if enabled with -DANSICOLORS.
#ifdef ANSICOLORS
#define TEST_OUTPUT_RED(text) "\x1B\x5B1;31m[text]\x1B\x5B0m"
#else
#define TEST_OUTPUT_RED(text) (text)
#endif
/// Change color to green on ANSI terminal output, if enabled with -DANSICOLORS.
#ifdef ANSICOLORS
#define TEST_OUTPUT_GREEN(text) "\x1B\x5B1;32m[text]\x1B\x5B0m"
#else
#define TEST_OUTPUT_GREEN(text) (text)
#endif

/// A trait source when adding traits through unit tests
#define TRAIT_SOURCE_UNIT_TESTS "unit_tests"

// SKYRAT EDIT START
#include "~skyrat/opposing_force.dm"
#include "~skyrat/automapper.dm"
//SKYRAT EDIT END
#include "ablative_hud.dm"
#include "achievements.dm"
#include "anchored_mobs.dm"
#include "anonymous_themes.dm"
#include "autowiki.dm"
#include "barsigns.dm"
#include "bespoke_id.dm"
#include "binary_insert.dm"
#include "bloody_footprints.dm"
#include "breath.dm"
#include "cable_powernets.dm"
#include "card_mismatch.dm"
#include "chain_pull_through_space.dm"
#include "chat_filter.dm"
#include "circuit_component_category.dm"
#include "closets.dm"
#include "combat.dm"
#include "component_tests.dm"
#include "confusion.dm"
#include "connect_loc.dm"
#include "crayons.dm"
#include "create_and_destroy.dm"
#include "dcs_get_id_from_elements.dm"
#include "designs.dm"
#include "dummy_spawn.dm"
#include "dynamic_ruleset_sanity.dm"
#include "egg_glands.dm"
#include "emoting.dm"
#include "food_edibility_check.dm"
#include "gas_transfer.dm"
#include "get_turf_pixel.dm"
#include "greyscale_config.dm"
#include "hallucination_icons.dm"
#include "heretic_knowledge.dm"
#include "heretic_rituals.dm"
#include "holidays.dm"
#include "human_through_recycler.dm"
#include "hydroponics_extractor_storage.dm"
#include "hydroponics_harvest.dm"
#include "hydroponics_self_mutations.dm"
#include "hydroponics_validate_genes.dm"
#include "inhands.dm"
#include "keybinding_init.dm"
#include "knockoff_component.dm"
#include "limbsanity.dm"
#include "load_map_security.dm"
#include "machine_disassembly.dm"
#include "mapping.dm"
#include "mecha_damage.dm"
#include "medical_wounds.dm"
#include "merge_type.dm"
#include "metabolizing.dm"
#include "mindbound_actions.dm"
#include "mob_faction.dm"
#include "mob_spawn.dm"
#include "modsuit.dm"
#include "modular_map_loader.dm"
#include "monkey_business.dm"
#include "mouse_bite_cable.dm"
#include "novaflower_burn.dm"
#include "ntnetwork_tests.dm"
#include "nuke_cinematic.dm"
#include "objectives.dm"
#include "operating_table.dm"
#include "outfit_sanity.dm"
#include "paintings.dm"
#include "pills.dm"
#include "plane_double_transform.dm"
#include "plane_dupe_detector.dm"
#include "plantgrowth_tests.dm"
#include "preference_species.dm"
#include "preferences.dm"
#include "projectiles.dm"
#include "quirks.dm"
#include "range_return.dm"
#include "rcd.dm"
#include "reagent_id_typos.dm"
#include "reagent_mod_expose.dm"
#include "reagent_mod_procs.dm"
#include "reagent_names.dm"
#include "reagent_recipe_collisions.dm"
#include "reagent_transfer.dm"
#include "resist.dm"
#include "say.dm"
#include "screenshot_antag_icons.dm"
#include "screenshot_basic.dm"
#include "screenshot_humanoids.dm"
#include "screenshot_saturnx.dm"
#include "security_officer_distribution.dm"
#include "security_levels.dm"
#include "serving_tray.dm"
#include "siunit.dm"
#include "slips.dm"
#include "spawn_humans.dm"
#include "spawn_mobs.dm"
#include "species_change_clothing.dm"
#include "species_change_organs.dm"
#include "species_config_sanity.dm"
#include "species_unique_id.dm"
#include "species_whitelists.dm"
#include "spell_invocations.dm"
#include "spell_mindswap.dm"
#include "spell_names.dm"
#include "spell_shapeshift.dm"
#include "spritesheets.dm"
#include "stack_singular_name.dm"
#include "stomach.dm"
#include "strippable.dm"
#include "subsystem_init.dm"
#include "suit_storage_icons.dm"
#include "surgeries.dm"
#include "teleporters.dm"
#include "tgui_create_message.dm"
#include "timer_sanity.dm"
#include "traitor.dm"
#include "unit_test.dm"
#include "verify_config_tags.dm"
#include "wizard_loadout.dm"
#ifdef REFERENCE_TRACKING_DEBUG //Don't try and parse this file if ref tracking isn't turned on. IE: don't parse ref tracking please mr linter
#include "find_reference_sanity.dm"
#endif

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#undef TEST_ASSERT_NOTEQUAL
//#undef TEST_FOCUS - This define is used by vscode unit test extension to pick specific unit tests to run and appended later so needs to be used out of scope here
#endif
