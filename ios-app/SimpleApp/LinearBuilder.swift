
import UIKit

/**
 * Builds a view with some subviews in a linear order (similar to Android's LinearLayout)
 * You usually want to call addBottomConstraint() after adding all views
 */

class LinearBuilder {

    let axis : UILayoutConstraintAxis
    let crossAxis : UILayoutConstraintAxis
    let layout : LayoutBuilder

    // margins
    private var ends: Float = 0
    private var sides: Float = 0
    private var between: Float = 0

    private var viewIsBuilt = false
    private var numViews = 0


    convenience init(axis: UILayoutConstraintAxis)
    {
        self.init(axis: axis, layout: LayoutBuilder())
    }

    convenience init(axis: UILayoutConstraintAxis, view: UIView)
    {
        self.init(axis: axis, layout: LayoutBuilder(view: view))
    }

    convenience init(axis: UILayoutConstraintAxis, controller: UIViewController)
    {
        self.init(axis: axis, layout: LayoutBuilder(controller: controller))
    }

    init(axis: UILayoutConstraintAxis, layout: LayoutBuilder)
    {
        self.axis = axis
        self.crossAxis = axis == .Vertical ? .Horizontal : .Vertical
        self.layout = layout
    }

    func withMargins(ends ends: Float, sides: Float, between: Float) -> LinearBuilder {
        self.ends = ends
        self.sides = sides
        self.between = between
        return self
    }
    
    func addViews(views: [UIView]) -> LinearBuilder
    {
        return addViews(views, centered: false)
    }

    func addViews(views: [UIView], centered: Bool) -> LinearBuilder
    {
        // For first view, it's aligned to superview "|" with `ends` margin
        // For next views, it's aligned to previous view "[vN]" with `between` margin
        let mainConstrainPrefix = numViews == 0 ?
                "|-(e)-" : "[\(viewKey(numViews))]-(b)-"

        var keys : [String] = []

        for view in views {
            numViews += 1
            let key = viewKey(numViews)
            keys.append(key)
            layout.addView(view, key: key)
        }

        let axisLetter = getAxisLetter(axis)
        let crossAxisLetter = getAxisLetter(crossAxis)
        let center = getCenter(crossAxis)

        updateMetrics()

        for key in keys {
            let crossAxisConstraint =
                centered ?
                    "X:parent.\(center) == \(key).\(center)" :
                    "\(crossAxisLetter):|-(s)-[\(key)]-(s)-|"
            layout.addConstraint(crossAxisConstraint)
        }

        let axisConstraint = "\(axisLetter):" + mainConstrainPrefix +
                "[" + keys.joinWithSeparator("]-(b)-[") + "]"
        layout.addConstraint(axisConstraint)

        return self
    }

    /**
     * Adds the bottom constraint so the last view is aligned
     * with the bottom of the parent view.
     */
    func addBottomConstraint() -> LinearBuilder {

        updateMetrics()
        let axisLetter = getAxisLetter(axis)
        let lastViewKey = viewKey(numViews)
        let lastAxisConstraint = "\(axisLetter):[\(lastViewKey)]-(e)-|"
        layout.addConstraint(lastAxisConstraint)
        viewIsBuilt = true

        return self
    }

    /** Gets built view */
    func getView() -> UIView {
        return layout.view
    }

    /** Gets built view inside a ScrollView */
    func getViewInScrollView() -> UIView {
        return LayoutBuilder().fillWithScrollView(axis, contentView: layout.view).view
    }

    private func viewKey(index: Int) -> String {
        return "v\(index)"
    }

    private func updateMetrics() {
        layout.withMetrics(["e":ends, "s":sides, "b":between])
    }

    private func getAxisLetter(axis: UILayoutConstraintAxis) -> String {
        return axis == .Vertical ? "V" : "H"
    }

    private func getCenter(axis: UILayoutConstraintAxis) -> String {
        return axis == .Vertical ? "centerY" : "centerX"
    }
}
