//
//  ShadingImageEditor.swift
//  MercurialText
//
//  Created by Simon Gladman on 30/11/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit
import SceneKit


class ShadingImageEditor: UIControl
{
    let lights = [
        OmniLight(),
        OmniLight(),
        OmniLight(),
        OmniLight()
    ]
  
    let parameterGroups = [
        ParameterGroup(name: "Material", parameters: [
            Parameter(name: "Shininess", parameterFunction: .AdjustMaterialShininess, value: 0.02, minMax: MinMax(min:0.001, max: 0.25))
            ]),
        
        ParameterGroup(name: "Light 1", parameters: [
            Parameter(name: "Hue", parameterFunction: .AdjustLightHue(index: 0), value: 0, minMax: MinMaxNorm),
            Parameter(name: "Brightness", parameterFunction: .AdjustLightBrightness(index: 0), value: 1, minMax: MinMaxNorm),
            Parameter(name: "x Position", parameterFunction: .AdjustLightPosition(index: 0, axis: .X), value: 0, minMax: MinMaxXY),
            Parameter(name: "y Position", parameterFunction: .AdjustLightPosition(index: 0, axis: .Y), value: 25, minMax: MinMaxXY),
            Parameter(name: "z Position", parameterFunction: .AdjustLightPosition(index: 0, axis: .Z), value: 0, minMax: MinMaxZ)
            ]),
        
        ParameterGroup(name: "Light 2", parameters: [
            Parameter(name: "Hue", parameterFunction: .AdjustLightHue(index: 1), value: 0.333, minMax: MinMaxNorm),
            Parameter(name: "Brightness", parameterFunction: .AdjustLightBrightness(index: 1), value: 1, minMax: MinMaxNorm),
            Parameter(name: "x Position", parameterFunction: .AdjustLightPosition(index: 1, axis: .X), value: 25, minMax: MinMaxXY),
            Parameter(name: "y Position", parameterFunction: .AdjustLightPosition(index: 1, axis: .Y), value: -35, minMax: MinMaxXY),
            Parameter(name: "z Position", parameterFunction: .AdjustLightPosition(index: 1, axis: .Z), value: 0, minMax: MinMaxZ)
            ]),
        
        ParameterGroup(name: "Light 3", parameters: [
            Parameter(name: "Hue", parameterFunction: .AdjustLightHue(index: 2), value: 0.85, minMax: MinMaxNorm),
            Parameter(name: "Brightness", parameterFunction: .AdjustLightBrightness(index: 2), value: 1, minMax: MinMaxNorm),
            Parameter(name: "x Position", parameterFunction: .AdjustLightPosition(index: 2, axis: .X), value: -35, minMax: MinMaxXY),
            Parameter(name: "y Position", parameterFunction: .AdjustLightPosition(index: 2, axis: .Y), value: -20, minMax: MinMaxXY),
            Parameter(name: "z Position", parameterFunction: .AdjustLightPosition(index: 2, axis: .Z), value: -10, minMax: MinMaxZ)
            ]),
        
        ParameterGroup(name: "Light 4", parameters: [
            Parameter(name: "Hue", parameterFunction: .AdjustLightHue(index: 3), value: 0.25, minMax: MinMaxNorm),
            Parameter(name: "Brightness", parameterFunction: .AdjustLightBrightness(index: 3), value: 1, minMax: MinMaxNorm),
            Parameter(name: "x Position", parameterFunction: .AdjustLightPosition(index: 3, axis: .X), value: -35, minMax: MinMaxXY),
            Parameter(name: "y Position", parameterFunction: .AdjustLightPosition(index: 3, axis: .Y), value: 10, minMax: MinMaxXY),
            Parameter(name: "z Position", parameterFunction: .AdjustLightPosition(index: 3, axis: .Z), value: 35, minMax: MinMaxZ)
            ])
    ]
    
    let material = SCNMaterial()
    
