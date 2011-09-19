#! /bin/bash
#  Must be run as root!

# Install compilers and downloaders
apt-get install --assume-yes build-essential curl;

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

# Finish setting up packages
chown -R analytics:analytics .;
popd;
