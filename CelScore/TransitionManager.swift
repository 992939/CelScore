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
    
    private var presenting = true
    private var indexedCell: Int = 0
    
    // MARK: UIViewControllerAnimatedTransitioning
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        let offScreenRight = CGAffineTransformMakeTranslation(container!.frame.width, 0)
        let offScreenLeft = CGAffineTransformMakeTranslation(-container!.frame.width, 0)
    
        let masterVC = ((presenting ? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! : transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!) as! NavigationDrawerController).rootViewController as! MasterViewController
        let detailVC = (presenting ? transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! : transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!) as! DetailViewController
        
        let selectedRow = NSIndexPath(forRow: indexedCell, inSection: 0)
        let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow) as! CelebrityTableViewCell
        cell.profilePicNode.hidden = true
        detailVC.view.frame = transitionContext.finalFrameForViewController(detailVC)
        detailVC.profilePicNode.hidden = true
        detailVC.view.transform = presenting ? offScreenRight : CGAffineTransformMakeTranslation(0, 0)
        
        var celebSnapshot = UIView()
        if self.presenting {
            celebSnapshot = cell.profilePicNode.view.snapshotViewAfterScreenUpdates(false)
            celebSnapshot.frame = container!.convertRect(cell.profilePicNode.view.frame, fromView: masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow).view)
        } else {
            masterVC.view.transform = offScreenLeft
            celebSnapshot = detailVC.profilePicNode.view.snapshotViewAfterScreenUpdates(false)
            celebSnapshot.frame = container!.convertRect(detailVC.profilePicNode.view.frame, fromView: detailVC.view)
        }
        let topVC = (presenting ? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! : transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!) as! NavigationDrawerController
        
        container!.addSubview(detailVC.view)
        container!.addSubview(topVC.view)
        container!.addSubview(celebSnapshot)
        
        let duration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            if self.presenting {
                detailVC.view.alpha = 1
                celebSnapshot.frame = detailVC.profilePicNode.view.frame
                masterVC.view.transform = offScreenLeft
                detailVC.view.transform = CGAffineTransformIdentity
            } else {
                masterVC.view.alpha = 1
                let selectedRow = NSIndexPath(forRow: self.indexedCell, inSection: 0)
                let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow) as! CelebrityTableViewCell
                cell.profilePicNode.hidden = true
                detailVC.view.transform = offScreenRight
                masterVC.view.transform = CGAffineTransformIdentity
                let rect = masterVC.celebrityTableView.rectForRowAtIndexPath(selectedRow)
                let relativeRect = CGRectOffset(rect, -masterVC.celebrityTableView.contentOffset.x, -masterVC.celebrityTableView.contentOffset.y)
                celebSnapshot.frame = CGRect(x: 15.0, y: relativeRect.origin.y + 134, width: UIDevice.getRowHeight(), height: UIDevice.getRowHeight())
            }
            }, completion: { _ in
                detailVC.profilePicNode.hidden = false
                if self.presenting == false {
                    let selectedRow = NSIndexPath(forRow: self.indexedCell, inSection: 0)
                    let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow) as? CelebrityTableViewCell
                    cell?.profilePicNode.hidden = false
                }
                celebSnapshot.removeFromSuperview()
                transitionContext.completeTransition(true)
        })
    }
    
    func setIndexedCell(index index: Int) { self.indexedCell = index }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval { return 1.0 }
    
    // MARK: UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
}
