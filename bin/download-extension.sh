#!/bin/sh -e
#
# Copyright (C) 2015 Glyptodon LLC
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
## @fn download-extension.sh
##
## Downloads Guacamole extensions, extracts the .jar file, and saves it the 
## the specified version to the given directory.
##
## @param EXTENSION
##     The name of the extension to download, such as "guacamole-auth-noauth".
##
## @param VERSION
##     The version of guacamole.war to download, such as "0.9.6".
##
## @param DESTINATION
##     The directory to save the extension.jar to.
##

EXTENSION="$1"
VERSION="$2"
DESTINATION="$3"

#
# Create destination, if it does not yet exist
#

mkdir -p "$DESTINATION"

#
# Download extension.tar.gz, extract the .jar, and place in specified 
# destination
#

echo "Downloading Guacamole Extension $EXTENSION version $VERSION to $DESTINATION ..."
curl -L "http://downloads.sourceforge.net/project/guacamole/current/extensions/${EXTENSION}-${VERSION}.tar.gz" > "/opt/guacamole/extensions/${EXTENSION}-${VERSION}.tar.gz"

cd /opt/guacamole/extensions
tar -zxf ${EXTENSION}-${VERSION}.tar.gz
mv ${EXTENSION}-${VERSION}/${EXTENSION}-${VERSION}.jar .
rm -f ${EXTENSION}-${VERSION}.tar.gz
cd -
