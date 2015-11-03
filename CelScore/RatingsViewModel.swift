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
            let totalRatings = ratings.rating1 + ratings.rating2 + ratings.rating3 + ratings.rating4 + ratings.rating5 + ratings.rating6 + ratings.rating7 + ratings.rating8 + ratings.rating9 + ratings.rating10
            return totalRatings / 10
        }
    }
    enum RatingsType { case Ratings, UserRatings }
    enum RatingsError: ErrorType { case RatingsNotFound, UserRatingsNotFound }
    
    
    //MARK: Initializers
    init(celebrityId: String) {
        super.init()
        
        self.ratings = RatingsModel(id: celebrityId)
        self.userRatings = UserRatingsModel(id: celebrityId)
    }
    
    
    //MARK: Methods
    func updateOnLocalStoreSignal(ratingType: RatingsType) -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            realm.beginWrite()
            
            switch ratingType {
            case .Ratings:
                self.ratings?.isSynced = false
                realm.add(self.ratings!, update: true)
            case .UserRatings:
                self.userRatings?.isSynced = false
                realm.add(self.userRatings!, update: true)
            }
            try! realm.commitWrite()
        }
    }
    
    func retrieveFromLocalStoreSignal(ratingType: RatingsType) -> SignalProducer<RatingsModel!, RatingsError> {
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
