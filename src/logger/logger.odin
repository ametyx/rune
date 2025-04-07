package logger

import "core:fmt"

// ANSI escape codes for terminal text color formatting
@(private="file")
RESET  := "\033[0m"   // Reset the text formatting
@(private="file")
RED    := "\033[31m"  // Red color for errors
@(private="file")
GREEN  := "\033[32m"  // Green color for success messages
@(private="file")
YELLOW := "\033[33m"  // Yellow color for warnings

// Prints an error message in red to the terminal.
//
// Parameters:
// - msg: The error message to print.
error :: proc(msg: string) {
    // Format the message with red color and reset formatting after
    print_msg := fmt.aprintf("%s%s%s", RED, msg, RESET)
    fmt.println(print_msg) // Print the formatted error message
    delete(print_msg)      // Clean up the string
}

// Prints a warning message in yellow to the terminal.
//
// Parameters:
// - msg: The warning message to print.
warn :: proc(msg: string) {
    // Format the message with yellow color and reset formatting after
    print_msg := fmt.aprintf("%s%s%s", YELLOW, msg, RESET)
    fmt.println(print_msg) // Print the formatted warning message
    delete(print_msg)      // Clean up the string
}

// Prints a success message in green to the terminal.
//
// Parameters:
// - msg: The success message to print.
success :: proc(msg: string) {
    // Format the message with green color and reset formatting after
    print_msg := fmt.aprintf("%s%s%s", GREEN, msg, RESET)
    fmt.println(print_msg) // Print the formatted success message
    delete(print_msg)      // Clean up the string
}

// Prints an informational message to the terminal.
//
// Parameters:
// - msg: The informational message to print. Defaults to an empty string if not provided.
info :: proc(msg: string = "") {
    fmt.println(msg) // Print the message (no color formatting)
}
