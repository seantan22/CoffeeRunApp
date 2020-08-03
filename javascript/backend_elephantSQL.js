const pg = require('pg');
const cred = require('./cred');
const crypto = require('crypto');

const table = 'messaging_board';

// Using ElephantSQL <- DaaS that uses SQL.

var credentials = cred.getSQLUrl();

async function createHash(sender, receiver){
    
    var joined = "";
    var saltRounds = 5;
    var db_limit = 100;
    
    // Alphabetical order for consistent ids
    if (sender < receiver){
        // Sender is first in the alphabet
        joined = sender + receiver;
    } else {
        joined = receiver + sender;
    }

    return crypto.createHash('md5').update(joined).digest('hex');
}

module.exports = {
    sendMessage: async function(message, sender, receiver){
        var client = new pg.Client(credentials);
        var db_connection = await client.connect();

        var hash = await createHash(sender, receiver);
        var current_date = JSON.stringify(new Date());

        // TimeStamp works with NOW() function
        var query = "insert into " + table + " VALUES ('" + hash + "',NOW(),'" + sender + "', '" + receiver + "', '" + message + "');"

        var response = await client.query(query).catch((error) => console.log(error));
        client.end();
        
        return JSON.stringify({result: true, errorMessage: "Successfully sent."});
    },
    getMessage: async function(sender, receiver){
        var client = new pg.Client(credentials);
        var db_connection = await client.connect();

        // Get id to search for messages between 2 users.
        var hash = await createHash(sender, receiver);

        // Query
        var query = "select date, sender, receiver , message from " + table + " where id = '" + hash + "' order by date DESC limit 20"
        var response = await client.query(query).catch((error) => console.log(error));      
        client.end();

        return JSON.stringify({result: true, response: response.rows});
    },
    deleteMessages: async function(sender, receiver){

        var client = new pg.Client(credentials);
        var db_connection = await client.connect();

        var hash = await createHash(sender, receiver);
        var query = "delete from " + table + " where id = '" + hash + "'"; 
        
        var response = await client.query(query).catch((error) => console.log(error));      
        client.end();

        return JSON.stringify({result: true, response: 'Successfully deleted all messages.'});        
    }
};