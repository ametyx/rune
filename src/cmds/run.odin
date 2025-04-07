package cmds

import "core:fmt"
import "core:strings"

import "../logger"
import "../utils"

// process_run handles the `rune run [profile | script]` command.
//
// It determines whether to run a build profile or a named script defined in `rune.json`.
// If a profile is matched, it delegates to `process_build` to compile and execute it.
// Otherwise, it attempts to run a custom script from the `scripts` map in the schema.
//
// Parameters:
// - sys:    System abstraction for shell and file operations.
// - args:   Command-line arguments passed to `rune run`.
// - schema: Parsed schema from `rune.json` containing profiles, configs, and scripts.
//
// Returns:
// - success: A message indicating a successful build or script execution.
// - err:     An error string if execution fails at any stage.
process_run :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> (success: string, err: string) {
    // If no profile is configured and no argument is passed, we can't run anything
    if schema.configs.profile == "" && len(args) < 2 {
        return "", strings.clone("Run script not found")
    }

    // If a default profile exists and no specific target was passed, run it as a build
    if schema.configs.profile != "" && len(args) < 2 {
        build_success, build_err := process_build(sys, args, schema)
        return build_success, build_err
    }

    // Try to match a passed argument to a profile by name
    profile: string
    if schema.configs.profile != "" && len(args) >= 2 {
        for p in schema.profiles {
            if p.name == args[1] {
                profile = p.name
                break
            }
        }
    }

    // If we matched a profile, build it
    if profile != "" {
        build_success, build_err := process_build(sys, args, schema)
        return build_success, build_err
    }

    // Try to match the argument to a defined script
    script: string
    for key in schema.scripts {
        if key == args[1] {
            script = schema.scripts[key]
            break
        }
    }

    // If no script matched, return an error
    if script == "" {
        return "", fmt.aprintf("Run script %s doesn't exists", args[1])
    }

    // Run the script using the utility shell processor
    script_out, script_err := utils.process_script(sys, script)
    defer delete(script_out)
    defer delete(script_err)

    // Output the result of the script (if any)
    if script_out != "" {
        logger.info(script_out)
    }

    // If the script had an error, return that
    if script_err != "" {
        return "", fmt.aprintf("Failed to execute script:\n%s", script_err)
    }

    return strings.clone("Successfully executed script"), err
}
