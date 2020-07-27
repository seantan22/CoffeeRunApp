var db = require('./backend_mongodb');

module.exports = {
    login: async function(res, username, password){
        var response = await db.login(username, password);
        res.send(response);
        return;
    },
    logout: async function(res, id){
        var response = await db.logout(id);
        res.send(response);
        return;
    },
    createUser: async function (res, username, password, email, phoneNum){

        if (await (db.checkIfUnique(1, username))){
            res.send([false, 'Username is already taken.']);
            return;
        }
        if (await (db.checkIfUnique(2, password))){
            res.send([false, 'Password is already taken.']);
            return;
        }
        if (await (db.checkIfUnique(3, email))){
            res.send([false, 'Email is already taken.']);
            return;
        }
        if (await (db.checkIfUnique(4, phoneNum))){
            res.send([false, 'Phone number is already taken.']);
            return;
        }
        
        response = await db.addUser(username, password, email, phoneNum);
        res.send(response);
        return;
    },
    createOrder: async function(res, beverage, size, details, restaurant, library, floor, segment, cost, status, id){
        response = await db.createOrder(beverage, size, details, restaurant, library, floor, segment, cost, status, id);
        res.send(response);
        return response;
    },
    completeOrder: async function(res, rating, order_id, user_id, delivery_id){
        response = await db.completeOrder(rating, order_id, user_id, delivery_id);
        res.send(response);
        return response;
    },
    verifyUser: async function(res, username, password, verification){
        response = await db.verifyUser(username, password, verification);
        res.send(response);
        return response;
    }
};