const fs = require('fs');
const readline = require('readline');
const {google} = require('googleapis');

const cred = require('./cred.js');

const TOKEN_PATH = 'token.json';
const SCOPES = ['https://www.googleapis.com/auth/drive.file'];

module.exports = {

    uploadPicture: async function(username, image){
        credentialInformation = cred.getGD();
        auth = authorize(credentialInformation);
        
        const drive = google.drive({version: 'v3', auth});

        var fileMetadata = {
            'name': username + '.jpg'
        };

        var media = {
            mimeType: 'image/jpg',
            body: image
        };

        drive.files.create({
            resource: fileMetadata,
            media: media,
            fields: 'id'
        }, function (err, file) {
            if (err) {
              console.error(err);
            } else {
              console.log('File Id: ', file.id);
            }
        });
    }
}


function authorize(credentials) {
    const {client_secret, client_id, redirect_uris} = credentials.installed;
    
    const oAuth2Client = new google.auth.OAuth2(
        client_id, client_secret, redirect_uris[0]);

    oAuth2Client.setCredentials(getAccessToken(oAuth2Client));

    return oAuth2Client;
  }


function getAccessToken(oAuth2Client) {
    return cred.getToken();
}

function getAccessTokenActual(oAuth2Client) {
    const authUrl = oAuth2Client.generateAuthUrl({
        access_type: 'offline',
        scope: SCOPES,
    });
    console.log('Authorize this app by visiting this url:', authUrl);
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
    });
    rl.question('Enter the code from that page here: ', (code) => {
        rl.close();
        oAuth2Client.getToken(code, (err, token) => {
            if (err) return console.error('Error retrieving access token', err);
            oAuth2Client.setCredentials(token);
            // Store the token to disk for later program executions
            fs.writeFile(TOKEN_PATH, JSON.stringify(token), (err) => {
                if (err) return console.error(err);
                console.log('Token stored to', TOKEN_PATH);
            });
        });
    });
    return oAuth2Client;
}