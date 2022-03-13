
import UIKit
import Foundation
import CoreFoundation
import CoreText
import CoreGraphics

public enum THLabelStrokePosition : Int {
    case outside
    case center
    case inside
}

open
class THLabel: UILabel {
    
    // MARK: - Accessors and Mutators
    
    open var letterSpacing: CGFloat = 0.0
    open var lineSpacing: CGFloat = 0.0
    
    private var _shadowBlur: CGFloat = 0.0
    open var shadowBlur: CGFloat {
        get {
            return _shadowBlur
        }
        set {
            _shadowBlur = CGFloat(fmaxf(Float(newValue), 0.0))
        }
    }
    
    open var strokeSize: CGFloat = 0.0
    open var strokeColor: UIColor!
    open var strokePosition: THLabelStrokePosition  = THLabelStrokePosition.outside
    
    
    private var _textInsets : UIEdgeInsets  = UIEdgeInsets.zero
    open var textInsets : UIEdgeInsets {
        get {
            return _textInsets
        }
        set {
            if _textInsets != newValue {
                _textInsets = newValue
                self.setNeedsDisplay()
            }
        }
    }
    
    open var isAutomaticallyAdjustTextInsets: Bool = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.setDefaults()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setDefaults()
    }
    
    fileprivate func setDefaults() {
        self.clipsToBounds = true
        self.isAutomaticallyAdjustTextInsets = true
    }
    
    fileprivate func hasStroke() -> Bool {
        return self.strokeSize > 0.0 && !self.strokeColor.isEqual(UIColor.clear)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.intrinsicContentSize
    }
    
    override open var intrinsicContentSize: CGSize {
        get {
            if self.text == nil || (self.text == "") {
                return CGSize.zero
            }
            let textRect = self.frameRef(from: CGSize(width: CGFloat(self.preferredMaxLayoutWidth), height: CGFloat.greatestFiniteMagnitude)).CGRect
            let newWidth = textRect.width + self.textInsets.left + self.textInsets.right
            let newHeight = textRect.height + self.textInsets.top + self.textInsets.bottom
            return CGSize(width: CGFloat(ceilf(Float(newWidth))), height: CGFloat(ceilf(Float(newHeight))))
        }
    }
    
    fileprivate func strokeSizeDependentOnStrokePosition() -> CGFloat {
        switch self.strokePosition {
        case .center:
            return self.strokeSize
        default:
            return self.strokeSize * 2.0
        }
    }
    
    // MARK: - Drawing
    
    override open func draw(_ rect: CGRect) {
        if self.text == nil || (self.text == "") {
            return
        }
        
        let hasStroke = self.hasStroke()
        let needsMask = hasStroke && self.strokePosition == .inside
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        var alphaMask: CGImage? = nil
        let frame = self.frameRef(from: self.bounds.size)
        let frameRef = frame.CTFrame
        
        context.translateBy(x: 0.0, y: rect.height)
        context.scaleBy(x: 1.0, y: -1.0)

        
        if needsMask {
            context.saveGState()
            // Draw alpha mask.
            context.setTextDrawingMode(.fill)
            UIColor.white.setFill()
            CTFrameDraw(frameRef, context)
            // Save alpha mask.
            alphaMask = context.makeImage()
            // Clear the content.
            context.clear(rect)
            context.restoreGState()
        }
        context.saveGState()
        
        // Draw text.
        context.setTextDrawingMode(.fill)
        CTFrameDraw(frameRef, context)
        
        context.restoreGState()
        
        
        if hasStroke {
            context.saveGState()
            context.setTextDrawingMode(.stroke)
            var image: CGImage? = nil
            if self.strokePosition == .outside {
                image = context.makeImage()
            }
            else if self.strokePosition == .inside {
                context.clip(to: rect, mask: alphaMask!)
            }
            
            // Draw stroke.
            let strokeImage = self.strokeImage(with: rect, frameRef: frameRef, strokeSize: self.strokeSizeDependentOnStrokePosition(), stroke: self.strokeColor)
            context.draw(strokeImage, in: rect)
            if self.strokePosition == .outside {
                // Draw the saved image over half of the stroke.
                context.draw(image!, in: rect)
            }
            // Clean up.
            context.restoreGState()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        image.draw(in: rect)
    }
    
    fileprivate func frameRef(from size: CGSize) -> (CTFrame: CTFrame, CGRect: CGRect) {
        // Set up font.
        let fontRef = CTFontCreateWithFontDescriptor((self.font.fontDescriptor as CTFontDescriptor), self.font.pointSize, nil)
        var alignment = CTTextAlignment(self.textAlignment)
        var lineBreakMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode)
        var lineSpacing = self.lineSpacing
        let paragraphStyleSettings: [CTParagraphStyleSetting] = [
            CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout.size(ofValue: alignment), value: &alignment),
            CTParagraphStyleSetting(spec: .lineBreakMode, valueSize: MemoryLayout.size(ofValue: lineBreakMode), value: &lineBreakMode),
            CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: MemoryLayout.size(ofValue: lineSpacing), value: &lineSpacing)
        ]
        
        let paragraphStyleRef = CTParagraphStyleCreate(paragraphStyleSettings, paragraphStyleSettings.count)
        let kernRef = CFNumberCreate(kCFAllocatorDefault, .cgFloatType, &letterSpacing)
        // Set up attributed string.
        let keys: [String] = [kCTFontAttributeName as String, kCTParagraphStyleAttributeName as String, kCTForegroundColorAttributeName as String, kCTKernAttributeName as String]
        let values: [CFTypeRef] = [fontRef, paragraphStyleRef, self.textColor.cgColor, kernRef!]
        
        let attributes = NSDictionary(objects: values, forKeys: keys as [NSCopying])
        let stringRef = (self.text! as CFString)
        let attributedStringRef = CFAttributedStringCreate(kCFAllocatorDefault, stringRef, attributes as CFDictionary)
        // Set up frame.
        let framesetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef!)
        if self.isAutomaticallyAdjustTextInsets {
            self.textInsets = self.fittingTextInsets()
        }
        
        let contentRect = self.contentRect(from: size, with: self.textInsets)
        let textRect = self.textRect(fromContentRect: contentRect, framesetterRef: framesetterRef)
        let pathRef = CGMutablePath()
        pathRef.addRect(textRect, transform: .identity)
        let frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, (self.text?.count)!), pathRef, nil)
        
        return (frameRef, textRect)
    }
    
    fileprivate func contentRect(from size: CGSize, with insets: UIEdgeInsets) -> CGRect {
        var contentRect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(size.width), height: CGFloat(size.height))
        // Apply insets.
        contentRect.origin.x += insets.left
        contentRect.origin.y += insets.top
        contentRect.size.width -= insets.left + insets.right
        contentRect.size.height -= insets.top + insets.bottom
        return contentRect
    }
    
    fileprivate func textRect(fromContentRect contentRect: CGRect, framesetterRef: CTFramesetter) -> CGRect {
        var suggestedTextRectSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, (self.text?.count)!), nil, contentRect.size, nil)
        if suggestedTextRectSize.equalTo(CGSize.zero) {
            suggestedTextRectSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, (self.text?.count)!), nil, CGSize(width: CGFloat(CGFloat.greatestFiniteMagnitude), height: CGFloat(CGFloat.greatestFiniteMagnitude)), nil)
        }
        var textRect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(ceilf(Float(suggestedTextRectSize.width))), height: CGFloat(ceilf(Float(suggestedTextRectSize.height))))
        // Horizontal alignment.
        switch self.textAlignment {
        case .center:
            textRect.origin.x = CGFloat(floorf(Float(contentRect.minX + (contentRect.width - textRect.width) / 2.0)))
        case .right:
            textRect.origin.x = CGFloat(floorf(Float(contentRect.minX + contentRect.width - textRect.width)))
        default:
            textRect.origin.x = CGFloat(floorf(Float(contentRect.minX)))
        }
        
        // Vertical alignment. Top and bottom are upside down, because of inverted drawing.
        switch self.contentMode {
        case .top, .topLeft, .topRight:
            textRect.origin.y = CGFloat(floorf(Float(contentRect.minY + contentRect.height - textRect.height)))
        case .bottom, .bottomLeft, .bottomRight:
            textRect.origin.y = CGFloat(floorf(Float(contentRect.minY)))
        default:
            textRect.origin.y = CGFloat(floorf(Float(contentRect.minY) + floorf(Float((contentRect.height - textRect.height)) / 2.0)))
        }
        
        return textRect
    }
    
    fileprivate func fittingTextInsets() -> UIEdgeInsets {
        let hasStroke = self.hasStroke()
        var edgeInsets = UIEdgeInsets.zero
        if hasStroke {
            switch self.strokePosition {
            case .outside:
                edgeInsets = UIEdgeInsets(top: self.strokeSize, left: self.strokeSize, bottom: self.strokeSize, right: self.strokeSize)
            case .inside:
                edgeInsets = UIEdgeInsets(top: self.strokeSize / 2.0, left: self.strokeSize / 2.0, bottom: self.strokeSize / 2.0, right: self.strokeSize / 2.0)
            default:
                break
            }
        }
        
        return edgeInsets
    }
    
    // MARK: - Image Functions
    
    fileprivate func inverseMask(fromAlphaMask alphaMask: CGImage, with rect: CGRect) -> CGImage {
        // Create context.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        // Fill rect, clip to alpha mask and clear.
        UIColor.white.setFill()
        UIRectFill(rect)
        context.clip(to: rect, mask: alphaMask)
        context.clear(rect)
        // Return image.
        let image = context.makeImage()
        UIGraphicsEndImageContext()
        return image!
    }
    
    fileprivate func strokeImage(with rect: CGRect, frameRef: CTFrame, strokeSize: CGFloat, stroke strokeColor: UIColor) -> CGImage {
        // Create context.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.setTextDrawingMode(.stroke)
        // Draw clipping mask.
        context.setLineWidth(strokeSize)
        context.setLineJoin(.round)
        UIColor.white.setStroke()
        CTFrameDraw(frameRef, context)
        // Save clipping mask.
        let clippingMask = context.makeImage()
        // Clear the content.
        context.clear(rect)
        // Draw stroke.
        context.clip(to: rect, mask: clippingMask!)
        context.translateBy(x: 0.0, y: rect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        strokeColor.setFill()
        UIRectFill(rect)
        // Clean up and return image.
        let image = context.makeImage()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func CTLineBreakModeFromUILineBreakMode(_ lineBreakMode: NSLineBreakMode) -> CTLineBreakMode {
        switch (lineBreakMode) {
        case .byWordWrapping: return .byWordWrapping;
        case .byCharWrapping: return .byCharWrapping;
        case .byClipping: return .byClipping;
        case .byTruncatingHead: return .byTruncatingHead;
        case .byTruncatingTail: return .byTruncatingTail;
        case .byTruncatingMiddle: return .byTruncatingMiddle;
        }
    }
}

