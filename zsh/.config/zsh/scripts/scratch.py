import os
import sys
import subprocess
from pathlib import Path

scratch_dir = Path.home() / "scratch"

def ensure_scratch_file():
    scratch_file = scratch_dir / "scratch.md"
    scratch_dir.mkdir(parents=True, exist_ok=True)
    if not scratch_file.exists():
        scratch_file.touch()
    return scratch_dir, scratch_file

def open_nvim_scratch():
    scratch_dir, scratch_file = ensure_scratch_file()
    # Launch Neovim in the scratch directory, opening only scratch.txt
    subprocess.run([
        "nvim",
        str(scratch_file)
    ], cwd=str(scratch_dir))

def clear_scratch():
    scratch_dir = Path.home() / "scratch"
    if not scratch_dir.exists():
        print("Scratch directory does not exist.")
        return
    for item in scratch_dir.iterdir():
        if item.is_file() or item.is_dir():
            subprocess.run(["trash", str(item)])
    print("Scratch directory cleared.")

def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--clear":
        clear_scratch()
    else:
        open_nvim_scratch()

if __name__ == "__main__":
    main()

