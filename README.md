# CoffeeRunApp

Important considerations:
- Make a Procfile. If not, ensure the package-json file has a "scripts": "node [].js" configuration
- When adding new dependencies, make sure you run 'npm install [] --save' to save the dependencies in the node_modules
- When using express, you have to listen to listen(process.env.PORT || 5000) to listen locally at 5000 and for the open port given
- When using mongodb, ensure your cluster has Network Access set to ALL users.




# API Endpoints

## User Object

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
| verified | boolean | True, if user has verified account by typing in verification number, false otherwise |
| verification_number | int32 | Number given randomly for verification |
------------------------------------------------------------
------------------------------------------------------------

### GET `/getUser`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get a user.  | `user_id` | `User` Object  |

| Errors  |
| ------------- |
| Please input correct password. |
| Have to be logged in to get user information. |

------------------------------------------------------------

### GET `/getOrder`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get all open orders.  | None | Array of all open orders.  |

| Errors  |
| ------------- |
| None |

------------------------------------------------------------


### GET `/getUsers`
| Usage  | Parameters | Returns |
| Get all users of CoffeeRun.  | `none` | Array of users |

| Errors  |
| ------------- |
| none |

------------------------------------------------------------

### GET `/getRating`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get the overall delivery rating of a person.  | `delivery_id` | int `score`  |

| Errors  |
| ------------- |
| No delivery user exists. |
| No ratings for this user. |

------------------------------------------------------------

### GET `/getNumberCurrentRunners`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get number of distinct active runners.  | None | Int 'runnerNumber' |

| Errors  |
| ------------- |
| None |

------------------------------------------------------------

### GET `/getNumberOfAllOpenOrders`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get number of open orders.  | None | Int 'numberOrders'  |

| Errors  |
| ------------- |
| None |

------------------------------------------------------------

### GET `/getOrdersByLibrary`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get orders for library.  | 'library' | Array of orders for designated library.  |

| Errors  |
| ------------- |
| Please input a library. |

------------------------------------------------------------

### GET `/getOrderByUser`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get order for designated user.  | 'user_id' | Object of order.  |

| Errors  |
| ------------- |
| User does not exist. |

------------------------------------------------------------

### GET `/getOrderDelivery`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get all orders associated to a deliery user.  | 'user_id' | Array of all orders.  |

| Errors  |
| ------------- |
| User does not exist. |

------------------------------------------------------------
------------------------------------------------------------

### POST `/createUser`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Create a new user account.  | `username`, `password`, `email`, `phone_numb` | string 'Successfuly added.'  |

| Errors  |
| ------------- |
| Please fill in the username. |
| Please enter an appropriate password. |
| Please enter an appropriate email. |
| Please enter an appropriate phone number. |

------------------------------------------------------------

### POST `/updateUser`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Update a user's account.  | `id`, `username`, `password`, `email`, `phone_numb`, `balance` | string 'Successfully updated credentials.' |

| Errors  |
| ------------- |
| Incorrect credentials. |
| You have to be logged in to change credentials. |
| New username is already taken. |
| New email is already taken. |
| New phone number is already taken. |

------------------------------------------------------------

### POST `/verify`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Verify users account.  | `username`, `password`, verification_number | Successfully logged in |

| Errors  |
| ------------- |
| Incorrect verification code. It has been resent. |

------------------------------------------------------------

### POST `/login`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Login to a user's account.  | `username`, `password` | string `user_id`  |

| Errors  |
| ------------- |
| Incorrect credentials. |
| This account has been flagged. |
| Incorrect username. |
| Already loggged in. |
| Please verify your account: ' + record.phone_number |

------------------------------------------------------------

### POST `/logout`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Logout of a user's account.  | `user_id` | string 'Successfully logged out.'  |

| Errors  |
| ------------- |
| Incorrect credentials. |
| Already loggged out. |

------------------------------------------------------------

### POST `/deleteUser`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Delete a user's account.  | `user_id` | string 'Successfully deleted.'  |

| Errors  |
| ------------- |
| Incorrect credentials. |
| You have to be logged in to delete your account. |
| You have to be logged in to delete your account. |
| You cannot delete your account with a pending order. |

------------------------------------------------------------

### POST `/makeReview`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Add a review.  | `username, review` | string 'Thank you for your review.'  |

| Errors  |
| ------------- |
| Please write a review. |
| You have to be logged in to delete your account. |
| You have to be logged in to delete your account. |
| You cannot delete your account with a pending order. |

------------------------------------------------------------

### POST `/createOrder`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Add an Order.  | `user_id, beverage, size, details, restaurant, library, floor, segment, cost` | string 'ID of Order'  |

| Errors  |
| ------------- |
| User does not exist. |
| User must be logged in to create order. |
| Please fill in the beverage. |
| Please fill in the size. |
| Please fill in details or indicate N/A if none. |
| Please enter the restaurant. |
| Please enter the floor you are on. |
| Please enter the segment you are in. |
| Please enter the cost. |
| Not enough funds. |
| You are already delivering orders. Please finish or cancel. |
| You already have a pending order. |


------------------------------------------------------------



