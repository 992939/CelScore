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
    
    //MARK: Property
    let celebST: CelebrityStruct
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        let celebPicNode = ASNetworkImageNode(webImage: ())
        celebPicNode.URL = NSURL(string: celebrityST.imageURL)
        celebPicNode.contentMode = UIViewContentMode.ScaleAspectFit
        let picWidth: CGFloat = 90.0
        celebPicNode.frame = CGRect(x: UIScreen.mainScreen().bounds.centerX - picWidth/2, y: 100, width: picWidth, height: picWidth)
        celebPicNode.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeRoundBorderModificationBlock(12.0, MaterialColor.white)(originalImage)
        }
        self.celebST = celebrityST
        
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
        
        let maxWidth = UIScreen.mainScreen().bounds.width - 2 * Constants.kCellPadding
        
        let backButton: FlatButton = FlatButton()
        backButton.pulseColor = MaterialColor.white
        backButton.pulseScale = false
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Normal)
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Highlighted)
        backButton.addTarget(self, action: Selector("backAction"), forControlEvents: .TouchUpInside)
        
        let navigationBarView = NavigationBarView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 130))
        navigationBarView.leftButtons = [backButton]
        navigationBarView.depth = .None
        navigationBarView.image = UIImage(named: "demo-cover-photo-2")
        navigationBarView.contentMode = .ScaleAspectFit
        
        let nameLabel = UILabel()
        nameLabel.text = self.celebST.nickname
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 16)
        nameLabel.frame = CGRect(x: Constants.kCellPadding, y: navigationBarView.bottom + 60, width: maxWidth, height: 30)
        nameLabel.textAlignment = .Center
        nameLabel.textColor = MaterialColor.grey.darken4
        
        let roleLabel = UILabel()
        roleLabel.text = "Actor"
        roleLabel.font = UIFont(name: roleLabel.font.fontName, size: 12)
        roleLabel.frame = CGRect(x: Constants.kCellPadding, y: nameLabel.bottom, width: maxWidth, height: 30)
        roleLabel.textAlignment = .Center
        roleLabel.textColor = MaterialColor.grey.base
        
        let segmentView = SMSegmentView(frame: CGRect(x: Constants.kCellPadding, y: 270, width: maxWidth, height: 40),
            separatorColour: MaterialColor.grey.lighten3, separatorWidth: 1,
            segmentProperties:[keySegmentTitleFont: UIFont.systemFontOfSize(12),
                keySegmentOnSelectionColour: Constants.kMainGreenColor,
                keySegmentOffSelectionColour: MaterialColor.grey.lighten5,
                keyContentVerticalMargin: 5])
        segmentView.addSegmentWithTitle("CelScore", onSelectionImage: UIImage(named: "target_light"), offSelectionImage: UIImage(named: "target"))
        segmentView.addSegmentWithTitle("Info", onSelectionImage: UIImage(named: "handbag_light"), offSelectionImage: UIImage(named: "handbag"))
        segmentView.addSegmentWithTitle("Votes", onSelectionImage: UIImage(named: "globe_light"), offSelectionImage: UIImage(named: "globe"))
        segmentView.selectSegmentAtIndex(0)
        segmentView.layer.cornerRadius = 5.0
        segmentView.layer.borderColor = MaterialColor.grey.lighten1.CGColor
        segmentView.layer.borderWidth = 1.0
        segmentView.delegate = self
        
        let gaugeView = LMGaugeView()
        gaugeView.minValue = Constants.kMinimumVoteValue
        gaugeView.maxValue = Constants.kMaximumVoteValue
        gaugeView.limitValue = Constants.kMiddleVoteValue
        let gaugeWidth: CGFloat = 300
        gaugeView.frame = CGRect(x: (maxWidth - gaugeWidth)/2, y: segmentView.bottom + 40, width: gaugeWidth, height: gaugeWidth)
        gaugeView.delegate = self
        AIRTimer.every(0.1){ timer in self.updateGauge(gaugeView, timer: timer) }
        
        self.view.backgroundColor = MaterialColor.white
        self.view.addSubview(navigationBarView)
        self.view.sendSubviewToBack(navigationBarView)
        self.view.addSubview(nameLabel)
        self.view.addSubview(roleLabel)
        self.view.addSubview(segmentView)
        self.view.addSubview(gaugeView)
        
        CelScoreViewModel().getFortuneCookieSignal(cookieType: .Positive).start()
    }
    
    func backAction() { self.dismissViewControllerAnimated(true, completion: nil) }
    
    func shareVote() {
        CelScoreViewModel().shareVoteOnSignal(socialNetwork: .Facebook)
            .on(next: { socialVC in
                UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(socialVC, animated: true, completion: nil)
            })
            .start()
    }
    
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




