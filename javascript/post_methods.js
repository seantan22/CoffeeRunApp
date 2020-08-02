var db = require('./backend_mongodb');

module.exports = {
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
            res.send(JSON.stringify({result: false, errorMessage: 'Username is already taken.'}));
            return;
        }
        if (await (db.checkIfUnique(3, email))){
            res.send(JSON.stringify({result: false, errorMessage: 'Email is already taken.'}));
            return;
        }
        if (await (db.checkIfUnique(4, phoneNum))){
            res.send(JSON.stringify({result: false, errorMessage: 'Phone number is already taken.'}));
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
    },
    makeReview: async function(res, review, username){
        response = await db.makeReview(username, review);
        res.send(response);
        return;
    },
    getVendors: async function(res){
        response = await db.getVendors();
        res.send(response);
        return;
    },
    getBeveragesFromVendor: async function(res, vendor){
        response = await db.getBeveragesFromVendor(vendor);
        res.send(response);
        return;
    },
    getBeveragesOfBevAndVendor: async function(res, vendor, beverage){
        response = await db.getBeveragesOfBevAndVendor(vendor, beverage);
        res.send(response);
        return;
    },
    getBeveragePrice: async function(res, vendor, beverage, size){
        response = await db.getBeveragePrice(vendor, beverage, size);
        res.send(response);
        return;
    },
    getLibraryInformation: async function(res){
        response = await db.getLibraryInformation();
        res.send(response);
        return;
    }
};