//
//  ViewPhoto.swift
//  Photo Gallery App Tutorial with Frameworks
//
//  Created by Annemarie Ketola on 4/14/15.
//  Copyright (c) 2015 UpEarly. All rights reserved.
//

import UIKit
import Photos

class ViewPhoto: UIViewController {
    
    var assetCollection : PHAssetCollection!
    var photosAsset : PHFetchResult!
    var index: Int = 0

    @IBAction func btnCancel(sender: AnyObject) {
        println("Cancel")
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func btnExport(sender: AnyObject) {
        println("export")
    }
    
    @IBAction func btnTrash(sender: AnyObject) {
        println("trash")
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this photo?", preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (alertAction) -> Void in
            // delete image
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                let request = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                request.removeAssets([self.photosAsset[self.index]])
            }, completionHandler: { (success, error) -> Void in
                NSLog("Deleted Image -> %@", (success ? "Success" : "Error"))
                alert.dismissViewControllerAnimated(true , completion:nil)
                self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
                if (self.photosAsset.count == 0) {
                    // no images left to display
                    self.imgView.image = nil
                    println("No images left")
                    // Option: here we could pop the root view controller back
                }
                if (self.index >= self.photosAsset.count){
                    self.index = self.photosAsset.count - 1
                }
                self.displayPhoto()
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (alertAction) -> Void in
            // do not delete the photo
            alert.dismissViewControllerAnimated(true , completion:nil)
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var imgView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
        self.displayPhoto()
    }
    
    func displayPhoto() {
        
        let screenSize : CGSize = UIScreen.mainScreen().bounds.size
        let targetSize = CGSizeMake(screenSize.width, screenSize.height)
        let imageManger = PHImageManager.defaultManager()
        var ID = imageManger.requestImageForAsset(self.photosAsset[self.index] as PHAsset, targetSize: targetSize, contentMode: .AspectFit, options: nil, resultHandler: { (result, info) -> Void in
            self.imgView.image = result
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
