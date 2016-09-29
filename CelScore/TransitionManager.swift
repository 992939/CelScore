//
//  TransitionManager.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/6/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import Material

final class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate  {
    
    fileprivate var presenting = true
    fileprivate var indexedCell: Int = 0
    
    // MARK: UIViewControllerAnimatedTransitioning
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let offScreenRight = CGAffineTransform(translationX: container.frame.width, y: 0)
        let offScreenLeft = CGAffineTransform(translationX: -container.frame.width, y: 0)
    
        let masterVC = ((presenting ? transitionContext.viewControllerForKey(UITransitionContextViewControllerKey.from)! : transitionContext.viewControllerForKey(UITransitionContextViewControllerKey.to)!) as! NavigationDrawerController).rootViewController as! MasterViewController
        let detailVC = (presenting ? transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! : transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!) as! DetailViewController
        
        let selectedRow = IndexPath(row: indexedCell, section: 0)
        let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow) as! CelebrityTableViewCell
        cell.profilePicNode.hidden = true
        detailVC.view.frame = transitionContext.finalFrame(for: detailVC)
        detailVC.profilePicNode.isHidden = true
        detailVC.view.transform = presenting ? offScreenRight : CGAffineTransform(translationX: 0, y: 0)
        
        var celebSnapshot = UIView()
        if self.presenting {
            celebSnapshot = cell.profilePicNode.view.snapshotViewAfterScreenUpdates(false)
            celebSnapshot.frame = container!.convertRect(cell.profilePicNode.view.frame, fromView: masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow).view)
        } else {
            masterVC.view.transform = offScreenLeft
            celebSnapshot = detailVC.profilePicNode.view.snapshotView(afterScreenUpdates: false)!
            celebSnapshot.frame = container.convert(detailVC.profilePicNode.view.frame, from: detailVC.view)
        }
        let topVC = (presenting ? transitionContext.viewControllerForKey(UITransitionContextViewControllerKey.from)! : transitionContext.viewControllerForKey(UITransitionContextViewControllerKey.to)!) as! NavigationDrawerController
        
        container.addSubview(detailVC.view)
        container!.addSubview(topVC.view)
        container.addSubview(celebSnapshot)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: UIViewAnimationOptions(), animations: {
            if self.presenting {
                detailVC.view.alpha = 1
                celebSnapshot.frame = detailVC.profilePicNode.view.frame
                masterVC.view.transform = offScreenLeft
                detailVC.view.transform = CGAffineTransform.identity
            } else {
                masterVC.view.alpha = 1
                let selectedRow = IndexPath(row: self.indexedCell, section: 0)
                let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow) as! CelebrityTableViewCell
                cell.profilePicNode.hidden = true
                detailVC.view.transform = offScreenRight
                masterVC.view.transform = CGAffineTransform.identity
                let rect = masterVC.celebrityTableView.rectForRowAtIndexPath(selectedRow)
                let relativeRect = rect.offsetBy(dx: -masterVC.celebrityTableView.contentOffset.x, dy: -masterVC.celebrityTableView.contentOffset.y)
                celebSnapshot.frame = CGRect(x: 15.0, y: relativeRect.origin.y + 134, width: UIDevice.getRowHeight(), height: UIDevice.getRowHeight())
            }
            }, completion: { _ in
                detailVC.profilePicNode.isHidden = false
                if self.presenting == false {
                    let selectedRow = IndexPath(row: self.indexedCell, section: 0)
                    let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow) as? CelebrityTableViewCell
                    cell?.profilePicNode.hidden = false
                }
                celebSnapshot.removeFromSuperview()
                transitionContext.completeTransition(true)
        })
    }
    
    func setIndexedCell(index: Int) { self.indexedCell = index }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { return 1.0 }
    
    // MARK: UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
}
