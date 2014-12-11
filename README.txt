
This is a quick script to automate installing Saratoga templates
on top of weewx v3, weewx-wd, and your favorite webserver.

It does the following:
 - grabs the upstream Saratoga zip files for the USA
 - grabs my github repo that adds a new WE-plugin to Saratoga
 - grabs my github repo that patches Saratoga to add weewx support
 - puts it all together

This is 'not' bulletproof code, nor is it intended to be.

The use case here is rapidly cycling through a install/test/nuke
cycle for doing a bare metal weewx-wd installation over Saratoga.

There are a couple features that hopefully help:
 - will 'git pull' the repos if you have previously cloned them
 - will not wget the zip files if you have previously gotten them

There are also non-features:
 - I don't try to support running this multiple times.  If you need
    to do so, just remove your destination tree first.

Lastly, I chose to 'not' fix up the permissions on the saratoga
web root, but on Debian with nginx you want everything therein
owned as www-data:www-data so Saratoga can write to the cache/
as well as (unfortunately) some files in the saratoga directory.


  vinceskahan@gmail.com - 2014-1210
