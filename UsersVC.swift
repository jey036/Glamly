//
//  UsersVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/3/16.
//  Copyright © 2016 UCSD. All rights reserved.
//
import ParseUI
import UIKit
import Parse

class UsersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout { //, UICollectionViewDataSource {

    var searchBar = UISearchBar()
    
    //table view information we retrieve from servers
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    //collection view information we retrieve from servers
    var collectionView : UICollectionView!
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var page : Int = 24
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //search bar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackgroundColor()
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        
        self.navigationItem.leftBarButtonItem  = searchItem
       
        
        loadUsers()
    }

    func loadUsers() {
        let query = PFQuery(className: "_User")
        query.addDescendingOrder("createdAt")
        query.limit = 20
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) in
            if error == nil {
                
                //clean up
                self.usernameArray.removeAll(keepCapacity: false)
                self.avaArray.removeAll(keepCapacity: false)
                
                for object in objects! {
                    
                    self.usernameArray.append(object.objectForKey("username") as! String)
                    self.avaArray.append(object.objectForKey("image") as! PFFile)
                }
                 self.tableView.reloadData()
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let query = PFQuery(className: "_User")
        query.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                //find by fullname
                if objects!.isEmpty {
                    let nameQuery = PFQuery()
                    nameQuery.whereKey("fullname", matchesRegex:"(?i)" + self.searchBar.text!)
                    nameQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
                        if error == nil {
                            //clean up
                            self.usernameArray.removeAll(keepCapacity: false)
                            self.avaArray.removeAll(keepCapacity: false)
                            
                            //found related objects
                            for object in objects! {
                                self.usernameArray.append(object.objectForKey("username") as! String)
                                self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            }
                            
                            self.tableView.reloadData()
                        }
                    })
                }
                //clean up
                self.usernameArray.removeAll(keepCapacity: false)
                self.avaArray.removeAll(keepCapacity: false)
                
                //found related objects
                for object in objects! {
                    
                    self.usernameArray.append(object.objectForKey("username") as! String)
                    self.avaArray.append(object.objectForKey("ava") as! PFFile)
                }
                self.tableView.reloadData()
            }
        }
        
        return true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.showsCancelButton = false
        //show users again after clicking cancel
        loadUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }

    
    
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! followersCell
        cell.followBtn.hidden = true
        
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) in
            if error == nil {
                cell.avaImg.image = UIImage(data:data!)
                
                
            }
        }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as! followersCell
        
        // until we implement home vc and guest vc
//        if cell.usernameLbl.text! == PFUser.currentUser()?.username {
//            let home = self.storyboard?.instantiateInitialViewControllerWithIdentifier("homeVC") as! homeVC
//            self.navigationController?.pushViewController(home, animated: true)
//        } else {
//            
//            guestname.append(cell.usernameLbl.text!)
//            let guest = storyboard?.instantiateViewControllerWithIdentifier("guestVC")
//            self.navigationController?.pushViewController(guest, animated: true)
//        }
    }
    
    
    
    //Collection View Implementation
    func collectionViewLaunch() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake( self.view.frame.size.width / 3, self.view.frame.size.width / 3)
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        let frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 20)
        
        //instantiate the collection view
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
       // collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView)
        
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
    }
    
}
