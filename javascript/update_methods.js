var db = require('./backend_mongodb');

module.exports = {

    updateUser: async function(res, id, username, password, balance){
        response = await db.updateUser(id, username, password, balance);
        res.send(response);
        return;
    },
    updateOrder: async function(res, order_id, username, beverage, size, details, restaurant, library, floor, segment, cost){
        response = await db.updateOrder(order_id, username, beverage, size, details, restaurant, library, floor, segment, cost);
        res.send(response);
        return;
    },
    attachDel: async function(res, order_id, delivery_id){
        response = await db.attachOrder(order_id, delivery_id);
        res.send(response);
        return;
    },
    detachDel: async function(res, order_id, delivery_id){
        response = await db.detachOrder(order_id, delivery_id);
        res.send(response);
        return;
    },
    withdraw: async function(res, user_id, funds){
        response = await db.withdraw(user_id, funds);
        res.send(response);
        return;
    },
    deposit: async function(res, user_id, funds){
        response = await db.deposit(user_id, funds);
        res.send(response);
        return;
    },
    cleanFlagged: async function(res, user_id){
        response = await db.cleanFlagged(user_id);
        res.send(response);
        return;
    }
}