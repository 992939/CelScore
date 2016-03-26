//
//  RatingsViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import RealmSwift
import Result


struct RatingsViewModel {
    
    func updateUserRatingSignal(ratingsId ratingsId: String, ratingIndex: Int, newRating: Int) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { observer, disposable in
            guard 1...5 ~= newRating else { observer.sendFailed(.RatingValueOutOfBounds); return }
            guard 0...9 ~= ratingIndex else { observer.sendFailed(.RatingIndexOutOfBounds); return }
            
            let realm = try! Realm()
            realm.beginWrite()
            var userRatings = realm.objects(UserRatingsModel).filter("id = %@", ratingsId).first
            if userRatings == nil { userRatings = UserRatingsModel(id: ratingsId) }
            let key = userRatings![ratingIndex]
            userRatings![key] = newRating
            userRatings!.isSynced = true
            realm.add(userRatings!, update: true)
            try! realm.commitWrite()
            observer.sendNext(userRatings!)
            observer.sendCompleted()
        }
    }
    
    func voteSignal(ratingsId ratingsId: String) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            realm.beginWrite()
            let userRatings = realm.objects(UserRatingsModel).filter("id = %@", ratingsId).first
            guard let object = userRatings else { observer.sendFailed(.UserRatingsNotFound); return }
            object.isSynced = false
            object.totalVotes += 1
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
    
    func hasUserRatingsSignal(ratingsId ratingsId: String) -> SignalProducer<Bool, NSError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let newRatings = realm.objects(UserRatingsModel).filter("id = %@", ratingsId).first
            guard newRatings?.isEmpty == false else { observer.sendNext(false); return }
            let hasRatings = newRatings!.totalVotes > 0 ? true : false
            observer.sendNext(hasRatings)
            observer.sendCompleted()
        }
    }
    
    func cleanUpRatingsSignal(ratingsId ratingsId: String) -> SignalProducer<AnyObject, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let newRatings = realm.objects(UserRatingsModel).filter("id = %@", ratingsId).first
            guard newRatings?.isEmpty == false else { observer.sendNext(false); return }
            
            realm.beginWrite()
            if newRatings!.getCelScore() == 0 { newRatings!.totalVotes = 0 }
            else if newRatings!.totalVotes == 0 { newRatings!.forEach({ rating in newRatings![rating] = 0 }) }
            realm.add(newRatings!, update: true)
            try! realm.commitWrite()
            observer.sendNext(newRatings!)
            observer.sendCompleted()
        }
    }
    
    func consensusBuildingSignal(ratingsId ratingsId: String) -> SignalProducer<String, RatingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(RatingsModel).filter("id = %@", ratingsId).first
            let userRatings = realm.objects(UserRatingsModel).filter("id = %@", ratingsId).first
            guard let allRatings = ratings else { observer.sendFailed(.UserRatingsNotFound); return }
            guard let allUserRatings = userRatings else { observer.sendFailed(.UserRatingsNotFound); return }
            
            var differences: [Double] = Array(count: 10, repeatedValue: 0)
            for (index, rating) in allRatings.generate().enumerate() {
                differences[index] = abs((allRatings[rating] as! Double) - (allUserRatings[allUserRatings[index]] as! Double))
            }
            let sumDiff = differences.reduce(0, combine: +)
            let percent: Int = 100 - Int(sumDiff * 2)
            let message = "\(percent)% of the consensus agrees with you.\n\nThank you for voting."
            observer.sendNext(message)
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
