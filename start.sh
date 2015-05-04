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

#
# start.sh: Automatically configures and starts Guacamole
#

GUACAMOLE_HOME="$HOME/.guacamole"
GUACAMOLE_LIB="$GUACAMOLE_HOME/lib"
GUACAMOLE_PROPERTIES="$GUACAMOLE_HOME/guacamole.properties"

set_property() {

    NAME="$1"
    VALUE="$2"

    # Ensure guacamole.properties exists
    if [ ! -e "$GUACAMOLE_PROPERTIES" ]; then
        mkdir -p "$GUACAMOLE_HOME"
        echo "# guacamole.properties - generated `date`" > "$GUACAMOLE_PROPERTIES"
    fi

    # Set property
    echo "$NAME: $VALUE" >> "$GUACAMOLE_PROPERTIES"

}

start_guacamole() {
    cd /usr/local/tomcat
    exec catalina.sh run
}

#
# Create and define Guacamole lib directory
#

mkdir -p "$GUACAMOLE_LIB"
set_property "lib-directory" "$GUACAMOLE_LIB"

#
# Point to associated guacd
#

# Verify required link is present
if [ -z "$GUACD_PORT_4822_TCP_ADDR" -o -z "$GUACD_PORT_4822_TCP_PORT" ]; then
    cat <<END
FATAL: Missing "guacd" link.
-------------------------------------------------------------------------------
Every Guacamole instance needs a corresponding copy of guacd running. Link a
container to the link named "guacd" to provide this.
END
    exit 1;
fi

# Update config file
set_property "guacd-hostname" "$GUACD_PORT_4822_TCP_ADDR"
set_property "guacd-port"     "$GUACD_PORT_4822_TCP_PORT"

#
# Set auth provider
#

set_property "auth-provider" "net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider"

#
# Finally start Guacamole (under Tomcat)
#

start_guacamole

