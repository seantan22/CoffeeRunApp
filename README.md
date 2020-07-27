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

## User Endpoints

### GET

`/getUser`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get a user.  | `_id` | `User` Object  |

| Errors  |
| ------------- |
| Please input correct password. |
| Have to be logged in to get user information. |

------------------------------------------------------------

`/getUsers`
**TODO**


`/getRating`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get the overall delivery rating of a person.  | `delivery_id` | int `score`  |

| Errors  |
| ------------- |
| No delivery user exists. |
| No ratings for this user. |

### POST

`/createUser`
`/updateUser`
`/login`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Login to a user's account.  | `username`, `password` | string `_id`  |

| Errors  |
| ------------- |
| Incorrect credentials. |
| This account has been flagged. |
| Incorrect username. |
| Already loggged in. |

`/logout`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Logout of a user's account.  | `_id` | string 'Successfully logged out.'  |

| Errors  |
| ------------- |
| Incorrect credentials. |
| Already loggged out. |

`/deleteUser`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Delete a user's account.  | `_id` | string 'Successfully deleted.'  |

| Errors  |
| ------------- |
| Incorrect credentials. |
| You have to be logged in to delete your account. |
| You have to be logged in to delete your account. |
| You cannot delete your account with a pending order. |
**TODO: What if you delete an account with a non-zero balance?** 




