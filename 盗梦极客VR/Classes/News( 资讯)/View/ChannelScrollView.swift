//
//  ChannelScrollView.swift
//  盗梦极客VR
//
//  Created by wl on 4/24/16.
//  Copyright © 2016 wl. All rights reserved.
//

import UIKit

protocol ChannelScrollViewDelegate: class {
    func channelScrollView(channelScrollView: ChannelScrollView, didClikChannelLabel channelLabel: UILabel)
}

class ChannelScrollView: UIScrollView {
    
    var channles: [String]! {
        didSet {
            setupChannelLabel()
        }
    }

    let labelMargin: CGFloat = 25
    
    var labelArray: [ChannelLabel] = []
    
    var defaultShowLabelCount = 5
    
    var currentChannelIndex: Int = 0 {
        didSet {
            let newChannelLabel = labelArray[currentChannelIndex]
            let oldChannelLabel = labelArray[oldValue]
            oldChannelLabel.scale = 0
            newChannelLabel.scale = 1
            
            moveCurrentChannelLabelToCenter(newChannelLabel)
        }
    }
    
    weak var myDelegate: ChannelScrollViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

extension ChannelScrollView {
    
    /**
     让当前列表标签显示在ChannelScrollView的中央
    
     */
    func moveCurrentChannelLabelToCenter(currentLabel: UILabel) {
        var offsetX = currentLabel.center.x - bounds.width * 0.5
        let maxOffset = contentSize.width - bounds.width
        if offsetX > 0{
            offsetX = offsetX > maxOffset ? maxOffset : offsetX
        }else {
            offsetX = 0
        }
        let offset = CGPoint(x: offsetX, y: 0)
        setContentOffset(offset, animated: true)
    }
    
    func setupChannelLabel() {
        func getLabelX() -> CGFloat {
            guard let lastLabel = labelArray.last else {
                return labelMargin
            }
            return CGRectGetMaxX(lastLabel.frame) + labelMargin
        }
        let windowsW = UIApplication.sharedApplication().keyWindow!.frame.width
        let totalMargin = CGFloat(defaultShowLabelCount + 1) * labelMargin
        let labelW = (windowsW - totalMargin) / CGFloat(defaultShowLabelCount)

        for (idx, title) in channles.enumerate() {
            // 初始化
            let label = ChannelLabel()
            label.text = title
            label.textColor = UIColor.grayColor()
            label.font = UIFont.systemFontOfSize(17)
            label.sizeToFit()
            label.frame.size.width = labelW
            label.frame.origin.y = (bounds.height -  label.bounds.height) * 0.5
            label.frame.origin.x = getLabelX()
            
            //增加点击事件
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChannelScrollView.channelLabelClick(_:))))
            label.userInteractionEnabled = true
            label.tag = idx
            
            labelArray.append(label)
            self.addSubview(label)
        }
        currentChannelIndex = 0
        contentSize = CGSize(width: getLabelX(), height: 0)
    }
}

extension ChannelScrollView {
    
    /**
     频道label的点击手势回调方法，
     当点击事件发生后，将新闻列表切换到被点击label对应的新闻列表
     */
    func channelLabelClick(recognizer: UITapGestureRecognizer) {
        let label = recognizer.view as! UILabel
        currentChannelIndex = label.tag
        myDelegate?.channelScrollView(self, didClikChannelLabel: label)
    }
}
