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
            for rating in ratings { totalRatings += rating.value }
            if userRatings.totalVotes == 0 { return totalRatings / 10 }
            else {
                totalRatings *= Double(ratings.totalVotes)
                for rating in userRatings { totalRatings += rating.value }
                return totalRatings / Double(ratings.totalVotes + 1)
            }
        }
    }
    enum RatingsType { case Ratings, UserRatings }
    enum RatingsError: ErrorType { case RatingsNotFound, UserRatingsNotFound, RatingValueOutOfBounds, RatingIndexOutOfBounds }
    enum RatingsIndex: Int { case Rating1 = 0, Rating2, Rating3, Rating4, Rating5, Rating6, Rating7, Rating8, Rating9, Rating10
        var key: String {
            switch self {
            case Rating1: return "rating1"
            case Rating2: return "rating2"
            case Rating3: return "rating3"
            case Rating4: return "rating4"
            case Rating5: return "rating5"
            case Rating6: return "rating6"
            case Rating7: return "rating7"
            case Rating8: return "rating8"
            case Rating9: return "rating9"
            case Rating10: return "rating10"
            }
        }
    }
    
    
    //MARK: Initializers
    init(celebrityId: String) {
        super.init()

        self.ratings = RatingsModel(id: celebrityId).copy() as! RatingsModel
        self.userRatings = UserRatingsModel(id: celebrityId).copy() as! UserRatingsModel
        
        print(self.celScore)
    }
    
    
    //MARK: Methods
    func updateUserRatingsSignal(ratingIndex ratingIndex: Int, newRating: Int) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { sink, _ in
            guard newRating > 0 && newRating < 6 else {
                sendError(sink, .RatingValueOutOfBounds)
                return
            }
            guard ratingIndex >= 0 && ratingIndex < 10 else {
                sendError(sink, .RatingIndexOutOfBounds)
                return
            }
            
            guard let userRated = self.userRatings else {
                sendError(sink, .UserRatingsNotFound)
                return
            }
            
            let realm = try! Realm()
            realm.beginWrite()
            
            let rating: RatingsIndex = RatingsIndex(rawValue: ratingIndex)!
            userRated[rating.key] = newRating
            userRated.isSynced = false
            realm.add(userRated, update: true)
            try! realm.commitWrite()
            
            sendNext(sink, userRated)
            sendCompleted(sink)
        }
    }
    
    func saveUserRatingsSignal() -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            realm.beginWrite()
            
            guard let object = self.userRatings else {
                sendError(sink, .UserRatingsNotFound)
                return
            }
            
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
                guard let object = self.ratings else {
                    sendError(sink, .RatingsNotFound)
                    return
                }
                sendNext(sink, object)
                
            case .UserRatings:
                let predicate = NSPredicate(format: "id = %@", self.userRatings.id)
                self.userRatings = realm.objects(UserRatingsModel).filter(predicate).first
                guard let object = self.userRatings else {
                    sendError(sink, .UserRatingsNotFound)
                    return
                }
                sendNext(sink, object)
            }
            sendCompleted(sink)
        }
    }
}
