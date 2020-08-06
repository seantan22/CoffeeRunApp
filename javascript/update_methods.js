var db = require('./backend_mongodb');

module.exports = {

    updateUser: async function(res, id, username, password){
        response = await db.updateUser(id, username, password);
        res.send(response);
        return;
    },
    updateOrder: async function(res, order_id, username, beverage, size, details, restaurant, library, floor, segment, cost, status){
        response = await db.updateOrder(order_id, username, beverage, size, details, restaurant, library, floor, segment, cost, status);
        res.send(response);
        return;
    },
    updateStatus: async function(res, order_id, delivery_id, status){
        response = await db.updateOrderStatus(order_id, delivery_id, status);
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