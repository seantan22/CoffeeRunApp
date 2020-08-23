const aws = require('aws-sdk');

module.exports = {
    // interact
    // getMongoURI: function(){
    //     var mongoKey = new aws.S3({mongo_uri: process.env.mongodb_uri,});
    //     return mongoKey.config.mongo_uri;
    // },
    getGoogleAPIToken: function(){
        var googleKey = new aws.S3({google_api: process.env.google_api,});
        return googleKey.config.google_api;
    },
    getElephantUri: function(){
        var elephantKey = new aws.S3({elephant_uri: process.env.elephant_uri,});
        return elephantKey.config.elephant_uri;
    },
    getGMailPassword: function(){
        var gmailKey = new aws.S3({gmail_pass: process.env.gmail_pass,});
        return gmailKey.config.gmail_pass;
    },

    getMongoUri(){
        return 'mongodb+srv://Dwarff19:NewLoc@lP@ss123!@coffeerun.y795l.azure.mongodb.net/CoffeeRun?retryWrites=true&w=majority'
    },
    getPass: function(){
        return 'NewLoc@lP@ss123!'
    }, 
    getSQLUrl: function(){
        return 'postgres://iuzprbuw:oGZLJDhqlTr-9jMRrRixgx2IreWPnir_@hansken.db.elephantsql.com:5432/iuzprbuw'
    },
    getGD: function(){
        return {
            "installed": {
                "client_id": "897610409846-0bep4ml14lnk6g1hqjq8131ttdh4llu2.apps.googleusercontent.com",
                "project_id": "coffeerun-1597254586063",
                "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                "token_uri": "https://oauth2.googleapis.com/token",
                "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
                "client_secret": "acHs92rj1sZK0STIUrNR0Sq9",
                "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob", "http://localhost"]
            }
        };
    },
    
    getTokenGet: function(){
        return {
            "access_token":"ya29.a0AfH6SMC0RuIJAxpKALR3i6H1T3vU6h39GEiLMxCMx5NkLkLuBm7aysbEEq926IGHLmdB2b5mLzX7rguMJt8BtkljUdyG2-JHJ1snWrjKUcaQU9ILBIOQLClIiNhRU3-Ww0a9X9oLTS3HH396KAd88oSuUbFxaHx6m_k",
            "refresh_token":"1//0fRcb0sL_66I6CgYIARAAGA8SNwF-L9IrASd25Ai9wje-UBUS4r-scM7HG1x6uWIWSowDL6eXzvcGsDlVQcs8U41UXPnhMUOL84s",
            "scope":"https://www.googleapis.com/auth/drive.file",
            "token_type":"Bearer",
            "expiry_date":1597270240736}
    }
}