# File-Sorter

A small command-line tool written in Rust that organizes the files in a directory into subfolders based on their file extension. You choose the folder name for each extension interactively when you run it.

## How it works

1. Point it at a directory.
2. It scans the top level of that directory (not recursively) and finds every unique file extension present.
3. For each extension it finds, it asks you what you want the destination folder to be called.
4. It creates those folders (if they don't already exist) and moves each file into the folder matching its extension.

Files without an extension are left untouched. Subdirectories are listed but not descended into or moved.

## Installation

### Quick install (Linux/macOS)

```bash
curl -fsSL https://raw.githubusercontent.com/Flightyx/File-Sorter/main/install.sh | sh
```

This detects your OS and architecture, downloads the matching prebuilt binary from the [latest release](https://github.com/Flightyx/File-Sorter/releases/latest), and installs it to `~/.local/bin`. If that directory isn't already on your `PATH`, the script will tell you what to add to your shell profile.

### Windows

Download the `.exe` for your system from the [latest release](https://github.com/Flightyx/File-Sorter/releases/latest) page and run it directly — no installer needed.

### Build from source

If you'd rather build it yourself:

#### Requirements

- [Rust](https://www.rust-lang.org/tools/install) and Cargo (edition 2024 toolchain or newer)

## Building

```bash
git clone https://github.com/Flightyx/File-Sorter.git
cd File-Sorter
cargo build --release
```

The compiled binary will be at `target/release/file_sort`.

## Usage

```bash
file_sort <path>
```

> **Important:** the path you pass in must end with a trailing slash (`/`). This is a known limitation — see [Known issues](#known-issues).

**Example:**

```bash
file_sort /home/user/Downloads/
```

The program will:
1. List every file it finds and print the extensions it detects (debug output).
2. Prompt you once per unique extension:
   ```
   What should the folder with all files with the extension 'pdf' be called?:
   ```
3. Move each file into `<path><your_folder_name>/<file_name>`.

## Example session

```
$ file_sort /home/user/Downloads/
[DEBUG] Successfully registered working_directory /home/user/Downloads/
...

What should the folder with all files with the extension 'pdf' be called?:
Documents
What should the folder with all files with the extension 'png' be called?:
Images

Finished cleanup!
```

Result:
```
Downloads/
├── Documents/
│   └── invoice.pdf
└── Images/
    └── screenshot.png
```

## Known issues

The project is early-stage; these are known, unresolved limitations:

- The path argument must end in `/`, or file discovery/moving will fail.
- If a file with the same name already exists in the destination folder, behavior is undefined — there's no overwrite/rename/skip prompt yet.
- Folder names for each extension must be typed in fresh every run; there's no way to save or reuse a naming scheme.
- There's no `--help` flag or usage output yet.

## Roadmap

Planned improvements (from the source comments):
- [ ] Fix the trailing-slash requirement for the input path
- [ ] Let users decide how to handle filename collisions (overwrite, auto-suffix, or skip)
- [ ] Add a proper `--help` page

## Releasing new versions (maintainers)

Pushing a version tag triggers the [release workflow](.github/workflows/release.yml), which builds binaries for Linux, macOS, and Windows and publishes them as a GitHub Release:

```bash
git tag v0.1.0
git push origin main --tags
```

## License

[MIT](LICENSE) © Flightyx
