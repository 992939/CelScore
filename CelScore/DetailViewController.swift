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


final class DetailViewController: ASViewController, ASPagerNodeDataSource, ASCollectionDelegate, UIScrollViewDelegate {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let celebPicNode: ASImageNode //TODO: ASMultiplexImageNode/ASNetworkImageNodes
    let pageNode: ASPagerNode
    let backButton: DynamicButton
    let navigationBarView: NavigationBarView
    let pageControl: UIPageControl
    enum PageType: Int { case CelScore = 0, Info, Ratings }
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST

        let celebBackgroundView: MaterialView = MaterialView(frame: CGRectMake(Constants.kCellPadding, Constants.kNavigationPadding, 395, 280))
        celebBackgroundView.depth = .Depth1
        celebBackgroundView.backgroundColor = MaterialColor.white
        let logoBackgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return celebBackgroundView })
        
        let pageBackgroundView: MaterialView = MaterialView(frame: CGRectMake(Constants.kCellPadding, Constants.kNavigationPadding + 285, 395, 320))
        pageBackgroundView.depth = .Depth1
        pageBackgroundView.backgroundColor = MaterialColor.white
        let pageBackgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return pageBackgroundView })
        
        self.celebPicNode = ASImageNode()
        self.pageNode = ASPagerNode()
        
        self.pageControl = UIPageControl(frame: CGRectMake(-90, 690, 200, 40))
        self.pageControl.numberOfPages = 3
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = MaterialColor.grey.darken3
        self.pageControl.currentPageIndicatorTintColor = Constants.kMainGreenColor
        
        self.backButton = DynamicButton(frame: CGRectMake(0, 0, 15.0, 15.0))
        self.navigationBarView = NavigationBarView()
        
        super.init(node: ASDisplayNode())
        
        self.pageNode.setDataSource(self)
        self.pageNode.delegate = self
        
        self.node.addSubnode(logoBackgroundNode)
        self.node.addSubnode(pageBackgroundNode)
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
        
        self.view.addSubview(self.navigationBarView)
        self.view.addSubview(self.pageControl)
        
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