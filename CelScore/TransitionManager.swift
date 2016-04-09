//
//  TransitionManager.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/6/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import Material

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate  {
    
    private var presenting = true
    
    // MARK: UIViewControllerAnimatedTransitioning
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        let offScreenRight = CGAffineTransformMakeTranslation(container!.frame.width, 0)
        let offScreenLeft = CGAffineTransformMakeTranslation(-container!.frame.width, 0)
    
        let masterVC = ((presenting ? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! : transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!) as! SideNavigationController).rootViewController as! MasterViewController
        let detailVC = (presenting ? transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! : transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!) as! DetailViewController
        
        let selectedRow = masterVC.celebrityTableView.indexPathForSelectedRow
        let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow!) as! CelebrityTableViewCell
        cell.profilePicNode.hidden = true
        detailVC.view.frame = transitionContext.finalFrameForViewController(detailVC)
        detailVC.view.alpha = 0
        detailVC.profilePicNode.hidden = true
        detailVC.view.transform = presenting ? offScreenRight : CGAffineTransformMakeTranslation(0, 0)
        
        var celebSnapshot = UIView()
        if self.presenting {
            celebSnapshot = cell.profilePicNode.view.snapshotViewAfterScreenUpdates(false)
            celebSnapshot.frame = container!.convertRect(cell.profilePicNode.view.frame, fromView: masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow!).view)
        } else {
            masterVC.view.transform =  CGAffineTransformMakeTranslation(0, 0)
            let selectedRow = masterVC.celebrityTableView.indexPathForSelectedRow
            let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow!) as! CelebrityTableViewCell
            cell.profilePicNode.hidden = true
            celebSnapshot = detailVC.profilePicNode.view.snapshotViewAfterScreenUpdates(false)
            celebSnapshot.frame = container!.convertRect(detailVC.profilePicNode.view.frame, fromView: detailVC.view)
        }
        let topVC = (presenting ? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! : transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!) as! SideNavigationController
        
        container!.addSubview(detailVC.view)
        container!.addSubview(topVC.view)
        container!.addSubview(celebSnapshot)
        
        let duration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            if self.presenting {
                detailVC.view.alpha = 1
                celebSnapshot.frame = detailVC.profilePicNode.view.frame
                masterVC.view.transform = offScreenLeft
                detailVC.view.transform = CGAffineTransformIdentity
            } else {
                masterVC.view.alpha = 1
                let selectedRow = masterVC.celebrityTableView.indexPathForSelectedRow
                let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow!) as! CelebrityTableViewCell
                cell.profilePicNode.hidden = true
                masterVC.view.transform = CGAffineTransformIdentity
                let rect = masterVC.celebrityTableView.rectForRowAtIndexPath(selectedRow!)
                let relativeRect = CGRectOffset(rect, -masterVC.celebrityTableView.contentOffset.x, -masterVC.celebrityTableView.contentOffset.y)
                celebSnapshot.frame = CGRect(x: 16.3, y: relativeRect.origin.y + 134, width: 70, height: 70)
                detailVC.view.transform = offScreenRight
            }
            }, completion: { _ in
                detailVC.profilePicNode.view.hidden = self.presenting ? false : true
                celebSnapshot.removeFromSuperview()
                transitionContext.completeTransition(true)
        })
    }
    
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
