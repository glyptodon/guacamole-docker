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
## @fn start.sh
##
## Automatically configures and starts Guacamole under Tomcat. Guacamole's
## guacamole.properties file will be automatically generated based on the
## linked database container (either MySQL or PostgreSQL) and the linked guacd
## container. The Tomcat process will ultimately replace the process of this
## script, running in the foreground until terminated.
##

GUACAMOLE_HOME="$HOME/.guacamole"
GUACAMOLE_LIB="$GUACAMOLE_HOME/lib"
GUACAMOLE_PROPERTIES="$GUACAMOLE_HOME/guacamole.properties"

##
## Sets the given property to the given value within guacamole.properties,
## creating guacamole.properties first if necessary.
##
## @param NAME
##     The name of the property to set.
##
## @param VALUE
##     The value to set the property to.
##
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

##
## Adds properties to guacamole.properties which select the MySQL
## authentication provider, and configure it to connect to the linked MySQL
## container.
##
associate_mysql() {

    # Verify required link is present
    if [ -z "$MYSQL_PORT_3306_TCP_ADDR" -o -z "$MYSQL_PORT_3306_TCP_PORT" ]; then
        cat <<END
FATAL: Missing "mysql" link.
-------------------------------------------------------------------------------
If using a MySQL database, you must explicitly link the container providing
that database with the link named "mysql".
END
        exit 1;
    fi

    # Verify required parameters are present
    if [ -z "$MYSQL_USER" -o -z "$MYSQL_PASSWORD" -o -z "$MYSQL_DATABASE" ]; then
        cat <<END
FATAL: Missing required environment variables
-------------------------------------------------------------------------------
If using a MySQL database, you must provide each of the following
environment variables:

    MYSQL_USER         The user to authenticate as when connecting to
                       MySQL.

    MYSQL_PASSWORD     The password to use when authenticating with MySQL as
                       MYSQL_USER.

    MYSQL_DATABASE     The name of the MySQL database to use for Guacamole
                       authentication.
END
        exit 1;
    fi

    # Update config file
    set_property "auth-provider" "net.sourceforge.guacamole.net.auth.mysql.MySQLAuthenticationProvider"
    set_property "mysql-hostname" "$MYSQL_PORT_3306_TCP_ADDR"
    set_property "mysql-port"     "$MYSQL_PORT_3306_TCP_PORT"
    set_property "mysql-database" "$MYSQL_DATABASE"
    set_property "mysql-username" "$MYSQL_USER"
    set_property "mysql-password" "$MYSQL_PASSWORD"

    # Add required .jar files to GUACAMOLE_LIB
    ln -s /opt/guacamole/mysql/*.jar "$GUACAMOLE_LIB"

}

##
## Adds properties to guacamole.properties which select the PostgreSQL
## authentication provider, and configure it to connect to the linked
## PostgreSQL container.
##
associate_postgresql() {

    # Verify required link is present
    if [ -z "$POSTGRES_PORT_5432_TCP_ADDR" -o -z "$POSTGRES_PORT_5432_TCP_PORT" ]; then
        cat <<END
FATAL: Missing "postgres" link.
-------------------------------------------------------------------------------
If using a PostgreSQL database, you must explicitly link the container
providing that database with the link named "postgres".
END
        exit 1;
    fi

    # Verify required parameters are present
    if [ -z "$POSTGRES_USER" -o -z "$POSTGRES_PASSWORD" -o -z "$POSTGRES_DATABASE" ]; then
        cat <<END
FATAL: Missing required environment variables
-------------------------------------------------------------------------------
If using a PostgreSQL database, you must provide each of the following
environment variables:

    POSTGRES_USER      The user to authenticate as when connecting to
                       PostgreSQL.

    POSTGRES_PASSWORD  The password to use when authenticating with PostgreSQL
                       as POSTGRES_USER.

    POSTGRES_DATABASE  The name of the PostgreSQL database to use for Guacamole
                       authentication.
END
        exit 1;
    fi

    # Update config file
    set_property "auth-provider" "org.glyptodon.guacamole.auth.postgresql.PostgreSQLAuthenticationProvider"
    set_property "postgresql-hostname" "$POSTGRES_PORT_5432_TCP_ADDR"
    set_property "postgresql-port"     "$POSTGRES_PORT_5432_TCP_PORT"
    set_property "postgresql-database" "$POSTGRES_DATABASE"
    set_property "postgresql-username" "$POSTGRES_USER"
    set_property "postgresql-password" "$POSTGRES_PASSWORD"

    # Add required .jar files to GUACAMOLE_LIB
    ln -s /opt/guacamole/postgresql/*.jar "$GUACAMOLE_LIB"

}

##
## Starts Guacamole under Tomcat, replacing the current process with the
## Tomcat process. As the current process will be replaced, this MUST be the
## last function run within the script.
##
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
# Point to associated PostgreSQL
#

# Only one database may be used
if [ -n "$MYSQL_DATABASE" -a -n "$POSTGRES_DATABASE" ]; then
    cat <<END
FATAL: Both MySQL and PostgreSQL databases specified
-------------------------------------------------------------------------------
You have specified both the MYSQL_DATABASE and POSTGRES_DATABASE environment
variables, but the Guacamole Docker container supports only one database.
Please specify only MYSQL_DATABASE or POSTGRES_DATABASE, not both.
END
    exit 1;
fi

# At least one database must be given
if [ -z "$MYSQL_DATABASE" -a -z "$POSTGRES_DATABASE" ]; then
    cat <<END
FATAL: No database specified
-------------------------------------------------------------------------------
The Guacamole Docker container needs an associated MySQL or PostgreSQL database
in order to function. Please specify either the MYSQL_DATABASE or
POSTGRES_DATABASE environment variables.
END
    exit 1;
fi

# Use MySQL if database specified
if [ -n "$MYSQL_DATABASE" ]; then
    associate_mysql
fi

# Use PostgreSQL if database specified
if [ -n "$POSTGRES_DATABASE" ]; then
    associate_postgresql
fi

#
# Finally start Guacamole (under Tomcat)
#

start_guacamole

