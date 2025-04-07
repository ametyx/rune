package logger_test

import "core:fmt"
import "core:testing"

import "../../src/logger"

@(test)
should_log_info :: proc(t: ^testing.T) {
    logger.info("Hello world")
}

@(test)
should_log_info_with_pointer :: proc(t: ^testing.T) {
    msg := fmt.aprintf("Hello world")
    logger.info(msg)
    delete(msg)
}

@(test)
should_log_warn :: proc(t: ^testing.T) {
    logger.warn("Hello world")
}

@(test)
should_log_warn_with_pointer :: proc(t: ^testing.T) {
    msg := fmt.aprintf("Hello world")
    logger.warn(msg)
    delete(msg)
}

@(test)
should_log_error :: proc(t: ^testing.T) {
    logger.error("Hello world")
}

@(test)
should_log_error_with_pointer :: proc(t: ^testing.T) {
    msg := fmt.aprintf("Hello world")
    logger.error(msg)
    delete(msg)
}

@(test)
should_log_success :: proc(t: ^testing.T) {
    logger.success("Hello world")
}

@(test)
should_log_success_with_pointer :: proc(t: ^testing.T) {
    msg := fmt.aprintf("Hello world")
    logger.success(msg)
    delete(msg)
}
