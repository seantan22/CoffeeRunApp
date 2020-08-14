var post_methods = require('./javascript/post_methods');
var cred_checker = require('./javascript/credential_check');
var update_methods = require('./javascript/update_methods');
var delete_methods = require('./javascript/delete_methods');
var get_methods = require('./javascript/get_methods');

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const Client = require('pg');

const app = express()

app.set('port', (process.env.PORT || 5000));
app.use(cors());
app.use(bodyParser.json());

// **************************** TAX ***************************

app.get('/getTaxRates', function(req, res){
    get_methods.getTaxRates(res);
    return;
})

// *************************** IMAGE ***************************

app.post('/postImage', function(req, res){
    var username = req.body.username;

    // Hexadecimal format
    var image = req.body.picture;
    post_methods.uploadPicture(res, username, image);
    return;
})

app.get('/getImage', function(req, res){
    var username = req.headers['username'];
    get_methods.getPicture(res, username);
    return;
})

// ************************* FOLLOWER/ING **************************
app.post('/sendFollowRequest', function(req, res){
    var sender = req.body.sender;
    // The person you are clicking to follow
    var receiver = req.body.receiver;
    
    post_methods.followUser(res, sender, receiver);
    return;
})

app.post('/acceptFollowRequest', function(req, res){
    var acceptor = req.body.acceptor;
    var sender = req.body.sender;
    post_methods.acceptUserFollowRequest(res, acceptor, sender);
    return;
})

app.post('/denyFollowRequest', function(req, res){
    var denier = req.body.denier;
    var sender = req.body.sender;
    delete_methods.denyUserFollowRequest(res, denier, sender);
    return;
})

// Requests that people have sent you
app.get('/getAllFollowerRequests', function(req, res){
    var user = req.headers['user'];
    get_methods.getAllFollowerRequests(res, user);
    return;
})

// Requests that you have sent others
app.get('/getPendingRequests', function(req, res){
    var user = req.headers['user'];
    get_methods.getAllFollowerPending(res, user);
    return;
})

app.get('/getAllFriends', function(req, res){
    var user = req.headers['user'];
    get_methods.getAllFriends(res, user);
    return;
})

app.delete('/deleteFriendship', function(req, res){
    var deleter = req.body.sender;
    var victim = req.body.receiver;

    delete_methods.deleteFriendship(res, deleter, victim);
    return;
})

// ************************** MESSAGING ***************************

app.post('/sendMessage', function(req, res){
    var message = req.body.message;
    var sender = req.body.sender;
    var receiver = req.body.receiver;

    post_methods.sendMessage(res, message, sender, receiver);
    return;
})
app.get('/getMessages', function(req, res){
    var sender = req.headers['sender'];
    var receiver = req.headers['receiver'];

    get_methods.getMessages(res, sender, receiver);
    return;
})

app.delete('/deleteMessages', function(req, res){
    var sender = req.body.sender;
    var receiver = req.body.receiver;

    delete_methods.deleteMessages(res, sender, receiver);
    return;
})

// **************************** USER *************************

app.post('/forgetPassword', function(req, res){
    var email = req.body.email;
    post_methods.forgetPassword(res, email.toLowerCase());
    return;
})

app.post('/updateForgottenPassword', function(req, res){
    
    var email = req.body.email;
    var new_password = req.body.password;

    if (cred_checker.passwordStrength(new_password) || new_password == null || new_password == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter an appropriate password."]}));
        return;
    }

    post_methods.updatePasswordFromReset(res, email, new_password);
})

app.post('/verify', function(req, res){
    var verification = req.body.verification_number;
    var id = req.body.user_id
    post_methods.verifyUser(res, id, verification);
    return;
})

app.get('/', function(req, res){
    res.send('SUCCESS');
    return;
})

app.get('/getNumberCurrentRunners', function(req, res){
    get_methods.getCurrentRunners(res);
    return;
})

app.get('/getNumberOfAllOpenOrders', function(req, res){
    get_methods.getNumberOfAllOpenOrders(res);
    return;
})

app.get('/getOrdersByLibrary', function(req, res){
    var library = req.headers['library'];
    if(library == "" || library == null){
        return JSON.stringify({result: false, response: ["Please input a library."]});
    }

    get_methods.getOrdersByLibrary(res, library);
    return;
})

app.post('/makeReview', function(req, res){
    var review = req.body.review;
    var username = req.body.username;

    if(review == "" || review == null){
        return JSON.stringify({result: false, response: ["Please write a review."]});
    }

    post_methods.makeReview(res, review, username);
    return;
})

app.get('/getUser', function(req, res){
    var user_id = req.headers['user_id'];
    get_methods.getUser(res, user_id);
    return;
})

app.get('/getUsers', function(req, res){
    var usernmae = req.headers['username'];
    get_methods.getUsers(res, usernmae);
    return;
})

app.get('/getOrderByUser', function(req, res){
    var user_id = req.headers['user_id'];
    get_methods.getOrderForUser(res, user_id);
    return;
})

