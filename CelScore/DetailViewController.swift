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
    var nickNameNode: ASTextNode?
    var celscoreNode: ASTextNode?
    var marginErrorNode: ASTextNode?
    var imageNode: ASImageNode?
    
    let celebrityProfile: CelebrityProfile
    let celebrityVM: CelebrityViewModel
    let ratingsVM: RatingsViewModel
    enum PageType: Int { case CelScore = 0, Info, Ratings }
    
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(profile: CelebrityProfile) {
        self.celebrityProfile = profile
        self.celebrityVM = CelebrityViewModel(celebrityId: profile.id)
        self.ratingsVM = RatingsViewModel(celebrityId: profile.id)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    //MARK: Methods
    override func viewWillLayoutSubviews() {}
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.celebrityVM.getFromLocalStoreSignal(id: self.celebrityProfile.id)
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("celebrityVM.getFromLocalStoreSignal Value: \(value)")
                case let .Error(error):
                    print("celebrityVM.getFromLocalStoreSignal Error: \(error)")
                case .Completed:
                    print("celebrityVM.getFromLocalStoreSignal Completed")
                case .Interrupted:
                    print("celebrityVM.getFromLocalStoreSignal Interrupted")
                }
        }
        
        self.ratingsVM.retrieveFromLocalStoreSignal(ratingType: .Ratings)
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("ratingsVM.retrieveFromLocalStoreSignal Value: \(value)")
                case let .Error(error):
                    print("ratingsVM.retrieveFromLocalStoreSignal Error: \(error)")
                case .Completed:
                    print("ratingsVM.retrieveFromLocalStoreSignal Completed")
                case .Interrupted:
                    print("ratingsVM.retrieveFromLocalStoreSignal Interrupted")
                }
        }
        
//        self.ratingsVM.retrieveFromLocalStoreSignal(.UserRatings)
//            .start { event in
//                switch(event) {
//                case let .Next(value):
//                    print("ratingsVM.retrieveFromLocalStoreSignal Value2: \(value)")
//                case let .Error(error):
//                    print("ratingsVM.retrieveFromLocalStoreSignal Error2: \(error)")
//                case .Completed:
//                    print("ratingsVM.retrieveFromLocalStoreSignal Completed2")
//                case .Interrupted:
//                    print("ratingsVM.retrieveFromLocalStoreSignal Interrupted2")
//                }
//        }
        
//        self.ratingsVM.updateUserRatingsSignal(ratingIndex: 1, newRating: 5)
//            .start { event in
//                switch(event) {
//                case let .Next(value):
//                    print("updateUserRatingsSignal Value: \(value)")
//                case let .Error(error):
//                    print("updateUserRatingsSignal Error: \(error)")
//                case .Completed:
//                    print("updateUserRatingsSignal Completed")
//                case .Interrupted:
//                    print("updateUserRatingsSignal Interrupted")
//                }
//        }
    }
}