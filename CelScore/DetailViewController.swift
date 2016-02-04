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
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        let celebPicNode = ASNetworkImageNode(webImage: ())
        celebPicNode.URL = NSURL(string: celebrityST.imageURL)
        celebPicNode.contentMode = UIViewContentMode.ScaleAspectFit
        celebPicNode.frame = CGRect(x: 150, y: 100, width: 90, height: 90)
        celebPicNode.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeRoundBorderModificationBlock(12.0, MaterialColor.white)(originalImage)
        }
        
        super.init(node: ASDisplayNode())
        
        self.node.addSubnode(celebPicNode)
        CelebrityViewModel().updateUserActivitySignal(id: celebrityST.id).startWithNext { activity in self.userActivity = activity }
    }
    
    //MARK: Methods
    override func viewWillLayoutSubviews() {}
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func updateUserActivityState(activity: NSUserActivity) { print(activity) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let segmentView = SMSegmentView(frame: CGRect(x: 30, y: 270, width: 300, height: 40),
            separatorColour: MaterialColor.grey.lighten3, separatorWidth: 1,
            segmentProperties:[keySegmentTitleFont: UIFont.systemFontOfSize(12),
                keySegmentOnSelectionColour: Constants.kMainGreenColor,
                keySegmentOffSelectionColour: MaterialColor.grey.lighten5,
                keyContentVerticalMargin: 5])
        segmentView.addSegmentWithTitle("CelScore", onSelectionImage: UIImage(named: "target_light"), offSelectionImage: UIImage(named: "target"))
        segmentView.addSegmentWithTitle("Info", onSelectionImage: UIImage(named: "handbag_light"), offSelectionImage: UIImage(named: "handbag"))
        segmentView.addSegmentWithTitle("Votes", onSelectionImage: UIImage(named: "globe_light"), offSelectionImage: UIImage(named: "globe"))
        segmentView.layer.cornerRadius = 5.0
        segmentView.layer.borderColor = MaterialColor.grey.lighten1.CGColor
        segmentView.layer.borderWidth = 1.0
        segmentView.delegate = self
        
        let backButton: FlatButton = FlatButton()
        backButton.pulseColor = MaterialColor.white
        backButton.pulseFill = true
        backButton.pulseScale = false
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Normal)
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Highlighted)
        backButton.addTarget(self, action: Selector("backAction"), forControlEvents: .TouchUpInside)
        
        let navigationBarView = NavigationBarView(frame: CGRect(x: 0, y: 0, width: 420, height: 130))
        navigationBarView.leftButtons = [backButton]
        navigationBarView.depth = .None
        navigationBarView.image = UIImage(named: "demo-cover-photo-2")
        navigationBarView.contentMode = .ScaleAspectFit
        
        let gaugeView = LMGaugeView()
        gaugeView.minValue = Constants.kMinimumVoteValue
        gaugeView.maxValue = Constants.kMaximumVoteValue
        gaugeView.limitValue = Constants.kMiddleVoteValue
        gaugeView.frame = CGRect(x: 35, y: 350, width: 300, height: 300)
        gaugeView.delegate = self
        AIRTimer.every(0.1){ timer in self.updateGauge(gaugeView, timer: timer) }
        
        self.view.backgroundColor = MaterialColor.white
        self.view.addSubview(navigationBarView)
        self.view.sendSubviewToBack(navigationBarView)
        self.view.addSubview(segmentView)
        self.view.addSubview(gaugeView)
        
        CelScoreViewModel().getFortuneCookieSignal(cookieType: .Positive).start()
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




