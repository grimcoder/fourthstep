import UIKit
import CoreData
import Alamofire
import SwiftyJSON


class ViewController: UITableViewController  {

    let moc = ObjectContext.managedObjectContext
    
    @IBAction func ImportFile(sender: AnyObject) {
        

    }
    
    func importR(url: NSURL){
        
        let a = url.lastPathComponent
        var string = FileLoad.loadString(a!, directory: NSSearchPathDirectory.DocumentDirectory, subdirectory: "Inbox")
        Resentment.resetResentments(moc, resentments: resentments)
        
        if let dataFromString = string!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            for (key,subJson):(String, JSON) in json {
                Resentment.createInManagedObjectContext(moc, who: String(subJson["who"]), didwhat: String(subJson["didwhat"]), affectedMy: String(subJson["affectedMy"]))
                
            }
        }

        do {
            try
                ObjectContext.managedObjectContext.save()
        }
            
        catch{
            
        }
        
        fetchLog()
        
    }
    
    @IBAction func ExportFile(sender: AnyObject) {

        let jsonResentment = resentments.map {["who": $0.who!, "didwhat": $0.didwhat!, "affectedMy" : $0.affectedMy!]}
        
        print(jsonResentment)
        
        let jsonString  = JSON(jsonResentment).rawString()
        
        FileSave.saveString(jsonString!, directory: NSSearchPathDirectory.DocumentDirectory, path: "export.json", subdirectory: "")
        
        docController.presentOptionsMenuFromBarButtonItem(sender as! UIBarButtonItem, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ViewResentment") {
            if let resentmentC =  segue.destinationViewController as? ResentmentView {
                resentmentC.resentment = sender as? Resentment
            }
        }
        
        if (segue.identifier == "AddNew") {

        }
    }
    
    // UIDocumentInteractionController instance is a class property
    var docController:UIDocumentInteractionController!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            self.performSegueWithIdentifier("ViewResentment", sender: resentments[indexPath.row])
    }
    

    var resentments = [Resentment]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.viewController = self
        
        let fileURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory,  inDomains: NSSearchPathDomainMask.UserDomainMask)[0].URLByAppendingPathComponent("export.json")
        
        // Instantiate the interaction controller
        print(String(fileURL))
        
        self.docController = UIDocumentInteractionController(URL: fileURL)
        
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self,
            action: "handleRefresh:",
            forControlEvents: .ValueChanged)
        
        tableView.addSubview(refreshControl!)
        fetchLog()
    }
    
    func handleRefresh(paramSender: AnyObject) {
        fetchLog()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchLog()
        

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "persistentStoreDidChange", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "persistentStoreWillChange:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recieveICloudChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
    }
    
    
    func persistentStoreDidChange () {
        // reenable UI and fetch data
        self.navigationItem.title = "iCloud ready"
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        fetchLog()
        
    }
    
    func persistentStoreWillChange (notification:NSNotification) {
        self.navigationItem.title = "Changes in progress"
        // disable the UI
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        moc.performBlock { () -> Void in
            if self.moc.hasChanges {
                
                var error:NSError? = nil
                
                do {
                    try
                        ObjectContext.managedObjectContext.save()
                }
                    
                catch{
                    
                }
                
                if error != nil {
                    print("Save error: \(error)")
                }
                else
                {
                    // drop any manged object refrences
                    self.moc.reset()
                }
                
                
            }
        }
    }
    
    func recieveICloudChanges (notification:NSNotification){
        moc.performBlock { () -> Void in
            self.moc.mergeChangesFromContextDidSaveNotification(notification)
            self.fetchLog()
        }
    }
    

    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resentments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") 
        let logItem = resentments[indexPath.row]

        cell!.textLabel?.text = logItem.who
        return cell!
    }

    override func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            if editingStyle == .Delete {
                        moc.deleteObject(resentments[indexPath.row])
                do {
                    try
                        ObjectContext.managedObjectContext.save()
                }
                catch{
                    
                }
            }
            fetchLog()
    }
    
    

    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "Resentment")
        let sortDescriptor = NSSortDescriptor(key: "who", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        do
        {
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Resentment]
            {
                resentments  = fetchResults
            }
        
        }
        catch
        {
            
        }
        
        self.refreshControl!.endRefreshing()
        self.tableView.reloadData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

