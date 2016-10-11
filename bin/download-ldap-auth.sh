#!/bin/sh -e
#
# Copyright (C) 2016 Glyptodon LLC
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

##
## @fn download-ldap-auth.sh
##
## Downloads LDAP authentication support. The LDAP authentication .jar file
## will be placed within the specified destination directory.
##
## @param VERSION
##     The version of guacamole-auth-ldap to download, such as "0.9.6".
##
## @param DESTINATION
##     The directory to save downloaded files within.
##

VERSION="$1"
DESTINATION="$2"

#
# Use ldap/ subdirectory within DESTINATION.
#

DESTINATION="$DESTINATION/ldap"

#
# Create destination, if it does not yet exist
#

mkdir -p "$DESTINATION"

#
# Download Guacamole LDAP auth
#

echo "Downloading LDAP auth version $VERSION ..."
curl -L "http://sourceforge.net/projects/guacamole/files/current/extensions/guacamole-auth-ldap-$VERSION.tar.gz" | \
tar -xz               \
    -C "$DESTINATION" \
    --wildcards       \
    --no-anchored     \
    --xform="s#.*/##" \
    "*.jar"           \
    "*.ldif"
