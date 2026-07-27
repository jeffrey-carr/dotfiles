#!/usr/bin/env python3
"""Pull the currently-active shades theme and push it into the running tmux server.

Mirrors the synchronous "get:" pull nvim/.config/nvim/lua/plugins/themes.lua does over
the same socket, so a brand-new tmux server doesn't have to wait for the next
`shades set <theme>` broadcast to get its pill styling.
"""

import os
import re
import socket
import subprocess
import sys

SOCKET_PATH = "/tmp/theme-change.sock"
SHADES_YAML = os.path.expanduser("~/.config/shades/shades.yaml")


def query_current_theme(sock_path, timeout=1.0):
    if not os.path.exists(sock_path):
        return None
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(timeout)
            s.connect(sock_path)
            s.sendall(b"get:\n")
            data = s.recv(4096)
    except OSError:
        return None
    text = data.decode(errors="ignore").strip()
    m = re.match(r"^set:(.+)$", text)
    return m.group(1) if m else None


def parse_tmux_client_block(lines):
    templates = {}
    in_tmux = False
    for line in lines:
        if re.match(r"^  tmux:\s*$", line):
            in_tmux = True
            continue
        if not in_tmux:
            continue
        m = re.match(r'^    ([\w-]+):\s*"(.*)"\s*$', line)
        if m:
            templates[m.group(1)] = m.group(2)
            continue
        if re.match(r"^  \S", line) or re.match(r"^\S", line):
            break
    return templates


def parse_theme_colors(lines, theme_name, variant_name):
    colors = {}
    state = "seek-themes"
    for line in lines:
        if state == "seek-themes":
            if line.rstrip("\n") == "themes:":
                state = "seek-theme"
            continue
        if state == "seek-theme":
            if re.match(rf"^  {re.escape(theme_name)}:\s*$", line):
                state = "seek-variants"
            continue
        if state == "seek-variants":
            if re.match(r"^    variants:\s*$", line):
                state = "seek-variant"
            elif re.match(r"^  \S", line) and not re.match(r"^    ", line):
                state = "seek-theme"
            continue
        if state == "seek-variant":
            if re.match(rf"^      {re.escape(variant_name)}:\s*$", line):
                state = "seek-colors"
            elif re.match(r"^    \S", line) and not re.match(r"^      ", line):
                break
            continue
        if state == "seek-colors":
            if re.match(r"^        colors:\s*$", line):
                state = "capture"
            elif re.match(r"^      \S", line) and not re.match(r"^        ", line):
                break
            continue
        if state == "capture":
            m = re.match(r'^          (\w+):\s*"(.*)"\s*$', line)
            if m:
                colors[m.group(1)] = m.group(2)
            elif not re.match(r"^          ", line):
                break
    return colors


def substitute(template, colors):
    for name, value in colors.items():
        template = template.replace("{" + name + "}", value)
    return template


def main():
    theme_full = query_current_theme(SOCKET_PATH)
    if not theme_full or ";" not in theme_full:
        return
    theme_name, variant_name = theme_full.split(";", 1)

    if not os.path.exists(SHADES_YAML):
        return
    with open(SHADES_YAML) as f:
        lines = f.readlines()

    templates = parse_tmux_client_block(lines)
    colors = parse_theme_colors(lines, theme_name, variant_name)
    if not templates or not colors:
        return

    status_bg = substitute(templates.get("status-bg", "default"), colors)
    status_fg = substitute(templates.get("status-fg", "white"), colors)

    options = {
        "status-style": f"bg={status_bg},fg={status_fg}",
    }
    for opt in ("window-status-format", "window-status-current-format", "status-left", "status-right"):
        if opt in templates:
            options[opt] = substitute(templates[opt], colors)

    for name, value in options.items():
        subprocess.run(["tmux", "set-option", "-g", name, value], check=False)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
