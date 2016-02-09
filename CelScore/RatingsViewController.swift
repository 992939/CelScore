//
//  RatingsViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/1/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material


final class RatingsViewController: ASViewController {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let pulseView: MaterialPulseView
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct, frame: CGRect) {
        self.celebST = celebrityST
        self.pulseView = MaterialPulseView(frame: frame)
        super.init(node: ASDisplayNode())
        self.view.frame = frame
        self.view.tag = Constants.kDetailViewTag
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let maxHeight = self.pulseView.height - 2 * Constants.kCellPadding
        let maxWidth = self.pulseView.width - 2 * Constants.kCellPadding
        
        let ratingsVM = RatingsViewModel(celebrityId: self.celebST.id)
        ratingsVM.getRatingsSignal(ratingType: .Ratings)
        .on(next: { ratings in
            for (index, quality) in Qualities.getAll().enumerate() {
                let qualityView = MaterialView(frame: CGRect(x: Constants.kCellPadding, y: CGFloat(index) * (maxHeight / 10) + Constants.kCellPadding, width: maxWidth, height: 30))
                let qualityLabel = UILabel()
                qualityLabel.text = quality
                qualityLabel.frame = CGRect(x: Constants.kCellPadding, y: 3, width: 120, height: 25)
                qualityView.depth = .Depth1
                qualityView.backgroundColor = MaterialColor.white
                qualityView.addSubview(qualityLabel)
                self.pulseView.addSubview(qualityView)
            }
        })
        .start()
        
        self.pulseView.backgroundColor = MaterialColor.clear
        self.view = self.pulseView
    }
}