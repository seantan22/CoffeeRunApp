# CoffeeRunApp

Important considerations:
- Make a Procfile. If not, ensure the package-json file has a "scripts": "node [].js" configuration
- When adding new dependencies, make sure you run 'npm install [] --save' to save the dependencies in the node_modules
- When using express, you have to listen to listen(process.env.PORT || 5000) to listen locally at 5000 and for the open port given
- When using mongodb, ensure your cluster has Network Access set to ALL users.


# API Endpoints

`User` Object

| Key  | Value Type | Value Description |
| ------------- | ------------- | ------------- |
| _id  | string  | Content Cell  |
| username  | string  | Content Cell  |
| password  | string  | Content Cell  |
| email  | string  | Content Cell  |
| phone_number  | string  | Content Cell  |
| loggedIn  | boolean  | Content Cell  |
| balance  | float  | Content Cell  |
| flagged  | boolean  | Content Cell  |


GET

`/getUser`
Usage: Get a user
Parameters: `user_id`
Returns: `User` Object

`/getRating`

