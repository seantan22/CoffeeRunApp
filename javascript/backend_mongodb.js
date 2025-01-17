const MongoClient = require('mongodb').MongoClient;
const ObjectId = require('mongodb').ObjectId;
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const cred = require('./cred');
const crypto = require('crypto');
const Filter = require('bad-words');

const dbName = 'CoffeeRun';
const pName = 'Products';
const sName = 'Statistics';

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
        } else if(transaction_history[0].type == 'new_account'){
            return previous_balance;
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
        await client.collection("User").updateOne({_id: ObjectId(user_record._id)}, personInfo).catch((error) => console.log(error)); 
        
        await client.collection("Transaction").insertOne({flagged: true, type: type, time_created: getCurrentDateTimeZone(), transaction_value: funds, username: user_record.username, balance: {expected_balance: previous_balance, corrupt_balance: user_record.balance}});

        return JSON.stringify({result: false, response: ['Your balance is incorrect and has been flagged.']});
    }

    return [true, previous_balance];
}

async function checkIfInputIsUnique(key, value){
    var existence = false;
    
    var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
    var client = db.db(dbName);
    
    var record = await client.collection("User").findOne({ [key]: value }).catch((error) => console.log(error));
    
    if (record != null) {
        existence = true;
    } 
    db.close();

    return existence;
}

async function loginWithCred(email, password){
    var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
    var client = db.db(dbName);
    
    var record = await client.collection("User").findOne({ email: email.toLowerCase() }).catch((error) => console.log(error));
    
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
    if(!(await bcrypt.compare(password, record.password))){
        db.close();
        return JSON.stringify({result: false, response: ['Password is incorrect.']});
    }

    // Check if in reset state
    var reset_record = await client.collection("Reset_Records").findOne({ email: email.toLowerCase(), active: true }).catch((error) => console.log(error));

    // Reset state
    if(reset_record != null && reset_record.active){
        db.close();
        return JSON.stringify({result: true, response: [record._id, record.username, record.verified.toString(), 'reset']});
    }

    if(record.verified){
        let updatedInfo = {$set: {loggedIn: true}};
        // Update
        var response = await client.collection("User").updateOne({password: record.password}, updatedInfo).catch((error) => console.log(error)); 
    }
    
    db.close();

    // Login returns this.
    return JSON.stringify({result: true, response: [record._id, record.username, record.verified.toString()]});
}

async function logoutWithCred(id){

    var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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
    await client.collection("User").updateOne({_id: ObjectId(id)}, updatedInfo).catch((error) => console.log(error)); 
    db.close();

    return JSON.stringify({result: true, response: ['Successfully logged out.']});
}

