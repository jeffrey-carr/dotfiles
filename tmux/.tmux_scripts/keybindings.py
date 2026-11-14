#!/usr/bin/env python3
"""FZF-searchable tmux keybindings viewer & launcher (Ctrl-a ?)."""

import os
import re
import subprocess
import sys

os.environ["PATH"] = f"/opt/homebrew/bin:/usr/local/bin:{os.environ.get('PATH', '')}"

FRIENDLY_NOTES = {
    ("prefix", "C-s"): "Save tmux session (tmux-resurrect)",
    ("prefix", "C-r"): "Restore tmux session (tmux-resurrect)",
    ("prefix", "Tab"): "Open Extrakto text extractor",
    ("prefix", "I"): "Install TPM plugins",
    ("prefix", "U"): "Update TPM plugins",
    ("prefix", "M-u"): "Clean/uninstall TPM plugins",
    ("root", "C-h"): "Navigate left pane / Neovim split",
    ("root", "C-j"): "Navigate down pane / Neovim split",
    ("root", "C-k"): "Navigate up pane / Neovim split",
    ("root", "C-l"): "Navigate right pane / Neovim split",
}


def run_cmd(args):
    try:
        return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL)
    except Exception:
        return ""


def get_prefix_name():
    out = run_cmd(["tmux", "show-options", "-gv", "prefix"]).strip()
    return out or "C-a"


def parse_notes(prefix_name):
    notes = {}
    out = run_cmd(["tmux", "list-keys", "-N"])
    for line in out.splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith(prefix_name + " "):
            rest = line[len(prefix_name) + 1 :].lstrip()
            parts = re.split(r"\s{2,}", rest, maxsplit=1)
            if len(parts) == 2:
                notes[("prefix", parts[0])] = parts[1]
        else:
            parts = re.split(r"\s{2,}", line, maxsplit=1)
            if len(parts) == 2:
                notes[("root", parts[0])] = parts[1]
    return notes


def parse_raw_keys():
    entries = []
    out = run_cmd(["tmux", "list-keys"])
    # Example: bind-key -r -T prefix < swap-window -d -t :-1
    pattern = re.compile(
        r"^bind-key\s+(?:(-r)\s+)?-T\s+(\S+)\s+(\S+)\s+(.+)$"
    )
    for line in out.splitlines():
        m = pattern.match(line.strip())
        if not m:
            continue
        repeatable, table, key, cmd = m.groups()
        # Clean escaped keys like \; or \'
        clean_key = key.replace("\\;", ";").replace("\\'", "'").replace('\\"', '"').replace("\\#", "#").replace("\\~", "~").replace("\\$", "$")
        entries.append((table, clean_key, bool(repeatable), cmd))
    return entries


def main():
    prefix_name = get_prefix_name()
    notes = parse_notes(prefix_name)
    raw = parse_raw_keys()

    table_order = {"prefix": 0, "root": 1, "copy-mode-vi": 2, "copy-mode": 3}
    raw.sort(key=lambda x: (table_order.get(x[0], 9), x[1]))

    lines = []
    lookup = {}
    for table, key, repeatable, cmd in raw:
        if table == "copy-mode":
            continue  # skip emacs copy-mode noise
        if key.startswith("Mouse") or key.startswith("Wheel") or key.startswith("DoubleClick") or key.startswith("TripleClick"):
            continue

        note = notes.get((table, key)) or FRIENDLY_NOTES.get((table, key)) or cmd
        if table == "prefix":
            chord = f"{prefix_name} {key}"
        elif table == "root":
            chord = key
        else:
            chord = f"[{table}] {key}"

        rep_tag = " (repeat)" if repeatable else ""
        display = f"\033[1;34m{table:<12}\033[0m  \033[1;33m{chord:<18}\033[0m  {note}{rep_tag}"
        plain_id = f"{table}::{key}"
        lines.append(f"{plain_id}\t{display}\t{cmd}")
        lookup[plain_id] = (table, key, note, cmd)

    fzf_input = "\n".join(lines)
    preview_cmd = (
        "printf '\\033[1;35mBinding:\\033[0m %s\\n\\n\\033[1;36mCommand:\\033[0m\\n%s\\n' {2} {3}"
    )

    proc = subprocess.run(
        [
            "fzf",
            "--ansi",
            "--reverse",
            "--delimiter=\t",
            "--with-nth=2",
            "--header=Search Tmux Keybindings (Enter: close | Esc: close)",
            "--prompt=󰌌 Keybinds > ",
            f"--preview={preview_cmd}",
            "--preview-window=down:30%:wrap",
        ],
        input=fzf_input,
        text=True,
        stdout=subprocess.PIPE,
    )
    sys.exit(0)


if __name__ == "__main__":
    main()
