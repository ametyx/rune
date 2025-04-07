package utils

import "core:encoding/json"
import "core:fmt"
import "core:strings"

import "../logger"

// Reads the `rune.json` configuration file from the root directory.
//
// This function checks if the `rune.json` file exists and can be read. If the file exists, 
// it attempts to deserialize the file's content into a `Schema` object. If there are errors 
// during reading or deserialization, it returns `false` indicating failure.
//
// Parameters:
// - sys: The system interface to handle file operations.
//
// Returns:
// - `Schema`: The deserialized schema from the `rune.json` file if the file exists and is read successfully.
// - `bool`: A boolean indicating whether the file was successfully read (`true`) or not (`false`).
read_root_file :: proc(sys: System) -> (Schema, bool) {
    rune_file := "./rune.json"

    // Check if the file exists
    if !sys.exists(rune_file) {
        return {}, false
    }

    // Attempt to read the file's content
    data, err := sys.read_entire_file_from_path(rune_file, context.allocator)
    defer delete(data)
    if err != nil {
        logger.error("Failed to read rune.json") // Log an error if the file cannot be read
        return {}, false
    }

    // Unmarshal the JSON data into the schema
    schema: Schema
    json.unmarshal(data, &schema)

    return schema, true // Return the deserialized schema and success status
}

// Writes the given schema to the `rune.json` file.
//
// This function creates a new `rune.json` file in the root directory. If the file already exists,
// it returns a message indicating the file already exists. The schema is serialized to JSON format,
// and if any error occurs during the serialization or writing process, an error message is returned.
//
// Parameters:
// - sys:    The system interface to handle file operations.
// - schema: The schema to serialize and write to the `rune.json` file.
//
// Returns:
// - A string message indicating success or the error encountered during the operation.
write_root_file :: proc(sys: System, schema: SchemaJon) -> string {
    path := "./rune.json"
    
    // Check if the file already exists
    if sys.exists(path) {
        return strings.clone("File rune.json already exists") // Return an error message if the file exists
    }

    // Marshal the schema to JSON format
    json_data, err := json.marshal(schema, { pretty = true, use_enum_names = true })
    defer delete(json_data)
    if err != nil {
        return fmt.aprintf("Failed to create rune.json:\n%s", err) // Return an error message if serialization fails
    }

    // Write the JSON data to the file
    werr := sys.write_entire_file(path, json_data)
    if werr != nil {
        return fmt.aprintf("Failed to write schema to rune.json: %s", werr) // Return an error message if writing fails
    }

    return "" // Return an empty string indicating success
}
