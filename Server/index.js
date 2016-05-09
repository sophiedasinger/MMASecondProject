/* BearKare server
 * 
 */

var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var Pusher = require('pusher');

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true })); 

var mongoUri = process.env.MONGODB_URI || process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost/mmda';
var MongoClient = require('mongodb').MongoClient, format = require('util').format;
var db = MongoClient.connect(mongoUri, function(error, databaseConnection) {
	db = databaseConnection;
});


app.get('/', function (req, res) {
  db.collection('sensorData').find().toArray(function (err, result) {
  	res.send(result);
  });
});

app.post('/sendData', function (req, res) {
  	var side = req.body.side;
  	if (!side) {
  		res.send(502);
  	} else {
  		var toInsert = {
	    	'timestamp': Date.now(),
	    	'side': side
	    };
	  	db.collection('sensorData', function(error, coll) {
			var id = coll.insert(toInsert, function(error, saved) {
				if (error) {
					res.send(500);
				}
				else {
					var pusher = new Pusher({
					  appId: 'INSERT_ID',
					  key: 'INSERT_KEY',
					  secret: 'INSERT_SECRET',
					});
					pusher.trigger('test_channel', 'my_event', {
					  "side": side
					});
					res.send(200);
				}
		    });
		});
  	}
});

app.listen(process.env.PORT || 3000);