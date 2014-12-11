#!/bin/bash
#
# install-weewx-wd-saratoga.sh
#
# this is a quickie script to grab the sources and patches/updates
# and install them to quickly bring up an unconfigured Saratoga
# using the default settings from the upstream author
#
# the expectation is:
# - you have weewx v3 and the weewx-wd plugin installed and running
# - you have weewx-wd writing into a WD subdirectory in weewx HTML_ROOT
# - you want saratoga similarly in a saratoga subdir in weewx HTML_ROOT
# - you have your webserver appropriately configured to run saratoga
#     note: for debian/raspbian I needed to apt-get install
#        php5-fpm, php5-gd, and php5-curl to run on top of nginx
#
# this is a quickie, so be gentle if you have feedback :-)
#
# vinceskahan@gmail.com - 20141210 - original
#

#############################################################
# configurable settings
#############################################################

# location where you want saratoga installed into
SARATOGA_ROOT="/var/www/saratoga"

# location to store sources and patches (at least temporarily)
SOURCES="/mnt/ramdisk/sources"

#############################################################
# you should probably stop editing here
#############################################################

# upstream Saratoga zip archives
BASE_ZIP="http://saratoga-weather.org/wxtemplates/Base-USA.zip"
ICONS_ZIP="http://saratoga-weather.org/saratoga-icons.zip"

# vds repos to clone from github
#   git clone https://github.com/vinceskahan/${FOO}.git
repos="vds-weewx-saratoga-plugin vds-weewx-saratoga-patches"

echo ".....setting up...."
for dir in ${SOURCES} ${SARATOGA_ROOT}
do
    # this could be 'way' smarter
    # in particular, it will try to mkdir if it's a 
    # pre-existing symlink....
    if [ ! -d "${dir}" ]; then
       echo "   making ${dir}"
       mkdir -p "${dir}"
    else
        echo "   ${dir} already present"
    fi
done

echo ".....getting sources...."
cd "${SOURCES}"

echo "     saratoga zips"
for file in ${BASE_ZIP} ${ICONS_ZIP}
do
    if [ ! -f "${file##*/}" ]; then
        wget ${file}
    else
        echo "       skipping ${file##*/} - already present"
    fi
done

echo "     github repos"
for repo in vds-weewx-saratoga-plugin vds-weewx-saratoga-patches
do
 if [ ! -d "${SOURCES}/${repo}" ]; then
      echo "   cloning repo ${repo}"
      git clone https://github.com/vinceskahan/${repo}.git
 else
      echo "   updating repo ${repo} - already present"
      (chdir "${SOURCES}/${repo}" ; git pull)
 fi
done

#------- from here down we're installing what we grabbed previously -----

echo ".....unzipping saratoga files...."
cd "${SARATOGA_ROOT}"
unzip -q ${SOURCES}/${BASE_ZIP##*/}
unzip -q ${SOURCES}/${ICONS_ZIP##*/}

echo "....copying WE plugin into place...."
cp -r "${SOURCES}"/vds-weewx-saratoga-plugin/[A-Za-z]* "${SARATOGA_ROOT}"

echo "....applying patches...."
for f in `ls -1 ${SOURCES}/vds-weewx-saratoga-patches/*.patch`
do
  echo "   ${f##*/}"
  patch -p1 < $f
done

echo "....done...."

# test all the links, they should all work
# ideally there are no error messages appearing in your webserver error log

#------ about US units and weewx-wd ------
#
# reminder, if you use US units with weewx-wd, you'll want to add overrides
# to your weewx.conf something like the following:
#
#    [[wdTesttags]]
#        HTML_ROOT = public_html/WD
#        skin = Testtags
#        [[[Units]]]
#            [[[[Groups]]]]
#                group_altitude = foot
#                group_degree_day = degree_F_day
#                group_pressure = inHg
#                group_rain = inch
#                group_rainrate = inch_per_hour
#                group_speed = mile_per_hour
#                group_speed2 = mi
#                group_temperature = degree_F
#                group_temperature2 = F
#            [[[[TimeFormats]]]]
#                date_f = %m/%d/%Y
#                date_time_f = %m/%d/%Y %H:%M
#    
#    [[wdPWS]]
#        HTML_ROOT = public_html/WD
#        skin = PWS
#        [[[Units]]]
#            [[[[Groups]]]]
#                group_altitude = foot
#                group_degree_day = degree_F_day
#                group_pressure = inHg
#                group_rain = inch
#                group_rainrate = inch_per_hour
#                group_speed = mile_per_hour
#                group_speed2 = mi
#                group_temperature = degree_F
#                group_temperature2 = F
#    
#    [[wdClientraw]]
#        HTML_ROOT = public_html/WD
#        skin = Clientraw
#        [[[Units]]]
#            [[[[Groups]]]]
#                group_altitude = foot
#                group_degree_day = degree_F_day
#                group_pressure = inHg
#                group_rain = inch
#                group_rainrate = inch_per_hour
#                group_speed = mile_per_hour
#                group_speed2 = mi
#                group_temperature = degree_F
#                group_temperature2 = F
#    
#    [[wdStackedWindRose]]
#        HTML_ROOT = public_html/WD
#        skin = StackedWindRose
#        [[[Units]]]
#            [[[[Groups]]]]
#                group_altitude = foot
#                group_degree_day = degree_F_day
#                group_pressure = inHg
#                group_rain = inch
#                group_rainrate = inch_per_hour
#                group_speed = mile_per_hour
#                group_speed2 = mi
#                group_temperature = degree_F
#                group_temperature2 = F
#            [[[[TimeFormats]]]]
#                date_f = %m/%d/%Y
#                date_time_f = %m/%d/%Y %H:%M
#    
#    [[wdSteelGauges]]
#        HTML_ROOT = public_html/WD
#        skin = SteelGauges
#        [[[Units]]]
#            [[[[Groups]]]]
#                group_altitude = foot
#                group_degree_day = degree_F_day
#                group_pressure = inHg
#                group_rain = inch
#                group_rainrate = inch_per_hour
#                group_speed = mile_per_hour
#                group_speed2 = mi
#                group_temperature = degree_F
#                group_temperature2 = F
#
#---------------------------------------------------    
