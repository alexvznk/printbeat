//
//  Animation.swift
//  printbeatAdmin
//
//  Created by Alex on 9/20/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit

class Animation: NSObject {
    
    var duration = 0.3

}

extension Animation: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.view(forKey: .to)!
        let containerView = transitionContext.containerView
        let bgView = toView.subviews[0]
        toView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        containerView.addSubview(toView)
        bgView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, animations: {
            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
            UIView.animate(withDuration: 0.2, delay: 0.1, animations: {
                bgView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5982716182)
            }, completion: nil)
            
        }) { _ in
            
            transitionContext.completeTransition(true)
        }
        
    }
    
    
}
