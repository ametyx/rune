package utils_tests

import "core:testing"

import "../mocks"
import "../../src/utils"


@(test)
should_read_root_file_correctly :: proc(t: ^testing.T) {
    sys := utils.System {
        exists = mocks.mock_exists_true,
        read_entire_file_from_path = mocks.mock_read_entire_file_from_path_ok
    }

    s, err := utils.read_root_file(sys)
    defer delete(s.configs.output)
    defer delete(s.configs.target)
    defer delete(s.configs.target_type)
    testing.expect_value(t, err, "")
}

@(test)
should_fail_if_file_exists :: proc(t: ^testing.T) {
    sys := utils.System {
        exists = mocks.mock_exists_false,
        read_entire_file_from_path = mocks.mock_read_entire_file_from_path_ok
    }

    _, err := utils.read_root_file(sys)
    defer delete(err)
    testing.expect_value(t, err, "Rune.json doesn't exists")
}

@(test)
should_fail_if_reading_file_fails :: proc(t: ^testing.T) {
    sys := utils.System {
        exists = mocks.mock_exists_true,
        read_entire_file_from_path = mocks.mock_read_entire_file_from_path_err
    }

    _, err := utils.read_root_file(sys)
    defer delete(err)
    testing.expect_value(t, err, "Failed to read rune.json")
}

@(test)
should_fail_if_empty_output :: proc(t: ^testing.T) {
    sys := utils.System {
        exists = mocks.mock_exists_true,
        read_entire_file_from_path = mocks.mock_read_entire_file_from_path_no_output
    }

    s, err := utils.read_root_file(sys)
    defer delete(s.configs.target)
    defer delete(s.configs.target_type)
    defer delete(err)
    testing.expect_value(t, err, "Invalid schema output")
}

@(test)
should_fail_if_empty_target :: proc(t: ^testing.T) {
    sys := utils.System {
        exists = mocks.mock_exists_true,
        read_entire_file_from_path = mocks.mock_read_entire_file_from_path_no_target
    }

    s, err := utils.read_root_file(sys)
    defer delete(s.configs.output)
    defer delete(s.configs.target_type)
    defer delete(err)
    testing.expect_value(t, err, "Invalid schema target")
}

@(test)
should_fail_if_empty_target_type :: proc(t: ^testing.T) {
    sys := utils.System {
        exists = mocks.mock_exists_true,
        read_entire_file_from_path = mocks.mock_read_entire_file_from_path_no_target_type
    }

    s, err := utils.read_root_file(sys)
    defer delete(s.configs.output)
    defer delete(s.configs.target)
    defer delete(err)
    testing.expect_value(t, err, "Invalid schema target type")
}

@(test)
should_write_root_file :: proc(t: ^testing.T) {
    sys := utils.System {
        exists = mocks.mock_exists_false,
        write_entire_file = mocks.mock_write_entire_file_ok
    }

    schema := utils.SchemaJon {}

    res := utils.write_root_file(sys, schema)
    testing.expect_value(t, res, "")
}

@(test)
should_fail_to_write_if_file_exists :: proc(t: ^testing.T) {
    sys := utils.System {
        exists = mocks.mock_exists_true,
        write_entire_file = mocks.mock_write_entire_file_ok
    }

    schema := utils.SchemaJon {}

    res := utils.write_root_file(sys, schema)
    defer delete(res)
    testing.expect_value(t, res, "File rune.json already exists")
}

@(test)
should_fail_if_fails_to_write_file :: proc(t: ^testing.T) {
    sys := utils.System {
        exists = mocks.mock_exists_false,
        write_entire_file = mocks.mock_write_entire_file_err
    }

    schema := utils.SchemaJon {}

    res := utils.write_root_file(sys, schema)
    defer delete(res)
    testing.expect_value(t, res, "Failed to write schema to rune.json: Exist")
}