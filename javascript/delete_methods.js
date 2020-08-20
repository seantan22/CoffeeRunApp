var db = require('./backend_mongodb');

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
    deleteFriendship: async function(res, deleter, victim){
        response = await db.deleteFriendship(deleter, victim);
        res.send(response);
        return;
    },
    denyUserFollowRequest: async function(res, denier, sender){
        response = await db.deleteFriendship(denier, sender);
        res.send(response);
        return;
    }

    // Messagges
    // deleteMessages: async function(res, sender, receiver){
    //     response = await esql.deleteMessages(sender, receiver);
    //     res.send(response);
    //     return;
    // },
};