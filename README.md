What is Guacamole?
==================

[Guacamole](http://guac-dev.org/) is a clientless remote desktop gateway. It
supports standard protocols like VNC and RDP. We call it clientless because no
plugins or client software are required.

Thanks to HTML5, once Guacamole is installed on a server, all you need to
access your desktops is a web browser.

How to use this image
=====================

Using this image will require an existing, running Docker container with the
[guacd image](https://registry.hub.docker.com/u/glyptodon/guacd/), and another
Docker container providing either a PostgreSQL or MySQL database.
Alternatively, you can also run with authentication disabled (not recommended
in production or untrusted environments for obvious reasons).

The name of the database and all associated credentials are specified with
environment variables given when the container is created. All other
configuration information is generated from the Docker links.

Beware that you will need to initialize the database manually. Guacamole will
not automatically create its own tables, but SQL scripts are provided to do
this.

Once the Guacamole image is running, Guacamole will be accessible at
`http://[address of container]:8080/guacamole/`. The instructions below use the
`-p 8080:8080` option to expose this port at the level of the machine hosting
Docker, as well.

Deploying Guacamole with PostgreSQL authentication
--------------------------------------------------

    docker run --name some-guacamole --link some-guacd:guacd \
        --link some-postgres:postgres      \
        -e POSTGRES_DATABASE=guacamole_db  \
        -e POSTGRES_USER=guacamole_user    \
        -e POSTGRES_PASSWORD=some_password \
        -d -p 8080:8080 glyptodon/guacamole

Linking Guacamole to PostgreSQL requires three environment variables. If any of
these environment variables are omitted, you will receive an error message, and
the image will stop:

1. `POSTGRES_DATABASE` - The name of the database to use for Guacamole authentication.
2. `POSTGRES_USER` - The user that Guacamole will use to connect to PostgreSQL.
3. `POSTGRES_PASSWORD` - The password that Guacamole will provide when connecting to PostgreSQL as `POSTGRES_USER`.

### Initializing the PostgreSQL database

If your database is not already initialized with the Guacamole schema, you will
need to do so prior to using Guacamole. A convenience script for generating the
necessary SQL to do this is included in the Guacamole image.

To generate a SQL script which can be used to initialize a fresh PostgreSQL
database
[as documented in the Guacamole manual](http://guac-dev.org/doc/gug/jdbc-auth.html#jdbc-auth-postgresql):

    docker run --rm glyptodon/guacamole /opt/guacamole/bin/initdb.sh --postgres > initdb.sql

Alternatively, you can use the SQL scripts included with
[guacamole-auth-jdbc](http://sourceforge.net/projects/guacamole/files/current/extensions/guacamole-auth-jdbc-0.9.6.tar.gz/download).

Once this script is generated, you must:

1. Create a database for Guacamole within PostgreSQL, such as `guacamole_db`.
2. Run the script on the newly-created database.
3. Create a user for Guacamole within PostgreSQL with access to the tables and
   sequences of this database, such as `guacamole_user`.

The process for doing this via the `psql` and `createdb` utilities included
with PostgreSQL is documented in
[the Guacamole manual](http://guac-dev.org/doc/gug/jdbc-auth.html#jdbc-auth-postgresql).

Deploying Guacamole with MySQL authentication
---------------------------------------------

    docker run --name some-guacamole --link some-guacd:guacd \
        --link some-mysql:mysql         \
        -e MYSQL_DATABASE=guacamole_db  \
        -e MYSQL_USER=guacamole_user    \
        -e MYSQL_PASSWORD=some_password \
        -d -p 8080:8080 glyptodon/guacamole

Linking Guacamole to MySQL requires three environment variables. If any of
these environment variables are omitted, you will receive an error message, and
the image will stop:

1. `MYSQL_DATABASE` - The name of the database to use for Guacamole authentication.
2. `MYSQL_USER` - The user that Guacamole will use to connect to MySQL.
3. `MYSQL_PASSWORD` - The password that Guacamole will provide when connecting to MySQL as `MYSQL_USER`.

### Initializing the MySQL database

If your database is not already initialized with the Guacamole schema, you will
need to do so prior to using Guacamole. A convenience script for generating the
necessary SQL to do this is included in the Guacamole image.

To generate a SQL script which can be used to initialize a fresh MySQL database
[as documented in the Guacamole manual](http://guac-dev.org/doc/gug/jdbc-auth.html#jdbc-auth-mysql):

    docker run --rm glyptodon/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql

Alternatively, you can use the SQL scripts included with
[guacamole-auth-jdbc](http://sourceforge.net/projects/guacamole/files/current/extensions/guacamole-auth-jdbc-0.9.6.tar.gz/download).

Once this script is generated, you must:

1. Create a database for Guacamole within MySQL, such as `guacamole_db`.
2. Create a user for Guacamole within MySQL with access to this database, such
   as `guacamole_user`.
3. Run the script on the newly-created database.

The process for doing this via the `mysql` utility included with MySQL is
documented in
[the Guacamole manual](http://guac-dev.org/doc/gug/jdbc-auth.html#jdbc-auth-mysql).

Deploying Guacamole with Authentication Disabled
-------------------------------------------------

    docker run --name some-guacamole --link some-guacd:guacd \
        -e NOAUTH=1 \
        -v /path/to/noauth-config.xml:/etc/guacamole/noauth-config.xml \
        -d -p 8080:8080 glyptodon/guacamole

Guacamole will look for configurations in the file specified by the
`NOAUTH_CONFIG` environment variable.  If the `NOAUTH_CONFIG` environment
variable is not passed into the container, Guacamole will default to
`/etc/guacamole/noauth-config.xml` (inside the container).  Therefore,
the configuration file must be passed as a volume in order to define the
connections.

An example configuration for the NoAuth extension looks like:

    <configs>
        <!-- node1 connections -->
        <config name="node1-ssh" protocol="ssh">
            <param name="hostname" value="192.168.0.101" />
            <param name="username" value="root" />
            <param name="password" value="OOBER_SECURE_PASSWORD" />
        </config>
        <config name="node1-vnc" protocol="vnc">
            <param name="hostname" value="192.168.0.101" />
            <param name="port">5901</param>
            <param name="username" value="root" />
            <param name="password" value="OOBER_SECURE_PASSWORD" />
        </config>

        <!-- node2 connections -->
        <config name="node2-rdp" protocol="rdp">
            <param name="hostname" value="192.168.0.102" />
            <param name="port" value="3389" />
            <param name="username" value="Administrator" />
            <param name="password" value="OOBER_SECURE_PASSWORD" />
        </config>
    </configs>


More information regarding disabling authentication via the NoAuth extension
can be found in [the Guacamole manual](http://guac-dev.org/doc/gug/noauth.html).


Reporting issues
================

Please report any bugs encountered by opening a new issue in
[our JIRA](http://glyptodon.org/jira/).

