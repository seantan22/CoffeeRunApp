//
//  FindUsersViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/11/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class FindUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
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
        
        tableView.backgroundColor = UIColor.clear
        view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
        
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
        return FindUsersViewController.users.count
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
     
    // Cell Content
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let hourglassImage = UIImage(systemName: "hourglass")
        let hourglassView = UIImageView(image: hourglassImage)
        let starImage = UIImage(systemName: "star.fill")
        let starView = UIImageView(image: starImage)
        
        if index < FindUsersViewController.subUsers.count {
         let user = FindUsersViewController.subUsers[index]
         let cell = tableView.dequeueReusableCell(withIdentifier: "UserItem", for: indexPath) as! UserTableViewCell
             cell.setUser(user: user[0])
            
            let state = user[1]
        
            if state == "friends" {
                cell.accessoryView = starView
            } else if state == "pending" {
                cell.accessoryView = hourglassView
            } else {
                cell.accessoryView = UIImageView()
            }
            
            index += 1
            return cell
        }
        return UITableViewCell()
    }
    
    // Swipe Cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let user = FindUsersViewController.subUsers[indexPath.section]
        
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
              self.unfriend(sender: UserDefaults.standard.string(forKey: "username")!, receiver: FindUsersViewController.subUsers[indexPath.section][0]) {(result: Response) in
                  if result.result {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Friend Removed", message: FindUsersViewController.subUsers[indexPath.section][0], preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Done", style: .default))
                        self.present(alert, animated: true)
                        
                        var counter: Int = 0
                        
                        for person in FindUsersViewController.users {
                            if person[0] == FindUsersViewController.subUsers[indexPath.section][0] {
                                FindUsersViewController.users[counter][1] = "nothing"
                                break
                            }
                            counter += 1
                        }
                        
                        
                        FindUsersViewController.subUsers[indexPath.section][1] = "nothing"
                        let tempNumOfFriends = Int(ProfileViewController.numOfFriends)
                        ProfileViewController.numOfFriends = String(tempNumOfFriends! - 1)
                    }
                  }
              }
            } else if state == "pending" {
              print("PENDING")
            } else {
               self.sendFriendRequest(sender: UserDefaults.standard.string(forKey: "username")!, receiver: FindUsersViewController.subUsers[indexPath.section][0]) {(result: Response) in
                   if result.result {
                       DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Request Sent!", message: "", preferredStyle: .alert)
                           alert.addAction(UIAlertAction(title: "Done", style: .default))
                           self.present(alert, animated: true)
                        
                        var counter: Int = 0
                        
                        for person in FindUsersViewController.users {
                            if person[0] == FindUsersViewController.subUsers[indexPath.section][0] {
                                FindUsersViewController.users[counter][1] = "pending"
                                break
                            }
                            counter += 1
                        }
                        
                            FindUsersViewController.subUsers[indexPath.section][1] = "pending"
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
        
        guard let url = URL(string: URLs.URL + "sendFollowRequest") else {
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
        
        guard let url = URL(string: URLs.URL + "deleteFriendship") else {
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
