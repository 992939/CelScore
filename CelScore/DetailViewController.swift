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


final class DetailViewController: ASViewController, ASPagerNodeDataSource {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let nickNameTextNode: ASTextNode
    let zodiacTextNode: ASTextNode
    let ageTextNode: ASTextNode
    let celscoreTextNode: ASTextNode
    let celebPicNode: ASImageNode //TODO: ASMultiplexImageNode/ASNetworkImageNodes
    let pageNode: ASPagerNode
    let celebrityVM: CelebrityViewModel
    let ratingsVM: RatingsViewModel
    let backButton: DynamicButton
    let navigationBarView: NavigationBarView
    enum PageType: Int { case CelScore = 0, Info, Ratings }
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        
        self.celebrityVM = CelebrityViewModel(celebrityId: self.celebST.id)
        self.ratingsVM = RatingsViewModel(celebrityId: self.celebST.id)
        self.nickNameTextNode = ASTextNode()
        self.celscoreTextNode = ASTextNode()
        self.zodiacTextNode = ASTextNode()
        self.ageTextNode = ASTextNode()
        self.pageNode = ASPagerNode()
        
        //MARK: CelebPic
        self.celebPicNode = ASImageNode()
        let celebBackgroundView: MaterialView = MaterialView(frame: CGRectMake(Constants.kCellPadding, Constants.kNavigationPadding, 395, 280))
        celebBackgroundView.depth = .Depth1
        celebBackgroundView.backgroundColor = MaterialColor.white
        let logoBackgroundNode = ASDisplayNode.init(viewBlock: { () -> UIView in return celebBackgroundView })
        
        self.backButton = DynamicButton(frame: CGRectMake(0, 0, 15.0, 15.0))
        self.navigationBarView = NavigationBarView()
        
        super.init(node: ASDisplayNode())
        
        self.pageNode.setDataSource(self)
        self.celebrityVM.updateUserActivitySignal(id: self.celebST.id).startWithNext { activity in self.userActivity = activity }
        self.node.addSubnode(logoBackgroundNode)
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
        self.navigationBarView.backgroundColor = MaterialColor.green.lighten1
        
        self.view.addSubview(self.navigationBarView)
        
        CelScoreViewModel().getFortuneCookieSignal(cookieType: .Positive).start()
        self.ratingsVM.getRatingsSignal(ratingType: .Ratings).start()
        self.ratingsVM.getRatingsSignal(ratingType: .UserRatings).start()

        self.ratingsVM.updateUserRatingSignal(ratingIndex: 0, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 1, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 2, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 3, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 4, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 5, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 6, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 7, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 8, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 9, newRating: 3).start()
        self.ratingsVM.voteSignal().start()
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
    
    //MARK: ASPagerNodeDataSource
    func numberOfPagesInPagerNode(pagerNode: ASPagerNode!) -> Int { return 3 }
    func pagerNode(pagerNode: ASPagerNode!, nodeAtIndex index: Int) -> ASCellNode! {
        switch index {
        case 0: return CelScoreNode(celebrityST: self.celebST)
        case 1: return InfoNode(celebrityST: self.celebST)
        case 2: return RatingsNode(celebrityST: self.celebST)
        default: return CelScoreNode(celebrityST: self.celebST)
        }
    }
}