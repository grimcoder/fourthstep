import UIKit

class ResentmentView: UIViewController {
    
    var resentment: Resentment? = nil
    
    @IBOutlet weak var WhoTextBox: UITextField!
    

    @IBOutlet weak var WhoLabel: UILabel!
    @IBOutlet weak var AffectedTextBox: UITextView!
    @IBOutlet weak var DidWhatTextBox: UITextView!


    @IBAction func Save(sender: AnyObject) {
        if resentment != nil {
            
                resentment?.who = WhoTextBox.text
                resentment?.didwhat = DidWhatTextBox.text
                resentment?.affectedMy = AffectedTextBox.text
            
        }
        else{
            
            Resentment.createInManagedObjectContext(ObjectContext.managedObjectContext, who: WhoTextBox.text!, didwhat: DidWhatTextBox.text, affectedMy: AffectedTextBox.text)
        }

        do {
            try
                ObjectContext.managedObjectContext.save()
        }
            
        catch{
            
        }
        
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    override func viewDidLoad() {
        WhoTextBox.text = resentment?.who
        AffectedTextBox.text = resentment?.affectedMy
        DidWhatTextBox.text = resentment?.didwhat
        
    }
}
