//
//  MemeTableViewController.swift
//  MemeMe 1.0
//
//  Created by Jeremy Benson on 8/26/16.
//  Copyright © 2016 840west. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var memes : [Meme]!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let memeDelegate = UIApplication.sharedApplication().delegate
        let appDelegate = memeDelegate as! AppDelegate
        
        memes = appDelegate.memes
        
        self.tableView.reloadData()
        print("\(memes)")
    }
    
    // MARK : TableView Stuffs
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myReuseIdentifier", forIndexPath: indexPath)
        let memeCell = memes[indexPath.row]
        
        cell.textLabel?.text = memeCell.topText
        cell.detailTextLabel?.text = memeCell.bottomText
        cell.imageView?.image = memeCell.memedImage
        
        return cell
        
    }

    @IBAction func memeEditButton(sender: UIBarButtonItem) {
        
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeViewController") as! ViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
}