module.exports = {
    getTest: async function(test){
        return getCurrentDateTimeZone()
    },

    getTaxRates: async function(){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var tax_records = await client.collection("Rates").findOne({Title: 'rates'}).catch((error) => console.log(error));
        
        db.close();

        // Delivery fee, GST, QST
        return JSON.stringify({result: true, response: [tax_records.Delivery_Fee, tax_records.GST, tax_records.QST]});

    },
    forgetPassword: async function(email){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var user_record = await client.collection("User").findOne({email: email.toLowerCase()}).catch((error) => console.log(error));
        
        if(user_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }

        if(user_record.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['You can only reset your password when logged out.']});
        }

        // Check if reset has already been sent.
        var reset_record = await client.collection("Reset_Records").findOne({email: email}).catch((error) => console.log(error));

        if(reset_record != null && reset_record.active) {
            db.close();
            return JSON.stringify({result: false, response: ['You already have a pending reset.']});
        }

        // Create an instance with an id of the password
        let passwordResetInstance = {active: true, email: email, time: getCurrentDateTimeZone()};
        await client.collection("Reset_Records").insertOne(passwordResetInstance).catch((error) => console.log(error)); 

        new_pass = await sendForgetPasswordEmail(email, user_record._id);
        let hashPassword = await bcrypt.hash(new_pass, await bcrypt.genSalt(5));

        // Update the password in the database.
        updateInfo = {$set: {password: hashPassword}}
        await client.collection("User").updateOne({_id: user_record._id}, updateInfo).catch((error) => console.log(error)); 
    
        db.close();
        return JSON.stringify({result: true, response: ['An email has been sent to your account.']});
    },
    updatePasswordFromReset: async function(email, new_password){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var reset_record = await client.collection("Reset_Records").findOne({email: email, active: true}).catch((error) => console.log(error));

        if(reset_record == null){
            db.close();
            return JSON.stringify({result: false, response: ["Reset hasn't been called."]});;
        }
        if(!reset_record.active){
            db.close();
            return JSON.stringify({result: false, response: ["Reset has already been made."]})
        }
    
        let hashPassword = await bcrypt.hash(new_password, await bcrypt.genSalt(8));
       
        let personInfo = {$set: {password: hashPassword}};
        await client.collection("User").updateOne({email: email}, personInfo).catch((error) => console.log(error)); 
        var user_record = await client.collection("User").findOne({email: email}, personInfo);

        // Resend email if not verified.
        if(!user_record.verified){
            sendEmailNotVerified(email, user_record.verification_number);
        }

        // Log user in when they update password
        let resetInfo = {$set: {active: false}};
        await client.collection("Reset_Records").updateOne({email: email, active: true}, resetInfo).catch((error) => console.log(error)); 
        
        db.close();     
        return JSON.stringify({result: true, response: ["Successfully updated."]});;
    },
    getOrdersByLibrary: async function(library){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        number_of_orders = await client.collection("Open_Orders").countDocuments({library: library});
        db.close();
        return JSON.stringify({result: true, response: number_of_orders});
    },
    getNumberOfAllOpenOrders: async function(){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        number_of_orders = await client.collection("Open_Orders").countDocuments({delivery_boy: ""});
        db.close();
        return JSON.stringify({result: true, response: number_of_orders.toString()});
    },
    getCurrentRunners: async function(){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        
        // Get all unique runners.
        array_of_unique_runners = await client.collection("Open_Orders").distinct("delivery_boy");
        db.close();
        return JSON.stringify({result: true, response: array_of_unique_runners.length});
    },
    makeReview: async function(username, review){
        var db = await MongoClient.connect(urclient.collection.distincti, { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        let reviewInfo = {time: getCurrentDateTimeZone(), username: username, review: review};
        await client.collection("Reviews").insertOne(reviewInfo);
        db.close();
        return JSON.stringify({result: true, response: ['Thank you for your review.']});
    },
    verifyUser: async function(id, verification_number){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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

        // Get balance of user if existed before
        var transaction_history = await client.collection("Transaction").find({$or: [{username: record.username}, {payer_name: record.username}, {payee_name: record.username}]}).sort({$natural: -1}).limit(1).toArray();
        var previous_value = getPreviousValue(transaction_history, record)

        let personInfo = {$set: {balance: previous_value, verified: true, loggedIn: true}}; // Update
        await client.collection("User").updateOne({_id: ObjectId(record._id)}, personInfo).catch((error) => console.log(error)); 
        
        db.close();

        // Login already returns JSON format
        return JSON.stringify({result: true, response: ['Sueccessfully verified.']});
    },

    // ************************************** USER ***************************************

    getUser: async function(id){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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
        
        var score = await getDeliveryRating(id, client);
        var value = 0.0;

        if (score[0]) {
            value = score[1];
        }

        db.close();

        var totalSum = await getTotalOnLogin(record.username);

        return ({result: true, response: [record.username, record.email, record.balance.toString(), totalSum.toString(), value.toString()]}); 
    },
    getUsers: async function(current_user){

        var username_array = [];
        var username = "";
        var slice_1 = [];
        var slice_2 = [];
        var added = false;

        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var record_response = await client.collection("User").find().toArray();

        // Get all requests and pending for display of users
        var followRequestArray = await getAllRecordsForUser(current_user, client);
        var dictionary = {};
        var result = "";

        db.close();

        // Process through info and store in dictionary for easy search.
        for (var i = 0; i < followRequestArray.length; i++){
            record = followRequestArray[i];

            if(record.sender == current_user){
                dictionary[record.receiver] = record.confirmation.toString();
            } else {
                dictionary[record.sender] = record.confirmation.toString();
            }
        }

        // Organize return array.
        for (var i = 0; i < record_response.length; i++) {
            username = record_response[i]['username'];

            // Check if friendship has been made.
            // True -> friends
            // False -> pending
            // undefined -> nothing
            if(dictionary[username] == "true"){
                result = 'friends';
            } else if (dictionary[username] == "false"){
                result = 'pending';
            } else {
                result = 'nothing';
            }

            if(username == current_user){
                continue;
            }

            added = false;
            if (username_array.length == 0){
                username_array.push([username, result]);
            } else {
                
                for (var inner = 0; inner < username_array.length; inner ++){

                    if(username < username_array[inner]){
                        if(inner == 0){
                            slice_1 = username_array;
                            username_array = [[username, result]].concat(slice_1);
                        } else {
                            slice_1 = username_array.slice(0, inner);
                            slice_2 = username_array.slice(inner, username_array.length);
                            username_array = slice_1.concat([[username, result]].concat(slice_2));
                        }
                        added = true;
                        break;
                    }
                }
                if(!added){
                    slice_1 = username_array;
                    username_array = slice_1.concat([[username, result]]);
                }
            }
        }

        return JSON.stringify({result: true, response: username_array}); 
    },
    addUser: async function(username, password, mail, number){
        var starting_balance = 0;
        var filter = new Filter(); 

        if (filter.isProfane(username)) {
            return JSON.stringify({result: false, response: ["Inappropriate language detected."]});      
        }

        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        verification_code = Math.floor(100000 + Math.random() * 899999);
            
        // Encrypt password.
        var saltRounds = 9;

        let hashPassword = await bcrypt.hash(password, await bcrypt.genSalt(saltRounds));

        var email = mail.toLowerCase();

        let personInfo = {username: username.toLowerCase(), password: hashPassword, email: email, phone_number: number, loggedIn: false, balance: starting_balance, flagged: false, verified: false, verification_number: verification_code};
        var response = await client.collection("User").insertOne(personInfo);
        
        sendEmail(mail, verification_code);
        db.close();

        return JSON.stringify({result: true, response: [response.ops[0]._id]});      
    },
    updateUser: async function(id, username, password){
        var hasUpdated = false;

        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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
        response = await client.collection("User").updateOne({_id: ObjectId(id)}, personInfo).catch((error) => console.log(error)); 
        console.log(response);
        
        db.close();
    
        return JSON.stringify({result: true, response: ['Successfully updated credentials.']});

    },
    deleteUser: async function(id){
        
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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

        await client.collection("User").deleteOne({_id: ObjectId(id)}).catch((error) => console.log(error)); 
        db.close();

        return JSON.stringify({result: true, response: ['Successfully deleted.']});

    },

    // WITHDRAW AND DEPOSIT USES CUSTOMER LEDGER
    withdraw: async function(user_id, funds){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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
        // Withdraw limit: Once every 48 hours - 2 days
        var withdraw_record_history = await client.collection("Transaction").find({username: user_record.username, type: "withdraw"}).sort({$natural: -1}).limit(1).toArray()
        
        // Previous withdrawals
        if (withdraw_record_history.length != 0){
            time_limit = 24;

            time_since = withdraw_record_history[0].time_created;
            current_time = getCurrentDateTimeZone();

            difference = Math.abs(current_time - time_since) / 36e5;
            if(difference < time_limit){

                db.close();
                if(difference > 23){
                    return JSON.stringify({result: false, response: ['You can withdraw again in ' + Math.round(24 - difference) + ' hour.']});
                }
 
                return JSON.stringify({result: false, response: ['You can withdraw again in ' + Math.round(24 - difference) + ' hours.']});
                
            }
        }
       
        //Cannot withdraw if you have an order.
        var order_record = await client.collection("Open_Orders").findOne({creator: user_record.username}).catch((error) => console.log(error));

        if(order_record != null){
            db.close();
            return JSON.stringify({result: false, response: ['Cannot withdraw funds when you have a pending order.']});
        }

        if(funds <= 0.00 || funds > user_record.balance){
            db.close();
            return JSON.stringify({result: false, response: ['Please withdraw between $0.00 and $' + user_record.balance + '.']});
        }
        if(funds > user_record.balance){
            db.close();
            return JSON.stringify({result: false, response: ['You do not enough enough funds to withdraw: ' + funds]});
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
        var rounded_balance = parseFloat(final_balance).toFixed(2);

        let personInfo = {$set: {balance: rounded_balance}};
        await client.collection("User").updateOne({_id: ObjectId(user_id)}, personInfo).catch((error) => console.log(error)); 

        // Create transaction of record.
        let transactionInfo = {flagged: false, type: 'withdraw', time_created: getCurrentDateTimeZone(), amount_drawn: funds, username: user_record.username, balance: {new_balance: rounded_balance, previous_balance: user_record.balance}};
        await client.collection("Transaction").insertOne(transactionInfo);
        db.close();

        return JSON.stringify({result: true, response: ['' + parseFloat(rounded_balance)]});
    },
    deposit: async function(user_id, funds){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var user_record = await client.collection("User").findOne({ _id: ObjectId(user_id) }).catch((error) => console.log(error));

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
        if(funds <= 5.00 || funds > 50.00){
            db.close();
            return JSON.stringify({result: false, response: ['Please deposit between $5.00 and $50.00.']});
        }

         // Deposit limit: Once every 24 hours - 1 days
         var deposit_record_history = await client.collection("Transaction").find({username: user_record.username, type: "deposit"}).sort({$natural: -1}).limit(1).toArray()
        
         // Previous withdrawals
         if (deposit_record_history.length != 0){
             time_limit = 24;
 
             time_since = deposit_record_history[0].time_created;
             current_time = getCurrentDateTimeZone();
 
             difference = Math.abs(current_time - time_since) / 36e5;
             if(difference < time_limit){
 
                 db.close();
                 if(difference > 23){
                    return JSON.stringify({result: false, response: ['You can deposit again in ' + Math.round(24 - difference) + ' hour.']});
                 }

                 return JSON.stringify({result: false, response: ['You can deposit again in ' + Math.round(24 - difference) + ' hours.']});
             
             }
         }

        checkCorrupt = await checkIfCorrupt('deposit', client, user_record, funds);
        if(!checkCorrupt[0]){
            db.close();
            return checkCorrupt;
        }

        var final_balance = parseFloat(checkCorrupt[1]) + parseFloat(funds);
        var rounded_balance = parseFloat(final_balance).toFixed(2);

        let personInfo = {$set: {balance: rounded_balance}};
        await client.collection("User").updateOne({_id: ObjectId(user_id)}, personInfo).catch((error) => console.log(error)); 

        // Create transaction of record.
        let transactionInfo = {flagged: false, type: 'deposit', time_created: getCurrentDateTimeZone(), amount_deposited: funds, username: user_record.username, balance: {new_balance: rounded_balance, previous_balance: user_record.balance}};
        await client.collection("Transaction").insertOne(transactionInfo);
        db.close();

        return JSON.stringify({result: true, response: ['' + parseFloat(rounded_balance)]});
    },

    // ************************************** ORDER ***************************************

    createOrder: async function(beverage, size, details, restaurant, library, floor, segment, cost, status, id){

        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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

        var tax_rates = await client.collection('Rates').findOne({Title: 'rates'}).catch((error) => console.log(error));

        var GSTtaxP = tax_rates.GST;
        var QSTtaxP = tax_rates.QST;
        var TotalTax = parseFloat(GSTtaxP) + parseFloat(QSTtaxP);
        
        var DFP = tax_rates.Delivery_Fee;

        // Round to 2 decimal places
        var delivery_charge = parseFloat(cost) * parseFloat(DFP) + 1.00;
        
        var taxed_charge = parseFloat(cost) * parseFloat(TotalTax);
        
        var tip_charge =  parseFloat(cost) * 0.20;

        var final_cost = Math.round((parseFloat(cost) + delivery_charge + taxed_charge + tip_charge) * 100) / 100;

        // Highest tip% 25%. Tax in quebec: GST: 5%, QST: 9.975%
        if(parseFloat(record.balance) < final_cost){
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

        let personInfo = {  time: getCurrentDateTimeZone(), 
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
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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

        await client.collection("Open_Orders").updateOne({_id: ObjectId(id)}, orderInfo).catch((error) => console.log(error));

        db.close();

        return JSON.stringify({result: true, response: ['Order successfully updated.']});
    },
    updateOrderStatus: async function(order_id, delivery_id, status) {
        var db = await MongoClient.connect(cred.getMongoUri(), {useUnifiedTopology: true }).catch((error) => console.log(error));
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
        await client.collection("Open_Orders").updateOne({_id: ObjectId(order_id)}, statusInfo).catch((error) => console.log(error));

        db.close()

        return JSON.stringify({result: true, response: ['Order status successfully updated to: ' + status]});

    },
    deleteOrder: async function(id, username){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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
        if(record.delivery_boy != ""){
            db.close();
            return JSON.stringify({result: false, response: ['Cannot delete order as it is being delivered.']});
        }

        await client.collection("Open_Orders").deleteOne({_id: ObjectId(id)}).catch((error) => console.log(error)); 
        db.close();

        return JSON.stringify({result: true, response: ['Successfully deleted order.']});
    },
    getOrderForUser: async function(id){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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

        db.close();

        return JSON.stringify({result: true, response: order_records});
    },
    getClosedOrders: async function(id){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        // Check if user exists.
        var record = await client.collection("User").findOne({_id: ObjectId(id)}).catch((error) => console.log(error));
        
        if(record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }
        var username = record.username;

        var order_records = await client.collection("Closed_Orders").find({payer: username}).toArray();
        var delivery_records = await client.collection("Closed_Orders").find({payee: username}).toArray();
        db.close();

        repurposedOrder = reformatClosedOrder(order_records.reverse());
        repurposedDelivery = reformatClosedOrder(delivery_records.reverse());
        
        return JSON.stringify({result: true, response: [repurposedOrder, repurposedDelivery]});
   
    },
    getOrdersForDelivery: async function(id){

        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        // Check if user exists.
        var delivery_record = await client.collection("User").findOne({_id: ObjectId(id)}).catch((error) => console.log(error));
        
        if(delivery_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }

        var username = delivery_record.username;

        var order_records = await client.collection("Open_Orders").find({delivery_boy: username}).toArray();

        var return_record = getTimeSince(order_records);
        db.close();

        return JSON.stringify({result: true, response: attachFriendToOrderArray(return_record)});
    },
    getAllOpenOrders: async function(username){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        
        var friend_list = await getAllFriends(username, client);
        var friend_dictionary = {}

        friend_list.forEach(function(friend){
            friend_dictionary[friend] = true
        })
        
        var order_records = await client.collection("Open_Orders").find({delivery_boy: ""}).toArray();
        db.close();

        var return_record = getTimeSince(order_records);

        return_record.forEach(function(order){

            order.friends = (order.creator in friend_dictionary).toString();

        });

        return JSON.stringify({result: true, response: return_record});
    },
    attachOrder: async function(order_id, delivery_id){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        
        // Check if users exists.
        var order_record = await client.collection("Open_Orders").findOne({_id: ObjectId(order_id)}).catch((error) => console.log(error));
                
        if(order_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['Order does not exist.']});
        }
        if(order_record.delivery_boy != ""){
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

        let orderInfo = {$set: {time: order_record.time, beverage: order_record.beverage, size: order_record.size, restaurant: order_record.restaurant, library: order_record.library, floor: order_record.floor, segment: order_record.segment, cost: order_record.cost, status: 'In Progress', creator: order_record.creator, delivery_boy: delivery_record.username}};
        await client.collection("Open_Orders").updateOne({_id: ObjectId(order_id)}, orderInfo).catch((error) => console.log(error));

        db.close();

        return JSON.stringify({result: true, response: ['Delivery user on route to deliver ('+(1+num_attached_delivery)+'/3)']});

    },
    detachOrder: async function(order_id, delivery_id){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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
        if(order_record.delivery_boy == ""){
            db.close();
            return JSON.stringify({result: false, response: ['No assigned delivery users.']});
        }
        if(delivery_order.username != order_record.delivery_boy){
            db.close();
            return JSON.stringify({result: false, response: ['Only the delivery user can cancel a delivery.']});
        }
        if(order_record.status != 'In Progress'){
            db.close();
            return JSON.stringify({result: false, response: 'Cannot detach if order has been picked up'})
        }
        
        response = await detachOrderFromDelivery(order_record, client);
        db.close();

        return JSON.stringify({result: true, response: response});
    },
    completeOrder: async function(rating, order_id, user_id, delivery_username, cost, tip){
                
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        if(rating < 0 || rating > 5){
            db.close();
            return JSON.stringify({result: false, response: ['Please give a rating between 0 and 5.']});
        }

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
            return JSON.stringify({result: false, response: ['Orderer does not exist.']});
        }
        if(!user_record.loggedIn){
            db.close();
            return JSON.stringify({result: false, response: ['Orderer must be logged in to complete a transaction.']});
        }
        if(order_record.creator != user_record.username){
            db.close();
            return JSON.stringify({result: false, response: ['User did not create the order.']});
        }

        var delivery_record = await client.collection('User').findOne({username: delivery_username}).catch((error) => console.log(error));

        if(delivery_record == null){
            db.close();
            return JSON.stringify({result: false, response: ['Delivery person does not exist.']});
        }
        if(order_record.delivery_boy != delivery_record.username){
            db.close();
            return JSON.stringify({result: false, response: ['Delivery user is not assigned to that order.']});
        }

        // Check if transaction is correct
        checkCorruptUser = await checkIfCorrupt('payment', client, user_record, cost);
        if(!checkCorruptUser[0]){
            db.close();
            return checkCorruptUser;
        }
        // If delivery person is corrupt
        checkCorruptDelivery = await checkIfCorrupt('payment', client, delivery_record, cost);
        if(!checkCorruptDelivery[0]){
            await detachOrderFromDelivery(order_record, client);
            db.close();
            return checkCorruptDelivery;
        }

        // Get db tax
        var tax_rates = await client.collection('Rates').findOne({Title: 'rates'}).catch((error) => console.log(error));
        var GSTtaxP = tax_rates.GST;
        var QSTtaxP = tax_rates.QST;
        var TotalTax = parseFloat(GSTtaxP) + parseFloat(QSTtaxP);
       
        var DFP = tax_rates.Delivery_Fee;
 
        // Round to 2 decimal places - $1.00 flat fee + 0.29%
        var delivery_charge = Math.round(parseFloat(cost) * parseFloat(DFP) * 100) / 100 + 1.00;        
        var taxed_charge = parseFloat(cost) * parseFloat(TotalTax);        
        var tip_charge =  parseFloat(cost) * parseFloat(tip);
        var final_cost = Math.round((parseFloat(cost) + taxed_charge + tip_charge) * 100) / 100;

        var newUserValue = parseFloat(checkCorruptUser[1]) - final_cost - delivery_charge; 
        var newDeliveryValue = parseFloat(checkCorruptDelivery[1]) + final_cost;

        var roundedNewUser = Math.round(newUserValue*100)/100;
        var roundedNewDelivery = Math.round(newDeliveryValue*100)/100;

        // Create transaction - balance for user
        let transactionInfo = {type: 'payment', time_created: getCurrentDateTimeZone(), transaction_value: final_cost, payer_name: user_record.username, payer_balance: {new_balance: roundedNewUser, previous_balance: user_record.balance}, payee_name: delivery_record.username, payee_balance: {new_balance: roundedNewDelivery, previous_balance: delivery_record.balance}};
        var transaction_history = await client.collection("Transaction").insertOne(transactionInfo);

        // Update user information
        let payerInformation = {$set: {balance: roundedNewUser}};
        await client.collection("User").updateOne({_id: ObjectId(user_id)}, payerInformation).catch((error) => console.log(error)); 
        
        let deliveryInformation = {$set: {balance: roundedNewDelivery}};
        await client.collection("User").updateOne({username: delivery_username}, deliveryInformation).catch((error) => console.log(error)); 
        
        let closedInfo = {time_closed: getCurrentDateTimeZone(), time_opened: order_record.time, payer: order_record.creator, payee: order_record.delivery_boy, transaction: {final: final_cost, subtotal: parseFloat(cost), tax:  Math.round(taxed_charge*100)/100, tip: Math.round(tip_charge*100)/100, delivery_fee: Math.round(delivery_charge*100)/100, transaction_id: transaction_history.ops[0]._id}, rating: rating, size: order_record.size, beverage: order_record.beverage, vendor: order_record.restaurant};
        await client.collection("Closed_Orders").insertOne(closedInfo);

        // Delete open order
        await client.collection("Open_Orders").deleteOne({_id: ObjectId(order_id)}).catch((error) => console.log(error)); 
        db.close(); 

        // Update delivery fee.
        await updateAdminFees(delivery_charge);
        
        return JSON.stringify({result: true, response: ['Successfully completed transaction.']});
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
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
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
        await client.collection("Transaction").deleteOne({$or: [{username: user_record.username}, {payer_name: user_record.username}, {payee_name: user_record.username}], flagged: true});
        
        // Get last updated, clean transaction.
        var transaction_history = await client.collection("Transaction").find({$or: [{username: user_record.username}, {payer_name: user_record.username}, {payee_name: user_record.username}]}).sort({$natural: -1}).limit(1).toArray();    
        
        var previous_balance = 0;

        if (transaction_history.length != 0) {
            previous_balance = getPreviousValue(transaction_history, user_record);
        }

        let personInfo = {$set: {loggedIn: false, flagged: false}};
        await client.collection("User").updateOne({_id: ObjectId(user_id)}, personInfo).catch((error) => console.log(error)); 
        db.close();

        return JSON.stringify({result: true, response: ['Account: ' + user_record.username + ' has been reactivated.']});
    },
    getOrderStatus: async function(order_id){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var statusValue = await client.collection("Open_Orders").findOne({_id: ObjectId(order_id)});

        if(statusValue == null){
            db.close();
            return JSON.stringify({result: false, response: ['Order does not exist.']});
        }

        db.close();
        return JSON.stringify({result: true, response: [statusValue.status, statusValue.delivery_boy]});
    },

    // *********************************** GET BEVERAGES **************************************
    getVendors: async function(){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(pName);
        var arrayOfVendors = await client.collection("ProductInformation").distinct("vendor");

        db.close();

        return JSON.stringify({result: true, response: arrayOfVendors});
    },
    getBeveragesInfoFromVendor: async function(vendor){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(pName);

        // Master stores all information about beverages
        var response = await client.collection("ProductInformation").findOne({vendor: 'master'});

        db.close();
        return JSON.stringify({result: true, response: [response.information[vendor].beverages, response.information[vendor].size]});
    },
    getBeveragesOfBevAndVendor: async function(vendor, beverage){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(pName);
        var arrayOfSizes = await client.collection("ProductInformation").distinct('size', {vendor: vendor,  beverage: beverage});

        db.close();

        return JSON.stringify({result: true, response: arrayOfSizes});
    },
    getBeveragePrice: async function(vendor, beverage, size){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(pName);
        var Order_Information = await client.collection("ProductInformation").findOne({vendor: vendor, beverage: beverage, size: size});

        if(Order_Information == null){
            db.close();
            return JSON.stringify({result: false, response: ['That order does not exist.']});
        }

        db.close();
        return JSON.stringify({result: true, response: [Order_Information.cost.toString()]});
    },
    getLibraryInformation: async function(){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(pName);

        var libraryInformation = await client.collection("LocationInformation").findOne();

        db.close();
        return JSON.stringify({result: true, response: [libraryInformation.Libraries]});
    },
    getFriendOrders: async function(username){

        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var friend_list = JSON.parse(await getAllFriends(username, client));
        var order_list = [];
        var record;

        for (var i = 0; i < friend_list.length; i++){
            record = await client.collection("Open_Orders").findOne({creator: friend_list[i]});
            
            if(record != null){
                order_list += [record];
            }
        }      

        db.close();

        return JSON.stringify({result: true, response: order_list});
    },

    getNewBalanceAfterOrder: async function(user_id){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var user_information = await client.collection("User").findOne({_id: ObjectId(user_id)});
        
        if(user_information == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }
        
        db.close();

        return JSON.stringify({result: true, response: [user_information.balance.toString()]});
    },
    getTotalProfitMade: async function(username){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var sum = 0;
        var closed_order_info = await client.collection("Closed_Orders").find({payee: username}).toArray();
        
        if(closed_order_info.length == 0){
            db.close();
            return JSON.stringify({result: false, response: ['You have not made any profit.']});
        }

        var user_information = await client.collection("User").findOne({username: username});
        
        if(user_information == null){
            db.close();
            return JSON.stringify({result: false, response: ['User does not exist.']});
        }

        for (var i = 0; i < closed_order_info.length; i++){

            sum += Math.round(closed_order_info[i]['transaction']['tip'] * 100) / 100;

        }

        var score = await getDeliveryRating(user_information._id, client);
        var value = 0.0;
        if (score[0]) {
            value = score[1];
        }

        db.close();
        return JSON.stringify({result: true, response: [sum.toString(), user_information.balance.toString(), value.toString()]});
    },
    doesOrderExistForDelivery: async function(order_id){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);
        var orderStatus = await client.collection("Open_Orders").findOne({_id: ObjectId(order_id)});
        
        if(orderStatus == null){
            db.close();
            return JSON.stringify({result: false, response: ["false"]});
        }

        db.close();
        return JSON.stringify({result: true, response: ["true"]});

    },

    // ************************************* FOLLOWERS *****************************************

    followUser: async function(sender, receiver){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var hash = await createHash(sender, receiver);

        var followerRequest = await client.collection("Friends").findOne({hash: hash});  

        // Check that no requests have already been sent
        if(followerRequest != null){

            if(followerRequest.confirmation){
                db.close();
                return JSON.stringify({result: false, response: ['Already friends.']}); 
            } else {
                db.close();
                return JSON.stringify({result: false, response: ['Friend request pending.']}); 
            }       

        }
        friendsResponse = {hash: hash, sender: sender, receiver: receiver, confirmation: false}
        await client.collection("Friends").insertOne(friendsResponse);

        db.close();
        return JSON.stringify({result: true, response: ['Request has been sent.']}); 

    },
    acceptUserFollowRequest: async function(acceptor, sender){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var hash = await createHash(acceptor, sender);

        var followerRequest = await client.collection("Friends").findOne({hash: hash});  
        
        if(followerRequest == null){
            db.close();
            return JSON.stringify({result: false, response: ['No pending requests.']});     
        }
                  
        if(followerRequest.confirmation){
            db.close();
            return JSON.stringify({result: false, response: ['You are already friends.']});  
        }
        
        var updatedRequest = {$set: {confirmation: true}};
        await client.collection("Friends").updateOne({hash: hash}, updatedRequest);
        db.close();
       
        return JSON.stringify({result: true, response: ['You are now friends with ' + sender]}); 
    },
    // Get all requests to current user
    getAllFollowerRequests: async function(user){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var returnArray = [];
        
        var followerRequests = await client.collection("Friends").find({confirmation: false, receiver: user}).toArray();  
        
        db.close();

        followerRequests.forEach(function(friendRequest){
            returnArray.push(friendRequest.sender);
        })
        
        return JSON.stringify({result: true, response: returnArray});
    },
    getAllFollowerPending: async function(user){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var returnArray = [];
        
        var followerRequests = await client.collection("Friends").find({confirmation: false, sender: user}).toArray();  
        
        db.close();

        followerRequests.forEach(function(friendRequest){
            returnArray.push(friendRequest.receiver);
        })
        
        return JSON.stringify({result: true, response: returnArray});
    },
    getAllFriends: async function(user){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var returnArray = [];
        var followerRequests = await client.collection("Friends").find({confirmation: true, $or: [{sender: user}, {receiver: user}]}).toArray();  
        
        db.close();

        followerRequests.forEach(function(friendRequest){

            if(friendRequest.sender == user){
                returnArray.push(friendRequest.receiver);
            } else {
                returnArray.push(friendRequest.sender);
            }

        })
        
        return JSON.stringify({result: true, response: returnArray});
    },
    deleteFriendship: async function(deleter, victim){
        var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
        var client = db.db(dbName);

        var hash = await createHash(deleter, victim);

        var deleteQuery = {hash: hash};
        await client.collection("Friends").deleteOne(deleteQuery);

        db.close();
        return JSON.stringify({result: true, response: ['Friendship has been deleted.']});
    },
};

async function getAllFriends(user, client){
    var returnArray = [];
    var followerRequests = await client.collection("Friends").find({confirmation: true, $or: [{sender: user}, {receiver: user}]}).toArray();  
    followerRequests.forEach(function(friendRequest){

        if(friendRequest.sender == user){
            returnArray.push(friendRequest.receiver);
        } else {
            returnArray.push(friendRequest.sender);
        }

    })
    return returnArray;
}

async function getTotalOnLogin(username){

    var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
    var client = db.db(dbName);

    var sum = 0;
    var closed_order_info = await client.collection("Closed_Orders").find({payee: username}).toArray();
    
    if(closed_order_info.length == 0){
        db.close();
        return 0;
    }

    for (var i = 0; i < closed_order_info.length; i++){
        sum += Math.round(closed_order_info[i]['transaction']['tip'] * 100) / 100;
    }

    db.close();
    return sum;
}

async function detachOrderFromDelivery(order_record, client){
    let orderInfo = {$set: {status: "Awaiting Runner", delivery_boy: ""}};
    await client.collection('Open_Orders').updateOne({_id: ObjectId(order_record._id)}, orderInfo).catch((error) => console.log(error));
    return ['Detached successfully.'];
}

function sendEmail(address, verification_code){
    var logistics = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: cred.getGMailUsername(),
            pass: cred.getGMailPassword()
        }
     });

    var mailInfo = {
        from: 'beyvo.contact@gmail.com',
        to: address,
        subject: 'Welcome to BEYVO!',
        html: '<html><body><p>Thanks for joining BEYVO!</p><p>To verify your account, please enter the following code into your app:</p><h4><b>' + verification_code + '</b></h4><p>Cheers,</p><p>The BEYVO Team</p><i><p>Having trouble? Contact us at beyvo.contact@gmail.com.</p></i></body></html>'
    };

    logistics.sendMail(mailInfo);
}

