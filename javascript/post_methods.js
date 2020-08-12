var db = require('./backend_mongodb');
var esql = require('./backend_elephantSQL');
var gdrive = require('./backend_googDrive');

module.exports = {
    updatePasswordFromReset: async function(res, email, new_password, id){
        var response = await db.updatePasswordFromReset(email, new_password, id);
        res.send(response);
        return;
    },
    login: async function(res, email, password){
        var response = await db.login(email, password);
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
            res.send(JSON.stringify({result: false, response: ['Username is already taken.']}));
            return;
        }
        if (await (db.checkIfUnique(3, email))){
            res.send(JSON.stringify({result: false, response: ['Email is already taken.']}));
            return;
        }
        if (await (db.checkIfUnique(4, phoneNum))){
            res.send(JSON.stringify({result: false, response: ['Phone number is already taken.']}));
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
    verifyUser: async function(res, id, verification){
        response = await db.verifyUser(id, verification);
        res.send(response);
        return response;
    },
    makeReview: async function(res, review, username){
        response = await db.makeReview(username, review);
        res.send(response);
        return;
    },
    forgetPassword: async function(res, email){
        response = await db.forgetPassword(email);
        res.send(response);
        return;
    },

    // ********* MESSAGING ***********

    sendMessage: async function(res, message, sender, receiver){
        response = await esql.sendMessage(message, sender, receiver);
        res.send(response);
        return;
    },

    // *********** FOLLOW ************
    followUser: async function(res, sender, receiver){
        response = await esql.followUser(sender, receiver);
        res.send(response);
        return;
    },
    acceptUserFollowRequest: async function(res, acceptor, sender){
        response = await esql.acceptUserFollowRequest(acceptor, sender);
        res.send(response);
        return;
    },

    // ************************* PICTURE ****************************
    uploadPicture: async function(res, username, image){
        response = await gdrive.uploadPicture(username, image);
        res.send(response);
        return;
    }
};