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
    }

    override func viewDidAppear(animated: Bool)
    {
        shadingImageChange()
    }
    
    func shadingImageChange()
    {
        textEditor.shadingImage = shadingImageEditor.image
        
        textEditor.createImage()
    }
    
    override func viewDidLayoutSubviews()
    {
        let top = topLayoutGuide.length
        let shadingImageEditorWidth = CGFloat(300)
        
        shadingImageEditor.frame = CGRect(x: view.frame.width - shadingImageEditorWidth,
            y: top,
            width: shadingImageEditorWidth,
            height: view.frame.height - top)
        
        textEditor.frame = CGRect(x: 0,
            y: top,
            width: view.frame.width - shadingImageEditorWidth,
            height: view.frame.height - top)
    }
}

