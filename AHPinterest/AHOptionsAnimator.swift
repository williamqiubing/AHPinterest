//
//  AHAnimator.swift
//  AHWeiBo
//
//  Created by Andy Hurricane on 3/2/17.
//  Copyright © 2017 AndyHurricane. All rights reserved.
//

import UIKit

fileprivate enum AHOptionsAnimatorState {
    case none
    case presenting
    case dismissing
}

// This protocol is specifically for AHOptionVC
protocol AHOptionsAnimatorDelegate: NSObjectProtocol {
    // The presenting VC should comfirm to this method. You should do the VC related animation here, such as the share buttons popping out after finishing transition.
    func optionsAnimatorDidFinishTransition()
}

extension AHOptionsAnimatorDelegate {
    func optionsAnimatorDidFinishTransition() {
        // default behavior
    }
}

class AHOptionsAnimator: NSObject {
    weak var delegate: AHOptionsAnimatorDelegate?
    weak var fromCell: UIView?
    fileprivate var state: AHOptionsAnimatorState = .none
    fileprivate var fromViewSnapshot: UIView?

    // Called before optionHandler use presenterVC to do presentation
    func start(fromCell: UIView) {
        self.fromCell = fromCell
    }
}


extension AHOptionsAnimator : UIViewControllerTransitioningDelegate{
    // callecd when presenting
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        state = .presenting
        return self
    }
    // called when dismissing
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        state = .dismissing
        return self
    }
}

extension AHOptionsAnimator : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch state {
        case .presenting:
            animationTransitionForPresenting(using: transitionContext)
        case .dismissing:
            animationTransitionForDismissing(using: transitionContext)
        default:
            break
        }
    }
    // for presenting aniamtion, will be called just before viewWillAppear:
    func animationTransitionForPresenting(using context: UIViewControllerContextTransitioning){
        
        // Can't not obtain the cell view here!!!
//        let fromViewByKey = context.view(forKey: UITransitionContextViewKey.from)

        
        guard
            let toView = context.view(forKey: UITransitionContextViewKey.to),
            let fromCell = fromCell
        else { return}

        
        // setup the snapshot and put it on the bottom of the toView
        fromViewSnapshot = fromCell.snapshotView(afterScreenUpdates: true)
        fromViewSnapshot?.frame = fromCell.convert(fromViewSnapshot!.frame, to: toView)
        fromViewSnapshot?.alpha = 0.6
        context.containerView.addSubview(toView)
        toView.insertSubview(fromViewSnapshot!, at: 0)
        
        toView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        UIView.animate(withDuration: 0.2, animations: {
            toView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            }, completion: { (_) in
                // the following will tell the VC to display views and call viewDidAppear:
                context.completeTransition(true)
                
                // this animation has to be called after VC's viewDidAppear: in order to do VC related animation
                self.delegate?.optionsAnimatorDidFinishTransition()
        })

    }
    
    /// For dismissing animation
    func animationTransitionForDismissing(using context: UIViewControllerContextTransitioning){
        
        // get presentedView by UITransitionContextViewKey.from
        if let fromView = context.view(forKey: UITransitionContextViewKey.from) {
            fromView.removeFromSuperview()
            fromViewSnapshot?.removeFromSuperview()
            context.completeTransition(true)
        }
        
        
    }
        
}





