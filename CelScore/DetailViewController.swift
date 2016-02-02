//
//  DetailViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/2/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import DynamicButton
import Material
import LMGaugeView
import AIRTimer


final class DetailViewController: ASViewController, LMGaugeViewDelegate {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let celebPicNode: ASNetworkImageNode
    let nameNode: ASTextNode
    let descriptionNode: ASTextNode
    let backButton: DynamicButton
    let navigationBarView: NavigationBarView
    let gaugeView: LMGaugeView
    enum PageType: Int { case CelScore = 0, Info, Ratings }
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        
        self.gaugeView = LMGaugeView()
        self.gaugeView.minValue = 1.00
        self.gaugeView.maxValue = 5.00
        self.gaugeView.limitValue = 3.00

        self.celebPicNode = ASNetworkImageNode(webImage: ())
        self.celebPicNode.contentMode = UIViewContentMode.ScaleAspectFit
        self.celebPicNode.frame = CGRectMake(85, 100, 50, 50)
        self.celebPicNode.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeRoundBorderModificationBlock(9.0, UIColor.redColor())(originalImage)
        }
        
        self.nameNode = ASTextNode()
        self.nameNode.attributedString = NSMutableAttributedString(string:"\(celebST.nickname)")
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.frame = CGRectMake(85, 200, 200, 20)
        
        self.descriptionNode = ASTextNode()
        self.descriptionNode.attributedString = NSMutableAttributedString(string:"\(celebST.nickname)")
        self.descriptionNode.maximumNumberOfLines = 1
        self.descriptionNode.frame = CGRectMake(85, 240, 200, 20)
        
        self.backButton = DynamicButton(frame: CGRectMake(0, 0, 15.0, 15.0))
        self.navigationBarView = NavigationBarView()
        
        super.init(node: ASDisplayNode())
        
        self.node.addSubnode(self.celebPicNode)
        self.node.addSubnode(self.nameNode)
        self.node.addSubnode(self.descriptionNode)
        AIRTimer.every(0.1) { timer in self.updateGauge(self.gaugeView) }
    }
    
    //MARK: Methods
    override func viewWillLayoutSubviews() {}
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func updateUserActivityState(activity: NSUserActivity) { print(activity) }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.kBackgroundColor
        
        let title = UILabel()
        title.text = self.celebST.nickname
        title.textAlignment = .Center
        title.textColor = Constants.kBackgroundColor
        self.navigationBarView.titleLabel = title
        
        self.backButton.setStyle(.CaretLeft, animated: true)
        self.backButton.addTarget(self, action: Selector("backAction"), forControlEvents: .TouchUpInside)
        self.backButton.strokeColor = Constants.kBackgroundColor
        
        self.navigationBarView.leftButtons = [self.backButton]
        self.navigationBarView.backgroundColor = Constants.kMainGreenColor
        
        self.gaugeView.frame = CGRectMake(35, 300, 350, 350)
        
        self.view.addSubview(self.navigationBarView)
        self.view.addSubview(self.gaugeView)
        
        CelScoreViewModel().getFortuneCookieSignal(cookieType: .Positive).start()
        CelebrityViewModel(celebrityId: self.celebST.id).updateUserActivitySignal(id: self.celebST.id).startWithNext { activity in self.userActivity = activity }
    }
    
    func backAction() { self.dismissViewControllerAnimated(true, completion: nil) }
    
    func screenShotMethod() {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func shareVote() {
        CelScoreViewModel().shareVoteOnSignal(socialNetwork: .Facebook)
            .on(next: { socialVC in
                UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(socialVC, animated: true, completion: nil)
            })
            .start()
    }
    
    func updateGauge(gaugeView: LMGaugeView) { if gaugeView.value < gaugeView.maxValue { gaugeView.value += 0.05 } }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        if value > gaugeView.limitValue { return Constants.kMainGreenColor }
        else { return Constants.kMainVioletColor }
    }
}