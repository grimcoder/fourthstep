import Foundation
import CoreData

extension Resentment {

    @NSManaged var who: String?
    @NSManaged var didwhat: String?
    @NSManaged var affectedMy: String?
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, who: String, didwhat: String, affectedMy: String ) -> Resentment {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Resentment", inManagedObjectContext: moc) as! Resentment
        
        newItem.who = who
        newItem.didwhat = didwhat
        newItem.affectedMy = affectedMy
        
        return newItem
    }
    

}
