var sys = require('sys');
var pg = require('pg');
var http = require('http');
var redis = require('./redis');

redis.resqueConnection(function(resque){
	http.createServer(function (request, response) {
		console.log("Request");
		var body = [];
		request.on('data', function(data){
			body.push(data);
		});
		request.on('end', function(){
			var data = JSON.parse(body.join(""));
		  	var output = [];
		    
			console.log("We got " + data.events.length + " events\n\n" + body.join("") + "\n");
	        
			for(var idx = 0; idx < data.events.length; idx++){
				var eventJSON = data.events[idx];
				resque.enqueue("event", "write", [eventJSON]);
			}

			response.writeHead(200);
			response.end();
		});
	}).listen(8080);
});