    let sceneKitView = SCNView()
    let tableView = UITableView()
    
    var sceneChanged = false
    
    var image: UIImage?
    {
        return sceneKitView.snapshot()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        sceneKitView.layer.borderColor = UIColor.darkGrayColor().CGColor
        sceneKitView.layer.borderWidth = 1
        
        sceneKitView.delegate = self
        
        addSubview(sceneKitView)
        addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setUpSceneKit()
        applyAllParameters()
        
        tableView.rowHeight = 60
        
        tableView.registerClass(ItemRenderer.self,
            forCellReuseIdentifier: "ItemRenderer")
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
 
    func setUpSceneKit()
    {
        sceneKitView.backgroundColor = UIColor.blackColor()
        
        let sphere = SCNSphere(radius: 1)
        let sphereNode = SCNNode(geometry: sphere)
        
        let scene = SCNScene()
        
        sceneKitView.scene = scene
        
        let camera = SCNCamera()

        camera.usesOrthographicProjection = true
        camera.orthographicScale = 1
        
        let cameraNode = SCNNode()
        
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
        
        scene.rootNode.addChildNode(cameraNode)
        
        // sphere...
        
        sphereNode.position = SCNVector3(x: 0, y: 0, z: 0)
        scene.rootNode.addChildNode(sphereNode)
        
        for light in lights
        {
            scene.rootNode.addChildNode(light)
        }

        material.lightingModelName = SCNLightingModelPhong
        material.specular.contents = UIColor.whiteColor()
        material.diffuse.contents = UIColor.darkGrayColor()
        material.shininess = 0.15
        
        sphere.materials = [material]
    }
    
    func sliderChangeHandler(slider: LabelledSlider)
    {
        guard let parameter = slider.parameter else
        {
            return
        }
        
        updateSceneFromParameter(parameter)
    }
    
    func applyAllParameters()
    {
        for group in parameterGroups
        {
            for parameter in group.parameters
            {
                updateSceneFromParameter(parameter)
            }
        }
    }
    
    func updateSceneFromParameter(parameter: Parameter)
    {
        switch parameter.parameterFunction
        {
        case let .AdjustLightPosition(index, axis):
            switch axis
            {
            case .X:
                lights[index].position.x = Float(parameter.value)
            case .Y:
                lights[index].position.y = Float(parameter.value)
            case .Z:
                lights[index].position.z = Float(parameter.value)
            }
            
        case .AdjustMaterialShininess:
            material.shininess = parameter.value
            
        case let .AdjustLightHue(index):
            lights[index].hue = parameter.value
            
        case let .AdjustLightBrightness(index):
            lights[index].brightness = parameter.value
        }
        
        sceneChanged = true
    }
 
    override func layoutSubviews()
    {
        sceneKitView.frame = CGRect(x: 0,
            y: 0,
            width: frame.width,
            height: frame.width)
        
        tableView.frame = CGRect(x: 0,
            y: frame.width,
            width: frame.width,
            height: frame.height - frame.width)
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
}

// MARK: scene renderer delegate

extension ShadingImageEditor: SCNSceneRendererDelegate
{
    func renderer(renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: NSTimeInterval)
    {
        guard sceneChanged else
        {
            return
        }
        
        sceneChanged = false
        
        dispatch_async(dispatch_get_main_queue())
        {
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
}

// MARK: table delegate

extension ShadingImageEditor: UITableViewDelegate
{
    
}

// MARK: table view datasource

extension ShadingImageEditor: UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return parameterGroups.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return parameterGroups[section].parameters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemRenderer",
            forIndexPath: indexPath) as! ItemRenderer
        
        cell.parameter = parameterGroups[indexPath.section].parameters[indexPath.item]
        
        cell.slider.addTarget(self, action: "sliderChangeHandler:", forControlEvents: UIControlEvents.ValueChanged)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return parameterGroups[section].name
    }
}


