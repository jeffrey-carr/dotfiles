#!/usr/bin/env python3
"""Render a btop-style Braille rolling CPU & GPU graph for the tmux status bar."""

import ctypes
import json
import os
import re
import subprocess
import time

STATE_PATH = f"/tmp/tmux-sysstat-{os.getuid()}.json"
HISTORY_LEN = 10  # 10 samples -> 5 Braille characters (2 samples per char)
MIN_SAMPLE_INTERVAL = 0.8  # seconds; avoids advancing history on duplicate tmux redraws

# Braille dot bitmasks for a 2x4 grid (bottom-up, levels 1..4)
# Left column uses dots 7, 3, 2, 1; right column uses dots 8, 6, 5, 4.
LEFT_DOTS = (0x00, 0x40, 0x44, 0x46, 0x47)
RIGHT_DOTS = (0x00, 0x80, 0xA0, 0xB0, 0xB8)

HOST_CPU_LOAD_INFO = 3
HOST_CPU_LOAD_INFO_COUNT = 4


class _HostCpuLoadInfo(ctypes.Structure):
    _fields_ = [("cpu_ticks", ctypes.c_uint32 * 4)]


def get_cpu_ticks():
    try:
        libc = ctypes.CDLL("/usr/lib/libSystem.B.dylib")
        info = _HostCpuLoadInfo()
        count = ctypes.c_uint32(HOST_CPU_LOAD_INFO_COUNT)
        host = libc.mach_host_self()
        if libc.host_statistics(
            host, HOST_CPU_LOAD_INFO, ctypes.byref(info), ctypes.byref(count)
        ) == 0:
            return list(info.cpu_ticks)
    except Exception:
        pass
    return None


def get_gpu_utilization():
    try:
        out = subprocess.check_output(
            ["/usr/sbin/ioreg", "-r", "-d", "1", "-w", "0", "-c", "IOAccelerator"],
             stderr=subprocess.DEVNULL,
            text=True,
            timeout=0.5,
        )
        # Match Device Utilization % (or Renderer/Tiler fallback)
        m = re.search(r'"Device Utilization %"\s*=\s*(\d+)', out)
        if m:
            return max(0, min(100, int(m.group(1))))
    except Exception:
        pass
    return 0


def pct_to_level(pct):
    if pct >= 55:
        return 4
    if pct >= 25:
        return 3
    if pct >= 8:
        return 2
    return 1


def render_braille_graph(samples, length=HISTORY_LEN):
    padded = ([0] * max(0, length - len(samples)) + list(samples))[-length:]
    chars = []
    for i in range(0, length, 2):
        left = pct_to_level(padded[i])
        right = pct_to_level(padded[i + 1])
        chars.append(chr(0x2800 | LEFT_DOTS[left] | RIGHT_DOTS[right]))
    return "".join(chars)


def load_state():
    try:
        with open(STATE_PATH, "r") as f:
            return json.load(f)
    except Exception:
        return {}


def save_state(state):
    tmp_path = f"{STATE_PATH}.tmp"
    try:
        with open(tmp_path, "w") as f:
            json.dump(state, f)
        os.replace(tmp_path, STATE_PATH)
    except Exception:
        pass


def main():
    now = time.time()
    state = load_state()

    last_ts = state.get("ts", 0.0)
    if now - last_ts < MIN_SAMPLE_INTERVAL and "rendered" in state:
        print(state["rendered"], end="")
        return

    ticks = get_cpu_ticks()
    prev_ticks = state.get("ticks")
    if ticks and prev_ticks and len(ticks) == 4 and len(prev_ticks) == 4:
        deltas = [(b - a) & 0xFFFFFFFF for a, b in zip(prev_ticks, ticks)]
        total = sum(deltas)
        # CPU_STATE_USER=0, CPU_STATE_SYSTEM=1, CPU_STATE_IDLE=2, CPU_STATE_NICE=3
        busy = deltas[0] + deltas[1] + deltas[3]
        cpu_pct = round(busy * 100.0 / total) if total > 0 else 0
    else:
        cpu_pct = 0

    cpu_pct = max(0, min(100, int(cpu_pct)))
    gpu_pct = get_gpu_utilization()

    cpu_hist = (state.get("cpu_hist", []) + [cpu_pct])[-HISTORY_LEN:]
    gpu_hist = (state.get("gpu_hist", []) + [gpu_pct])[-HISTORY_LEN:]

    cpu_graph = render_braille_graph(cpu_hist)
    gpu_graph = render_braille_graph(gpu_hist)

    rendered = f"󰻠 {cpu_graph} {cpu_pct:2d}% │ 󰢮 {gpu_graph} {gpu_pct:2d}%"

    save_state(
        {
            "ts": now,
            "ticks": ticks,
            "cpu_hist": cpu_hist,
            "gpu_hist": gpu_hist,
            "rendered": rendered,
        }
    )
    print(rendered, end="")


if __name__ == "__main__":
    main()
