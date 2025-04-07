# Rune 🪄

**Rune** is a modular, JSON-based build system tailored for [Odin](https://odin-lang.org/) projects. It lets you define and automate complex builds cleanly and predictably.

## 🔧 Features

- 🔍 **Explicit Build Definitions** – Everything lives in a single `.rune.json` file.
- 🧱 **Multi-profile Support** – Build for multiple architectures easily.
- ⚙️ **Script Hooks** – Add pre/post build behavior with reusable named scripts.
- 📦 **Custom Output Paths & Flags** – Fine-tune builds per profile with full control.

## Usage

**❓Help**

```txt
rune - A build profile tool for the Odin programming language

Usage:
  rune command> [options]

Commands:
  new [build-mode] <target>        Create a new rune.json file with the given build mode and output target.
                                   Example: rune new debug bin/my_app

  test [profile] [-t:<test>] [-f:<file>]
                                   Run tests for the project. If no profile is specified, uses the default in rune.json.
                                   -t:<test>    Run a specific test by name.
                                   -f:<file>    Run tests from a specific file or package.
                                   Example: rune test debug -t:math_addition -f:math.odin

  run [profile | script]           Compile and run the executable for a given profile or script.
                                   If no profile is given, uses the default profile in rune.json.
                                   Example: rune run release
                                            rune run deploy_script

  build [profile]                  Compile the project using a given profile. Defaults to the one set in rune.json.
                                   Example: rune build debug

  -v, --version                    Print the version of rune.
  -h, --help                       Show this help message.

Project files:
  rune.json                        Defines profiles, default profile, and scripts for the project.

Examples:
  rune new release bin/app        Create a rune.json with a 'release' profile targeting bin/app
  rune test                       Run tests using the default profile
  rune run                        Run the executable using the default profile
```

**✨New**

Create a new rune.json file with the given build mode and output target.

```sh
# Usage
rune new [build-mode] -o:<target>

# Creates an executable called my_project
rune new exe -o:my_project

# Creates a dynamic library with the name of the parent directory
rune new dynamic
```

**🛠️Build**

Compile the project using a given profile. Defaults to the profile specified in `configs.profile`.

```sh
# Usage
rune build [profile?]

# Build the default profile
rune build

# Builds a debug profile
rune build debug

# Builds a release profile
rune build release
```

**🧪Test**

Run tests given a profile with the option of targeting a specific file or a single test. Defaults
to the profile specified in `configs.test_profile`.

```sh
# Usage
rune test [profile?] -t:<test_name> -f:<file_name>

# Run the default test profile
rune test

# Run a specific test profile
rune test my_test_profile

# Test a specific file
rune test -f:./path/to/my/file.odin

# Run a specific test
rune test -t:name_of_my_test_procedure
```

**🚀Run**

Compiles and run a project given a profile. Defaults to `configs.profile`. Can really only be used for
executable projects.

```sh
# Usage
rune run [profile?]

# Runs the default profile
rune run

# Runs a debug profile
rune run debug

# Runs a release profile
rune run release
```