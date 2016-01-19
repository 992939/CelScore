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
    let ratingsId: String
    enum RatingsType { case Ratings, UserRatings }
    enum RatingsError: ErrorType { case RatingsNotFound, UserRatingsNotFound, RatingValueOutOfBounds, RatingIndexOutOfBounds }
    
    //MARK: Initializer
    init(celebrityId: String) {
        self.ratingsId = celebrityId
        super.init()
    }
    
    //MARK: Methods
    func updateUserRatingSignal(ratingIndex ratingIndex: Int, newRating: Int) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { sink, _ in
            guard newRating > 0 && newRating < 6 else { sendError(sink, .RatingValueOutOfBounds); return }
            guard ratingIndex >= 0 && ratingIndex < 10 else { sendError(sink, .RatingIndexOutOfBounds); return }
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", self.ratingsId)
            let userRatings = realm.objects(UserRatingsModel).filter(predicate).first
            guard let object = userRatings else { sendError(sink, .UserRatingsNotFound); return }
            
            realm.beginWrite()
            let key = object[ratingIndex]
            object[key] = newRating
            object.isSynced = true
            try! realm.commitWrite()
            sendNext(sink, object)
            sendCompleted(sink)
        }
    }
    
    func voteSignal() -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", self.ratingsId)
            let userRatings = realm.objects(UserRatingsModel).filter(predicate).first
            guard let object = userRatings else { sendError(sink, .UserRatingsNotFound); return }
            
            realm.beginWrite()
            object.isSynced = false
            object.totalVotes += 1
            realm.add(object, update: true)
            try! realm.commitWrite()
            sendNext(sink, object)
            sendCompleted(sink)
        }
    }
    
    func getRatingsSignal(ratingType ratingType: RatingsType) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            switch ratingType {
            case .Ratings:
                let predicate = NSPredicate(format: "id = %@", self.ratingsId)
                let ratings = realm.objects(RatingsModel).filter(predicate).first
                guard let object = ratings else { sendError(sink, .RatingsNotFound); return }
                sendNext(sink, object)
            case .UserRatings:
                let predicate = NSPredicate(format: "id = %@", self.ratingsId)
                let userRatings = realm.objects(UserRatingsModel).filter(predicate).first
                guard let object = userRatings else { sendError(sink, .UserRatingsNotFound); return }
                sendNext(sink, object)
            }
            sendCompleted(sink)
        }
    }
    
    func getCelScoreSignal() -> SignalProducer<Double, NoError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", self.ratingsId)
            let ratings = realm.objects(RatingsModel).filter(predicate).first
            let newRatings = realm.objects(UserRatingsModel).filter(predicate).first
            
            var celScore: Double = 0
            if let totalRatings = ratings {
                for rating in totalRatings { celScore += totalRatings[rating] as! Double }
                if let userRatings = newRatings where userRatings.totalVotes > 0 {
                    celScore *= Double(totalRatings.totalVotes)
                    for rating in userRatings { celScore += userRatings[rating] as! Double }
                    celScore = celScore / Double(totalRatings.totalVotes + 1)
                } else {
                    celScore = celScore / 10
                }
            }
            sendNext(sink, celScore)
            sendCompleted(sink)
        }
    }
}
