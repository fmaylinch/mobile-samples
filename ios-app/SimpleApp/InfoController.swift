
import UIKit

class InfoController : UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Test app (second view)"
        self.view.backgroundColor = .whiteColor()
        self.edgesForExtendedLayout = .None
        
        let label = UILabel()
        label.text = "Second view, you can just go back. To go back, click the back button on the nav bar above, or this button below."
        label.numberOfLines = 0
        
        let button = UIButton()
        button.setTitle("Go back", forState: .Normal)
        button.setTitleColor(.blueColor(), forState: .Normal)
        button.addTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
        
        LinearBuilder(axis: .Vertical, controller: self)
            .withMargins(ends: 20, sides: 20, between: 20)
            .addViews([label])
            .addViews([button], centered: true)
    }
    
    func goBack()
    {
        self.navigationController!.popViewControllerAnimated(true)
    }
}
