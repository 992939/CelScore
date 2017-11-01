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
import PMAlertController


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
    
    func hasUserRatingsSignal(ratingsId: String) -> SignalProducer<Bool, NoError> {
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
    
    func getVoteMessageSignal(celeb: CelebrityModel) -> SignalProducer<PMAlertController, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(RatingsModel.self).filter("id = %@", celeb.id).first
            let newRatings = realm.objects(UserRatingsModel.self).filter("id = %@", celeb.id).first
            
            var celScore: Double = ratings!.getCelScore()
            if let userRatings = newRatings {
                celScore *= Double(ratings!.totalVotes)
                celScore = (celScore + userRatings.getCelScore()) / Double(ratings!.totalVotes + 1)
            }
            
            let status: String
            switch (celScore, celeb.prevScore) {
            case (Constants.kRoyalty..<101, Constants.kRoyalty..<101): status = "is"
            case (Constants.kRoyalty..<101, 0..<Constants.kRoyalty): status = "is"
            case (0..<Constants.kRoyalty, Constants.kRoyalty..<101): status = "is no longer"
            default: status = "is no"
            }
            
            let title = celScore >= Constants.kRoyalty ? "Blue Blooded" : "Red Blooded"
            let logo = celScore >= Constants.kRoyalty ? R.image.big_blue_fans()! : R.image.big_red_fans()!
            let voteMessage = String("\(celeb.nickName) \(status)\nHollywood Royalty!\n\nThank you for\nWatching the throne!")
            let voteAlert = PMAlertController(title: title, description: voteMessage!, image: logo, style: .alert)
            voteAlert.alertTitle.textColor = celScore >= Constants.kRoyalty ? Constants.kBlueText : Constants.kRedText
            
            observer.send(value: voteAlert)
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
