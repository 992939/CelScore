//
//  DetailViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/2/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material
import SMSegmentView


final class DetailViewController: ASViewController, SMSegmentViewDelegate {
    
    //MARK: Property
    let celebST: CelebrityStruct
    let infoVC: InfoViewController
    let ratingsVC: RatingsViewController
    let celscoreVC: CelScoreViewController
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.infoVC = InfoViewController(celebrityST: self.celebST)
        self.ratingsVC = RatingsViewController(celebrityST: self.celebST)
        self.celscoreVC = CelScoreViewController(celebrityST: self.celebST)
        
        super.init(node: ASDisplayNode())
        CelebrityViewModel().updateUserActivitySignal(id: celebrityST.id).startWithNext { activity in self.userActivity = activity }
    }
    
    //MARK: Methods
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func updateUserActivityState(activity: NSUserActivity) { print(activity) }

    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationBarView: NavigationBarView = getNavigationView()
        let topView: MaterialView = getTopView()
        let segmentView: SMSegmentView = getSegmentView()
        let voteButton: MaterialButton = getVoteButton()
        
        self.view.addSubview(navigationBarView)
        self.view.sendSubviewToBack(navigationBarView)
        self.view.addSubview(topView)
        self.view.addSubview(segmentView)
        self.view.addSubview(voteButton)
        self.view.addSubview(self.celscoreVC.view)
        self.view.backgroundColor = MaterialColor.blueGrey.darken4
    }
    
    func backAction() { self.dismissViewControllerAnimated(true, completion: nil) }
    func voteAction() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings)
            .on(next: { ratings in
                let unrated = ratings.filter{ (ratings[$0] as! Int) == 0 }
                if unrated.count == 0 {
                    RatingsViewModel().voteSignal(ratingsId: self.celebST.id)
                        .on(next: { ratings in self.voteAnimation() })
                        .start()
                }
            })
            .start()
    }
    
    func voteAnimation() {
        print("murder!!!!")
        CelScoreViewModel().getFortuneCookieSignal(cookieType: .Positive).start()
    }
    
    func shareVote() {
        CelScoreViewModel().shareVoteOnSignal(socialNetwork: .Facebook)
            .on(next: { socialVC in
                UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(socialVC, animated: true, completion: nil)
            })
            .start()
    }
    
    //MARK: View Helpers
    func getVoteButton() -> MaterialButton {
        let celScoreButton: MaterialButton = MaterialButton(frame: CGRect(x: Constants.kMaxWidth - 35, y: Constants.kTopViewRect.bottom - 20, width: 40, height: 40))
        celScoreButton.shape = .Circle
        celScoreButton.depth = .Depth2
        celScoreButton.backgroundColor = MaterialColor.grey.lighten5
        celScoreButton.addTarget(self, action: Selector("voteAction"), forControlEvents: .TouchUpInside)
        return celScoreButton
    }
    
    func getNavigationView() -> NavigationBarView {
        let backButton: FlatButton = FlatButton()
        backButton.pulseColor = MaterialColor.white
        backButton.pulseScale = false
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Normal)
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Highlighted)
        backButton.addTarget(self, action: Selector("backAction"), forControlEvents: .TouchUpInside)
        
        let navigationBarView = NavigationBarView(frame: Constants.kNavigationBarRect)
        navigationBarView.leftButtons = [backButton]
        navigationBarView.depth = .Depth3
        navigationBarView.image = UIImage(named: "demo-cover-photo-2")
        navigationBarView.contentMode = .ScaleAspectFit
        return navigationBarView
    }
    
    func getSegmentView() -> SMSegmentView {
        let segmentView = SMSegmentView(frame: Constants.kSegmentViewRect,
            separatorColour: MaterialColor.grey.lighten3, separatorWidth: 1,
            segmentProperties:[keySegmentTitleFont: UIFont.systemFontOfSize(12),
                keySegmentOnSelectionColour: Constants.kMainGreenColor,
                keySegmentOffSelectionColour: MaterialColor.grey.lighten5,
                keyContentVerticalMargin: 5])
        segmentView.addSegmentWithTitle("CelScore", onSelectionImage: UIImage(named: "target_light"), offSelectionImage: UIImage(named: "target"))
        segmentView.addSegmentWithTitle("Info", onSelectionImage: UIImage(named: "handbag_light"), offSelectionImage: UIImage(named: "handbag"))
        segmentView.addSegmentWithTitle("Votes", onSelectionImage: UIImage(named: "globe_light"), offSelectionImage: UIImage(named: "globe"))
        segmentView.selectSegmentAtIndex(0)
        segmentView.delegate = self
        return segmentView
    }
    
    func getTopView() -> MaterialView {
        let topView = MaterialView(frame: Constants.kTopViewRect)
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
        topView.depth = .Depth2
        return topView
    }
    
    //MARK: SMSegmentViewDelegate
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int, previousIndex: Int) {
        let infoView: UIView
        switch index {
        case 1: infoView = self.infoVC.view
        case 2: infoView = self.ratingsVC.view
        default: infoView = self.celscoreVC.view
        }
        
        //TODO: animate removingView out of the screen.
        let removingView = self.view.viewWithTag(Constants.kDetailViewTag)
        removingView?.removeFromSuperview()
        self.view.addSubview(infoView)

        if index == 0 || (index == 1 && previousIndex == 2 ){ infoView.slideLeft() }
        else { infoView.slideRight() }
    }
}




