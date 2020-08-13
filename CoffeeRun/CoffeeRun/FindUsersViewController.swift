//
//  FindUsersViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/11/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class FindUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    static var users: Array<Array<String>> = Array(Array())
    static var subUsers: Array<Array<String>> = Array(Array())
    
    var index: Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let lowercaseSearchText = searchText.lowercased()
        FindUsersViewController.subUsers = []
        if searchText.count == 0 {
            FindUsersViewController.subUsers = FindUsersViewController.users
        }
        for user in FindUsersViewController.users {
            if user[0].contains(lowercaseSearchText) {
                FindUsersViewController.subUsers.append(user)
            }
        }
        index = 0
        tableView.reloadData()
    }
    
    // Number of Cells in Table
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FindUsersViewController.users.count
     }
     
    // Cell Content
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if index < FindUsersViewController.subUsers.count {
         let user = FindUsersViewController.subUsers[index]
         let cell = tableView.dequeueReusableCell(withIdentifier: "UserItem", for: indexPath) as! UserTableViewCell
             cell.setUser(user: user[0])
            
            let state = user[1]
            if state == "friends" {
                cell.layer.borderColor = UIColor.systemGreen.cgColor
            } else if state == "pending" {
                cell.layer.borderColor = UIColor.systemYellow.cgColor
            } else {
                cell.layer.borderColor = UIColor.white.cgColor
            }
            
            index += 1
            return cell
        }
        return UITableViewCell()
    }
    
    // Swipe Cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let user = FindUsersViewController.subUsers[indexPath.row]
        
        let state = user[1]
        
        var title: String = String()
        
       if state == "friends" {
            title = NSLocalizedString("Unfriend", comment: "Unfriend")
        } else if state == "pending" {
            title = NSLocalizedString("Pending...", comment: "Pending...")
        } else {
            title = NSLocalizedString("Add Friend", comment: "Add")
        }

        let action = UIContextualAction(style: .normal, title: title,
          handler: { (action, view, completionHandler) in
            
            if state == "friends" {
              self.unfriend(sender: UserDefaults.standard.string(forKey: "username")!, receiver: FindUsersViewController.subUsers[indexPath.row][0]) {(result: Response) in
                  if result.result {
                      DispatchQueue.main.async {
                          let alert = UIAlertController(title: "Friend Removed", message: FindUsersViewController.subUsers[indexPath.row][0], preferredStyle: .alert)
                          alert.addAction(UIAlertAction(title: "Done", style: .default))
                          self.present(alert, animated: true)
                            FindUsersViewController.subUsers[indexPath.row][1] = "nothing"
                      }
                  }
              }
            } else if state == "pending" {
              print("PENDING")
            } else {
               self.sendFriendRequest(sender: UserDefaults.standard.string(forKey: "username")!, receiver: FindUsersViewController.subUsers[indexPath.row][0]) {(result: Response) in
                   if result.result {
                       DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Request Sent!", message: "", preferredStyle: .alert)
                           alert.addAction(UIAlertAction(title: "Done", style: .default))
                           self.present(alert, animated: true)
                            FindUsersViewController.subUsers[indexPath.row][1] = "pending"
                       }
                   }
               }
            }
            self.run(after: 1000) {
                self.index = 0
                tableView.reloadData()
            }
            completionHandler(true)
    })
        action.backgroundColor = UIColor.black
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
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
    
    // POST /sendFollowRequest
    func sendFriendRequest(sender: String, receiver: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "sendFollowRequest") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonRequest = [
            "sender": sender,
            "receiver": receiver
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
                var friendResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    friendResponse.result = jsonResponse.result
                    friendResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(friendResponse)
            }
        }
        task.resume()
    }
    
    // DELETE /deleteFriendship
    func unfriend(sender: String, receiver: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "deleteFriendship") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonRequest = [
            "sender": sender,
            "receiver": receiver
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
                var friendResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    friendResponse.result = jsonResponse.result
                    friendResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(friendResponse)
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
