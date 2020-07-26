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
const port = 8080

app.set('port', (process.env.PORT || 5000));
app.use(cors());
app.use(bodyParser.json());

// **************************** USER *************************

app.get('/', function(req, res){
    res.send('SUCCESS');
    return;
})

app.get('/getUser', function(req, res){
    var user_id = req.body.user_id;
    get_methods.getUser(res, user_id);
    return;
})

app.get('/getRating', function(req, res){
    var delivery_id = req.body.delivery_id;
    get_methods.getRatingForDelivery(res, delivery_id);
    return;

})

app.post('/createUser', function (req, res) {
    if (req.body.username == null || req.body.username == ""){
        res.send([false, "Please fill in the username."]);
        return;
    }
    if (cred_checker.passwordStrength(req.body.password) || req.body.password == null || req.body.password == ""){
        res.send([false, "Please enter an appropriate password."]);
        return;
    }
    if (cred_checker.emailStrength(req.body.email) || req.body.email == null || req.body.email == ""){
        res.send([false, "Please enter an appropriate email."]);
        return;
    }
    if (cred_checker.phoneStrength(req.body.phone_number) || req.body.phone_number == null || req.body.phone_number == ""){
        res.send([false, "Please enter an appropriate phone number."][false,);
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
        res.send([false, "Please fill in the username."]);
        return;
    }
    if (cred_checker.passwordStrength(req.body.password) || req.body.password == null || req.body.password == ""){
        res.send([false, "Please enter an appropriate password."]);
        return;
    }
    if (cred_checker.emailStrength(req.body.email) || req.body.email == null || req.body.email == ""){
        res.send([false, "Please enter an appropriate email."]);
        return;
    }
    if (cred_checker.phoneStrength(req.body.phone_number) || req.body.phone_number == null || req.body.phone_number == ""){
        res.send([false,"Please enter an appropriate phone number."]);
        return;
    }

    var user_id = req.body.user_id;
    var username = req.body.username;
    var password = req.body.password;
    var email = req.body.email;
    var phone_numb = req.body.phone_number;
    var balance = req.body.balance;

    update_methods.updateUser(res, user_id, username, password, email, phone_numb, balance);
    return;
})

app.post('/login', function (req, res) {

    var username = req.body.username;
    var password = req.body.password;

    post_methods.login(res, username, password);
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

app.get('/getOrderByUser', function(req, res){
    var user_id = req.body.user_id;
    get_methods.getOrderForUser(res, user_id);
    return;
})

app.get('/getOrders', function(req, res){
    get_methods.getAllOrders(res);
    return;
})

app.get('/getOrderDelivery', function(req, res){
    var user_id = req.body.user_id;
    get_methods.getOrderForDelivery(res, user_id);
    return;
})

app.post('/createOrder', function (req, res) {
    if (req.body.beverage == null || req.body.beverage == ""){
        res.send("Please fill in the beverage.");
        return;
    }
    if (req.body.size == null || req.body.size == ""){
        res.send("Please fill in the size.");
        return;
    }
    if (req.body.restaurant == null || req.body.restaurant == ""){
        res.send("Please enter the restaurant.");
        return;
    }
    if (req.body.library == null || req.body.library == ""){
        res.send("Please enter the library you are in.");
        return;
    }
    if (req.body.floor == null || req.body.floor == ""){
        res.send("Please enter the floor you are on.");
        return;
    }
    if (req.body.segment == null || req.body.segment == ""){
        res.send("Please enter the floor you are on.");
        return;
    }
    if (req.body.cost == null || req.body.cost == "" || req.body.cost < 0){
        res.send("Please enter the cost.");
        return;
    }
    
    var beverage = req.body.beverage;
    var size = req.body.size;
    var restaurant = req.body.restaurant;
    var library = req.body.library;
    var floor = req.body.floor;
    var segment = req.body.segment;
    var cost = req.body.cost;
    var user_id = req.body.user_id;
        
    post_methods.createOrder(res, beverage, size, restaurant, library, floor, segment, cost, user_id);
    return;
})

app.post('/updateOrder', function(req, res){
    if (req.body.beverage == null || req.body.beverage == ""){
        res.send("Please fill in the beverage.");
        return;
    }
    if (req.body.size == null || req.body.size == ""){
        res.send("Please fill in the size.");
        return;
    }
    if (req.body.restaurant == null || req.body.restaurant == ""){
        res.send("Please enter the restaurant.");
        return;
    }
    if (req.body.library == null || req.body.library == ""){
        res.send("Please enter the library you are in.");
        return;
    }
    if (req.body.floor == null || req.body.floor == ""){
        res.send("Please enter the floor you are on.");
        return;
    }
    if (req.body.segment == null || req.body.segment == ""){
        res.send("Please enter the floor you are on.");
        return;
    }
    if (req.body.cost == null || req.body.cost == "" || req.body.cost < 0){
        res.send("Please enter the cost.");
        return;
    }

    var beverage = req.body.beverage;
    var size = req.body.size;
    var restaurant = req.body.restaurant;
    var library = req.body.library;
    var floor = req.body.floor;
    var segment = req.body.segment;
    var cost = req.body.cost;
    var order_id = req.body.order_id;
    var username = req.body.username;

    update_methods.updateOrder(res, order_id, username, beverage, size, restaurant, library, floor, segment, cost);
    return;
})

app.post('/attachDelivery', function(req, res){
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

    var user_id = req.body.user_id;
    var delivery_id = req.body.delivery_id;
    var order_id = req.body.order_id;
    var rating = req.body.rating;

    post_methods.completeOrder(res, rating, order_id, user_id, delivery_id);
    return;

})

app.post('/clean', function(req, res){
    var user_id = req.body.user_id;
    update_methods.cleanFlagged(res, user_id);
    return;
})
var server = app.listen(process.env.PORT || 5000, function () {
    console.log('Server started...')
})