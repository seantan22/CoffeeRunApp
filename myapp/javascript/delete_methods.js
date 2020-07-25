var db = require('./mongodb');

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
    }
};