#!/usr/bin/env python
import urllib.request

try:

    city = "Criciuma"
    api_key = "642a76e68929c32f7bdee0ed86ed30a3"

    weather = eval(str(urllib.request.urlopen(
        "http://api.openweathermap.org/data/2.5/weather?q={}&APPID={}".format(city, api_key)).read())[2:-1])

    info = weather["weather"][0]["description"].capitalize()
    temp = int(float(weather["main"]["temp"]) - 272.15)

    # print("%i°C" % (temp))

    # Green Color
    # cloud = "%{F#01DE95}%{F-}"
    # Lime Color
    # cloud = "%{F#ADFE04}%{F-}"
    # Teal Color
    # snow = "%{F#1DDAC8}%{F-}"
    # Yellow Color
    # sun = "%{F#FAED06}%{F-}"

    cloud = "%{F#13E5A8}%{F-}"
    snow = "%{F#13E5A8}%{F-}"
    sun = "%{F#13E5A8}%{F-}"

    if (temp < 15):
        print("%s   %i°C" % (snow, temp))
    elif (temp >= 15) and (temp < 25):
        print("%s   %i°C" % (cloud, temp))
    else:
        print("%s   %i°C" % (sun, temp))

except Exception:
    print("%{F#555} Unavailable Weather!%{F-}")
