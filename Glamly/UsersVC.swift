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
import MultipeerConnectivity

class UsersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //var mpcManager: MPCManager!
    
    var searchBar = UISearchBar()
    var refresher = UIRefreshControl()
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
  
       
        
        
    
        // search bar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackgroundColor()
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        
        self.navigationItem.leftBarButtonItem  = searchItem
        //self.tableView.hidden = true
        
        loadUsers()
        collectionViewLaunch()
    }
    

//    override func viewWillAppear(animated: Bool) {
//        loadPosts()
//    }
    
    
    
    
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
        self.tableView.hidden = false
        let query = PFQuery(className: "_User")
        query.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                //clean up
                self.usernameArray.removeAll(keepCapacity: false)
                self.avaArray.removeAll(keepCapacity: false)
                
                //found related objects
                for object in objects! {
                    
                    self.usernameArray.append(object.objectForKey("username") as! String)
                    self.avaArray.append(object.objectForKey("image") as! PFFile)
                }
                self.tableView.reloadData()
            }
        }
        
        return true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.collectionView.hidden = true
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.collectionView.hidden = false
        self.searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.showsCancelButton = false
        
        //show users again after clicking cancel
        loadUsers()
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
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! followersCell
        
        
                if cell.usernameLbl.text! == PFUser.currentUser()?.username {
                    let home = self.storyboard?.instantiateViewControllerWithIdentifier("HomeVC") as! HomeVC
                    self.navigationController?.pushViewController(home, animated: true)
                } else {
        
                    guestname.append(cell.usernameLbl.text!)
                    let guest = storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
                    self.navigationController?.pushViewController(guest, animated: true)
                }
    }
    
    
    
    //Collection View Implementation
    func collectionViewLaunch() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(self.view.frame.size.width / 3 , self.view.frame.size.width / 3)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        let frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - 20)
        
        //instantiate the collection view
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView)
        
        //refresher
//        let refresher = UIRefreshControl()
        refresher.addTarget(self, action:"loadPosts", forControlEvents: .ValueChanged)
        self.collectionView.addSubview(refresher)
        
        
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        loadPosts()
        self.tableView.scrollEnabled = false
    }
    
    
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInterimSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 0.0
//    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 0.0
//    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Pic array size  \(picArray.count)")
        return picArray.count
    }
    
    
  
    
    //cell config
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //create the picture image view in the cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        let picImg = UIImageView(frame: CGRectMake(0,0,cell.frame.size.width , cell.frame.size.height))
        
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) in
            if error == nil {
                picImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        cell.addSubview(picImg)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        postuuid.append(uuidArray[indexPath.row])
        let post = self.storyboard?.instantiateViewControllerWithIdentifier("PostVC") as! PostVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    func loadPosts() {
       
        self.picArray.removeAll(keepCapacity: false)
        self.uuidArray.removeAll(keepCapacity: false)
        var mpcUsers = [String]()
        if appDelegate.useMPC {
            let query = PFQuery(className: "posts")
            query.limit = page * 5
            //copy the set into an array for the query
            for name in appDelegate.mpcManager.displayNames {
                mpcUsers.append(name)
            }
            query.whereKey("username", containedIn: mpcUsers)
            query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
                if error == nil {
                
                
                    //find random posts from the server
                    for object in objects! {
                        print("\(object.objectForKey("username") as! String)")
                        self.picArray.append(object.objectForKey("pic") as! PFFile)
                        self.uuidArray.append(object.objectForKey("uuid") as! String)
                    }
                }
            }
        }
        
        let noMPCQuery = PFQuery(className: "posts")
        noMPCQuery.limit = page * 5
        noMPCQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
        if error == nil {
                    
            //find random posts from the server
            for object in objects! {
                if self.appDelegate.useMPC {
                    if !mpcUsers.contains((object.objectForKey("username") as! String)) {
                        self.picArray.append(object.objectForKey("pic") as! PFFile)
                        self.uuidArray.append(object.objectForKey("uuid") as! String)
                    }
                }
            }
            self.collectionView.reloadData()
            self.refresher.endRefreshing()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //scroll down for paging
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
               //self.loadMore()
        }
    }
    
    
    func loadMore() {
        
        // load more posts
        if page <= picArray.count {
            //increase the page size
            page += 24
            let query = PFQuery(className: "posts")
            query.limit = page
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil {
                    for object in objects! {
                        self.picArray.append(object.objectForKey("pic") as! PFFile)
                        self.uuidArray.append(object.objectForKey("uuid") as! String)
                    }
                    
                    //relaod the new posts
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
}





