//
//  DetailViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/2/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit


final class DetailViewController: ASViewController {
    
    //MARK: Properties
    let nickNameTextNode: ASTextNode
    let zodiacTextNode: ASTextNode
    let ageTextNode: ASTextNode
    let celscoreTextNode: ASTextNode
    let celebPicNode: ASImageNode //TODO: ASMultiplexImageNode/ASNetworkImageNodes
    let pageNode: ASPagerNode
    let celebrityVM: CelebrityViewModel
    let ratingsVM: RatingsViewModel
    enum PageType: Int { case CelScore = 0, Info, Ratings }
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityId: String) {
        self.celebrityVM = CelebrityViewModel(celebrityId: celebrityId)
        self.ratingsVM = RatingsViewModel(celebrityId: celebrityId)
        self.nickNameTextNode = ASTextNode()
        self.celscoreTextNode = ASTextNode()
        self.zodiacTextNode = ASTextNode()
        self.ageTextNode = ASTextNode()
        self.celebPicNode = ASImageNode()
        self.pageNode = ASPagerNode()
        
        super.init(node: ASDisplayNode())
        
        self.celebrityVM.updateUserActivitySignal(id: celebrityId).startWithNext { activity in self.userActivity = activity }
        self.celebrityVM.getCelebritySignal(id: celebrityId)
            .on(next: { celeb in
                self.navigationItem.title = celeb.nickName
                self.nickNameTextNode.attributedString = NSMutableAttributedString(string:"\(celeb.nickName)")
                let zodiac = (celeb.birthdate.dateFromFormat("MM/dd/yyyy")?.zodiacSign().name())!
                self.zodiacTextNode.attributedString = NSMutableAttributedString(string:"\(zodiac)")
                let birthdate = celeb.birthdate.dateFromFormat("MM/dd/yyyy")
                var age = 0
                if NSDate().month < birthdate!.month || (NSDate().month == birthdate!.month && NSDate().day < birthdate!.day )
                { age = NSDate().year - (birthdate!.year+1) } else { age = NSDate().year - birthdate!.year }
                self.ageTextNode.attributedString = NSMutableAttributedString(string: "\(age)")
            })
            .start()
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