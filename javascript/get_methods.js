var db = require('./backend_mongodb');
var esql = require('./backend_elephantSQL');

module.exports = {
    getUser: async function(res, id){
        response = await db.getUser(id);
        res.send(response);
        return;
    },
    getUsers: async function(res){
        response = await db.getUsers();
        res.send(response);
        return;
    },
    getOrderForUser: async function(res, id){
        response = await db.getOrderForUser(id);
        res.send(response);
        return;
    },
    getAllOrders: async function(res){
        response = await db.getAllOpenOrders();
        res.send(response);
        return;
    },
    getOrderForDelivery: async function(res, id){
        response = await db.getOrdersForDelivery(id);
        res.send(response);
        return;
    },
    getRatingForDelivery: async function(res, delivery_id){
        response = await db.getDeliveryRating(delivery_id);
        res.send(response);
        return;
    },
    getCurrentRunners: async function(res){
        response = await db.getCurrentRunners();
        res.send(response);
        return;
    },
    getNumberOfAllOpenOrders: async function(res){
        response = await db.getNumberOfAllOpenOrders();
        res.send(response);
        return;
    },
    getOrdersByLibrary: async function(res, library){
        response = await db.getOrdersByLibrary(library);
        res.send(response);
        return;
    },
    getStatusOfOrder: async function(res, order_id){
        response = await db.getStatusOfOrder(order_id);
        res.send(response);
        return;
    },
    getMessages: async function(res, sender, receiver){
        response = await esql.getMessage(sender, receiver);
        res.send(response);
        return;
    }
};