app.get('/getClosedOrdersByUser', function(req, res){
    var user_id = req.headers['user_id'];
    get_methods.getClosedOrders(res, user_id);
    return;
})

app.get('/getAllFriendOrders', function(req, res){
    var username = req.headers['username'];
    get_methods.getFriendOrders(res, username);
    return;
})

app.get('/getRating', function(req, res){
    var delivery_id = req.headers['delivery_id'];
    get_methods.getRatingForDelivery(res, delivery_id);
    return;

})

app.post('/createUser', function (req, res) {
    if (req.body.username == null || req.body.username == ""){
        res.send(JSON.stringify({result: false, response: ["Please fill in the username."]}));
        return;
    }
    if (cred_checker.passwordStrength(req.body.password) || req.body.password == null || req.body.password == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter an appropriate password."]}));
        return;
    }
    if (cred_checker.emailStrength(req.body.email) || req.body.email == null || req.body.email == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter an appropriate mcgill email."]}));
        return;
    }
    if (cred_checker.phoneStrength(req.body.phone_number) || req.body.phone_number == null || req.body.phone_number == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter an appropriate phone number."]}));
        return;
    }
    
    var username = req.body.username;
    var password = req.body.password;
    var email = req.body.email;
    var phone_numb = req.body.phone_number;

    post_methods.createUser(res, username, password, email, phone_numb);

    return;
})

app.post('/updateUser', function(req, res){

    if (req.body.username == null || req.body.username == ""){
        res.send(JSON.stringify({result: false, response: ["Please fill in the username."]}));
        return;
    }
    if (cred_checker.passwordStrength(req.body.password) || req.body.password == null || req.body.password == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter an appropriate password."]}));
        return;
    }

    var user_id = req.body.user_id;
    var username = req.body.username;
    var password = req.body.password;

    update_methods.updateUser(res, user_id, username, password);
    return;
})

app.post('/login', function (req, res) {

    var email = req.body.email;
    var password = req.body.password;

    post_methods.login(res, email, password);
    return;
})

app.post('/logout', function (req, res) {

    var user_id = req.body.user_id;

    post_methods.logout(res, user_id);
    return;
})

app.delete('/deleteUser', function (req, res){
    var user_id = req.body.user_id;
    delete_methods.deleteUser(res, user_id);
    return;
})

// ****************************** ORDERS **************************

app.get('/getOrders', function(req, res){
    get_methods.getAllOrders(res);
    return;
})

app.get('/getOrderDelivery', function(req, res){
    var user_id = req.headers['user_id'];
    get_methods.getOrderForDelivery(res, user_id);
    return;
})

app.post('/createOrder', function (req, res) {
    if (req.body.beverage == null || req.body.beverage == ""){
        res.send(JSON.stringify({result: false, response: ["Please fill in the beverage."]}));
        return;
    }
    if (req.body.size == null || req.body.size == ""){
        res.send(JSON.stringify({result: false, response: ["Please fill in the size."]}));
        return;
    }
    if (req.body.details == null || req.body.details == ""){
        res.send(JSON.stringify({result: false, response: ["Please fill in details or indicate N/A if none."]}));
        return;
    }
    if (req.body.restaurant == null || req.body.restaurant == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter the restaurant."]}));
        return;
    }
    if (req.body.library == null || req.body.library == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter the library you are in."]}));
        return;
    }
    if (req.body.floor == null || req.body.floor == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter the floor you are on."]}));
        return;
    }
    if (req.body.segment == null || req.body.segment == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter the segment you are in."]}));
        return;
    }
    if (req.body.cost == null || req.body.cost == "" || req.body.cost < 0){
        res.send(JSON.stringify({result: false, response: ["Please enter the cost."]}));
        return;
    }
    
    var beverage = req.body.beverage;
    var size = req.body.size;
    var details = req.body.details;
    var restaurant = req.body.restaurant;
    var library = req.body.library;
    var floor = req.body.floor;
    var segment = req.body.segment;
    var cost = req.body.cost;
    var status = "Awaiting Runner";
    var user_id = req.body.user_id;
        
    post_methods.createOrder(res, beverage, size, details, restaurant, library, floor, segment, cost, status, user_id);
    return;
})

