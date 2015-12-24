//
//  TextEditor.swift
//  MercurialText
//
//  Created by Simon Gladman on 01/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit
import GLKit

class TextEditor: UIView
{
    let imageView: GLKView
  
    let toolbar = UIToolbar()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    let fonts = UIFont.familyNames().sort()

    var pendingUpdate = false
    
    var shadingImage: UIImage?
    var filteredImageData: CIImage?
    
    let heightMapFilter = CIFilter(name: "CIHeightFieldFromMask")!
    let shadedMaterialFilter = CIFilter(name: "CIShadedMaterial")!
    
    var isBusy = false
    {
        didSet
        {
            if isBusy
            {
                activityIndicator.startAnimating()
            }
            else
            {
                activityIndicator.stopAnimating()
            }
        }
    }

    lazy var ciContext: CIContext =
    {
        [unowned self] in
        
        return CIContext(EAGLContext: self.imageView.context, options: [kCIContextWorkingColorSpace: NSNull()])
    }()
    
    lazy var fontPicker: UIPickerView =
    {
        [unowned self] in
        
        let fontPicker = UIPickerView()
        
        fontPicker.dataSource = self
        fontPicker.delegate = self
        fontPicker.backgroundColor = UIColor.lightGrayColor()
        
        return fontPicker
    }()
    
    lazy var label: UILabel =
    {
        [unowned self] in
        
        let label = UILabel()
        
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: self.fonts.first!, size: 300)
        label.numberOfLines = 5
        label.adjustsFontSizeToFitWidth = true
        label.text = "Flex Monkey Mercurial Text"
        label.textColor = UIColor.whiteColor()
        
        return label
    }()
   
    override init(frame: CGRect)
    {
        imageView = GLKView(frame: frame, context: EAGLContext(API: .OpenGLES2))
        
        super.init(frame: frame)

        imageView.delegate = self
        
        backgroundColor = UIColor.blackColor()
        imageView.backgroundColor = UIColor.blackColor()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editTextClicked")
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveImageClicked")

        toolbar.setItems([editButton, saveButton], animated: false)
        
        activityIndicator.stopAnimating()
        
        addSubview(label)
        addSubview(fontPicker)
        addSubview(imageView)
        addSubview(toolbar)
        addSubview(activityIndicator)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func editTextClicked()
    {
        guard let rootController = UIApplication.sharedApplication().keyWindow!.rootViewController else
        {
            return
        }
        
        let editTextController = UIAlertController(title: "Mercurial Text", message: nil, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
        {
            (_: UIAlertAction) in
            
            if let updatedText = editTextController.textFields?.first?.text
            {
                self.label.text = updatedText
                
                self.createImage()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        editTextController.addTextFieldWithConfigurationHandler
        {
            (textField: UITextField) in
            
            textField.text = self.label.text
        }
        
        editTextController.addAction(okAction)
        editTextController.addAction(cancelAction)
       
        rootController.presentViewController(editTextController, animated: false, completion: nil)
    }
  
    func saveImageClicked()
    {
        guard let filteredImageData = filteredImageData else
        {
            return
        }
        
        toolbar.items?.forEach
        {
            $0.enabled = false
        }
        
        let cgImage = ciContext.createCGImage(filteredImageData, fromRect: filteredImageData.extent)
        
        UIImageWriteToSavedPhotosAlbum(UIImage(CGImage: cgImage), self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>)
    {
        toolbar.items?.forEach
        {
            $0.enabled = true
        }
    }
    
    func createImage()
    {
        guard !isBusy else
        {
            pendingUpdate = true
            return
        }
       
        guard let shadingImage = shadingImage, ciShadingImage = CIImage(image: shadingImage) else
        {
            return
        }
        
        isBusy = true
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.label.frame.width,
            height: self.label.frame.height), false, 1)
        
        self.label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let textImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        {
            let heightMapFilter = self.heightMapFilter.copy()
            let shadedMaterialFilter = self.shadedMaterialFilter.copy()
            
            heightMapFilter.setValue(CIImage(image: textImage),
                forKey: kCIInputImageKey)
            
            shadedMaterialFilter.setValue(heightMapFilter.valueForKey(kCIOutputImageKey),
                forKey: kCIInputImageKey)
            
            shadedMaterialFilter.setValue(ciShadingImage,
                forKey: "inputShadingImage")
            
            self.filteredImageData = shadedMaterialFilter.valueForKey(kCIOutputImageKey) as? CIImage
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.imageView.setNeedsDisplay()
            }
        }
    }
    
    // MARK: Layout stuff
    
    override func layoutSubviews()
    {
        let availableHeight = frame.height - fontPicker.intrinsicContentSize().height
        let toolbarHeight = toolbar.intrinsicContentSize().height
        
        let mainFrame = CGRect(x: 0,
            y: 0,
            width: frame.width,
            height: availableHeight - toolbarHeight)
        
        label.frame = mainFrame
        imageView.frame = mainFrame
        activityIndicator.frame = mainFrame
        
        fontPicker.frame = CGRect(x: 0,
            y: frame.height - fontPicker.intrinsicContentSize().height - toolbarHeight,
            width: frame.width,
            height: fontPicker.intrinsicContentSize().height)
        
        toolbar.frame = CGRect(x: 0,
            y: frame.height - toolbarHeight,
            width: frame.width,
            height: toolbarHeight)
    }
}

extension TextEditor: GLKViewDelegate
{
    func glkView(view: GLKView, drawInRect rect: CGRect)
    {
        guard let filteredImageData = filteredImageData else
        {
            return
        }
        
        ciContext.drawImage(filteredImageData,
            inRect: CGRect(x: 0, y: 0, width: imageView.drawableWidth, height: imageView.drawableHeight),
            fromRect: filteredImageData.extent)
        
        isBusy = false
        
        if pendingUpdate
        {
            pendingUpdate = false
            
            createImage()
        }
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