#!/usr/bin/env python3
# Follow https://superuser.com/q/484678 to avoid a Permission denied error.

import sys
import subprocess

BR_MIN = 1
BR_MAX_FILE = "/sys/class/backlight/intel_backlight/max_brightness"
BR_CUR_FILE = "/sys/class/backlight/intel_backlight/brightness"


def read_br(filename: str) -> int:
    with open(filename, 'r') as f:
        return int(f.read())


def write_br(filename: str, br: int) -> None:
    with open(filename, 'w') as f:
        f.write(str(br))


def usage() -> None:
    print(f"{sys.argv[0]} REL_BRIGHTNESS\n"
          "REL_BRIGTNESS: relative increment/decrement between -1 and 1")


def modify_brightness(step: float) -> None:
    # The new brightness is between the minimum and maximum values.
    cur_br = read_br(BR_CUR_FILE)
    max_br = read_br(BR_MAX_FILE)
    new_br = int(min(max(cur_br + step * max_br, BR_MIN), max_br))

    # Applying the new brightness
    write_br(BR_CUR_FILE, new_br)

    # Notifying the user
    perc_br = int((new_br / max_br) * 100)
    subprocess.run(["notify-send", "Brightness",
                    f"Set to {perc_br}% ({new_br})",
                    "-t", "750"])


if len(sys.argv) == 2:
    modify_brightness(float(sys.argv[1]))
else:
    usage()
