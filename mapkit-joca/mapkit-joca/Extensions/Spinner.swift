//
//  Spinner.swift
//  mapkit-joca
//
//  Created by Matheus Silva on 06/04/20.
//  Copyright © 2020 Matheus Gois. All rights reserved.
//

import UIKit

var vSpinner: UIView?

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = (UIColor(named: "myColor") ?? .white) .withAlphaComponent(0.5)
            
        let ai = UIActivityIndicatorView.init(style: .medium)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
