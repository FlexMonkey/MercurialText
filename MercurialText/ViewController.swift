//
//  ViewController.swift
//  MercurialText
//
//  Created by Simon Gladman on 30/11/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

    let textEditor = TextEditor()
    let shadingImageEditor = ShadingImageEditor()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        shadingImageEditor.addTarget(self, action: "shadingImageChange", forControlEvents: UIControlEvents.ValueChanged)
        
        view.addSubview(shadingImageEditor)
        
        view.addSubview(textEditor)
        
        shadingImageChange()
    }

    func shadingImageChange()
    {
        textEditor.shadingImage = shadingImageEditor.image
        
        textEditor.createImage()
    }
    
    override func viewDidLayoutSubviews()
    {
        shadingImageEditor.frame = CGRect(x: view.frame.width - 300,
            y: 0,
            width: 300,
            height: view.frame.height)
        
        textEditor.frame = CGRect(x: 0,
            y: 0,
            width: view.frame.width - 300,
            height: view.frame.height)
    }


}

