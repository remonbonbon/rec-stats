#!/usr/bin/python
# coding: utf-8
import commands
import re
import datetime
import os.path

now = datetime.datetime.today()
timestamp = now.strftime("%Y-%m-%d %H:%M:%S")

# recording state
recording_size = os.path.getsize("../chinachu/data/recording.json")
recording_state = "standby"
if 2 < recording_size:
	# when not recording, this file is "[]"
	recording_state = "recording"

# HDD state
hdparm = commands.getoutput("sudo hdparm -C /dev/sdb")
hdd_state = re.search(r"drive state is\:[ ]+(.+)", hdparm).group(1).strip()

# CPU temperature
sensors = commands.getoutput("sudo sensors")
cpu_temp = re.search(r"CPUTIN\:[ ]+\+([0-9.]+)", sensors).group(1).strip()

# Drive temperature
hddtemp = commands.getoutput("sudo hddtemp /dev/sdb")
hdd_temp_groups = re.search(r"\: ([0-9.]+)", hddtemp)
if hdd_temp_groups:
	hdd_temp = hdd_temp_groups.group(1).strip()
else:
	hdd_temp = ""

# USBRH
usb_temp = ""
usb_humi = ""
# usbrh = commands.getoutput("sudo usbrh")
# match = re.search(r"([0-9\-.]+) ([0-9\-.]+)", usbrh)
# if match:
#   usb_temp = match.group(1).strip()
#   usb_humi = match.group(2).strip()

print timestamp + "," + recording_state + "," + hdd_state + "," + cpu_temp + "," + hdd_temp + "," + usb_temp + "," + usb_humi