async function sendForgetPasswordEmail(address, id){

    // Create a new password unique to the id.
    var tempPass = await bcrypt.hash(id.toString(), await bcrypt.genSalt(5));
    var new_pass = tempPass.substring(6, 16);

    var logistics = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: cred.getGMailUsername(),
            pass: cred.getGMailPassword()
        }
     });

    var mailInfo = {
        from: 'beyvo.contact@gmail.com',
        to: address,
        subject: 'BEYVO: Forget Password',
        html: "<html><body><b>Password Reset</b><br><br><p>This account's password has been reset. To choose a new password, please log back into BEYVO using the temporary password:</p><br><b style='text-align:center'>" + new_pass + "</b></p><br><p>If you did not send the reset request, ignore this email.</p>"
    };

    logistics.sendMail(mailInfo);
    
    return new_pass;
}

async function sendEmailNotVerified(email, verification_code){
  
    var logistics = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: cred.getGMailUsername(),
            pass: cred.getGMailPassword()
        }
     });

    var mailInfo = {
        from: 'beyvo.contact@gmail.com',
        to: email,
        subject: 'BEYVO: Forget Password',
        html: "<html><body><b>Password Reset, Not Verified?</b><br><br><p>We have noticed you have not verified your account after reseting your password. If you forgot the verification code, it is: " + verification_code + "</p>"
    };

    logistics.sendMail(mailInfo);
}

