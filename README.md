# CoffeeRunApp

Important considerations:
- Make a Procfile. If not, ensure the package-json file has a "scripts": "node [].js" configuration
- When adding new dependencies, make sure you run 'npm install [] --save' to save the dependencies in the node_modules
- When using express, you have to listen to listen(process.env.PORT || 5000) to listen locally at 5000 and for the open port given
- When using mongodb, ensure your cluster has Network Access set to ALL users.


# API Endpoints

### User Object

| Key  | Value Type | Value Description |
| ------------- | ------------- | ------------- |
| _id  | string  | The user's id.  |
| username  | string  | The user's username.  |
| password  | string  | The user's password.  |
| email  | string  | The user's email.  |
| phone_number  | string  | The user's phone number.  |
| loggedIn  | boolean  | True, if the user is logged in; False, otherwise.  |
| balance  | float  | The amount (in $CAD) in the user's account.  |
| flagged  | boolean  | True, if the user's account has been flagged for suspicious activity; False, otherwise.  |


## GET

`/getUser`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get a user  | `user_id` | `User` Object  |

`/getRating`

