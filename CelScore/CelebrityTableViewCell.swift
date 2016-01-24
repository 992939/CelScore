//
//  CelebrityTableViewCell.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 5/23/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import WebASDKImageManager


final class CelebrityTableViewCell: ASCellNode {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let nameNode: ASTextNode
    let profilePicNode: ASNetworkImageNode //TODO: ASMultiplexImageNode//ASLazyImageNode
    let ratingsNode: ASDisplayNode
    let followSwitch: UISwitch
    
    //MARK: Initializer
    init(celebrityStruct: CelebrityStruct) {
        self.celebST = celebrityStruct
        
        self.nameNode = ASTextNode()
        self.nameNode.attributedString = NSMutableAttributedString(string:"\(celebST.nickname)")
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.truncationMode = .ByTruncatingTail
        self.nameNode.placeholderEnabled = true
        
        self.profilePicNode = ASNetworkImageNode(webImage: ())
        self.profilePicNode.URL = NSURL(string: "https://s3.amazonaws.com/celeb3x/dmx@3x.jpg")
        self.profilePicNode.placeholderEnabled = true
        self.profilePicNode.contentMode = UIViewContentMode.ScaleAspectFit
        //self.profilePicNode.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
//        self.profilePicNode.imageModificationBlock = { [weak profilePicNode] image in
//            if image == nil { return image }
//            
//            let rect = CGRect(origin: CGPointZero, size: image.size)
//            UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.mainScreen().scale)
//            let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSizeMake(10, 10))
//            maskPath.addClip()
//            image.drawInRect(rect)
//            let modifiedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            return modifiedImage
//        }
        
        let cosmosView = CosmosView()
        cosmosView.settings.starSize = 10
        cosmosView.settings.starMargin = 2
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.colorFilled = UIColor.orangeColor()
        cosmosView.settings.borderColorEmpty = UIColor.orangeColor()
        self.ratingsNode = ASDisplayNode.init(viewBlock: { () -> UIView in return cosmosView })
        //self.ratingsNode.preferredFrameSize = CGSizeMake(100, 50)
        
        self.followSwitch = UISwitch()
        
        super.init()
        
        self.backgroundColor = UIColor.whiteColor()
        self.addSubnode(self.profilePicNode)
        self.addSubnode(self.nameNode)
        self.addSubnode(self.ratingsNode)
    }
    
    //MARK: Methods
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.profilePicNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.2)
        self.profilePicNode.backgroundColor = UIColor.greenColor()
        
        self.nameNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.5)
        self.nameNode.backgroundColor = UIColor.redColor()
        
        self.ratingsNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.3)
        self.ratingsNode.backgroundColor = UIColor.blueColor()
        
        let horizontalStack = ASStackLayoutSpec(
            direction: .Horizontal,
            spacing: Constants.cellPadding,
            justifyContent: .Start,
            alignItems: .Center,
            children: [self.profilePicNode, self.nameNode, self.ratingsNode])
        horizontalStack.flexBasis = ASRelativeDimension(type: .Percent, value: 1.0)
        
        return ASInsetLayoutSpec(
                insets: UIEdgeInsetsMake(Constants.cellPadding, Constants.cellPadding, Constants.cellPadding, Constants.cellPadding),
                child: horizontalStack)
    }
    
    func getId() -> String { return celebST.id }
}
