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
## @fn initdb.sh
##
## Generates a database initialization SQL script for a database of the given
## type. The SQL will be sent to STDOUT.
##
## @param DATABASE
##     The database to generate the SQL script for. This may be either
##     "--postgres", for PostgreSQL, or "--mysql" for MySQL.
##

DATABASE="$1"

##
## Prints usage information for this shell script and exits with an error code.
## Calling this function will immediately terminate execution of the script.
##
incorrect_usage() {
    cat <<END
USAGE: /opt/guacamole/bin/initdb.sh [--postgres | --mysql]
END
    exit 1
}

# Validate parameters
if [ "$#" -ne 1 ]; then
    echo "Wrong number of arguments."
    incorrect_usage
fi

#
# Produce script
#

case $DATABASE in

    --postgres)
        cat /opt/guacamole/postgresql/schema/*.sql
        ;;

    --mysql)
        cat /opt/guacamole/mysql/schema/*.sql
        ;;

    *)
        echo "Bad database type: $DATABASE"
        incorrect_usage
esac

