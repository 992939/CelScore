//
//  SearchListViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/1/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import ReactiveCocoa
import RealmSwift


final class SearchListViewModel: CelebrityListViewModel {
    
    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Method
    func searchSignal(searchToken searchToken: String) -> SignalProducer<AnyObject, NoError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "nickName contains[c] %@", searchToken)
            let list: AnyObject = realm.objects(CelebrityModel).filter(predicate)
            sendNext(sink, list)
            sendCompleted(sink)
        }
    }
}