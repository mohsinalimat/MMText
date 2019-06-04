//
//  MMTextView.swift
//  MMText
//
//  Created by Millman on 2019/6/3.
//

import Foundation
import UIKit

extension MMTextView {
    public enum LineType {
        case left
        case center
        case right
    }
}

@IBDesignable
public class MMTextView: UITextView {
    private static var defaultMargin: CGFloat = 8
    private static var systemPlaceHolderColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
    var isFitContent: Bool {
        set  {
            self.isScrollEnabled = !newValue
        } get {
            return self.isScrollEnabled
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private var lineView: UIView & LineViewProtocol = LineLeftAnimateView()
    private lazy var lineContainerView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = UIColor.clear
        v.clipsToBounds = false
        self.addSubview(v)
        return v
    }()
    
    private var placeHolderLabel: UITextView = {
        let label = UITextView()
        label.backgroundColor = UIColor.clear
        label.isScrollEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = MMTextView.systemPlaceHolderColor
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private var titleLabel: MMTextLabel = {
        let label = MMTextLabel()
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private var errorLabel: MMTextLabel = {
        let label = MMTextLabel()
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    public var lineType: LineType = .left {
        didSet {
            lineView.removeFromSuperview()
            switch lineType {
            case .left:
                lineView = LineLeftAnimateView()
            case .right:
                lineView = LineRightAnimateView()
            case .center:
                lineView = LineCenterView()
            }
            lineView.lineWidth = CGFloat(lineWidth)
            lineView.lineColor = lineColor
            lineView.editWidth = CGFloat(editLineWidth)
            lineView.editColor = editLineColor
            self.lineContainerView.addSubview(lineView)
            lineView.layout
                .setTop(anchor: self.lineContainerView.topAnchor, type: .equal(constant: 0))
                .setLeading(anchor: self.lineContainerView.leadingAnchor, type: .equal(constant: 0))
                .setTrailing(anchor: self.lineContainerView.trailingAnchor, type: .equal(constant: 0))
                .setBottom(anchor: self.lineContainerView.bottomAnchor, type: .equal(constant: 0))
        }
    }
    
    // MARK: - Public Parameter
    @IBInspectable
    public var titleFromPlaceHolder: Bool = false {
        didSet {
            self.titleLabel.text = titleFromPlaceHolder ? placeholder : title
        }
    }
    
    @IBInspectable
    public var title: String?  {
        set {
            if titleFromPlaceHolder { return }
            self.titleLabel.text = newValue
            self.titleLabel.sizeToFit()
            titleLabel.layout[.bottom]?.constant = -realTopMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        } get {
            return self.titleLabel.text
        }
    }
    
    public var attributeTitle: NSAttributedString? {
        set {
            if titleFromPlaceHolder { return }
            self.titleLabel.attributedText = newValue
            self.titleLabel.sizeToFit()
            titleLabel.layout[.bottom]?.constant = -realTopMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        } get {
            return self.titleLabel.attributedText
        }
    }
    
    @IBInspectable
    public var titleMargin: CGFloat = 5 {
        didSet {
            titleLabel.layout[.bottom]?.constant = -realTopMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()

        }
    }
    
    @IBInspectable
    public var titleColor: UIColor = UIColor.black {
        didSet {
            self.titleLabel.textColor = titleColor
        }
    }
    
    @IBInspectable
    public var errorTitle: String? = nil {
        didSet {
            self.errorLabel.text = errorTitle
            self.errorLabel.sizeToFit()
            errorLabel.layout[.top]?.constant = realBottomMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        }
    }
    
    public var errorAttributeTitle: NSAttributedString? = nil {
        didSet {
            self.errorLabel.attributedText = errorAttributeTitle
            self.errorLabel.sizeToFit()
            errorLabel.layout[.top]?.constant = realBottomMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var errorMargin: CGFloat = 5 {
        didSet {
            errorLabel.layout[.top]?.constant = realBottomMargin
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var errorColor: UIColor = UIColor.red {
        didSet {
            self.errorLabel.textColor = errorColor
        }
    }
    
    @IBInspectable
    public var lineWidth:Float = 1 {
        didSet {
            self.lineView.lineWidth = CGFloat(lineWidth)
        }
    }
    
    @IBInspectable
    public var lineColor: UIColor? = UIColor.black {
        didSet {
            self.lineView.lineColor = lineColor
        }
    }
    
    @IBInspectable
    public var editLineWidth:Float = 2 {
        didSet {
            self.lineView.editWidth = CGFloat(editLineWidth)
        }
    }
    
    @IBInspectable
    public var editLineColor: UIColor? = UIColor.black {
        didSet {
            self.lineView.editColor = editLineColor
        }
    }
    
    override public var textColor: UIColor? {
        didSet {
            self.tintColor = textColor
        }
    }
    
    override public var font: UIFont? {
        didSet {
            self.placeHolderLabel.font = font
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        let topBotMargin = realTopHeight+realBottomHeight
        let width = self.textContainer.size.width
        let font = self.font
        let textHeight = (self.text ?? "").calHeightWith(width: width, font: font)
        let placeHeight = (self.placeHolderLabel.text ?? "").calHeightWith(width: width, font: font)

        let textH = max(textHeight,placeHeight) + 2*MMTextView.defaultMargin
        size.height = topBotMargin + textH 
        self.lineContainerView.layout[.height]?.constant  = textH
        self.textContainerInset = UIEdgeInsets(top: realTopHeight+MMTextView.defaultMargin,
                                               left: 0,
                                               bottom: realBottomHeight+MMTextView.defaultMargin,
                                               right: 0)
        return size
    }
    @IBInspectable
    public var placeholder: String? {
        didSet {
            self.placeHolderLabel.text = placeholder
        }
    }
    
    override public var text: String? {
        didSet {
            self.valueChange()
        }
    }
    
    override public var attributedText: NSAttributedString? {
        didSet {
            self.valueChange()
        }
    }
    
    override public var textAlignment: NSTextAlignment {
        didSet {
            self.titleLabel.textAlignment = textAlignment
            self.errorLabel.textAlignment = textAlignment
            self.placeHolderLabel.textAlignment = textAlignment
        }
    }
}

extension MMTextView {
    func setup() {
        self.textContainer.lineFragmentPadding = 0
        self.placeHolderLabel.textContainer.lineFragmentPadding = 0

        NotificationCenter.default.addObserver(forName: UITextView.textDidBeginEditingNotification, object: nil, queue: OperationQueue.main) { [weak self] (value) in
            if let o = value.object as? UITextView , o == self {
                self?.beginEdit()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UITextView.textDidEndEditingNotification, object: nil, queue: OperationQueue.main) { [weak self] (value) in
            if let o = value.object as? UITextView , o == self {
                self?.endEdit()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] (value) in
            if let o = value.object as? UITextView , o == self {
                self?.valueChange()
            }
        }
        self.tintColor = textColor
        self.lineType = .left
        let t = self.textAlignment
        self.textAlignment = t
        self.addSubview(titleLabel)
        self.addSubview(placeHolderLabel)
        self.addSubview(errorLabel)
        self.errorColor = UIColor.red
        self.titleColor = UIColor.black
        self.lineContainerView.addSubview(self.lineView)
        self.editLineWidth = 2
        self.lineWidth = 1
        self.placeHolderLabel.font = font
        lineContainerView.layout
            .setCenterX(anchor: self.centerXAnchor, type: .equal(constant: 0))
            .setWidth(type: .equalTo(anchor: self.widthAnchor, multiplier: 1, constant: 0))
            .setHeight(type: .greaterThanOrEqual(constant: 0))
        titleLabel.layout
            .setTop(anchor: self.topAnchor, type: .equal(constant: 0))
            .setCenterX(anchor: self.centerXAnchor, type: .equal(constant: 0))
            .setWidth(type: .equalTo(anchor: self.widthAnchor, multiplier: 1, constant: 0))
            .setBottom(anchor: self.lineContainerView.topAnchor, type: .equal(constant: 0))
        
        errorLabel.layout
            .setTop(anchor: self.lineContainerView.bottomAnchor, type: .equal(constant: 0))
            .setLeft(anchor: self.lineContainerView.leftAnchor, type: .equal(constant: 0))
            .setRight(anchor: self.lineContainerView.rightAnchor, type: .equal(constant: 0))
        placeHolderLabel.layout
            .setTop(anchor: self.lineContainerView.topAnchor, type: .equal(constant: 0))
            .setLeading(anchor: self.lineContainerView.leadingAnchor, type: .equal(constant: 0))
            .setTrailing(anchor: self.lineContainerView.trailingAnchor, type: .equal(constant: 0))
            .setBottom(anchor: self.lineContainerView.bottomAnchor, type: .equal(constant: 0))
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
        }
    }

    private var realTopHeight: CGFloat {
        return titleLabel.frame.height > 0 ? titleLabel.frame.height + titleMargin : 0
    }
    
    private var realBottomHeight: CGFloat {
        return errorLabel.frame.height > 0 ? errorLabel.frame.height + errorMargin : 0
    }
    
    private var realTopMargin: CGFloat {
        return titleLabel.frame.height > 0 ? titleMargin : 0
    }
    
    private var realBottomMargin: CGFloat {
        return errorLabel.frame.height > 0 ? errorMargin : 0
    }
    
    @objc func beginEdit() {
        lineView.beginEdit()
        self.valueChange()
        if self.titleFromPlaceHolder {
            placeHolderLabel.font = titleLabel.font
            placeHolderLabel.textColor = self.textColor
            placeHolderLabel.layout.setTop(anchor: self.topAnchor, type: .equal(constant: 0))
                .setHeight(type: .equalTo(anchor: self.titleLabel.heightAnchor, multiplier: 1, constant: 0))
            UIView.animate(withDuration: 0.1) { self.layoutIfNeeded() }
        }
    }
    
    @objc func endEdit() {
        lineView.endEdit()
        self.valueChange()
        if self.titleFromPlaceHolder {
            placeHolderLabel.font = self.font
            placeHolderLabel.textColor = MMTextView.systemPlaceHolderColor
            
            placeHolderLabel.layout
                .setTop(anchor: self.lineContainerView.topAnchor, type: .equal(constant: 0))
                .setHeight(type: .equalTo(anchor: self.lineContainerView.heightAnchor, multiplier: 1, constant: 0))
            UIView.animate(withDuration: 0.1) { self.layoutIfNeeded() }
        }
    }
    
    @objc func valueChange() {
        let textNotEmpty = self.text?.isEmpty == false || self.attributedText?.string.isEmpty == false
        if titleFromPlaceHolder {
            self.placeHolderLabel.isHidden = textNotEmpty && !self.isFocused
        } else {
            self.placeHolderLabel.isHidden = textNotEmpty
        }
    }
}
