//
//  InfoViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/1/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material


final class InfoViewController: ASViewController {
    
    //MARK: Properties
    let ratingsVM: RatingsViewModel
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct, frame: CGRect) {
        self.ratingsVM = RatingsViewModel(celebrityId: celebrityST.id)
        
        super.init(node: ASDisplayNode())
        self.view.frame = frame
        
        
        //        self.celebrityVM.getCelebritySignal(id: self.celebST.id)
        //            .on(next: { celeb in
        //
        //                self.nickNameTextNode.attributedString = NSMutableAttributedString(string:"\(celeb.nickName)")
        //                let zodiac = (celeb.birthdate.dateFromFormat("MM/dd/yyyy")?.zodiacSign().name())!
        //                self.zodiacTextNode.attributedString = NSMutableAttributedString(string:"\(zodiac)")
        //                let birthdate = celeb.birthdate.dateFromFormat("MM/dd/yyyy")
        //                var age = 0
        //                if NSDate().month < birthdate!.month || (NSDate().month == birthdate!.month && NSDate().day < birthdate!.day )
        //                { age = NSDate().year - (birthdate!.year+1) } else { age = NSDate().year - birthdate!.year }
        //                self.ageTextNode.attributedString = NSMutableAttributedString(string: "\(age)")
        //            })
        //            .start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MaterialColor.green.base
        print("Say waaaaah \(self.view.frame)")
    }
}