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
import ImagePalette


final class DetailViewController: ASViewController, LMGaugeViewDelegate, SMSegmentViewDelegate {
    
    //MARK: Property
    let celebST: CelebrityStruct
    var strongColor: UIColor
    var weakColor: UIColor
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.strongColor = MaterialColor.black
        self.weakColor = MaterialColor.grey.base
        super.init(node: ASDisplayNode())
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
        
        //navigationBarView
        let backButton: FlatButton = FlatButton()
        backButton.pulseColor = MaterialColor.white
        backButton.pulseScale = false
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Normal)
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Highlighted)
        backButton.addTarget(self, action: Selector("backAction"), forControlEvents: .TouchUpInside)
        
        let navigationBarView = NavigationBarView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 110))
        navigationBarView.leftButtons = [backButton]
        navigationBarView.depth = .Depth3
        navigationBarView.image = UIImage(named: "demo-cover-photo-2")
        navigationBarView.contentMode = .ScaleAspectFit
        
        //topView
        let topView: MaterialPulseView = MaterialPulseView(frame: CGRect(
            x: Constants.kCellPadding,
            y: navigationBarView.bottom + 10,
            width: maxWidth,
            height: 170))
        topView.depth = .Depth2
        
        let viewMaxWidth = topView.width - 2 * Constants.kCellPadding
        
        let celebPicNode = ASNetworkImageNode(webImage: ())
        celebPicNode.URL = NSURL(string: self.celebST.imageURL)
        celebPicNode.contentMode = UIViewContentMode.ScaleAspectFit
        let picWidth: CGFloat = 90.0
        celebPicNode.frame = CGRect(x: topView.bounds.centerX - picWidth/2, y: Constants.kCellPadding, width: picWidth, height: picWidth)
        celebPicNode.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeRoundBorderModificationBlock(12.0, MaterialColor.white)(originalImage)
        }
        
        let nameLabel = UILabel()
        nameLabel.text = self.celebST.nickname
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 25)
        nameLabel.frame = CGRect(x: Constants.kCellPadding, y: celebPicNode.view.bottom + Constants.kCellPadding, width: viewMaxWidth, height: 30)
        nameLabel.textAlignment = .Center
        nameLabel.textColor = MaterialColor.white
        
        let roleLabel = UILabel()
        roleLabel.text = "Actor"
        roleLabel.font = UIFont(name: roleLabel.font.fontName, size: 14)
        roleLabel.frame = CGRect(x: Constants.kCellPadding, y: nameLabel.bottom, width: viewMaxWidth, height: 30)
        roleLabel.textAlignment = .Center
        roleLabel.textColor = MaterialColor.white
        
        topView.addSubview(celebPicNode.view)
        topView.addSubview(nameLabel)
        topView.addSubview(roleLabel)
        
        //segmentView
        let segmentView = SMSegmentView(frame: CGRect(x: Constants.kCellPadding, y: topView.bottom + Constants.kCellPadding, width: maxWidth, height: 40),
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
        
        //bottomView
        let bottomView: MaterialPulseView = MaterialPulseView(frame: CGRect(
            x: Constants.kCellPadding,
            y: segmentView.bottom + Constants.kCellPadding,
            width: maxWidth,
            height: 370))
        bottomView.depth = .Depth2
        bottomView.backgroundColor = MaterialColor.white
        
        let gaugeView = LMGaugeView()
        gaugeView.minValue = Constants.kMinimumVoteValue
        gaugeView.maxValue = Constants.kMaximumVoteValue
        gaugeView.limitValue = Constants.kMiddleVoteValue
        let gaugeWidth: CGFloat = 300
        gaugeView.frame = CGRect(x: (viewMaxWidth - gaugeWidth)/2, y: 20, width: gaugeWidth, height: gaugeWidth)
        gaugeView.delegate = self
        AIRTimer.every(0.1){ timer in self.updateGauge(gaugeView, timer: timer) }
        
        let consensusLabel = UILabel()
        consensusLabel.text = "Social Consensus: 80%"
        consensusLabel.font = UIFont(name: roleLabel.font.fontName, size: 15)
        consensusLabel.frame = CGRect(x: Constants.kCellPadding, y: gaugeView.bottom + 20, width: viewMaxWidth, height: 30)
        consensusLabel.textAlignment = .Center
        consensusLabel.textColor = MaterialColor.black
        
        Palette.generateWithConfiguration(PaletteConfiguration(image: UIImage(named: "demo-cover-photo-2")!)) {
            if let color = $0.darkMutedSwatch?.color {
                print("1. color is \($0.darkMutedSwatch?.debugDescription)")
                topView.backgroundColor = color
                segmentView.segmentOnSelectionColour = color
                self.strongColor = color
                self.weakColor = MaterialColor.blueGrey.lighten3
            }
            if let color = $0.lightVibrantSwatch?.color {
                topView.backgroundColor = color
                print("2. color is \(color.debugDescription)")
            }
        }
        
        bottomView.addSubview(gaugeView)
        bottomView.addSubview(consensusLabel)
        
        self.view.backgroundColor = MaterialColor.blueGrey.lighten5  //MaterialColor.grey.lighten5
        self.view.addSubview(navigationBarView)
        self.view.sendSubviewToBack(navigationBarView)
        self.view.addSubview(topView)
        self.view.addSubview(segmentView)
        self.view.addSubview(bottomView)
        
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
        if value > gaugeView.limitValue { return self.strongColor }
        else { return self.weakColor }
    }
    
    //MARK: SMSegmentViewDelegate
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {}
}




