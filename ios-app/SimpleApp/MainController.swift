
import UIKit

// UIViewController is like an Activity in Android.
// The colon `:` is like `extends` in Java.

class MainController : UIViewController {

    var info : UILabel!
    var field : UITextField!
    
    // like Android onCreate()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Test app"
        self.view.backgroundColor = .whiteColor()
        self.edgesForExtendedLayout = .None // so views don't appear behind the nav bar

        info = UILabel()
        info.text = "Enter your email so we can send you"
            + " information about our products when they are available"
        info.numberOfLines = 0
        
        // TextView text = new TextView()
        let label = UILabel()
        label.text = "Email"
        //label.textAlignment = .Center
        //label.textColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)
        //label.backgroundColor = UIColor.brownColor()
        
        field = UITextField()
        field.placeholder = "your email"
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.blackColor().CGColor
        field.layer.cornerRadius = 7
        field.layer.masksToBounds = true
        
        let button = UIButton()
        button.setTitle("Send", forState: .Normal)
        button.setTitleColor(.blueColor(), forState: .Normal)
        
        // Add listener to button, when it's clicked the sendEmail() function will be called
        button.addTarget(self, action: #selector(sendEmail), forControlEvents: .TouchUpInside)
        
        // Builds a row with a label, a field and a button
        let row = LinearBuilder(axis: .Horizontal)
            .withMargins(ends: 0, sides: 0, between: 20)
            .addViews([label, field, button])
            .addBottomConstraint()
            .layout // get layout to add more specific constraints
            .setWrapContent(button, axis: .Horizontal)
            .setWrapContent(label, axis: .Horizontal)
            .view
        
        // The whole view is a vertical layout with the info label and the row view
        LinearBuilder(axis: .Vertical, controller: self)
            .withMargins(ends: 20, sides: 20, between: 20)
            .addViews([info, row])
    }
    
    func sendEmail()
    {
        let email = field.text!
        info.text = "Thanks for contacting us: \(email)"
        
        let ctrl = InfoController()
        pushController(ctrl)
    }
    
    // Opens the controller
    func pushController(ctrl: UIViewController)
    {
        let backBtn = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBtn;
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
}
