#!/bin/sh
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

#
# Guacamole configuration file generator
#

# Create Guacamole configuration directory
GUACAMOLE_HOME="$HOME/.guacamole"
mkdir -p "$GUACAMOLE_HOME"

# Create initial guacamole.properties file
GUACAMOLE_PROPERTIES="$GUACAMOLE_HOME/guacamole.properties"
echo "# guacamole.properties - generated `date`" > "$GUACAMOLE_PROPERTIES"

# Create Guacamole lib directory
GUACAMOLE_LIB="$GUACAMOLE_HOME/lib"
mkdir -p "$GUACAMOLE_LIB"
echo "lib-directory: $GUACAMOLE_LIB" >> "$GUACAMOLE_PROPERTIES"

# Set auth provider
echo "auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider" >> "$GUACAMOLE_PROPERTIES"

# Start Tomcat
cd /usr/local/tomcat
exec catalina.sh run

