var util = require('util');
var redis = require('./redis');
var postgres = require('./postgres');

var eventWriter = exports;

var noOp = function(){};
var sanitizeUserInput = function(input){
	if(!input || input.length === 0){
		return null;
	}
	
	if(typeof input == "string"){
		input = "'" + input + "'";
	}
	return input;
}

var sqlStatementForEvent = function(event){
	var timestamp = sanitizeUserInput(event.timestamp);
	var platformOS = sanitizeUserInput(event.platformOS);
	var platformOSVersion = sanitizeUserInput(event.platformOSVersion);
	var deviceID = sanitizeUserInput(event.deviceID);
	var eventName = sanitizeUserInput(event.eventName);
	var eventTarget = sanitizeUserInput(event.eventTarget);
	var duration = sanitizeUserInput(event.duration);
//	var metdata = sanitizeUserInput(event.metadata);
	
	console.log("Event at " + timestamp + " " + event.timestamp);
	
	var keys = [];
	var values = [];

	if(timestamp){ 
		keys.push('timestamp');
		values.push("" + (timestamp/1000) + "::integer::abstime::timestamp");
	}

	if(platformOS){ 
		keys.push('platform_os');
		values.push(platformOS);
	}

	if(platformOSVersion){ 
		keys.push('platform_os_version');
		values.push(platformOSVersion);
	}

	if(deviceID){ 
		keys.push('device_id');
		values.push(deviceID);
	}

	if(eventName){ 
		keys.push('event_name');
		values.push(eventName);
	}

	if(eventTarget){ 
		keys.push('event_target');
		values.push(eventTarget);
	}

	if(duration || duration === 0){ 
		keys.push('duration');
		values.push(duration);
	}
	
	// TODO push metadata into hstore
	
	return "INSERT INTO events (" + keys.join(", ") + ") VALUES (" + values.join(", ") + ");";
};

exports.getDatabase = function(cb){
	postgres.postgresConnection(cb || noOp);
}

exports.writeEvent = function(event, cb){
	cb = cb || noOp;
	var eventJSON = event;
	var sql = sqlStatementForEvent(eventJSON) + "\n";

	eventWriter.getDatabase(function(err, db){
		if(err){
			cb(err);
			return;
		}
		
		db.query(sql, function(err, result){
			cb(err);
		});
	});
}

var log = function(){
	arguments[0] = "* EventWriter * " + arguments[0];
	util.puts.apply(util, Array.apply(null, arguments));
}

log("Connecting to Redis job queue...");
redis.resqueConnection(function(worker){
	log("Connected to Redis job queue.");

	worker = worker.worker("event", {
		write: function(event, cb){
			exports.writeEvent(event, function(err){
				if(err){
					err = new Error(err);
				}
				cb(err);
			});
		}
	});

	// Triggered every time the Worker polls.
	//worker.on('poll', function(worker, queue) {});

	// Triggered before a Job is attempted.
	worker.on('job', function(worker, queue, job) {
		log("Processing job " + util.inspect(job));
	});

	// Triggered every time a Job errors.
	worker.on('error', function(err, worker, queue, job) {
		log("Job had error\n\n" + util.inspect(err) + "\n\n" + util.inspect(job) + "\n");
	});

	// Triggered on every successful Job run.
	worker.on('success', function(worker, queue, job, result) {
		log("Finished processing job " + result);
	});

	worker.start();
});
