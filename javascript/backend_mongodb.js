const MongoClient = require('mongodb').MongoClient;
const ObjectId = require('mongodb').ObjectId;
const TMClient = require('textmagic-rest-client');
const bcrypt = require('bcrypt');
const cred = require('./cred');
const { ObjectID } = require('mongodb');

const dbName = 'CoffeeRun';
const pName = 'Products';

const uri = "mongodb+srv://Dwarff19:" + cred.getPass() + "@coffeerun.y795l.azure.mongodb.net/" + dbName + "?retryWrites=true&w=majority";

// Upon login for the first time, send SMS message.
function sendSMS(phone_number, verification_code){
    var c = new TMClient('alexgruenwald', 'fzRW0tCWGeQHpenejnz8dt5mBMcjab');
    // Phone number format - no '-' allowed.
    number = '+1' + phone_number.split('-').join('');
    c.Messages.send({text: 'Welcome to CoffeeRun! Your verification code is: ' + verification_code, phones: number});
    return [true, 'Verification code send.'];
}

// Gets the previous VIABLE balance
function getPreviousValue(transaction_history, user_record){
    var previous_balance = 0;
    // Check which was most recent
    if(transaction_history.length != 0){
        if(transaction_history[0].type == 'payment'){
            // Check to see if user was a payer or payee before
            if(transaction_history[0].payer_name == user_record.username){
                previous_balance = transaction_history[0].payer_balance.new_balance;
            } else {
                previous_balance = transaction_history[0].payee_balance.new_balance;
            }
        } else {
            // If this was not first deposit, then update funds
            previous_balance = transaction_history[0].balance.new_balance;
        }
    }
    return previous_balance
}

async function checkIfCorrupt(type, client, user_record, funds){

    // Get last transaction deposit OR withdraw OR payment
    var transaction_history = await client.collection("Transaction").find({$or: [{username: user_record.username}, {payer_name: user_record.username}, {payee_name: user_record.username}]}).sort({$natural: -1}).limit(1).toArray();    

    if(transaction_history.length == 0) {
        return [true, 0];
    }

    if(transaction_history[0].flagged){
        return JSON.stringify({result: false, response: ['Last transaction was flagged. Please contact us.']});
    }

    var previous_balance = getPreviousValue(transaction_history, user_record);

    // Balance does NOT match transaction history
    if(user_record.balance != previous_balance){
        // Automatic logout and flagging of account
        let personInfo = {$set: {username: user_record.username, password: user_record.password, email: user_record.email, phone_number: user_record.phone_number, loggedIn: false, balance: user_record.balance, flagged: true}};
        var response = await client.collection("User").updateOne({_id: ObjectId(user_record._id)}, personInfo).catch((error) => console.log(error)); 
        
        var transaction = await client.collection("Transaction").insertOne({flagged: true, type: type, time_created: new Date().toJSON(), transaction_value: funds, username: user_record.username, balance: {expected_balance: previous_balance, corrupt_balance: user_record.balance}});

        return JSON.stringify({result: false, response: ['Your balance is incorrect and has been flagged.']});
    }

    return [true, previous_balance];
}

async function checkIfInputIsUnique(key, value){
    var existence = false;
    
    var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
    var client = db.db(dbName);
    
    var record = await client.collection("User").findOne({ [key]: value }).catch((error) => console.log(error));
    
    if (record != null) {
        existence = true;
    } 
    db.close();

    return existence;
}

async function loginWithCred(email, password){
    var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
    var client = db.db(dbName);
    
    var record = await client.collection("User").findOne({ email: email }).catch((error) => console.log(error));
    
    if(record == null){
        db.close();
        return JSON.stringify({result: false, response: ['Account does not exist.']});
    }
    if(record.flagged){
        db.close();
        return JSON.stringify({result: false, response: ['This account has been flagged.']});
    }
    if(record.loggedIn){
        db.close();
        return JSON.stringify({result: false, response: ['Already logged in.']});
    }
    // if(!record.verified){
    //     db.close();
    //     return JSON.stringify({result: false, response: 'Please verify your account: ' + record.phone_number});
    // }
    if(!(await bcrypt.compare(password, record.password))){
        db.close();
        return JSON.stringify({result: false, response: ['Password is incorrect.']});
    }

    let updatedInfo = {$set: {loggedIn: true}};
    // Update
    var response = await client.collection("User").updateOne({password: record.password}, updatedInfo).catch((error) => console.log(error)); 
    
    db.close();

    // Login returns this.
    return JSON.stringify({result: true, response: [record._id]});
}

