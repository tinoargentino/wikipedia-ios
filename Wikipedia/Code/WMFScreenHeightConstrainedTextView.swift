
private extension CGFloat {
    func constrainedBetween(minHeight: Int, maxPercentOfScreenHeight: Int) -> CGFloat {
        assert(minHeight >= 0, "minHeight should be at least 0")
        assert(maxPercentOfScreenHeight <= 100, "maxPercentOfScreenHeight should be no more than 100")
        let screenHeight = UIScreen.main.bounds.size.height
        let proportionOfScreenHeight = screenHeight > 0.0 ? self / screenHeight : 0.0
        var constrainedHeight = self
        let maxAllowedProportionOfScreenHeight = CGFloat(maxPercentOfScreenHeight) / 100.0
        if (proportionOfScreenHeight > maxAllowedProportionOfScreenHeight) {
            constrainedHeight = screenHeight * maxAllowedProportionOfScreenHeight
        }
        return fmax(CGFloat(minHeight), constrainedHeight)
    }
}

private enum OpenStatePercent: Int {
    case normal = 22, maximized = 60
}

@objc class WMFScreenHeightConstrainedTextView: UITextView {
    private let minHeight = 30
    private var maxPercentOfScreenHeight: Int {
        get {
            return openStatePercent.rawValue
        }
    }
    
    private var openStatePercent: OpenStatePercent = .normal {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    @objc func toggleOpenState() {
        openStatePercent = openStatePercent == .normal ? .maximized : .normal
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        assert(contentCompressionResistancePriority(for: .vertical) == .required, "vertical contentCompressionResistancePriority must be `.required` for height to correctly account for text height.")
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = size.height.constrainedBetween(minHeight: minHeight, maxPercentOfScreenHeight: maxPercentOfScreenHeight)
        return size
    }

    override func invalidateIntrinsicContentSize() {
        isScrollEnabled = false // UITextView intrinsicContentSize only works when scrolling is false
        super.invalidateIntrinsicContentSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isScrollEnabled = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setContentOffset(.zero, animated: false)
        invalidateIntrinsicContentSize() // Needed so height is correctly adjusted on rotation.
    }
}