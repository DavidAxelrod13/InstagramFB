//
//  CustomAnimationDismisser.swift
//  InstagramFB
//
//  Created by David on 30/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class CustomAnimationDismisser: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // custom transistion animation code
       
        let containerView = transitionContext.containerView
        // the camera controller view
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        // the home controller view
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let startFrameForToView = CGRect(x: toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        
        toView.frame = startFrameForToView
        
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            fromView.frame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            
        }) { (_) in
            transitionContext.completeTransition(true)
        }
        
    }
}