async function logoutWithCred(id){

    var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
    var client = db.db(dbName);
    
    var record = await client.collection("User").findOne({ _id: ObjectId(id)}).catch((error) => console.log(error));
    
    if(record == null){
        db.close();
        return JSON.stringify({result: false, response: ['Incorrect credentials.']});
    }
    if(!record.loggedIn){
        db.close();
        return JSON.stringify({result: false, response: ['Already logged out.']});
    }

    let updatedInfo = {$set: {username: record.username, password: record.password, email: record.email, phone_number: record.phone_number, loggedIn: false}};
    // Update
    var response = await client.collection("User").updateOne({_id: ObjectId(id)}, updatedInfo).catch((error) => console.log(error)); 
    db.close();

    return JSON.stringify({result: true, response: ['Successfully logged out.']});
}

module.exports = {
    getStatusOfOrder: async function(order_id){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var record = await client.collection("Open_Orders").findOne({_id: ObjectId(order_id)}).catch((error) => console.log(error));
        if(record == null){
            db.close();
            return JSON.stringify({result: false, response: ['Order does not exist.']});
        }
        db.close();
        return JSON.stringify({result: true, response: record.status});
    },
    getOrdersByLibrary: async function(library){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        number_of_orders = await client.collection("Open_Orders").countDocuments({library: library});
        db.close();
        return JSON.stringify({result: true, response: number_of_orders});
    },
    getNumberOfAllOpenOrders: async function(){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        number_of_orders = await client.collection("Open_Orders").countDocuments();
        db.close();
        return JSON.stringify({result: true, response: number_of_orders});
    },
    getCurrentRunners: async function(){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        
        // Get all unique runners.
        array_of_unique_runners = await client.collection("Open_Orders").distinct("delivery_boy");
        db.close();
        return JSON.stringify({result: true, response: array_of_unique_runners.length});
    },
    makeReview: async function(username, review){
        var db = await MongoClient.connect(urclient.collection.distincti, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        let reviewInfo = {time: new Date().toJSON(), username: username, review: review};
        var response = await client.collection("Reviews").insertOne(reviewInfo);
        db.close();
        return JSON.stringify({result: true, response: ['Thank you for your review.']});
    },
    verifyUser: async function(id, verification_number){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var record = await client.collection("User").findOne({_id: ObjectId(id)});

        if(record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }
        if(record.verified){
            db.close();
            return JSON.stringify({result: false, response: ['Account already verified.']});
        }
        if(verification_number != record.verification_number){
            //sendSMS(record.phone_number, record.verification_number);
            db.close();
            return JSON.stringify({result: false, response: ['Incorrect verification code. It has been resent.']});
        }

        let personInfo = {$set: {verified: true, loggedIn: true}}; // Update
        var response = await client.collection("User").updateOne({_id: ObjectId(record._id)}, personInfo).catch((error) => console.log(error)); 
        db.close();

        // Login already returns JSON format
        return JSON.stringify({result: true, response: ['Sueccessfully verified.']});
    },

    // ************************************** USER ***************************************

    getUser: async function(id){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var record = await client.collection("User").findOne({_id: ObjectId(id)});
        
        if(record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User ID does not exist.']});
        }

        if(!record.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['Have to be logged in to get user information.']});
        }
        
        db.close();

        return ({result: true, response: [record.username, record.email, record.balance.toString()]}); 
    },
    getUsers: async function(){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var record = await client.collection("User").find().toArray();
        db.close();
        return JSON.stringify({result: true, response: record}); 
    },
    addUser: async function(username, password, mail, number){
        var starting_balance = 0;
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        verification_code = Math.floor(100000 + Math.random() * 899999);
            
        // Encrypt password.
        var saltRounds = 9;

        let hashPassword = await bcrypt.hash(password, await bcrypt.genSalt(saltRounds));

        let personInfo = {username: username, password: hashPassword, email: mail, phone_number: number, loggedIn: false, balance: starting_balance, flagged: false, verified: false, verification_number: verification_code};
        var response = await client.collection("User").insertOne(personInfo);
        
        //sendSMS(number, verification_code);
        db.close();

        return JSON.stringify({result: true, response: [response.ops[0]._id]});      
    },
    updateUser: async function(id, username, password){
        var hasUpdated = false;

        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var record = await client.collection("User").findOne({ _id: ObjectId(id)}).catch((error) => console.log(error));
           
        if(record == null){
            db.close();
            return JSON.stringify({result: false, response: ['Incorrect credentials.']});
        }

        if(!record.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['You have to be logged in to change credentials.']});
        }

        var number_of_orders = await client.collection("Open_Orders").countDocuments({creator: record.username}).catch((error) => console.log(error));
        if(number_of_orders >= 1){
            db.close();
            return JSON.stringify({result: false, response: ['You cannot update your account with a pending order.']});
        }
        var number_of_deliveries = await client.collection("Open_Orders").countDocuments({delivery_boy: record.username}).catch((error) => console.log(error));
        if(number_of_deliveries >= 1){
            db.close();
            return JSON.stringify({result: false, response: ['You cannot update your account while delivering.']});
        }

        // Check if new info is unique
        if (record.username != username){
            if (await (checkIfInputIsUnique('username', username))){
                db.close();
                return JSON.stringify({result: false, response: ['New username is already taken.']});
            }
            hasUpdated = true;
        }

        if(await bcrypt.compare(password, record.password)){
            if(!hasUpdated){
                db.close();
                return JSON.stringify({result: false, response: ['No change in user profile has been found.']});
            }
        }

        var saltRounds = 8;
        let newHashedPassword = await bcrypt.hash(password, await bcrypt.genSalt(saltRounds));

        let personInfo = {$set: {username: username, password: newHashedPassword}};
        var response = await client.collection("User").updateOne({_id: ObjectId(id)}, personInfo).catch((error) => console.log(error)); 
        db.close();
    
        return JSON.stringify({result: true, response: ['Successfully updated credentials.']});

    },
    deleteUser: async function(id){
        
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var record = await client.collection("User").findOne({ _id: ObjectId(id) }).catch((error) => console.log(error));
        
        if(record == null){
            db.close();
            return JSON.stringify({result: false, response: ['Incorrect credentials.']});
        }
        if(!record.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['You have to be logged in to delete your account.']});
        }

        var number_of_orders = await client.collection("Open_Orders").countDocuments({creator: record.username}).catch((error) => console.log(error));
        
        if(number_of_orders >= 1){
            db.close();
            return JSON.stringify({result: false, response: ['You cannot delete your account with a pending order.']});
        }

        var number_of_deliveries = await client.collection("Open_Orders").countDocuments({delivery_boy: record.username}).catch((error) => console.log(error));
        
        if(number_of_deliveries >= 1){
            db.close();
            return JSON.stringify({result: false, response: ['You cannot delete your account while delivering.']});
        }

        var response = await client.collection("User").deleteOne({_id: ObjectId(id)}).catch((error) => console.log(error)); 
        db.close();

        return JSON.stringify({result: true, response: ['Successfully deleted.']});

    },

    // WITHDRAW AND DEPOSIT USES CUSTOMER LEDGER

    withdraw: async function(user_id, funds){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var user_record = await client.collection("User").findOne({ _id: ObjectId(user_id) }).catch((error) => console.log(error));

        if(user_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }
        if(!user_record.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['User must be logged in to withdraw funds.']});
        }
        if(funds <= 0.00 || funds > 50.00){
            db.close();
            return JSON.stringify({result: false, response: ['Please withdraw between $0.00 and $50.00.']});
        }
        if(funds > user_record.balance){
            db.close();
            return JSON.stringify({result: false, response: [']You do not enough enough funds to withdraw: ' + funds]});
        }
        if(user_record.flagged){
            db.close();
            return JSON.stringify({result: false, response: ['User is flagged.']});
        }

        checkCorrupt = await checkIfCorrupt('withdraw', client, user_record, funds);
        if(!checkCorrupt[0]){
            db.close();
            return checkCorrupt;
        }
        
        var final_balance = parseFloat(checkCorrupt[1]) - parseFloat(funds);

        let personInfo = {$set: {balance: parseFloat(final_balance)}};
        var response = await client.collection("User").updateOne({_id: ObjectId(user_id)}, personInfo).catch((error) => console.log(error)); 

        // Create transaction of record.
        let transactionInfo = {flagged: false, type: 'withdraw', time_created: new Date().toJSON(), amount_drawn: funds, username: user_record.username, balance: {new_balance: final_balance, previous_balance: user_record.balance}};
        var transaction_history = await client.collection("Transaction").insertOne(transactionInfo);
        db.close();

        return JSON.stringify({result: true, response: ['New balance: ' + parseFloat(final_balance)]});
    },
    deposit: async function(user_id, funds){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var user_record = await client.collection("User").findOne({ _id: ObjectId(user_id) }).catch((error) => console.log(error));

        var previous_balance = 0.00;
        if(user_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }
        if(!user_record.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['User must be logged in to deposit funds.']});
        }
        if(user_record.flagged){
            db.close();
            return JSON.stringify({result: false, response: ['User is flagged.']});
        }
        if(funds <= 0.00 || funds > 50.00){
            db.close();
            return JSON.stringify({result: false, response: ['Please deposit between $0.00 and $50.00.']});
        }

        checkCorrupt = await checkIfCorrupt('deposit', client, user_record, funds);
        if(!checkCorrupt[0]){
            db.close();
            return checkCorrupt;
        }

        var final_balance = parseFloat(checkCorrupt[1]) + parseFloat(funds);

        let personInfo = {$set: {balance: parseFloat(final_balance)}};

        var response = await client.collection("User").updateOne({_id: ObjectId(user_id)}, personInfo).catch((error) => console.log(error)); 

        // Create transaction of record.
        let transactionInfo = {flagged: false, type: 'deposit', time_created: new Date().toJSON(), amount_deposited: funds, username: user_record.username, balance: {new_balance: final_balance, previous_balance: user_record.balance}};
        var transaction_history = await client.collection("Transaction").insertOne(transactionInfo);
        db.close();

        return JSON.stringify({result: true, response: ['New balance: ' + parseFloat(final_balance)]});
    },

    // ************************************** ORDER ***************************************

    createOrder: async function(beverage, size, details, restaurant, library, floor, segment, cost, status, id){

        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        // Check if user exists.
        var record = await client.collection("User").findOne({_id: ObjectId(id)}).catch((error) => console.log(error));
        
        if(record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }
        if(!record.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['User must be logged in to create order.']});
        }

        // Check if user is corrupt
        checkCorruptUser = await checkIfCorrupt('order creation', client, record, cost);
        if(!checkCorruptUser[0]){
            db.close();
            return checkCorruptUser;
        }

        if(record.balance < cost){
            db.close();
            return JSON.stringify({result: false, response: ['Not enough funds.']});
        }

        // Make sure user is not delivering if they make an order.
        var num_attached_delivery = await client.collection("Open_Orders").countDocuments({delivery_boy: record.username}).catch((error) => console.log(error));

        if(num_attached_delivery != 0){
            db.close();
            return JSON.stringify({result: false, response: ['You are already delivering orders. Please finish or cancel.']});
        }

        var username = record.username;
        var num_current_orders = await client.collection("Open_Orders").countDocuments({creator: username}).catch((error) => console.log(error));
        
        if(num_current_orders >= 1){
            db.close();
            return JSON.stringify({result: false, response: ['You already have a pending order.']});
        }

        let personInfo = {  time: new Date().toJSON(), 
                            beverage: beverage, 
                            size: size, 
                            details: details, 
                            restaurant: restaurant, 
                            library: library, 
                            floor: floor, 
                            segment: segment, 
                            cost: cost, 
                            status: status,
                            creator: record.username, 
                            delivery_boy: ""};
        var response = await client.collection("Open_Orders").insertOne(personInfo);

        db.close();

        return JSON.stringify({result: true, response: [response.ops[0]._id]});
    },
    updateOrder: async function(id, username, beverage, size, details, restaurant, library, floor, segment, cost, status){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        // Check if order exists.
        var record = await client.collection("Open_Orders").findOne({_id: ObjectId(id)}).catch((error) => console.log(error));
        
        if(record == null){
            db.close();
            return JSON.stringify({result: false, response: ['Order does not exist.']});
        }
        if(record.creator != username){
            db.close();
            return JSON.stringify({result: false, response: ['Only user:'+username+ ' can update their order.']});
        }
        if(record.delivery_boy != null){
            db.close();
            return JSON.stringify({result: false, response: ['Cannot update order while delivery in progress.']});
        }

        let orderInfo = {$set: {    beverage: beverage, 
                                    size: size, 
                                    details: details, 
                                    restaurant: restaurant, 
                                    library: library, 
                                    floor: floor, 
                                    segment: segment, 
                                    cost: cost, 
                                    status: status,
                                    delivery_boy: record.delivery_boy   }};

        var response = await client.collection("Open_Orders").updateOne({_id: ObjectId(id)}, orderInfo).catch((error) => console.log(error));

        db.close();

        return JSON.stringify({result: true, response: ['Order successfully updated.']});
    },
    updateOrderStatus: async function(order_id, delivery_id, status) {
        var db = await MongoClient.connect(uri, {useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        // Check if order exists.
        var order = await client.collection("Open_Orders").findOne({_id: ObjectId(order_id)}).catch((error) => console.log(error));

        if(order == null) {
            db.close();
            return JSON.stringify({result: false, response: ['Order does not exist.']});
        }

        var runner = await client.collection("User").findOne({ _id: ObjectId(delivery_id)}).catch((error) => console.log(error));

        if(runner == null) {
            db.close();
            return JSON.stringify({result: false, response: ['Delivery user does not exist.']});
        }

        if(order.delivery_boy != runner.username) {
            db.close();
            return JSON.stringify({result: false, response: ['Only the runner can update the order status.']});
        }

        let statusInfo = {$set: { status: status }};
        var response = await client.collection("Open_Orders").updateOne({_id: ObjectId(order_id)}, statusInfo).catch((error) => console.log(error));

        db.close()

        return JSON.stringify({result: true, response: ['Order status successfully updated to: ' + status]});

    },
    deleteOrder: async function(id, username){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        // Check if order exists.
        var record = await client.collection("Open_Orders").findOne({_id: ObjectId(id)}).catch((error) => console.log(error));
        
        if(record == null){
            db.close();
            return JSON.stringify({result: false, response: ['Order does not exist.']});
        }
        if(record.creator != username){
            db.close();
            return JSON.stringify({result: false, response: ['Only user:'+username+ ' can delete their order.']});
        }
        if(record.delivery_boy != null){
            db.close();
            return JSON.stringify({result: false, response: ['Cannot delete order as it is being delivered.']});
        }

        var response = await client.collection("Open_Orders").deleteOne({_id: ObjectId(id)}).catch((error) => console.log(error)); 
        db.close();

        return JSON.stringify({result: true, response: ['Successfully deleted order.']});
    },
    getOrderForUser: async function(id){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        // Check if user exists.
        var user_record = await client.collection("User").findOne({_id: ObjectId(id)}).catch((error) => console.log(error));
        
        if(user_record == null){
            db.close();
            return JSON.stringify({result: false, response: [{_id: 'User does not exist.'}]});
        }

        var username = user_record.username;

        var order_records = await client.collection("Open_Orders").find({creator: username}).toArray();

        if(order_records.length == 0){
            db.close();
            return JSON.stringify({result: false, response: [{_id: 'No current orders.'}]});
        }

        console.log(order_records);

        db.close();
        return JSON.stringify({result: true, response: order_records});
    },
    getOrdersForDelivery: async function(id){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        // Check if user exists.
        var delivery_record = await client.collection("User").findOne({_id: ObjectId(id)}).catch((error) => console.log(error));
        
        if(delivery_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }

        var username = delivery_record.username;

        var order_records = await client.collection("Open_Orders").find({delivery_boy: username}).toArray();
        db.close();
        
        return JSON.stringify({result: true, response: order_records});
    },
    getAllOpenOrders: async function(){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var order_records = await client.collection("Open_Orders").find({delivery_boy: null}).toArray();
        db.close();
        
        return JSON.stringify({result: true, response: order_records});
    },
    attachOrder: async function(order_id, delivery_id){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        
        // Check if users exists.
        var order_record = await client.collection("Open_Orders").findOne({_id: ObjectId(order_id)}).catch((error) => console.log(error));
                
        if(order_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['Order does not exist.']});
        }
        if(order_record.delivery_boy != null){
            db.close();
            return JSON.stringify({result: false, response: ['There is a delivery user already on route.']});
        }
        var delivery_record = await client.collection("User").findOne({_id: ObjectId(delivery_id)}).catch((error) => console.log(error));
        if(delivery_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['Delivery user does not exist.']});
        }
        if(delivery_record.flagged){
            db.close();
            return JSON.stringify({result: false, response: ['Delivery account is flagged.']});
        }
        if(!delivery_record.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['Delivery user is not logged in.']});
        }

        // Check if delivery person is corrupt
        checkCorruptDelivery = await checkIfCorrupt('attach order', client, delivery_record, order_record.cost);
        if(!checkCorruptDelivery[0]){
            db.close();
            return checkCorruptDelivery;
        }

        if(order_record.creator == delivery_record.username){
            db.close();
            return JSON.stringify({result: false, response: ['You cannot order and deliver the same item.']});
        }
        var num_attached_delivery = await client.collection("Open_Orders").countDocuments({delivery_boy: delivery_record.username}).catch((error) => console.log(error));

        if(num_attached_delivery >= 3){
            db.close();
            return JSON.stringify({result: false, response: ['Maximum orders for: ' + delivery_record.username + ' is 3.']});
        }

        // Make sure no orders are being waited upon.
        var num_current_orders = await client.collection("Open_Orders").countDocuments({creator: delivery_record.username}).catch((error) => console.log(error));
        if(num_current_orders != 0){
            db.close();
            return JSON.stringify({result: false, response: ['Delivery user has a pending order. Cancel before delivering.']});
        }

        let orderInfo = {$set: {time: order_record.time, beverage: order_record.beverage, size: order_record.size, restaurant: order_record.restaurant, library: order_record.library, floor: order_record.floor, segment: order_record.segment, cost: order_record.cost, creator: order_record.creator, delivery_boy: delivery_record.username}};
        var response = await client.collection("Open_Orders").updateOne({_id: ObjectId(order_id)}, orderInfo).catch((error) => console.log(error));

        db.close();

        return JSON.stringify({result: true, response: ['Delivery user on route to deliver ('+(1+num_attached_delivery)+'/3)']});

    },
    detachOrder: async function(order_id, delivery_id){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var order_record = await client.collection('Open_Orders').findOne({_id: ObjectId(order_id)}).catch((error) => console.log(error));
        
        if(order_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['Order does not exist.']});
        }
        var delivery_order = await client.collection('User').findOne({_id: ObjectId(delivery_id)}).catch((error) => console.log(error));
        
        if(delivery_order == null){
            db.close();
            return JSON.stringify({result: false, response: ['Delivery user does not exist.']});
        }
        if(!delivery_order.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['Delivery user must be logged in to cancel delivery.']});
        }
        if(order_record.delivery_boy == null){
            db.close();
            return JSON.stringify({result: false, response: ['No assigned delivery users.']});
        }
        if(delivery_order.username != order_record.delivery_boy){
            db.close();
            return JSON.stringify({result: false, response: ['Only the delivery user can cancel a delivery.']});
        }
        
        response = await detachOrderFromDelivery(order_record, client);
        db.close();

        return JSON.stringify({result: true, response: response});
    },
    completeOrder: async function(delivery_rating, order_id, user_id, delivery_id){
        
        if(delivery_rating < 0 || delivery_rating > 5){
            db.close();
            return JSON.stringify({result: false, response: ['Please give a rating between 0 and 5.']});
        }
        
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var order_record = await client.collection('Open_Orders').findOne({_id: ObjectId(order_id)}).catch((error) => console.log(error));
        
        if(order_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['Order does not exist.']});
        }
        if(order_record.delivery_boy == null){
            db.close();
            return JSON.stringify({result: false, response: ['Cannot complete an order if no delivery person is assigned.']});
        }

        if(order_record.status !== "Delivered"){
            db.close();
            return JSON.stringify({result: false, response: ['Please update the order status to "Delivered".']});
        }

        var user_record = await client.collection('User').findOne({_id: ObjectId(user_id)}).catch((error) => console.log(error));

        if(user_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }
        if(!user_record.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['Orderer must be logged in to complete a transaction.']});
        }
        if(user_record.balance < order_record.cost){
            db.close();
            return JSON.stringify({result: false, response: ['User does not have enough funds.']});
        }
        if(order_record.creator != user_record.username){
            db.close();
            return JSON.stringify({result: false, response: ['User did not create the order.']});
        }
        var delivery_record = await client.collection('User').findOne({_id: ObjectId(delivery_id)}).catch((error) => console.log(error));

        if(delivery_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }
        if(!delivery_record.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['Delivery user has to be logged in to complete order.']});
        }
        if(order_record.delivery_boy != delivery_record.username){
            db.close();
            return JSON.stringify({result: false, response: ['Delivery user does not exist.']});
        }

        // Check if transaction is correct
        checkCorruptUser = await checkIfCorrupt('payment', client, user_record, order_record.cost);
        if(!checkCorruptUser[0]){
            db.close();
            return checkCorruptUser;
        }
        // If delivery person is corrupt
        checkCorruptDelivery = await checkIfCorrupt('payment', client, delivery_record, order_record.cost);
        if(!checkCorruptDelivery[0]){
            await detachOrderFromDelivery(order_record, client);
            db.close();
            return checkCorruptDelivery;
        }

        var newUserValue = parseFloat(checkCorruptUser[1]) - parseFloat(order_record.cost); 
        var newDeliveryValue = parseFloat(checkCorruptDelivery[1]) + parseFloat(order_record.cost) 

        // Create transaction - balance for user
        let transactionInfo = {type: 'payment', time_created: new Date().toJSON(), transaction_value: order_record.cost, payer_name: user_record.username, payer_balance: {new_balance: newUserValue, previous_balance: user_record.balance}, payee_name: delivery_record.username, payee_balance: {new_balance: newDeliveryValue, previous_balance: delivery_record.balance}};
        var transaction_history = await client.collection("Transaction").insertOne(transactionInfo);

        // Update user information
        let payerInformation = {$set: {balance: newUserValue}};
        var response = await client.collection("User").updateOne({_id: ObjectId(user_id)}, payerInformation).catch((error) => console.log(error)); 
        
        let deliveryInformation = {$set: {balance: newDeliveryValue}};
        var response = await client.collection("User").updateOne({_id: ObjectId(delivery_id)}, deliveryInformation).catch((error) => console.log(error)); 
        
        let closedInfo = {time_closed: new Date().toJSON(), time_opened: order_record.time, payer: order_record.creator, payee: order_record.delivery_boy, transaction: {cost: order_record.cost, transaction_id: transaction_history.ops[0]._id}, rating: delivery_rating};
        var closed_order = await client.collection("Closed_Orders").insertOne(closedInfo);

        // Delete open order
        var o_response = await client.collection("Open_Orders").deleteOne({_id: ObjectId(order_id)}).catch((error) => console.log(error)); 
        db.close(); 
        
        return JSON.stringify({result: true, response: ['Successfully completed transaction.']});
    },

    getDeliveryRating: async function(delivery_id){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var delivery_record = await client.collection('User').findOne({_id: ObjectId(delivery_id)}).catch((error) => console.log(error));
        if(delivery_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['No delivery user exists.']});
        }

        var username = delivery_record.username;
        var close_orders_array = await client.collection('Closed_Orders').find({payee: username}).toArray();
        if(close_orders_array.length == 0){
            db.close();
            return JSON.stringify({result: false, response: ['No ratings for this user.']});
        }

        var cumulated_score = 0;
        for (var i = 0; i < close_orders_array.length; i++){
            cumulated_score += parseFloat(close_orders_array[i].rating);
        }
        db.close();

        let score = cumulated_score/parseFloat(close_orders_array.length);
        return [true, score];
    },
    // Check if user credentials are unique
    checkIfUnique: async function(number, input){

        // 1 == username
        // 2 == password
        // 3 == email 
        // 4 == phone number

        if (number == 1){
            return checkIfInputIsUnique('username', input);
        } else if(number == 2){
            return checkIfInputIsUnique('password', input);
        } else if(number == 3){
            return checkIfInputIsUnique('email', input);
        } else {
            return checkIfInputIsUnique('phone_number', input);
        }
    },
    login: async function(email, password){
        // Is user logged in
        var loggedIn = await loginWithCred(email, password);
        return loggedIn;
    },
    logout: async function(id){
        // Is user logged in
        var loggedOut = await logoutWithCred(id);
        return loggedOut;
    },
    // Only admin privilege
    cleanFlagged: async function(user_id){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var user_record = await client.collection("User").findOne({ _id: ObjectId(user_id)}).catch((error) => console.log(error));
        
        if(user_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }
        if(!user_record.flagged){
            db.close();
            return JSON.stringify({result: false, response: ['User not flagged.']});
        }

        // Delete flagged transaction.
        var flagged_hist = await client.collection("Transaction").deleteOne({$or: [{username: user_record.username}, {payer_name: user_record.username}, {payee_name: user_record.username}], flagged: true});
        
        // Get last updated, clean transaction.
        var transaction_history = await client.collection("Transaction").find({$or: [{username: user_record.username}, {payer_name: user_record.username}, {payee_name: user_record.username}]}).sort({$natural: -1}).limit(1).toArray();    
        
        var previous_balance = 0;

        if (transaction_history.length != 0) {
            previous_balance = getPreviousValue(transaction_history, user_record);
        }

        let personInfo = {$set: {loggedIn: false, flagged: false}};
        var response = await client.collection("User").updateOne({_id: ObjectId(user_id)}, personInfo).catch((error) => console.log(error)); 
        db.close();

        return JSON.stringify({result: true, response: ['Account: ' + user_record.username + ' has been reactivated.']});
    },
    getOrderStatus: async function(order_id){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var statusValue = await client.collection("Open_Orders").distinct("status", {_id: ObjectId(order_id)});
        
        if(statusValue == null || statusValue.length == 0){
            db.close();
            return JSON.stringify({result: false, response: ['Order does not exist.']});
        }

        db.close();
        return JSON.stringify({result: true, response: [statusValue[0]]});
    },

    // *********************************** GET BEVERAGES **************************************
    getVendors: async function(){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(pName);
        var arrayOfVendors = await client.collection("ProductInformation").distinct("vendor");

        return JSON.stringify({result: true, response: arrayOfVendors});
    },
    getBeveragesInfoFromVendor: async function(vendor){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(pName);

        // Master stores all information about beverages
        var response = await client.collection("ProductInformation").findOne({vendor: 'master'});

        return JSON.stringify({result: true, response: [response.information[vendor].beverages, response.information[vendor].size]});
    },
    getBeveragesOfBevAndVendor: async function(vendor, beverage){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(pName);
        var arrayOfSizes = await client.collection("ProductInformation").distinct('size', {vendor: vendor,  beverage: beverage});

        return JSON.stringify({result: true, response: arrayOfSizes});
    },
    getBeveragePrice: async function(vendor, beverage, size){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(pName);
        var Order_Information = await client.collection("ProductInformation").findOne({vendor: vendor, beverage: beverage, size: size});

        if(Order_Information == null){
            db.close();
            return JSON.stringify({result: false, response: ['That order does not exist.']});
        }
        return JSON.stringify({result: true, response: [Order_Information.cost.toString()]});
    },
    getLibraryInformation: async function(){
        var db = await MongoClient.connect(uri, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(pName);

        var libraryInformation = await client.collection("LocationInformation").findOne();
        return JSON.stringify({result: true, response: [libraryInformation.Libraries]});
    }
};

async function detachOrderFromDelivery(order_record, client){
    
    let orderInfo = {$set: {delivery_boy: null}};
    var response = await client.collection('Open_Orders').updateOne({_id: ObjectId(order_record._id)}, orderInfo).catch((error) => console.log(error));
    return JSON.stringify({result: true, response: ['Detached successfully.']});
}
