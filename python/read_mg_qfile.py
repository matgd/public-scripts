#!/usr/bin/env python3.12

from __future__ import annotations

import argparse
import sys
import tomllib
from pathlib import Path
from typing import TypedDict, NotRequired


CONFIG_FILE: Path = Path(".mg_qfile.toml")

SAMPLE_CONFIG = """
[mappings]
a = { cmd = "htop"}
b = { cmd = "ls -la", label = "List all files in $PWD" }
c = { cmd = "git status", label = "Show git status", wd = "~/projects/myrepo" }
"""


class MappingEntry(TypedDict):
    cmd: str
    label: NotRequired[str]
    wd: NotRequired[str]


class Config(TypedDict):
    mappings: dict[str, MappingEntry]


def load_config(path: Path) -> Config:
    if not path.exists():
        print(f"Config file not found: {path}", file=sys.stderr)
        sys.exit(1)

    with path.open("rb") as f:
        return tomllib.load(f)  # type: ignore[return-value]


def format_mapping(key: str, entry: MappingEntry) -> str:
    cmd: str = entry["cmd"]
    label: str = entry.get("label", "")
    wd: str = entry.get("wd" ,"")

    cmd_display = cmd

    if wd:
        cmd_display = f"(cd {wd} && {cmd})"

    if label:
        cmd_display = f"{cmd}  # {label}"


    return f"{key}) $ {cmd_display}"


def build_command(entry: MappingEntry, *, with_comment: bool) -> str:
    cmd: str = entry["cmd"]
    label: str = entry.get("label", "")
    wd: str = entry.get("wd", "")

    if wd:
        result = f"(cd {wd} && {cmd})"
    else:
        result = cmd

    if with_comment and label:
        result += f"  # {label}"

    return result

def generate_qfile() -> bool:
    # Check if already exists
    if CONFIG_FILE.exists():
        print(f"Config file already exists: {CONFIG_FILE}", file=sys.stderr)
        return False

    try:
        with CONFIG_FILE.open("w", encoding="utf-8") as f:
            f.write(SAMPLE_CONFIG.strip() + "\n")
        print(f"Sample config file created at: {CONFIG_FILE}")
        return True
    except Exception as e:
        print(f"Failed to create config file: {e}", file=sys.stderr)
        return False

def print_mappings(mappings: dict[str, MappingEntry]) -> bool:
    if not mappings:
        print("No mappings found", file=sys.stderr)
        return False

    for key, entry in mappings.items():
        print(format_mapping(key, entry))
    return True

def main() -> None:
    parser = argparse.ArgumentParser()
    _ = parser.add_argument("--no-comment", action="store_true", help="Omit comments in the output command")
    _ = parser.add_argument("--generate-qfile", action="store_true", help="Generate a sample mg_qfile.toml in the current directory")
    _ = parser.add_argument("--print-mappings", action="store_true", help="Print all available mappings and exit")
    _ = parser.add_argument("--choice", type=str, help="Directly specify the choice to execute")
    args = parser.parse_args()

    if args.generate_qfile:
        error_code = int(generate_qfile())
        sys.exit(error_code)

    config: Config = load_config(CONFIG_FILE)
    mappings: dict[str, MappingEntry] = config.get("mappings", {})

    if args.print_mappings:
        error_code = int(print_mappings(mappings))
        sys.exit(error_code)

    if args.choice:
        choice: str = args.choice.strip()
    else:
        choice: str = input("> ").strip()

    if choice not in mappings:
        print(f"Unknown choice: {choice}", file=sys.stderr)
        sys.exit(1)

    output: str = build_command(
        mappings[choice],
        with_comment=not args.no_comment,
    )

    print(output)


if __name__ == "__main__":
    main()

