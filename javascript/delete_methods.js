var db = require('./backend_mongodb');
var esql = require('./backend_elephantSQL');

module.exports = {
    deleteUser: async function(res, id){
        response = await db.deleteUser(id);
        res.send(response);
        return;
    },
    deleteOrder: async function(res, id, username){
        response = await db.deleteOrder(id, username);
        res.send(response);
        return;
    },
    deleteMessages: async function(res, sender, receiver){
        response = await esql.deleteMessages(sender, receiver);
        res.send(response);
        return;
    },
    deleteFriendship: async function(res, deleter, victim){
        response = await esql.deleteFriendship(deleter, victim);
        res.send(response);
        return;
    }
};