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
SARATOGA_ROOT="/home/weewx/public_html/saratoga"

# location to store sources and patches (at least temporarily)
SOURCES="/mnt/ramdisk/sources"

#############################################################
# you should probably stop editing here
#############################################################

# repos to grab from github
#   git clone https://github.com/vinceskahan/${FOO}.git
repos="vds-weewx-saratoga-plugin vds-weewx-saratoga-patches"

# upstream Saratoga zip archives to grab
zips="Base-USA.zip saratoga-icons.zip"

echo ".....setting up...."
mkdir -p "${SOURCES}"
mkdir -p "${SARATOGA_ROOT}"

echo ".....getting sources...."
cd "${SOURCES}"

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

echo "     saratoga zips"
BASE_ZIP="Base-USA.zip"
if [ ! -f "${BASE_ZIP}" ]; then
    wget http://saratoga-weather.org/wxtemplates/${BASE_ZIP}
 else
    echo "       skipping ${BASE_ZIP} - already present"
fi
ICONS_ZIP="saratoga-icons.zip"
if [ ! -f "${ICONS_ZIP}" ]; then
    wget http://saratoga-weather.org/${ICONS_ZIP}
else
    echo "       skipping ${ICONS_ZIP} - already present"
fi

echo ".....unzipping saratoga files...."
cd "${SARATOGA_ROOT}"
unzip -q ${SOURCES}/${BASE_ZIP}
unzip -q ${SOURCES}/${ICONS_ZIP}

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