app.post('/updateOrder', function(req, res){
    if (req.body.beverage == null || req.body.beverage == ""){
        res.send(JSON.stringify({result: false, response: ["Please fill in the beverage."]}));
        return;
    }
    if (req.body.size == null || req.body.size == ""){
        res.send(JSON.stringify({result: false, response: ["Please fill in the size."]}));
        return;
    }
    if (req.body.details == null || req.body.details == ""){
        res.send(JSON.stringify({result: false, response: ["Please fill in details or indicate N/A if none."]}));
        return;
    }
    if (req.body.restaurant == null || req.body.restaurant == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter the restaurant."]}));
        return;
    }
    if (req.body.library == null || req.body.library == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter the library you are in."]}));
        return;
    }
    if (req.body.floor == null || req.body.floor == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter the floor you are on."]}));
        return;
    }
    if (req.body.segment == null || req.body.segment == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter the segment you are in."]}));
        return;
    }
    if (req.body.cost == null || req.body.cost == "" || req.body.cost < 0){
        res.send(JSON.stringify({result: false, response: ["Please enter the cost."]}));
        return;
    }
    if (req.body.status == null || req.body.status == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter the status."]}));
        return;
    }

    var beverage = req.body.beverage;
    var size = req.body.size;
    var details = req.body.details;
    var restaurant = req.body.restaurant;
    var library = req.body.library;
    var floor = req.body.floor;
    var segment = req.body.segment;
    var cost = req.body.cost;
    var status = req.body.status;
    var order_id = req.body.order_id;
    var username = req.body.username;

    update_methods.updateOrder(res, order_id, username, beverage, size, details, restaurant, library, floor, segment, cost, status);
    return;
})

app.post('/attachDelivery', function(req, res){

    if(req.body.order_id == null || req.body.order_id == "") {
        res.send(JSON.stringify({result: false, response: ["Please enter the order_id."]}));
        return;
    }

    if(req.body.delivery_id == null || req.body.delivery_id == "") {
        res.send(JSON.stringify({result: false, response: ["Please enter the delivery_id."]}))
        return;
    }

    var order_id = req.body.order_id;
    var delivery_id = req.body.delivery_id;

    update_methods.attachDel(res, order_id, delivery_id);
    return;
})

app.post('/detachDelivery', function(req, res){
    var order_id = req.body.order_id;
    var delivery_id = req.body.delivery_id;

    update_methods.detachDel(res, order_id, delivery_id);
    return;
})

app.post('/markInProgress', function(req, res){
    
    var order_id = req.body.order_id;
    var delivery_id = req.body.delivery_id;
    var status = "In Progress";

    update_methods.updateStatus(res, order_id, delivery_id, status);
    return;
})

app.post('/markPickedUp', function(req, res){
    
    var order_id = req.body.order_id;
    var delivery_id = req.body.delivery_id;
    var status = "Picked Up";

    update_methods.updateStatus(res, order_id, delivery_id, status);
    return;
})

app.post('/markDelivered', function(req, res){
    
    var order_id = req.body.order_id;
    var delivery_id = req.body.delivery_id;
    var status = "Delivered";

    update_methods.updateStatus(res, order_id, delivery_id, status);
    return;
})

app.delete('/deleteOrder', function(req, res){
    var order_id = req.body.order_id;
    var username = req.body.username;

    delete_methods.deleteOrder(res, order_id, username);
    return;
})

app.post('/withdraw', function(req, res){
    var user_id = req.body.user_id;
    var funds = req.body.fund;

    update_methods.withdraw(res, user_id, funds);
    return;
})

app.post('/deposit', function(req, res){
    var user_id = req.body.user_id;
    var funds = req.body.fund;

    update_methods.deposit(res, user_id, funds);
    return;
})

app.post('/completeOrder', function(req, res){

    if(req.body.user_id == null || req.body.user_id == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter user_id."]}));
        return;
    }
    if(req.body.delivery_username == null || req.body.delivery_username == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter delivery_id."]}));
        return;
    }
    if(req.body.order_id == null || req.body.order_id == ""){
        res.send(JSON.stringify({result: false, response: ["Please enter order_id."]}));
        return;
    }

    var user_id = req.body.user_id;
    var delivery_username = req.body.delivery_username;
    var order_id = req.body.order_id;
    var rating = req.body.rating;
    var cost = req.body.cost;
    var tip = req.body.tip;

    post_methods.completeOrder(res, rating, order_id, user_id, delivery_username, cost, tip);
    return;

})

app.post('/clean', function(req, res){
    var user_id = req.body.user_id;
    update_methods.cleanFlagged(res, user_id);
    return;
})

// *************************************  GETTERS FOR BEVERAGES  ****************************************

app.get('/getVendors', function(req, res){
    get_methods.getVendors(res);
    return;
})

app.get('/getBeverageInfo', function(req, res){
    var vendor = req.headers['vendor'];
    get_methods.getBeveragesInfoFromVendor(res, vendor);
    return;
})

app.get('/getPriceOfBeverage', function(req, res){
    var vendor = req.headers['vendor'];
    var beverage = req.headers['beverage'];
    var size = req.headers['size'];

    get_methods.getBeveragePrice(res, vendor, beverage, size);
    return;
})

app.get('/getLibraryInformation', function(req, res){
    get_methods.getLibraryInformation(res);
    return;
})

app.get('/getOrderStatus', function(req, res){
    var order_id = req.headers['order_id'];

    get_methods.getOrderStatus(res, order_id);
    return;
})

var server = app.listen(process.env.PORT || 5000, function () {
    console.log('Server started...')
})
