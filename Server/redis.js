var resque = require('coffee-resque');
var config = require("./config/config").config;

exports.resqueConnection = function(cb){
	if(!(config.redis.host && config.redis.port)){
		cb(null);
		return;
	}
	
	var connection = resque.connect({
		host: config.redis.host,
		port: config.redis.port
	});	
	cb(connection);
};