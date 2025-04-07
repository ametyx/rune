/*
    List of predefined variables

    config:     Build mode
    arch:       Targeted architecture
    profile:    Name of the profile
*/

package utils

import "core:fmt"
import filepath "core:path/filepath"
import "core:strings"

import "../logger"

// BuildData defines the structure for holding build-related information like entry, output, flags, and architecture.
BuildData :: struct {
    entry:  string,          // Path to the entry point (e.g., source file)
    output: string,          // Output file location
    flags:  [dynamic]string, // Additional flags for the Odin command
    arch:   string           // Target architecture for the build
}

// Processes and executes the Odin build command for a given profile.
//
// This function handles pre-build, build, and post-build steps for the provided profile.
// It first executes any pre-build scripts, runs the Odin build command, and then processes
// any post-build operations such as copying files or running additional scripts.
//
// Parameters:
// - sys:       The system interface to handle file operations.
// - profile:   The build profile containing configurations such as entry point, flags, and architecture.
// - scripts:   A map of predefined scripts that can be executed during the build process.
// - output:    The output path for the build.
// - cmd:       The Odin build command to execute.
//
// Returns:
// - A string containing any error message, or an empty string if successful.
process_odin_cmd :: proc(
    sys: System,
    profile: SchemaProfile,
    scripts: map[string]string,
    output: string,
    cmd: string
) -> (string) {

    // Execute pre-build scripts if any are defined
    if len(profile.pre_build.scripts) > 0 {
        pre_build_err := execute_pre_build(sys, profile.pre_build.scripts, scripts)

        if pre_build_err != "" {
            return pre_build_err
        }
    }

    // Execute the build command
    cmd_err := execute_cmd(sys, BuildData{
        entry = profile.entry,
        output = output,
        flags = profile.flags,
        arch = profile.arch
    }, cmd)
    
    if cmd_err != "" {
        return cmd_err
    }

    // Execute post-build actions such as file copying and additional scripts
    if len(profile.post_build.copy) > 0 || len(profile.post_build.scripts) > 0 {
        post_build_err := execute_post_build(sys, profile.post_build, scripts, output)

        if post_build_err != "" {
            return post_build_err
        }
    }

    return ""
}

// Executes the Odin build command with the provided build data.
//
// This function constructs the final command by appending flags and other options based on the
// provided build data (entry point, output path, architecture, and additional flags). It then
// runs the command and handles any output or error.
//
// Parameters:
// - sys:    The system interface to handle file operations.
// - data:   The build data containing entry point, output path, flags, and architecture.
// - buildCmd: The base Odin command to execute (e.g., "build").
//
// Returns:
// - A string containing any error message, or an empty string if successful.
@(private="file")
execute_cmd :: proc(sys: System, data: BuildData, buildCmd: string) -> string {
    cmd, _ := strings.join({"odin", buildCmd}, " ")
    defer delete(cmd)

    // Append the entry point to the command if it's specified
    if data.entry != "" {
        new_cmd, _ := strings.join({cmd, data.entry}, " ")
        delete(cmd)
        cmd = new_cmd
    }

    // Append the output path to the command if it's specified
    if data.output != "" {
        out := fmt.aprintf("-out:%s", data.output)
        new_cmd, _ := strings.join({cmd, out}, " ")
        delete(out)
        delete(cmd) 
        cmd = new_cmd
    }

    // Append the architecture to the command if it's specified
    if data.arch != "" {
        out := fmt.aprintf("-target:%s", data.arch)
        new_cmd, _ := strings.join({cmd, out}, " ")
        delete(out)
        delete(cmd)
        cmd = new_cmd
    }
    
    // Append any additional flags to the command
    if len(data.flags) > 0 {
        for flag in data.flags {
            new_cmd, _ := strings.join({cmd, flag}, " ")
            delete(cmd)
            cmd = new_cmd
        }
    }

    logger.info(cmd) // Log the final command to be executed

    // Execute the command and handle any output or error
    script_out, script_err := process_script(sys, cmd)
    defer delete(script_out)

    if script_out != "" {
        logger.info(script_out)
    }

    if script_err != "" {
        return script_err
    }
    
    return ""
}

// Executes the pre-build scripts defined in the profile.
//
// This function iterates over the pre-build scripts in the provided profile and executes them.
//
// Parameters:
// - sys:          The system interface to handle file operations.
// - step_scripts: A list of pre-build scripts to be executed.
// - script_list:  A map of predefined scripts that can be executed.
//
// Returns:
// - A string containing any error message, or an empty string if successful.
@(private="file")
execute_pre_build :: proc(sys: System, step_scripts: []string, script_list: map[string]string) -> string {
    script_err := execute_scripts(sys, step_scripts, script_list)
    if script_err != "" {
        return script_err
    }

    return "" // Return an empty string on success
}

// Executes the post-build actions defined in the profile, such as file copying or running scripts.
//
// This function processes both file copy operations and post-build scripts.
//
// Parameters:
// - sys:         The system interface to handle file operations.
// - post_build:  The post-build configuration (e.g., file copy actions and scripts).
// - script_list: A map of predefined scripts that can be executed.
// - output:      Output for the process_copy command
//
// Returns:
// - A string containing any error message, or an empty string if successful.
@(private="file")
execute_post_build :: proc(sys: System, post_build: SchemaPostBuild, script_list: map[string]string, output: string) -> string {
    // Execute any file copy operations
    for copy in post_build.copy {
        output_dir := filepath.dir(output)
        defer delete(output_dir)
        output_copy_dir := filepath.join({output_dir, copy.to})
        defer delete(output_copy_dir)
        copy_err := process_copy(sys, copy.from, copy.from, output_copy_dir)
        if copy_err != "" {
            return copy_err
        }
    }

    // Execute any post-build scripts
    script_err := execute_scripts(sys, post_build.scripts, script_list)
    if script_err != "" {
        return script_err
    }

    return ""
}

// Executes a series of scripts.
//
// This function iterates over the provided scripts and executes each one in the specified order.
//
// Parameters:
// - sys:         The system interface to handle file operations.
// - step_scripts: A list of scripts to be executed.
// - script_list: A map of predefined scripts that can be executed.
//
// Returns:
// - A string containing any error message, or an empty string if successful.
@(private="file")
execute_scripts :: proc(sys: System, step_scripts: []string, script_list: map[string]string) -> string {
    for script_name in step_scripts {
        script := script_list[script_name] or_else ""
        if script == "" {
            return fmt.aprintf("Script %s is not defined in rune.json", script_name)
        }

        script_out, script_err := process_script(sys, script)
        defer delete(script_out)

        if script_out != "" {
            logger.info(script_out)
        }

        if script_err != "" {
            return script_err
        }
    }

    return ""
}
