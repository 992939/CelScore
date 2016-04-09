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
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let offScreenRight = CGAffineTransformMakeTranslation(container!.frame.width, 0)
        let offScreenLeft = CGAffineTransformMakeTranslation(-container!.frame.width, 0)
        
        if (self.presenting){
            let masterVC = (fromVC as! SideNavigationController).rootViewController as! MasterViewController
            let selectedRow = masterVC.celebrityTableView.indexPathForSelectedRow
            let cell = masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow!) as! CelebrityTableViewCell
            let celebSnapshot = cell.profilePicNode.view.snapshotViewAfterScreenUpdates(false)
            celebSnapshot.frame = container!.convertRect(cell.profilePicNode.view.frame, fromView: masterVC.celebrityTableView.nodeForRowAtIndexPath(selectedRow!).view)
            cell.profilePicNode.hidden = true
            toVC.view.transform = offScreenRight
        } else { toVC.view.transform = offScreenLeft }
        
        container!.addSubview(toVC.view)
        container!.addSubview(fromVC.view)
        
        let duration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            if (self.presenting){ fromVC.view.transform = offScreenLeft }
            else { fromVC.view.transform = offScreenRight }
            toVC.view.transform = CGAffineTransformIdentity
            }, completion: { finished in transitionContext.completeTransition(true)
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
