const aws = require('aws-sdk');

module.exports = {
    // interact
    getMongoURI: function(){
        
        var globalKey = new aws.S3({mongo_uri: process.env.mongodb_uri,});
        return globalKey.config.mongo_uri;
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