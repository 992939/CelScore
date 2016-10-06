//
//  RatingsViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AWSCore
import RealmSwift
import Result
import ReactiveCocoa
import ReactiveSwift


struct RatingsViewModel {
    
    func updateUserRatingSignal(ratingsId: String, ratingIndex: Int, newRating: Int) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { observer, disposable in
            guard 1...5 ~= newRating else { return observer.send(error: .ratingValueOutOfBounds) }
            guard 0...9 ~= ratingIndex else { return observer.send(error: .ratingIndexOutOfBounds) }
            
            let realm = try! Realm()
            realm.beginWrite()
            let userRatings = realm.objects(UserRatingsModel.self).filter("id = %@", ratingsId).first ?? UserRatingsModel(id: ratingsId)
            let key = userRatings[ratingIndex]
            userRatings[key] = newRating
            userRatings.isSynced = true
            realm.add(userRatings, update: true)
            try! realm.commitWrite()
            observer.send(value: userRatings)
            observer.sendCompleted()
        }
    }
    
    func voteSignal(ratingsId: String) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let userRatings = realm.objects(UserRatingsModel.self).filter("id = %@", ratingsId).first
            guard let object = userRatings else { return observer.send(error: .userRatingsNotFound) }
            realm.beginWrite()
            object.isSynced = false
            object.totalVotes += 1
            realm.add(object, update: true)
            try! realm.commitWrite()
            observer.send(value: object)
            observer.sendCompleted()
        }
    }
    
    func getRatingsSignal(ratingsId: String, ratingType: RatingsType) -> SignalProducer<RatingsModel, RatingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            switch ratingType {
            case .ratings:
                let ratings = realm.objects(RatingsModel.self).filter("id = %@", ratingsId).first
                guard let object = ratings else { return observer.send(error: .ratingsNotFound) }
                observer.send(value: object)
            case .userRatings:
                let userRatings = realm.objects(UserRatingsModel.self).filter("id = %@", ratingsId).first
                guard let object = userRatings else { return observer.send(error: .userRatingsNotFound) }
                observer.send(value: object)
            }
            observer.sendCompleted()
        }
    }
    
    func hasUserRatingsSignal(ratingsId: String) -> SignalProducer<Bool, NSError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(UserRatingsModel.self).filter("id = %@", ratingsId).first
            guard let userRatings = ratings else { return observer.send(value: false) }
            observer.send(value: userRatings.totalVotes > 0 ? true : false)
            observer.sendCompleted()
        }
    }
    
    func cleanUpRatingsSignal(ratingsId: String) -> SignalProducer<RatingsModel, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let newRatings = realm.objects(UserRatingsModel.self).filter("id = %@", ratingsId).first
            guard newRatings?.isEmpty == false else { return observer.sendCompleted() }
            
            realm.beginWrite()
            if newRatings!.getCelScore() == 0 { newRatings!.totalVotes = 0 }
            else if newRatings!.totalVotes == 0 { newRatings!.forEach({ rating in newRatings![rating] = 0 }) }
            realm.add(newRatings!, update: true)
            try! realm.commitWrite()
            observer.send(value: newRatings!)
            observer.sendCompleted()
        }
    }
    
    func consensusBuildingSignal(ratingsId: String) -> SignalProducer<String, RatingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(RatingsModel.self).filter("id = %@", ratingsId).first
            let userRatings = realm.objects(UserRatingsModel.self).filter("id = %@", ratingsId).first
            guard let allRatings = ratings else { return observer.send(error: .userRatingsNotFound) }
            guard let allUserRatings = userRatings else { return observer.send(error: .userRatingsNotFound) }
            
            var differences: [Double] = Array(repeating: 0, count: 10)
            for (index, rating) in allRatings.makeIterator().enumerated() {
                differences[index] = abs((allRatings[rating] as! Double) - (allUserRatings[allUserRatings[index]] as! Double))
            }
            let sumDiff = differences.reduce(0, +)
            let percent: Int = 100 - Int(sumDiff * 2)
            let message = "\(percent)% of the consensus agrees with you. Thank you for building!"
            observer.send(value: message)
            observer.sendCompleted()
        }
    }
    
    func getMoneyShotSignal(ratingsId: String) -> SignalProducer<Int, RatingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings: RatingsModel = realm.objects(RatingsModel.self).filter("id = %@", ratingsId).first!
            guard let max = ratings.max() else { return observer.send(error: .ratingsNotFound) }
            guard (ratings[max] as! Double) >= 3 else { return observer.send(error: .ratingsNotFound) }
            observer.send(value: ratings.index(of: max)!)
            observer.sendCompleted()
        }
    }
    
    func getConsensusSignal(ratingsId: String) -> SignalProducer<Double, NoError> {
        return SignalProducer { observer, disposable in
        let realm = try! Realm()
        let ratings: RatingsModel = realm.objects(RatingsModel.self).filter("id = %@", ratingsId).first!
        let consensus = 100 - ( 20 * ratings.getAvgVariance())
        observer.send(value: consensus)
        observer.sendCompleted()
        }
    }
    
    func getCelScoreSignal(ratingsId: String) -> SignalProducer<Double, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(RatingsModel.self).filter("id = %@", ratingsId).first
            let newRatings = realm.objects(UserRatingsModel.self).filter("id = %@", ratingsId).first
            
            var celScore: Double = ratings!.getCelScore()
            if let userRatings = newRatings {
                celScore *= Double(ratings!.totalVotes)
                celScore = (celScore + userRatings.getCelScore()) / Double(ratings!.totalVotes + 1)
            }
            observer.send(value: celScore)
            observer.sendCompleted()
        }
    }
}
