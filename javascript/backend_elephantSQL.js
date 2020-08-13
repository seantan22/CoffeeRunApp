const pg = require('pg');
const cred = require('./cred');
const crypto = require('crypto');

const msg_table = 'messaging_board';
const fol_table = 'follower_table';

// Using ElephantSQL <- DaaS that uses SQL.

var credentials = cred.getSQLUrl();

async function createHash(sender, receiver){
    
    var joined = "";
    
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
        await client.connect();

        var hash = await createHash(sender, receiver);
        JSON.stringify(new Date());

        // TimeStamp works with NOW() function
        var query = "insert into " + msg_table + " VALUES ('" + hash + "',NOW(),'" + sender + "', '" + receiver + "', '" + message + "');"

        await client.query(query).catch((error) => console.log(error));
        client.end();
        
        return JSON.stringify({result: true, response: ["Successfully sent."]});
    },
    getMessage: async function(sender, receiver){
        var client = new pg.Client(credentials);
        await client.connect();

        // Get id to search for messages between 2 users.
        var hash = await createHash(sender, receiver);

        // Query
        var query = "select date, sender, receiver , message from " + msg_table + " where id = '" + hash + "' order by date DESC limit 20"
        var response = await client.query(query).catch((error) => console.log(error));      
        client.end();

        if(response.rows.length == 0){
            return JSON.stringify({result: true, response: ["Start of your conversation"]});
        }

        return JSON.stringify({result: true, response: response.rows});
    },
    deleteMessages: async function(sender, receiver){
        var client = new pg.Client(credentials);
        await client.connect();

        var hash = await createHash(sender, receiver);
        var query = "delete from " + msg_table + " where id = '" + hash + "'"; 
        
        await client.query(query).catch((error) => console.log(error));      
        client.end();

        return JSON.stringify({result: true, response: ['Successfully deleted all messages.']});        
    },

    // New table
    followUser: async function(sender, receiver){
        var client = new pg.Client(credentials);
        await client.connect();

        var hash = await createHash(sender, receiver);
        var checkIfExists = "select confirmation from follower_table where hash = '" + hash + "'";
        var checkResponse = await client.query(checkIfExists).catch((error) => console.log(error));      

        // Check that no requests have already been sent
        if(checkResponse.rowCount != 0){
            // Check if confirmed or not
            if(checkResponse.rows[0]['confirmation']){
                return JSON.stringify({result: false, response: ['Already friends.']}); 
            } else {
                return JSON.stringify({result: false, response: ['Friend request pending.']}); 
            }       
        }

        var addQuery = "insert into " + fol_table + " values ('" + hash + "','" + sender + "','" + receiver + "', false)"; 
        await client.query(addQuery).catch((error) => console.log(error));
        client.end();

        return JSON.stringify({result: true, response: ['Request has been sent.']}); 
    },
    acceptUserFollowRequest: async function(acceptor, sender){
        var client = new pg.Client(credentials);
        await client.connect();
        var hash = await createHash(acceptor, sender);
        
        var checkQuery = "select confirmation from " + fol_table + " where hash = '" + hash + "' AND receiver = '" + acceptor + "'";     
        var checkResponse = await client.query(checkQuery).catch((error) => console.log(error));      
        if(checkResponse.rowCount == 0){
            return JSON.stringify({result: false, response: ['No pending requests.']});     
        }
        if(checkResponse.rows[0]['confirmation']){
            return JSON.stringify({result: false, response: ['You are already friends.']});     
        }

        var updateQuery = "update " + fol_table + " set confirmation = true where hash = '" + hash + "'";  
        await client.query(updateQuery).catch((error) => console.log(error));      
        client.end();
        return JSON.stringify({result: true, response: ['You are now friends with ' + sender]}); 
    },
    getAllFollowerRequests: async function(user){
        var client = new pg.Client(credentials);
        await client.connect();
        
        var getQuery = "select sender from " + fol_table + " where confirmation = false AND receiver = '" + user + "'";
        response = await client.query(getQuery).catch((error) => console.log(error));      
        client.end();

        var return_array = getArrayFromDictionary(response.rows, 'sender', user);
        return JSON.stringify({result: true, response: return_array});
    },
    getAllFollowerPending: async function(user){
        var client = new pg.Client(credentials);
        await client.connect();
        
        var getQuery = "select receiver from " + fol_table + " where confirmation = false AND sender = '" + user + "'";
        response = await client.query(getQuery).catch((error) => console.log(error));      
        client.end();

        var return_array = getArrayFromDictionary(response.rows, 'receiver', user);
        return JSON.stringify({result: true, response: return_array});
    },
    getAllFriends: async function(user){
        var client = new pg.Client(credentials);
        await client.connect();

        var getQuery = "select sender, receiver from " + fol_table + " where confirmation = true AND (sender = '" + user + "' OR receiver = '" + user + "')";       
        response = await client.query(getQuery).catch((error) => console.log(error));      
        client.end();

        var returnArray = getArrayFromDictionary(response.rows, 'send_rec', user);
        return JSON.stringify({result: true, response: returnArray});
    },
    deleteFriendship: async function(deleter, victim){
        var client = new pg.Client(credentials);
        await client.connect();

        var hash = await createHash(deleter, victim);

        var deleteQuery = "delete from " + fol_table + " where hash = '" + hash + "'";
        response = await client.query(deleteQuery).catch((error) => console.log(error));      
        client.end();
        return JSON.stringify({result: true, response: ['Friendship has been deleted.']});
    },
  

    // For internal use.
    getAllRecordsForUser: async function(user){
        var client = new pg.Client(credentials);
        await client.connect();

        var getQuery = "select sender, receiver, confirmation from " + fol_table + " where (sender = '" + user + "' OR receiver = '" + user + "')";       
        response = await client.query(getQuery).catch((error) => console.log(error));      
        client.end();

        var returnArray = response.rows;
        return returnArray;
    },

};

function getArrayFromDictionary(array, type, user){
    var returnArray = [];
    for (var i = 0; i < array.length; i++){

        if(type == 'send_rec'){

            if(array[i]['receiver'] == user){
                returnArray.push(array[i]['sender'])
            } else {
                returnArray.push(array[i]['receiver'])
            }

        } else {
            returnArray.push(array[i][type]);
        }
    }
    return returnArray;
}