//
//  DetailViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/2/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material
import LMGaugeView
import AIRTimer


final class DetailViewController: ASViewController, LMGaugeViewDelegate {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let celebPicNode: ASNetworkImageNode
    let nameNode: ASTextNode
    let descriptionNode: ASTextNode
    let navigationBarView: NavigationBarView
    let gaugeView: LMGaugeView
    enum PageType: Int { case CelScore = 0, Info, Ratings }
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        
        self.navigationBarView = NavigationBarView(frame: CGRectMake(0, 0, 420, 130))
        
        self.gaugeView = LMGaugeView()
        self.gaugeView.minValue = Constants.kMinimumVoteValue
        self.gaugeView.maxValue = Constants.kMaximumVoteValue
        self.gaugeView.limitValue = Constants.kMiddleVoteValue

        self.celebPicNode = ASNetworkImageNode(webImage: ())
        self.celebPicNode.URL = NSURL(string: celebST.imageURL)
        self.celebPicNode.contentMode = UIViewContentMode.ScaleAspectFit
        self.celebPicNode.frame = CGRectMake(150, 100, 90, 90)
        self.celebPicNode.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeRoundBorderModificationBlock(12.0, MaterialColor.white)(originalImage)
        }
        
        self.nameNode = ASTextNode()
        self.nameNode.attributedString = NSMutableAttributedString(string:"\(celebST.nickname)")
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.frame = CGRectMake(85, 200, 200, 20)
        
        self.descriptionNode = ASTextNode()
        self.descriptionNode.attributedString = NSMutableAttributedString(string:"\(celebST.nickname)")
        self.descriptionNode.maximumNumberOfLines = 1
        self.descriptionNode.frame = CGRectMake(85, 240, 200, 20)
        
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
        view.backgroundColor = MaterialColor.white
        
        let backButton: FlatButton = FlatButton()
        backButton.pulseColor = MaterialColor.white
        backButton.pulseFill = true
        backButton.pulseScale = false
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Normal)
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Highlighted)
        backButton.addTarget(self, action: Selector("backAction"), forControlEvents: .TouchUpInside)
        
        self.navigationBarView.leftButtons = [backButton]
        self.navigationBarView.depth = .None
        self.navigationBarView.image = UIImage(named: "demo-cover-photo-2")
        self.navigationBarView.contentMode = .ScaleAspectFit
        
        self.gaugeView.frame = CGRectMake(35, 350, 300, 300)
        
        self.view.addSubview(self.navigationBarView)
        self.view.sendSubviewToBack(self.navigationBarView)
        self.view.addSubview(self.gaugeView)
        
        CelScoreViewModel().getFortuneCookieSignal(cookieType: .Positive).start()
        CelebrityViewModel(celebrityId: self.celebST.id).updateUserActivitySignal(id: self.celebST.id).startWithNext { activity in self.userActivity = activity }
    }
    
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
    
    func backAction() { self.dismissViewControllerAnimated(true, completion: nil) }
    
    func updateGauge(gaugeView: LMGaugeView) { if gaugeView.value < gaugeView.maxValue { gaugeView.value += 0.05 } }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        if value > gaugeView.limitValue { return Constants.kMainGreenColor }
        else { return Constants.kMainVioletColor }
    }
}