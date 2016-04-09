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
        let celebSnapshot = cell.profilePicNode.view.snapshotViewAfterScreenUpdates(false)
        celebSnapshot.frame = container!.convertRect(cell.profilePicNode.view.frame, fromView: masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow!).view)
        cell.profilePicNode.hidden = true
        detailVC.view.frame = transitionContext.finalFrameForViewController(detailVC)
        detailVC.view.alpha = 0
        detailVC.profilePicNode.hidden = true
        detailVC.view.transform = presenting ? offScreenRight : offScreenLeft
        
        container!.addSubview(detailVC.view)
        container!.addSubview(masterVC.view)
        container!.addSubview(celebSnapshot)
        
        let duration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            if self.presenting {
                detailVC.view.alpha = 1
                celebSnapshot.frame = detailVC.profilePicNode.view.frame
            } else {
                masterVC.view.alpha = 1
                let selectedRow = masterVC.celebrityTableView.indexPathForSelectedRow
                let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow!) as! CelebrityTableViewCell
                let celebSnapshot = cell.profilePicNode.view.snapshotViewAfterScreenUpdates(false)
                celebSnapshot.frame = container!.convertRect(cell.profilePicNode.view.frame, fromView: masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow!).view)
            }
            masterVC.view.transform = self.presenting ? offScreenLeft : offScreenRight
            detailVC.view.transform = CGAffineTransformIdentity
            }, completion: { _ in
                detailVC.profilePicNode.hidden = false
                if self.presenting {
                    let selectedRow = masterVC.celebrityTableView.indexPathForSelectedRow
                    let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow!) as! CelebrityTableViewCell
                    cell.profilePicNode.hidden = false
                }
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
