//
//  ViewController.swift
//  FourthStep
//
//  Created by Taras Kovtun on 9/25/15.
//  Copyright © 2015 Taras Kovtun. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController  {

    @IBAction func asdqwe(sender: AnyObject) {
        // Do any additional setup after loading the view, typically from a nib.
        
        // Use optional binding to confirm the managedObjectContext
        let moc = self.managedObjectContext
        
        // Create some dummy data to work with
        var items = [
            ("Alex", "Has a nicer girl", "Self esteem")
        ]
        
        // Loop through, creating items
        for (itemTitle, itemText, affected) in items {
            // Create an individual item
            Resentment.createInManagedObjectContext(moc,
                who: itemTitle, didwhat: itemText, affectedMy: affected)
        }
        var error : NSError?
        
        do { try managedObjectContext.save()          }
            
        catch{
        }
        fetchLog()
        
            self.tableView.reloadData()
    }


    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var resentments = [Resentment]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // Use optional binding to confirm the managedObjectContext
        let moc = self.managedObjectContext
            
            // Create some dummy data to work with
            var items = [
                ("Alex", "Has a nicer girl", "Self esteem")
            ]
            
            // Loop through, creating items
            for (itemTitle, itemText, affected) in items {
                // Create an individual item
                Resentment.createInManagedObjectContext(moc,
                    who: itemTitle, didwhat: itemText, affectedMy: affected)
            }
        
        
        fetchLog()
    }
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // How many rows are there in this section?
        // There's only 1 section, and it has a number of rows
        // equal to the number of logItems, so return the count
        return resentments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell?
        
        // Get the LogItem for this index
        let logItem = resentments[indexPath.row]
        
        // Set the title of the cell to be the title of the logItem
        cell!.textLabel?.text = logItem.who
        return cell!
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let logItem = resentments[indexPath.row]
        print(logItem.didwhat)
    }

    

    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "Resentment")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "who", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        do{
        if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Resentment] {
            resentments  = fetchResults
            }
        }
        catch
        {
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

