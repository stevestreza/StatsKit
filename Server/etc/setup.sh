#! /bin/bash
#  Must be run as root!

# - Random Password Generator (source: http://legroom.net/2010/05/06/bash-random-password-generator)
#   Generate a random password and stores it in
#   $1 = number of characters; defaults to 32
function createPostgreSQLPassword() {
    POSTGRES_PASSWORD=`cat /dev/urandom | LC_CTYPE=C tr -cd "[:alnum:]" | head -c ${1:-32}`
}

# - Execution Script

# Redirect output to this log file, comment out if you don't want log files
exec &> /root/stackscript.log

# pre-flight, generates a password for Postgres
createPostgreSQLPassword 16;

# update the system, this is needed for certain Ubuntus which won't load build-essential on Linode
apt-get upgrade;
apt-get update;

# Install compilers and some other utilities
apt-get install --assume-yes build-essential;
apt-get install --assume-yes curl;
apt-get install --assume-yes libssl-dev;

# Add repo manager
apt-get install --assume-yes python-software-properties;

# Add Postgres 9 repo
add-apt-repository ppa:pitti/postgresql;
apt-get update

# Install Postgres 9
apt-get install --assume-yes postgresql-9.0 libpq-dev;

# Install Redis
apt-get install --assume-yes redis-server;

# Install Git
apt-get install --assume-yes git-core;

# Add the analytics user
yes "" | adduser --home /home/analytics --shell /bin/bash --disabled-login analytics > /dev/null

# Begin setting up packages
mkdir -p ~analytics/packages
pushd ~analytics/packages

# Install node.js
git clone https://github.com/joyent/node.git node;
pushd node;
git fetch origin;
git checkout v0.4.10;
./configure --prefix=/usr;
make;
make install;
popd;

# Install npm
curl http://npmjs.org/install.sh | sh;

# Install server
git clone https://github.com/amazingsyco/StatsKit.git;
pushd StatsKit/Server;
npm install;
su postgres -s /usr/bin/perl -- /usr/bin/psql -f etc/load.sql
popd;

# Create the load.sql file
pushd config;
POSTGRES_PASSWORD_REGEX="s/\-\-\-PASSWORD\-\-\-/$POSTGRES_PASSWORD/g"
cp config.js.example config.js;
sed -i ".orig" $POSTGRES_PASSWORD_REGEX config.js;
rm config.js.orig;
popd;

pushd etc;
sed -i ".orig" $POSTGRES_PASSWORD_REGEX load.sql;
rm load.sql.orig;
popd;

# Finish setting up packages
chown -R analytics:analytics .;
popd;

# Cleanup
echo; echo; echo "---"; echo;
echo "    StatsKit server setup complete."; echo;
echo "  - PostgreSQL Username: analytics";
echo "  - PostgreSQL Password:" $POSTGRES_PASSWORD;
echo; echo "---";
