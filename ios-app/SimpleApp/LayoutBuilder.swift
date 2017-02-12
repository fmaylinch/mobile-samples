
/** Helper class for creating layouts */

import UIKit

public class LayoutBuilder {
    
    /** Use this identifier to refer to parent view in extended constraints (you can change it) */
    public static var parentViewKey = "parent"
    /** This identifier is used in some methods like fillWithView */
    public static var defaultViewKey = "view"
    public static let XtConstraintPrefix = "X"
    public static let DefaultPriority: UILayoutPriority = 0
    private static let TopGuideKey = "TOP_GUIDE"
    private static let BottomGuideKey = "BOTTOM_GUIDE"
    
    public let view: UIView
    private var viewOfController = false // view is the UIView of a UIViewController
    private var subviews = [String:AnyObject]() // may contain UILayoutGuide objects
    public var metrics = [String:Float]()
    
    public var displayRandomColors = false
    
    /** The subviews and constraints will be added to the given `view` */
    public init(view: UIView) {
        self.view = view
    }

    /** Inits object with a the view of a controller */
    public convenience init(controller: UIViewController) {
        self.init(view: controller.view)
        viewOfController = true
        addGuides([
                LayoutBuilder.TopGuideKey:controller.topLayoutGuide,
                LayoutBuilder.BottomGuideKey:controller.bottomLayoutGuide])
    }

    /** Inits object with a new UIView as main view */
    public convenience init() {
        self.init(view: UIView())
    }
    
    // Add views
    
    public func fillWithView(view: UIView) -> LayoutBuilder {
        return fillWithView(view, margins: UIEdgeInsetsMake(0,0,0,0))
    }
    
    public func fillWithView(view: UIView, margins:UIEdgeInsets) -> LayoutBuilder
    {
        // In the view of a controller, we use layout guides as vertical anchors
        let topKey = viewOfController ? "[\(LayoutBuilder.TopGuideKey)]" : "|"
        let bottomKey = viewOfController ? "[\(LayoutBuilder.BottomGuideKey)]" : "|"
        
        let key = LayoutBuilder.defaultViewKey
        
        return addView(view, key: key)
            .withMetrics([
                "left":Float(margins.left), "right":Float(margins.right),
                "top":Float(margins.top), "bottom":Float(margins.bottom)])
            .addConstraints([
                "H:|-(left)-[\(key)]-(right)-|",
                "V:\(topKey)-(top)-[\(key)]-(bottom)-\(bottomKey)"])
    }
    
    public func addViews(views: [String:UIView]) -> LayoutBuilder {
        return addViews(views, addToParent:true)
    }
    
    /** 
     * Adds views to the main view.
     * Use `addToParent: false` if you just want to use the views in the constraints but not add them to main view.
     */
    public func addViews(views: [String:UIView], addToParent:Bool) -> LayoutBuilder {
        for (key,view) in views {
            addView(view, key:key, addToParent:addToParent)
        }
        return self
    }
    
    public func addView(view:UIView, key:String) -> LayoutBuilder {
        return addView(view, key: key, addToParent:true)
    }
    
    public func addView(view:UIView, key:String, addToParent:Bool) -> LayoutBuilder {
        
        subviews[key] = view
        
        if !addToParent { return self }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        
        if displayRandomColors {
            view.backgroundColor = LayoutBuilder.getRandomColorWithAlpha(0.4)
        }
        
        return self
    }

    // Remove views

    public func removeAllViews()
    {
        removeViewsWithKeys(Array(subviews.keys))
    }

    public func removeViewsWithKeys(keysToRemove: [String])
    {
        for key in keysToRemove {
            if let view = subviews[key] as? UIView {
                view.removeFromSuperview()
                subviews.removeValueForKey(key)
            }
        }
    }

    // Scroll view

