//
//  FriendRequestsViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/13/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class FriendRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    static var friendRequests: Array<String> = Array()
    static var noRequests: Array<String> = ["No Friend Requests."]
    
    @IBOutlet weak var tableView: UITableView!
    
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor.clear
        view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
        
        tableView.reloadData()

    }


    // Number of Cells in Table
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if FriendRequestsViewController.friendRequests.count == 0 {
            return FriendRequestsViewController.noRequests.count
        }

        return FriendRequestsViewController.friendRequests.count
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
     
    // Cell Content
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("test")
        
        if index < FriendRequestsViewController.friendRequests.count {
            let user = FriendRequestsViewController.friendRequests[index]
               let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestItem", for: indexPath) as! FriendRequestTableViewCell
                  cell.setUser(user: user)
               index += 1
               return cell
        }
        
        if FriendRequestsViewController.friendRequests.count == 0 {
            let user = FriendRequestsViewController.noRequests[index]
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestItem", for: indexPath) as! FriendRequestTableViewCell
               cell.setUser(user: user)
            index += 1
            return cell
        }
        
        return FriendRequestTableViewCell()
    }
    
    // Swipe Cell
       func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           
        
        if FriendRequestsViewController.friendRequests.count != 0 {
            
            let sender = FriendRequestsViewController.friendRequests[indexPath.row]
        
            let accept = UIContextualAction(style: .normal, title: "Accept",
             handler: { (action, view, completionHandler) in
               
                print("click accept")
                
                self.acceptFriendRequest(acceptor: UserDefaults.standard.string(forKey: "username")!, sender: sender) {(result: Response) in
                    if result.result {
                        FriendRequestsViewController.friendRequests.remove(at: indexPath.row)
                    } else {
                        print(result.response)
                    }
                }
                
                self.run(after: 1000) {
                    self.index = 0
                    tableView.reloadData()
                }
               completionHandler(true)
            })
        
            let reject = UIContextualAction(style: .normal, title: "Delete",
             handler: { (action, view, completionHandler) in
               
                print("click delete")
                
                self.rejectFriendRequest(denier: UserDefaults.standard.string(forKey: "username")!, sender: sender) {(result: Response) in
                    if result.result {
                        FriendRequestsViewController.friendRequests.remove(at: indexPath.row)
                    } else {
                        print(result.response)
                    }
                }
            
                self.run(after: 1000) {
                    self.index = 0
                    tableView.reloadData()
                }
               completionHandler(true)
            })
        
            accept.backgroundColor = UIColor.systemGreen
            reject.backgroundColor = UIColor.systemRed
            let configuration = UISwipeActionsConfiguration(actions: [accept, reject])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
        return UISwipeActionsConfiguration()
       }
    
    func tableView(_ tableView: UITableView,
      editingStyleForRowAt indexPath: IndexPath)
        -> UITableViewCell.EditingStyle {
      return .none
    }
    
    //MARK: Response
    struct Response: Decodable {
      var result: Bool
      var response: Array<String>
      init() {
          self.result = false
          self.response = Array()
      }
    }
    
    // POST /acceptFollowRequest
    func acceptFriendRequest(acceptor: String, sender: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "acceptFollowRequest") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonRequest = [
            "acceptor": acceptor,
            "sender": sender
        ]
        
        let dataLogin: Data
        do {
            dataLogin = try JSONSerialization.data(withJSONObject: jsonRequest, options: [] )
        } catch {
            print("Error: Unable to convert JSON to Data object")
            return
        }
       
        let task = session.uploadTask(with: request, from: dataLogin) { data, response, error in
            if let data = data {
                var acceptFriendResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    acceptFriendResponse.result = jsonResponse.result
                    acceptFriendResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(acceptFriendResponse)
            }
        }
        task.resume()
    }
    
    // POST /rejectFollowRequest
    func rejectFriendRequest(denier: String, sender: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "denyFollowRequest") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonRequest = [
            "denier": denier,
            "sender": sender
        ]
        
        let dataLogin: Data
        do {
            dataLogin = try JSONSerialization.data(withJSONObject: jsonRequest, options: [] )
        } catch {
            print("Error: Unable to convert JSON to Data object")
            return
        }
       
        let task = session.uploadTask(with: request, from: dataLogin) { data, response, error in
            if let data = data {
                var rejectFriendResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    rejectFriendResponse.result = jsonResponse.result
                    rejectFriendResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(rejectFriendResponse)
            }
        }
        task.resume()
    }
    
    func run(after milliseconds: Int, completion: @escaping() -> Void) {
        let deadline = DispatchTime.now() + .milliseconds(milliseconds)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completion()
        }
    }
    
    

}
