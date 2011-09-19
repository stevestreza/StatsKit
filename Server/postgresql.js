var pg = require('pg');
var config = require("./config/config").config;

var getDatabaseURL = function(){
	var username = config.postgresql.username;
	var password = config.postgresql.password;
	var host     = config.postgresql.host;
	var port     = config.postgresql.port;
	var database = config.postgresql.databaseName;
	var authString = (username && password) ? ("" + username + ":" + password + "@") : "";
	return "tcp://" + authString + host + (port ? (":" + port) : "" + "/" + database;
}

exports.postgresConnection = function(cb){
	if(!(config.postgresql.host && config.postgresql.port)){
		cb(null);
		return;
	}

	pg.connect(getDatabaseURL(), function(err, db){
		cb(db);
	});
};