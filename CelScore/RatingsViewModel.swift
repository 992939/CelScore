//
//  RatingsViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift
import Result


final class RatingsViewModel: NSObject {

    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Methods
    func updateUserRatingSignal(ratingsId ratingsId: String, ratingIndex: Int, newRating: Int) -> SignalProducer<RatingsModel, NSError> {
        return SignalProducer { observer, disposable in //TODO: RatingsError
            guard 1...5 ~= newRating else { observer.sendFailed(NSError(domain: "rating value out of bounds", code: 1, userInfo: nil)); return }
            guard 0...9 ~= ratingIndex else { observer.sendFailed(NSError(domain: "rating index out of bounds", code: 1, userInfo: nil)); return }
            
            let realm = try! Realm()
            var userRatings = realm.objects(UserRatingsModel).filter("id = %@", ratingsId).first
            if userRatings == nil { userRatings = UserRatingsModel(id: ratingsId) }
            let key = userRatings![ratingIndex]
            userRatings![key] = newRating
            userRatings!.isSynced = true
            realm.beginWrite()
            realm.add(userRatings!, update: true)
            try! realm.commitWrite()
            observer.sendNext(userRatings!)
            observer.sendCompleted()
        }
    }
    
    func voteSignal(ratingsId ratingsId: String) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let userRatings = realm.objects(UserRatingsModel).filter("id = %@", ratingsId).first
            guard let object = userRatings else { observer.sendFailed(.UserRatingsNotFound); return }
            object.isSynced = false
            object.totalVotes += 1
            realm.beginWrite()
            realm.add(object, update: true)
            try! realm.commitWrite()
            observer.sendNext(object)
            observer.sendCompleted()
        }
    }
    
    func getRatingsSignal(ratingsId ratingsId: String, ratingType: RatingsType) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            switch ratingType {
            case .Ratings:
                let ratings = realm.objects(RatingsModel).filter("id = %@", ratingsId).first
                guard let object = ratings else { observer.sendFailed(.RatingsNotFound); return }
                observer.sendNext(object)
            case .UserRatings:
                let userRatings = realm.objects(UserRatingsModel).filter("id = %@", ratingsId).first
                guard let object = userRatings else { observer.sendFailed(.UserRatingsNotFound); return }
                observer.sendNext(object)
            }
            observer.sendCompleted()
        }
    }
    
    func hasUserRatingsSignal(ratingsId ratingsId: String) -> SignalProducer<Bool, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let newRatings = realm.objects(UserRatingsModel).filter("id = %@", ratingsId).first
            var hasRatings: Bool = false
            if let userRatings = newRatings where userRatings.totalVotes > 0 { hasRatings = true }
            if let userRatings = newRatings where userRatings.totalVotes == 0 && userRatings.getCelScore() > 0 {
                realm.beginWrite()
                userRatings.forEach({ rating in userRatings[rating] = 0 })
                realm.add(userRatings, update: true)
                try! realm.commitWrite()
            }
            observer.sendNext(hasRatings)
            observer.sendCompleted()
        }
    }
    
    func getConsensusSignal(ratingsId ratingsId: String) -> SignalProducer<Double, NoError> {
        return SignalProducer { observer, disposable in
        let realm = try! Realm()
        let ratings: RatingsModel = realm.objects(RatingsModel).filter("id = %@", ratingsId).first!
        let consensus = 100 - ( 20 * ratings.getAvgVariance())
        observer.sendNext(consensus)
        observer.sendCompleted()
        }
    }
    
    func getCelScoreSignal(ratingsId ratingsId: String) -> SignalProducer<Double, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(RatingsModel).filter("id = %@", ratingsId).first
            let newRatings = realm.objects(UserRatingsModel).filter("id = %@", ratingsId).first
            
            var celScore: Double = ratings!.getCelScore()
            if let userRatings = newRatings {
                celScore *= Double(ratings!.totalVotes)
                celScore = (celScore + userRatings.getCelScore()) / Double(ratings!.totalVotes + 1)
            }
            observer.sendNext(celScore)
            observer.sendCompleted()
        }
    }
}
