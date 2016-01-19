//
//  DetailViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/2/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import AsyncDisplayKit


final class DetailViewController: UIViewController {
    
    //MARK: Properties
    let nickNameNode: ASTextNode
    let celscoreNode: ASTextNode
    let marginErrorNode: ASTextNode
    let celebPicNode: ASImageNode //TODO: ASMultiplexImageNode/ASNetworkImageNode
    let celebrityVM: CelebrityViewModel
    let ratingsVM: RatingsViewModel
    let pageNode: ASPagerNode
    enum PageType: Int { case CelScore = 0, Info, Ratings }
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityId: String) {
        self.celebrityVM = CelebrityViewModel(celebrityId: celebrityId)
        self.ratingsVM = RatingsViewModel(celebrityId: celebrityId)
        self.nickNameNode = ASTextNode()
        self.celscoreNode = ASTextNode()
        self.marginErrorNode = ASTextNode()
        self.celebPicNode = ASImageNode()
        self.pageNode = ASPagerNode()
        
        super.init(nibName: nil, bundle: nil)
        self.nickNameNode.attributedString = NSMutableAttributedString(string:"\(celebrityVM.celebrity?.nickName)")
        self.celebrityVM.updateUserActivitySignal(id: celebrityId).startWithNext { activity in self.userActivity = activity }
    }
    
    //MARK: Methods
    override func viewWillLayoutSubviews() {}
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func updateUserActivityState(activity: NSUserActivity) { print(activity) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CelScoreViewModel().getFortuneCookieSignal(cookieType: .Positive).start()
        self.ratingsVM.getRatingsSignal(ratingType: .Ratings).start()
        self.ratingsVM.getRatingsSignal(ratingType: .UserRatings).start()

        self.ratingsVM.updateUserRatingSignal(ratingIndex: 0, newRating: 5).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 1, newRating: 5).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 2, newRating: 5).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 3, newRating: 5).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 4, newRating: 5).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 5, newRating: 5).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 6, newRating: 5).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 7, newRating: 5).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 8, newRating: 4).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 9, newRating: 4).start()
        self.ratingsVM.voteSignal().start()
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
}