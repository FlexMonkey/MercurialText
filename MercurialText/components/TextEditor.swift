//
//  TextEditor.swift
//  MercurialText
//
//  Created by Simon Gladman on 01/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class TextEditor: UIView
{
    let label = UILabel()
    let fontPicker = UIPickerView()
    let imageView = UIImageView()
    
    let fonts = UIFont.familyNames().sort()
    
    let heightMapFilter = CIFilter(name: "CIHeightFieldFromMask")!
    let shadedMaterialFilter = CIFilter(name: "CIShadedMaterial")!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        backgroundColor = UIColor.lightGrayColor()
        
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: fonts.first!, size: 300)
        label.numberOfLines = 5
        label.adjustsFontSizeToFitWidth = true
        label.text = "ABC XYZ Xyzzy"
        
        label.backgroundColor = UIColor.blackColor()
        label.textColor = UIColor.whiteColor()
        
        addSubview(label)
        addSubview(fontPicker)
        addSubview(imageView)
        
        fontPicker.dataSource = self
        fontPicker.delegate = self
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var shadingImage: UIImage?
    
    override func layoutSubviews()
    {
        let availableHeight = frame.height - fontPicker.intrinsicContentSize().height
        
        label.frame = CGRect(x: 0,
            y: 0,
            width: frame.width,
            height: availableHeight / 2)

        imageView.frame = CGRect(x: 0,
            y: availableHeight / 2,
            width: frame.width,
            height: availableHeight / 2)
        
        fontPicker.frame = CGRect(x: 0,
            y: frame.height - fontPicker.intrinsicContentSize().height,
            width: frame.width,
            height: fontPicker.intrinsicContentSize().height)
        
        fontPicker.reloadInputViews()
    }
    
    
    func createImage()
    {
        guard let shadingImage = shadingImage, ciShadingImage = CIImage(image: shadingImage) else
        {
            print("shadingImage nil!")
            
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: label.frame.width, height: label.frame.height), true, 1)
        
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        heightMapFilter.setValue(CIImage(image: image), forKey: kCIInputImageKey)

        shadedMaterialFilter.setValue(heightMapFilter.valueForKey(kCIOutputImageKey), forKey: kCIInputImageKey)
        shadedMaterialFilter.setValue(ciShadingImage, forKey: "inputShadingImage")
        
        imageView.image = UIImage(CIImage: shadedMaterialFilter.valueForKey(kCIOutputImageKey) as! CIImage)
    }
}

extension TextEditor: UIPickerViewDataSource
{
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return fonts.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
}

extension TextEditor: UIPickerViewDelegate
{
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return fonts[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        label.font = UIFont(name: fonts[row], size: 300)
        
        createImage()
    }
    
}