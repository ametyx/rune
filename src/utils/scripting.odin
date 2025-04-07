package utils

import "core:fmt"
import "core:strings"
import "core:os/os2"

// Executes a script command and returns its standard output and error.
//
// Parameters:
// - sys (System): The system context that manages the process execution.
// - script (string): The script or command to execute.
//
// Returns:
// - A string containing the standard output from the script.
// - A string containing the standard error from the script.
process_script :: proc(sys: System, script: string) -> (string, string) {
    cmds := strings.split(script, " ")
    defer delete(cmds)
    _, stdout, stderr, process_err := sys.process_exec({
        command = cmds
    }, context.allocator)

    defer delete(stdout)

    if process_err != nil {
        return "", fmt.aprintf("Script %s failed with %s", script, process_err)
    }

    return strings.clone(string(stdout)), strings.clone(string(stderr))
}

// Copies a file or directory from the source location to the destination.
//
// Parameters:
// - sys: The system context that manages file and directory operations.
// - original_from: The original root path of the source.
// - from: The source path (file or directory) to copy.
// - to: The destination path where the file or directory should be copied to.
//
// Returns:
// - A string describing any error that occurred during the copy operation, or an empty string if the operation was successful.
process_copy :: proc(sys: System, original_from: string, from: string, to: string) -> string {
    if sys.is_dir(from) {
        extra := strings.trim_prefix(from, original_from)
        new_dir, _ := strings.concatenate({to, extra})
        defer delete(new_dir)

        if !sys.exists(new_dir) {
            err := sys.make_directory(new_dir)
            if err != nil {
                return fmt.aprintf("Failed to create directory %s: %s", new_dir, err)
            }
        }

        dir, err := sys.open(from)
        if err != nil {
            return fmt.aprintf("Failed to open directory %s: %s", from, err)
        }
        defer sys.close(dir)

        files: []os2.File_Info
        files, err = sys.read_dir(dir, -1, context.allocator)
        defer delete(files)
        if err != nil {
            return fmt.aprintf("Failed to read files from %s: %s", from, err)
        }

        for file in files {
            name, _ := strings.replace(file.fullpath, "\\", "/", -1)
            defer delete(name)
            copy_err := process_copy(sys, original_from, name, to)
            if copy_err != "" {
                return copy_err
            }
        }

        return ""
    }

    extra := strings.trim_prefix(from, original_from)
    real_to := strings.concatenate({to, extra})
    defer delete(real_to)
    
    copy_err := sys.copy_file(real_to, from)
    if copy_err != nil{
        return fmt.aprintf("Failed to copy: %s", copy_err)
    }

    return ""
}