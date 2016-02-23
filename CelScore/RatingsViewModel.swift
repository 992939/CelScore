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
    enum RatingsType { case Ratings, UserRatings }
    enum RatingsError: ErrorType { case RatingsNotFound, UserRatingsNotFound, RatingValueOutOfBounds, RatingIndexOutOfBounds }
    
    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Methods
    func updateUserRatingSignal(ratingsId ratingsId: String, ratingIndex: Int, newRating: Int) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { sink, _ in
            guard newRating > 0 && newRating < 6 else { sendError(sink, .RatingValueOutOfBounds); return }
            guard ratingIndex >= 0 && ratingIndex < 10 else { sendError(sink, .RatingIndexOutOfBounds); return }
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", ratingsId)
            var userRatings = realm.objects(UserRatingsModel).filter(predicate).first
            if  userRatings == nil { userRatings = UserRatingsModel(id: ratingsId) }
            
            realm.beginWrite()
            let key = userRatings![ratingIndex]
            userRatings![key] = newRating
            userRatings!.isSynced = true
            realm.add(userRatings!, update: true)
            try! realm.commitWrite()
            sendNext(sink, userRatings!)
            sendCompleted(sink)
        }
    }
    
    func voteSignal(ratingsId ratingsId: String) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", ratingsId)
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
    
    func getRatingsSignal(ratingsId ratingsId: String, ratingType: RatingsType) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            switch ratingType {
            case .Ratings:
                let predicate = NSPredicate(format: "id = %@", ratingsId)
                let ratings = realm.objects(RatingsModel).filter(predicate).first
                guard let object = ratings else { sendError(sink, .RatingsNotFound); return }
                sendNext(sink, object)
            case .UserRatings:
                let predicate = NSPredicate(format: "id = %@", ratingsId)
                let userRatings = realm.objects(UserRatingsModel).filter(predicate).first
                guard let object = userRatings else { sendError(sink, .UserRatingsNotFound); return }
                sendNext(sink, object)
            }
            sendCompleted(sink)
        }
    }
    
    func hasUserRatingsSignal(ratingsId ratingsId: String) -> SignalProducer<Bool, NoError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", ratingsId)
            let newRatings = realm.objects(UserRatingsModel).filter(predicate).first
            var hasRatings: Bool = false
            if let userRatings = newRatings where userRatings.totalVotes > 0 { hasRatings = true }
            sendNext(sink, hasRatings)
            sendCompleted(sink)
        }
    }
    
    func getConsensusSignal(ratingsId ratingsId: String) -> SignalProducer<Double, NoError> {
        return SignalProducer { sink, _ in
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@", ratingsId)
        let ratings: RatingsModel = realm.objects(RatingsModel).filter(predicate).first!
        let variance = (ratings.variance1 + ratings.variance2 + ratings.variance3 + ratings.variance4 + ratings.variance5
                    + ratings.variance6 + ratings.variance7 + ratings.variance8 + ratings.variance9 + ratings.variance10) / 10
        let consensus = 100 - ( 20 * variance )
        sendNext(sink, consensus)
        sendCompleted(sink)
        }
    }
    
    func getCelScoreSignal(ratingsId ratingsId: String) -> SignalProducer<Double, NoError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", ratingsId)
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
