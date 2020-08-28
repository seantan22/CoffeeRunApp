//
//  FriendRequestsViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/13/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class FriendRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    static var friendRequests: Array<String> = Array()
    static var noRequests: Array<String> = ["No Friend Requests."]
    
    @IBOutlet weak var tableView: UITableView!
    
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
        if FriendRequestsViewController.friendRequests.count == 0 {
            return FriendRequestsViewController.noRequests.count
        }

        return FriendRequestsViewController.friendRequests.count
     }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return 5.0
       }

       // Space between cells
       func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           let spacer = UIView()
           spacer.backgroundColor = UIColor.clear
           return spacer
       }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
     
    // Cell Content
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath[0] < FriendRequestsViewController.friendRequests.count {
            let user = FriendRequestsViewController.friendRequests[indexPath[0]]
               let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestItem", for: indexPath) as! FriendRequestTableViewCell
                  cell.setUser(user: user)
               return cell
        }
        
        if FriendRequestsViewController.friendRequests.count == 0 {
            let user = FriendRequestsViewController.noRequests[indexPath[0]]
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestItem", for: indexPath) as! FriendRequestTableViewCell
               cell.setUser(user: user)
            return cell
        }
        
        return FriendRequestTableViewCell()
    }
    
    // Swipe Cell
       func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           
        
        if FriendRequestsViewController.friendRequests.count != 0 {
            
            let sender = FriendRequestsViewController.friendRequests[indexPath.section]
        
            let accept = UIContextualAction(style: .normal, title: "Accept",
             handler: { (action, view, completionHandler) in
                
                self.acceptFriendRequest(acceptor: UserDefaults.standard.string(forKey: "username")!, sender: sender) {(result: Response) in
                    if result.result {
                        FriendRequestsViewController.friendRequests.remove(at: indexPath.section)
                    } else {
                        print(result.response)
                    }
                }
                
                self.run(after: 1000) {
                    tableView.reloadData()
                }
               completionHandler(true)
            })
        
            let reject = UIContextualAction(style: .normal, title: "Delete",
             handler: { (action, view, completionHandler) in
                
                self.rejectFriendRequest(denier: UserDefaults.standard.string(forKey: "username")!, sender: sender) {(result: Response) in
                    if result.result {
                        FriendRequestsViewController.friendRequests.remove(at: indexPath.section)
                    } else {
                        print(result.response)
                    }
                }
            
                self.run(after: 1000) {
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
        
        guard let url = URL(string: URLs.URL + "acceptFollowRequest") else {
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
        
        guard let url = URL(string: URLs.URL + "denyFollowRequest") else {
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
