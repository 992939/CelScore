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
    
    //MARK: Properties
    let searchText = MutableProperty("")
    let isSearching = MutableProperty<Bool>(false)
    
    //MARK: Initializers
    init(searchToken: String) {
        super.init()
        
        self.searchText.producer
            .filter { $0.characters.count > 2 }
            .throttle(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
            .on(next: { _ in self.isSearching.value = true })
            .flatMap(.Latest) { (token: String) -> SignalProducer<AnyObject, NoError> in
                return self.searchSignal(searchToken: token)
            }
            .startWithNext {
                response in
                print("Search results: \(response)")
                self.isSearching.value = false
        }
    }
    
    //MARK: Methods
    func searchSignal(searchToken searchToken: String) -> SignalProducer<AnyObject, NoError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            let predicate: NSPredicate
            let list: AnyObject
            
            predicate = NSPredicate(format: "nickName contains[c] %@", searchToken)
            list = realm.objects(CelebrityModel).filter(predicate)
            sendNext(sink, list)
        }
    }
}