function getTimeSince(order_records){

    var time_since;

    if(order_records.length != 0){
        for (var i = 0; i < order_records.length; i++){
            var previous_time = order_records[i].time;
            var current_time = getCurrentDateTimeZone()

            var seconds = (current_time.getTime() - previous_time.getTime())/1000;
            
            if(seconds < 30){
                time_since = "just now";
            } else if (seconds < 60){
                time_since = "<1 minute ago";
            } else if (seconds < 3600){
                if (Math.round(seconds / 60) == 1){
                    time_since = Math.round(seconds / 60) + " minute ago";
                } else {
                    time_since = Math.round(seconds / 60) + " minutes ago";
                }
            } else {
                if (Math.round(seconds / 3600) == 1){
                    time_since = Math.round(seconds / 3600) + " hour ago";
                } else {
                    time_since = Math.round(seconds / 3600) + " hours ago";
                }
            }

            order_records[i].time = time_since;
        }
    }
    return order_records;
}

function formatDate(date) {
    var d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) 
        month = '0' + month;
    if (day.length < 2) 
        day = '0' + day;

    return [month, day, year.toString().substring(2,4)].join('-');
}

function convertToNormalTime(time){

    time = time.split(':'); // convert to array

    // fetch
    var hours = Number(time[0]);
    var minutes = Number(time[1]);

    // calculate
    var timeValue;

    if (hours > 0 && hours <= 12) {
    timeValue= "" + hours;
    } else if (hours > 12) {
    timeValue= "" + (hours - 12);
    } else if (hours == 0) {
    timeValue= "12";
    }
    
    timeValue += (minutes < 10) ? ":0" + minutes : ":" + minutes; 
    timeValue += (hours >= 12) ? " PM" : " AM";  

    return timeValue;
}