    /**
     * Configures a UIScrollView you have added before (with given key) to scroll in the specified axis (direction).
     * The contentView is configured to fill the scroll view and to be as wide as the layout main view.
     */
    public func configureScrollView(scrollViewKey: String, axis: UILayoutConstraintAxis, contentView: UIView) -> LayoutBuilder
    {
        let scrollView = subviews[scrollViewKey] as! UIScrollView // you should have added it
        LayoutBuilder(view: scrollView).fillWithView(contentView)

        let crossAxisLetter: String = axis == .Vertical ? "H" : "V"

        // Make the scrollView's contentView match cross axis size with main view (main view contains scrollView)
        // For example, in a vertical scrollView, the contentView has the same width (horizontal size) as the main view
        let constraint = "\(crossAxisLetter):|[content(==main)]|"
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constraint,
                options: [], metrics: nil, views: ["content":contentView, "main":self.view]))

        return self
    }

    /**
     * Convenience method when you want a UIScrollView to fill the main view and scroll in the given axis.
     * The contentView is the content of the scroll view.
     */
    public func fillWithScrollView(axis: UILayoutConstraintAxis, contentView: UIView) -> LayoutBuilder
    {
        fillWithView(UIScrollView()) // scrollView is added with defaultViewKey
        return configureScrollView(LayoutBuilder.defaultViewKey, axis: axis, contentView:contentView)
    }

    // Layout support guides
    
    public func addGuides(guides: [String:UILayoutSupport]) -> LayoutBuilder {
        for (key,guide) in guides {
            subviews[key] = guide
        }
        return self
    }
    
    // Various
    
    public func withRandomColors(displayRandomColors: Bool) -> LayoutBuilder {
        self.displayRandomColors = displayRandomColors
        return self
    }
    
    public func withMetrics(metrics: [String:Float]) -> LayoutBuilder {
        self.metrics = metrics
        return self
    }
    
    // Hugging and compression - http://stackoverflow.com/questions/33842797
    
    /** Tries to simulate Android's wrap_content by setting hugging and compression to view and children (recursively) */
    public func setWrapContent(viewKey:String, axis: UILayoutConstraintAxis) -> LayoutBuilder {
        
        let view = findViewFromKey(viewKey)
        return setWrapContent(view, axis: axis)
    }
    
    /** Tries to simulate Android's wrap_content by setting hugging and compression to view and children (recursively) */
    public func setWrapContent(view:UIView, axis: UILayoutConstraintAxis) -> LayoutBuilder {
        
        setHugging(view, priority: UILayoutPriorityDefaultHigh, axis: axis)
        setResistance(view, priority: UILayoutPriorityRequired, axis: axis)
        return self
    }
    
    /** Sets hugging priority to view with given key and children (recursively) */
    public func setHugging(viewKey:String, priority:UILayoutPriority, axis: UILayoutConstraintAxis) -> LayoutBuilder {
        
        let view = findViewFromKey(viewKey)
        return setHugging(view, priority: priority, axis: axis)
    }
    
    /** Sets hugging priority to view and children (recursively) */
    public func setHugging(view:UIView, priority:UILayoutPriority, axis: UILayoutConstraintAxis) -> LayoutBuilder {
        
        view.setContentHuggingPriority(priority, forAxis: axis)
        for v in view.subviews {
            setHugging(v, priority: priority, axis: axis) // recursive
        }
        return self
    }
    
    /** Sets compression resistance priority to view with given key and children (recursively) */
    public func setResistance(viewKey:String, priority:UILayoutPriority, axis: UILayoutConstraintAxis) -> LayoutBuilder {
        
        let view = findViewFromKey(viewKey)
        return setResistance(view, priority: priority, axis: axis)
    }
    
    /** Sets compression resistance priority to view and children (recursively) */
    public func setResistance(view:UIView, priority:UILayoutPriority, axis: UILayoutConstraintAxis) -> LayoutBuilder {
        
        view.setContentCompressionResistancePriority(priority, forAxis: axis)
        for v in view.subviews {
            setResistance(v, priority: priority, axis: axis) // recursive
        }
        return self
    }
    
    
    // Constraints
    
    public func addConstraints(cs:[String]) -> LayoutBuilder {
        return addConstraints(cs, priority: LayoutBuilder.DefaultPriority)
    }
    
    public func addConstraints(cs:[String], priority:UILayoutPriority) -> LayoutBuilder {
        for c in cs {
            addConstraint(c, priority: priority)
        }
        return self
    }
    
    public func addConstraint(c:String) -> LayoutBuilder {
        return addConstraint(c, priority: LayoutBuilder.DefaultPriority)
    }

    public func addConstraint(c:String, priority:UILayoutPriority) -> LayoutBuilder {
        addAndGetConstraint(c, priority: priority)
        return self
    }

    /** Adds a constraint and returns the generated NSLayoutConstraint objects */
    public func addAndGetConstraint(c:String) -> [NSLayoutConstraint]
    {
        return addAndGetConstraint(c, priority: LayoutBuilder.DefaultPriority)
    }

    /** Adds a constraint (with given priority) and returns the generated NSLayoutConstraint objects */
    public func addAndGetConstraint(c:String, priority:UILayoutPriority) -> [NSLayoutConstraint]
    {
        let realConstraints = parseConstraint(c)

        if priority != LayoutBuilder.DefaultPriority {
            for realConstraint in realConstraints {
                realConstraint.priority = priority;
            }
        }

        self.view.addConstraints(realConstraints)

        return realConstraints
    }

    /** Parses a constraint, either a normal Visual Format constraint (H,V) or an extended (X) constraint */
    private func parseConstraint(c:String) -> [NSLayoutConstraint] {
        
        if c.hasPrefix(LayoutBuilder.XtConstraintPrefix) {
            return parseXtConstraint(c)
        }
        else {
            return NSLayoutConstraint.constraintsWithVisualFormat(c,
                options: NSLayoutFormatOptions(), metrics: metrics, views: subviews)
        }
    }
    
    /** Parses an extended (X) constraint */
    private func parseXtConstraint(constraint: String) -> [NSLayoutConstraint]
    {
        let results = LayoutBuilder.xtConstraintRegex.matchesInString(constraint,
            options: NSMatchingOptions(), range: NSMakeRange(0, constraint.characters.count))
        
        if results.count != 1 {
            fatalError("Invalid constraint: \(constraint)")
        }
        
        let match: NSTextCheckingResult = results[0]
        if match.numberOfRanges != 10 {
            dumpMatch(match, forString: constraint)
            fatalError("Invalid constraint: \(constraint)")
        }
        let item1Key: String = constraint.substring(match.rangeAtIndex(1))
        let attr1Str: String = constraint.substring(match.rangeAtIndex(2))
        let relationStr: String = constraint.substring(match.rangeAtIndex(3))
        let item2Key: String = constraint.substring(match.rangeAtIndex(4))
        let attr2Str: String = constraint.substring(match.rangeAtIndex(5))
        let item1: AnyObject = findViewFromKey(item1Key)
        let item2: AnyObject = findViewFromKey(item2Key)
        let attr1: NSLayoutAttribute = parseAttribute(attr1Str)
        let attr2: NSLayoutAttribute = parseAttribute(attr2Str)
        let relation: NSLayoutRelation = parseRelation(relationStr)
        var multiplier: Float = 1
        if match.rangeAtIndex(6).location != NSNotFound {
            let operation: String = constraint.substring(match.rangeAtIndex(6))
            let multiplierValue: String = constraint.substring(match.rangeAtIndex(7))
            multiplier = getFloat(multiplierValue)
            if (operation == "/") { // TODO: deprecate this, I think it leads to weird behaviour sometimes
                multiplier = 1 / multiplier
            }
        }
        var constant: Float = 0
        if match.rangeAtIndex(8).location != NSNotFound {
            let operation: String = constraint.substring(match.rangeAtIndex(8))
            let constantValue: String = constraint.substring(match.rangeAtIndex(9))
            constant = getFloat(constantValue)
            if (operation == "-") {
                constant = -constant
            }
        }
        let c: NSLayoutConstraint = NSLayoutConstraint(
            item: item1, attribute: attr1, relatedBy: relation,
            toItem: item2, attribute: attr2, multiplier: CGFloat(multiplier), constant: CGFloat(constant))
        
        return [c]
    }
    
    /** `value` may be the name of a metric, or a literal float value */
    private func getFloat(value: String) -> Float
    {
        if stringIsIdentifier(value) {
            if let metric = metrics[value] {
                return metric
            }
            else {
                let reason = "Metric `\(value)` was not provided"
                fatalError(reason)
            }
        }
        else {
            return (value as NSString).floatValue
        }
    }
    
    /** Returns true if `value` starts with a valid identifier character */
    private func stringIsIdentifier(value: String) -> Bool {
        let c = value[value.startIndex] // gets first char of string
        return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_"
    }
    
    private func findViewFromKey(key: String) -> UIView
    {
        if (key == LayoutBuilder.parentViewKey) {
            return self.view
        }
        else {
            if let view = subviews[key] as? UIView {
                return view
            }
            else {
                let reason = "No view was added with key `\(key)`"
                fatalError(reason)
            }
        }
    }
    
    private static let attributes : [String:NSLayoutAttribute] = [
        "left": .Left, "right": .Right, "top": .Top, "bottom": .Bottom,
        "leading": .Leading, "trailing": .Trailing,
        "width": .Width, "height": .Height,
        "centerX": .CenterX, "centerY": .CenterY,
        "baseline": .LastBaseline]
    
    private func parseAttribute(attrStr: String) -> NSLayoutAttribute
    {
        if let value = LayoutBuilder.attributes[attrStr] {
            return value
        }
        else {
            let reason = "Attribute `\(attrStr)` is not valid. Use one of: \(LayoutBuilder.attributes.keys)"
            fatalError(reason)
        }
    }
    
    private static let relations : [String:NSLayoutRelation] = [
        "==": .Equal, ">=": .GreaterThanOrEqual, "<=": .LessThanOrEqual]
    
    private func parseRelation(relationStr: String) -> NSLayoutRelation
    {
        if let value = LayoutBuilder.relations[relationStr] {
            return value
        }
        else {
            let reason = "Relation `\(relationStr)` is not valid. Use one of: \(LayoutBuilder.relations.keys)"
            fatalError(reason)
        }
    }
    
    private static var xtConstraintRegex = LayoutBuilder.prepareRegex()
    
    private static func prepareRegex() -> NSRegularExpression {
        
        // C identifier
        let identifier: String = "[_a-zA-Z][_a-zA-Z0-9]{0,30}"
        // VIEW_KEY.ATTR or (use LayoutBuilder.parentViewKey as VIEW_KEY to refer to parent view)
        let attr: String = "(\(identifier))\\.(\(identifier))"
        // Relations taken from NSLayoutRelation
        let relation: String = "([=><]+)"
        // float number e.g. "12", "12.", "2.56"
        let number: String = "\\d+\\.?\\d*"
        // Value (indentifier or number)
        let value: String = "(?:(?:\(identifier))|(?:\(number)))"
        // e.g. "*5" or "/ 27.3" or "* 200"
        let multiplier: String = "([*/]) *(\(value))"
        // e.g. "+ 2." or "- 56" or "-7.5"
        let constant: String = "([+-]) *(\(value))"
        let pattern: String = "^\(XtConstraintPrefix): *\(attr) *\(relation) *\(attr) *(?:\(multiplier))? *(?:\(constant))?$"
        
        return try! NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
    }
    
    static func getRandomColorWithAlpha(alpha: CGFloat) -> UIColor
    {
        let red = arc4random_uniform(256)
        let green = arc4random_uniform(256)
        let blue = arc4random_uniform(256)
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    private func dumpMatch(match: NSTextCheckingResult, forString str: String)
    {
        for i in 0 ..< match.numberOfRanges {
            
            let range = match.rangeAtIndex(i)
            
            if range.location != NSNotFound {
                let part = str.substring(range)
                print("Range \(i): \(part)")
            }
            else {
                print("Range \(i)  NOT FOUND")
            }
        }
    }
}
