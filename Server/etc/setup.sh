#! /bin/bash
#  Must be run as root!

# Add repo manager
apt-get install python-software-properties;

# Add Postgres 9 repo
add-apt-repository ppa:pitti/postgresql;
apt-get update

# Install Postgres 9
apt-get install postgresql-9.0 libpq-dev;

# Install Redis
apt-get install redis-server;

# Add the analytics user
yes "" | adduser --home /home/analytics --shell /bin/bash --disabled-login analytics > /dev/null

mkdir -p ~analytics/packages
pushd ~analytics/packages

# Install node.js
git clone https://github.com/joyent/node.git node;
pushd node;
./configure --prefix=/usr;
make;
make install;
popd;

# Install server