function closedOrderDateReformatter(date){

    // Format date
    var date_complete = date;
    var formated_date = formatDate(date_complete);

    // Format time
    reformat = date_complete.toISOString().
    replace(/T/, ' ').      
    replace(/\..+/, '').split(' ');

    time_GMT = convertToNormalTime(reformat[1]);

    return formated_date + ' ' + time_GMT;
}

function reformatClosedOrder(record){

    var orderArray = [];
    var tempArray = [];

    record.forEach(function(order){
        tempArray = orderArray;

        // id, open, closed, payer, payee, price, rating.
        orderArray = tempArray.concat([[order._id.toString(), closedOrderDateReformatter(order.time_opened), closedOrderDateReformatter(order.time_closed).toString(), order.payer, order.payee, order.transaction.final.toString(), order.rating, order.size, order.beverage, order.vendor]]);
    })

    return orderArray;
}

async function updateAdminFees(updateAdminFees){

    var db = await MongoClient.connect(cred.getMongoUri(), { useUnifiedTopology: true }).catch((error) => console.log(error));
    var client = db.db(sName);

    var administration_information = await client.collection("Administration").findOne({type: 'admin'});

    var current_total = administration_information.earned;
    var new_total = updateAdminFees + current_total;

    let setAdmin = {$set: {earned: new_total}};
    await client.collection("Administration").updateOne({type: 'admin'}, setAdmin).catch((error) => console.log(error)); ;
    
    db.close();

    return;
}

