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
    
    enum searchType {
        case Celebrity
        case List
    }
    
    //MARK: Initializers
    init(searchToken: String) {
        super.init()
        
        self.searchText.producer
            .promoteErrors(ListError.self)
            .filter { $0.characters.count > 3 }
            .throttle(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
            .on(next: { _ in self.isSearching.value = true })
            .flatMap(.Latest) { (token: String) -> SignalProducer<AnyObject, ListError> in
                return self.searchForCelebritiesSignal(searchToken: token)
            }
            .observeOn(QueueScheduler.mainQueueScheduler).start(Event.sink(error: {
                print("Error \($0)")
                },
                next: {
                    response in
                    print("Search results: \(response)")
                    self.isSearching.value = false
            }))
    }
    
    func searchForCelebritiesSignal(searchToken searchToken: String) -> SignalProducer<AnyObject, ListError> {
        return SignalProducer {
            sink, disposable in
            
            let realm = try! Realm()
            
            let predicate = NSPredicate(format: "nickName contains[c] %@", searchToken)
            let list = realm.objects(CelebrityModel).filter(predicate)
            
            guard list.count > 0 else {
                sendError(sink, ListError.Empty)
                return
            }
            sendNext(sink, list)
            sendCompleted(sink)
        }
    }
    
    //MARK: Methods
    func searchForListsSignal(searchToken searchToken: String) -> SignalProducer<AnyObject, ListError> {
        return SignalProducer {
            sink, _ in
            
            let realm = try! Realm()
            
            let predicate = NSPredicate(format: "name contains[c] %@", searchToken)
            let list = realm.objects(ListsModel).filter(predicate)
            
            guard list.count > 0 else {
                sendError(sink, ListError.Empty)
                return
            }
            sendNext(sink, list)
            sendCompleted(sink)
        }
    }

}