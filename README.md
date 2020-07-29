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

## Order Object

| Key  | Value Type | Value Description |
| ------------- | ------------- | ------------- |
| _id  | string  | The user's id.  |
| time | Date | Time when order was created. |
| beverage  | string  | The name of the beverage.  |
| size  | string  | The size of the beverage.  |
| details  | string  | Details associated to the order (ex. 1 milk).  |
| restaurant  | string  | Location where to get the beverage from.  |
| library  | string  | The library where to drop off the beverage.  |
| floor  | string  | The floor in the library to drop off the beverage.  |
| segment  | string  | The area on the floor where to find the creator.  |
| cost | int32 | The cost of the beverage - including tip and tax. |
| status | string | The status of the order in relation to where the delivery person is with the delivery. |
| creator | string | User who created the order. |
| delivery_boy | string | Runner who will deliver the order. |

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

### GET `/getCurrentOrderStatus`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Get the status of the specified order.  | 'order_id' | String order_status |

| Errors  |
| ------------- |
| Order does not exist. |

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

### DELETE `/deleteUser`
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

### POST `/updateOrder`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Update an Order.  | `order_id, username, beverage, status, size, details, restaurant, library, floor, segment, cost` | string 'Order successfully updated.'  |

| Errors  |
| ------------- |
| Order does not exist. |
| Please enter the status. |
| Please fill in the beverage. |
| Please fill in the size. |
| Please fill in details or indicate N/A if none. |
| Please enter the restaurant. |
| Please enter the floor you are on. |
| Please enter the segment you are in. |
| Please enter the cost. |
| Not enough funds. |
| Only user:'+username+ ' can update their order. |
| Cannot update order while delivery in progress. |

------------------------------------------------------------

### POST `/attachDelivery`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Attach an order to a delivery user.  | `order_id, delivery_id` | string 'Delivery user on route to deliver ('+(1+num_attached_delivery)+'/3)'  |

| Errors  |
| ------------- |
| Please enter the order_id. |
| Please enter the delivery_id. |
| Order does not exist. |
| There is a delivery user already on route. |
| Delivery user does not exist. |
| Delivery account is flagged. |
| Delivery user is not logged in. |
| Last transaction was flagged. Please contact us. |
| Your balance is incorrect and has been flagged. |
| You cannot order and deliver the same item. |
| Maximum orders for: ' + delivery_record.username + ' is 3. |
| Delivery user has a pending order. Cancel before delivering. |

------------------------------------------------------------

### POST `/detachDelivery`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Detach an order from a delivery user.  | `order_id, delivery_id` | string 'Detached successfully.' |

| Errors  |
| ------------- |
| Order does not exist. |
| Delivery user does not exist. |
| Delivery user must be logged in to cancel delivery. |
| No assigned delivery users. |
| Only the delivery user can cancel a delivery. |


------------------------------------------------------------

### POST `/markInProgress`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Update order state to "In Progress".  | `order_id, delivery_id` | string 'Order status successfully updated to: ' + status.' |

| Errors  |
| ------------- |
| Order does not exist. |
| Delivery user does not exist. |
| Only the runner can update the order status. |

------------------------------------------------------------

### POST `/markPickedUp`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Update order state to "Picked Up".  | `order_id, delivery_id` | string 'Order status successfully updated to: ' + status.' |

| Errors  |
| ------------- |
| Order does not exist. |
| Delivery user does not exist. |
| Only the runner can update the order status. |

------------------------------------------------------------

### POST `/markDelivered`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Update order state to "Delivered".  | `order_id, delivery_id` | string 'Order status successfully updated to: ' + status.' |

| Errors  |
| ------------- |
| Order does not exist. |
| Delivery user does not exist. |
| Only the runner can update the order status. |

------------------------------------------------------------

### DELETE `/deleteOrder`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Delete order.  | `order_id, username` | string 'Successfully deleted order.' |

| Errors  |
| ------------- |
| Order does not exist. |
| Only user:'+username+ ' can delete their order. |
| Cannot delete order as it is being delivered. |

------------------------------------------------------------

### POST `/withdraw`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Withdraw funds from an account and saves transaction.  | `user_id, fund` | string 'New balance: ' + parseFloat(final_balance)' |

| Errors  |
| ------------- |
| User does not exist. |
| User must be logged in to withdraw funds. |
| Please withdraw between $0.00 and $50.00. |
| You do not enough enough funds to withdraw: ' + funds |
| User is flagged. |
| Last transaction was flagged. Please contact us. |
| Your balance is incorrect and has been flagged. |

------------------------------------------------------------

### POST `/deposit`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Deposit funds from an account and saves transaction.  | `user_id, fund` | string 'New balance: ' + parseFloat(final_balance)' |

| Errors  |
| ------------- |
| User does not exist. |
| User must be logged in to deposit funds. |
| User is flagged. |
| Please deposit between $0.00 and $50.00. |
| Last transaction was flagged. Please contact us. |
| Your balance is incorrect and has been flagged. |


------------------------------------------------------------

### POST `/completeOrder`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Complete the order, transfer payments, and save transaction.  | `user_id, delivery_id, order_id, rating` | string 'Successfully completed transaction.' |

| Errors  |
| ------------- |
| Please enter user_id. |
| Please enter delivery_id. |
| Please enter order_id. |
| Please give a rating between 0 and 5. |
| Order does not exist. |
| Cannot complete an order if no delivery person is assigned. |
| Please update the order status to "Delivered". |
| User does not exist. |
| Orderer must be logged in to complete a transaction. |
| User does not have enough funds. |
| User did not create the order. |
| User does not exist. |
| Delivery user has to be logged in to complete order. |
| Delivery user does not exist. |
| Last transaction was flagged. Please contact us. |
| Your balance is incorrect and has been flagged. |

------------------------------------------------------------


### POST `/clean`
| Usage  | Parameters | Returns |
| ------------- | ------------- | ------------- |
| Re activates a flagged users account, deleting previous transactions.  | `user_id` | string 'Account: ' + user_record.username + ' has been reactivated.' |

| Errors  |
| ------------- |
| User does not exist. |
| User not flagged. |


------------------------------------------------------------