// For follower request

async function createHash(sender, receiver){
    
    var joined = "";
    
    // Alphabetical order for consistent ids
    if (sender < receiver){
        // Sender is first in the alphabet
        joined = sender + receiver;
    } else {
        joined = receiver + sender;
    }

    return crypto.createHash('md5').update(joined).digest('hex');
}

// For internal use.
async function getAllRecordsForUser(user, client){
    var recordsForUser = await client.collection("Friends").find({$or: [{sender: user}, {receiver: user}]}).toArray();  
    return recordsForUser;
}

function attachFriendToOrderArray(array){

    array.forEach(function(order){

        order.friends = "";

    })

    return array;

}

async function getDeliveryRating(delivery_id, client){
      
    var delivery_record = await client.collection('User').findOne({_id: ObjectId(delivery_id)}).catch((error) => console.log(error));
    
    if(delivery_record == null){
        return [false, 'No delivery user exists.'];
    }

    var username = delivery_record.username;
    var close_orders_array = await client.collection('Closed_Orders').find({payee: username}).toArray();
    if(close_orders_array.length == 0){
        return [false, 'No ratings for this user.'];
    }

    var cumulated_score = 0;

    for (var i = 0; i < close_orders_array.length; i++){
        cumulated_score += parseFloat(close_orders_array[i].rating);
    }

    let score = cumulated_score/parseFloat(close_orders_array.length);
    return [true, score];
}

function getCurrentDateTimeZone(){
    var date = new Date();
    var localOffset = date.getTimezoneOffset() * 60000;
    var localDate = date.getTime();

    var utc = localDate - localOffset;
    var newServerDate = new Date(utc);

    // subtract 4 hours to make it ET
    newServerDate.setHours(newServerDate.getHours() - 4);
    return newServerDate;    
}