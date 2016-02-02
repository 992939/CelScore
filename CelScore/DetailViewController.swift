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
import SMSegmentView


final class DetailViewController: ASViewController, LMGaugeViewDelegate, SMSegmentViewDelegate {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let celebPicNode: ASNetworkImageNode
    let nameNode: ASTextNode
    let descriptionNode: ASTextNode
    let navigationBarView: NavigationBarView
    let gaugeView: LMGaugeView
    let segmentView: SMSegmentView
    enum PageType: Int { case CelScore = 0, Info, Ratings }
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        
        self.navigationBarView = NavigationBarView(frame: CGRect(x: 0, y: 0, width: 420, height: 130))
        
        self.segmentView = SMSegmentView(frame: CGRect(x: 30, y: 270, width: 300, height: 40),
            separatorColour: MaterialColor.grey.lighten3, separatorWidth: 1,
            segmentProperties:[keySegmentTitleFont: UIFont.systemFontOfSize(12),
                keySegmentOnSelectionColour: Constants.kMainGreenColor,
                keySegmentOffSelectionColour: MaterialColor.grey.lighten5,
                keyContentVerticalMargin: 5])
        
        self.gaugeView = LMGaugeView()
        self.gaugeView.minValue = Constants.kMinimumVoteValue
        self.gaugeView.maxValue = Constants.kMaximumVoteValue
        self.gaugeView.limitValue = Constants.kMiddleVoteValue

        self.celebPicNode = ASNetworkImageNode(webImage: ())
        self.celebPicNode.URL = NSURL(string: celebST.imageURL)
        self.celebPicNode.contentMode = UIViewContentMode.ScaleAspectFit
        self.celebPicNode.frame = CGRect(x: 150, y: 100, width: 90, height: 90)
        self.celebPicNode.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeRoundBorderModificationBlock(12.0, MaterialColor.white)(originalImage)
        }
        
        self.nameNode = ASTextNode()
        self.nameNode.attributedString = NSMutableAttributedString(string:"\(celebST.nickname)")
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.frame = CGRect(x: 85, y: 200, width: 200, height: 20)
        
        self.descriptionNode = ASTextNode()
        self.descriptionNode.attributedString = NSMutableAttributedString(string:"\(celebST.nickname)")
        self.descriptionNode.maximumNumberOfLines = 1
        self.descriptionNode.frame = CGRect(x: 85, y: 240, width: 200, height: 20)
        
        super.init(node: ASDisplayNode())
        
        self.node.addSubnode(self.celebPicNode)
        self.node.addSubnode(self.nameNode)
        self.node.addSubnode(self.descriptionNode)
        AIRTimer.every(0.1){ timer in self.updateGauge(self.gaugeView, timer: timer) }
    }
    
    //MARK: Methods
    override func viewWillLayoutSubviews() {}
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func updateUserActivityState(activity: NSUserActivity) { print(activity) }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MaterialColor.white
        
        self.segmentView.addSegmentWithTitle("CelScore", onSelectionImage: UIImage(named: "target_light"), offSelectionImage: UIImage(named: "target"))
        self.segmentView.addSegmentWithTitle("Info", onSelectionImage: UIImage(named: "handbag_light"), offSelectionImage: UIImage(named: "handbag"))
        self.segmentView.addSegmentWithTitle("Votes", onSelectionImage: UIImage(named: "globe_light"), offSelectionImage: UIImage(named: "globe"))
        self.segmentView.layer.cornerRadius = 5.0
        self.segmentView.layer.borderColor = MaterialColor.grey.lighten1.CGColor
        self.segmentView.layer.borderWidth = 1.0
        self.segmentView.delegate = self
        
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
        
        self.gaugeView.frame = CGRect(x: 35, y: 350, width: 300, height: 300)
        self.gaugeView.delegate = self
        
        self.view.addSubview(self.navigationBarView)
        self.view.sendSubviewToBack(self.navigationBarView)
        self.view.addSubview(self.segmentView)
        self.view.addSubview(self.gaugeView)
        
        CelScoreViewModel().getFortuneCookieSignal(cookieType: .Positive).start()
        CelebrityViewModel(celebrityId: self.celebST.id).updateUserActivitySignal(id: self.celebST.id).startWithNext { activity in self.userActivity = activity }
    }
    
    func shareVote() {
        CelScoreViewModel().shareVoteOnSignal(socialNetwork: .Facebook)
            .on(next: { socialVC in
                UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(socialVC, animated: true, completion: nil)
            })
            .start()
    }
    
    func backAction() { self.dismissViewControllerAnimated(true, completion: nil) }
    
    func updateGauge(gaugeView: LMGaugeView, timer: AIRTimer) {
        if gaugeView.value < gaugeView.maxValue { gaugeView.value += 0.05 }
        else { timer.invalidate() }
    }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        if value > gaugeView.limitValue { return Constants.kMainGreenColor }
        else { return Constants.kMainVioletColor }
    }
    
    //MARK: SMSegmentViewDelegate
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {}
}




