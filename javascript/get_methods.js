var db = require('./backend_mongodb');
var esql = require('./backend_elephantSQL');
var googleD = require('./backend_googDrive');

module.exports = {

    getTest: async function(res){
        response = await db.getTest();
        res.send(response);
        return;
    },


    getTaxRates: async function(res){
        response = await db.getTaxRates();
        res.send(response);
        return;
    },
    getUser: async function(res, id){
        response = await db.getUser(id);
        res.send(response);
        return;
    },
    getUsers: async function(res, username){
        response = await db.getUsers(username);
        res.send(response);
        return;
    },
    getOrderForUser: async function(res, id){
        response = await db.getOrderForUser(id);
        res.send(response);
        return;
    },
    getAllOrders: async function(res, username){
        response = await db.getAllOpenOrders(username);
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
    getMessages: async function(res, sender, receiver){
        response = await esql.getMessage(sender, receiver);
        res.send(response);
        return;
    },
    getVendors: async function(res){
        response = await db.getVendors();
        res.send(response);
        return;
    },
    getBeveragesInfoFromVendor: async function(res, vendor){
        response = await db.getBeveragesInfoFromVendor(vendor);
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
    },
    getOrderStatus: async function(res, order_id){
        response = await db.getOrderStatus(order_id);
        res.send(response);
        return;
    },
    getClosedOrders: async function(res, user_id){
        response = await db.getClosedOrders(user_id);
        res.send(response);
        return;
    },
    getFriendOrders: async function(res, username){
        response = await db.getFriendOrders(username);
        res.send(response);
        return;
    },

    // ********************* FOLLOWERS *******************
    getAllFollowerRequests: async function(res, user){
        response = await esql.getAllFollowerRequests(user);
        res.send(response);
        return;
    },
    getAllFollowerPending: async function(res, user){
        response = await esql.getAllFollowerPending(user);
        res.send(response);
        return;
    },
    getAllFriends: async function(res, user){
        response = await esql.getAllFriends(user);
        res.send(response);
        return;
    },
    doesOrderExistForDelivery: async function(res, order_id){
        response = await db.doesOrderExistForDelivery(order_id);
        res.send(response);
        return;
    },

    // *********************** UPDATE PRICING **********************
    getNewBalanceAfterOrder: async function(res, id){
        response = await db.getNewBalanceAfterOrder(id);
        res.send(response);
        return;
    },
    getTotalProfitMade: async function(res, username){
        response = await db.getTotalProfitMade(username);
        res.send(response);
        return;
    },

    // *********************** IMAGES **********************
    getPicture: async function(res, username){
        response = await googleD.getPicture(username);
        res.send(response);
        return;
    }
};