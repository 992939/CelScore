//
//  RatingsViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

final class RatingsViewModel: NSObject {
    
    //MARK: Properties
    var ratings: RatingsModel!
    var userRatings: UserRatingsModel!
    var celScore: Double {
        get {
            var totalRatings: Double = 0
            for rating in ratings { totalRatings += ratings[rating] as! Double }
            if userRatings.totalVotes == 0 { return totalRatings / 10 }
            else {
                totalRatings *= Double(ratings.totalVotes)
                for rating in userRatings { totalRatings += ratings[rating] as! Double }
                return totalRatings / Double(ratings.totalVotes + 1)
            }
        }
    }
    enum RatingsType { case Ratings, UserRatings }
    enum RatingsError: ErrorType { case RatingsNotFound, UserRatingsNotFound, RatingValueOutOfBounds, RatingIndexOutOfBounds }
    
    
    //MARK: Initializers
    init(celebrityId: String) {
        super.init()

        self.ratings = RatingsModel(id: celebrityId).copy() as! RatingsModel
        self.userRatings = UserRatingsModel(id: celebrityId).copy() as! UserRatingsModel
    }
    
    
    //MARK: Methods
    func updateUserRatingsSignal(ratingIndex ratingIndex: Int, newRating: Int) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { sink, _ in
            guard newRating > 0 && newRating < 6 else { sendError(sink, .RatingValueOutOfBounds); return }
            guard ratingIndex >= 0 && ratingIndex < 10 else { sendError(sink, .RatingIndexOutOfBounds); return }
            guard self.userRatings != nil else { sendError(sink, .UserRatingsNotFound); return }
            
            let realm = try! Realm()
            realm.beginWrite()
            let key = self.userRatings[ratingIndex]
            self.userRatings[key] = newRating
            self.userRatings.isSynced = true
            try! realm.commitWrite()
            
            sendNext(sink, self.userRatings)
            sendCompleted(sink)
        }
    }
    
    func saveUserRatingsSignal() -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { sink, _ in
            guard let object = self.userRatings else { sendError(sink, .UserRatingsNotFound); return }
            
            let realm = try! Realm()
            realm.beginWrite()
            object.isSynced = false
            object.totalVotes += 1
            realm.add(object, update: true)
            try! realm.commitWrite()
            
            sendNext(sink, object)
            sendCompleted(sink)
        }
    }
    
    func retrieveFromLocalStoreSignal(ratingType ratingType: RatingsType) -> SignalProducer<RatingsModel!, RatingsError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            
            switch ratingType {
            case .Ratings:
                let predicate = NSPredicate(format: "id = %@", self.ratings.id)
                self.ratings = realm.objects(RatingsModel).filter(predicate).first
                guard let object = self.ratings else { sendError(sink, .RatingsNotFound); return }
                sendNext(sink, object)
                
            case .UserRatings:
                let predicate = NSPredicate(format: "id = %@", self.userRatings.id)
                self.userRatings = realm.objects(UserRatingsModel).filter(predicate).first
                guard let object = self.userRatings else { sendError(sink, .UserRatingsNotFound); return }
                sendNext(sink, object)
            }
            sendCompleted(sink)
        }
    }
}
