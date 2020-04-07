//
//  UIView.swift
//  mapkit-joca
//
//  Created by Matheus Silva on 06/04/20.
//  Copyright © 2020 Matheus Gois. All rights reserved.
//

import UIKit

@IBDesignable
class RoundUIView: UIVisualEffectView {

    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

}
