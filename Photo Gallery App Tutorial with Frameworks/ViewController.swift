//
//  ViewController.swift
//  Photo Gallery App Tutorial with Frameworks
//
//  Created by Annemarie Ketola on 4/14/15.
//  Copyright (c) 2015 UpEarly. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier = "PhotoCell"
let albumName = "Anne's App"

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var noPhotoLabel: UILabel!

    var assetCollection : PHAssetCollection!
    var photosAsset : PHFetchResult!
    var albumFound : Bool = false
    var assetThumbnailSize:CGSize!


    @IBAction func btnCamera(sender: AnyObject) {
        println("camera")
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            // load the camera interface
            var picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            // no camera available
            let alert = UIAlertController(title: "Error", message: "There is no camera available on this device", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (alertAction) -> Void in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
        self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func btnPhotoAlbum(sender: AnyObject) {
        println("photoAlbum")
        var picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Check if there is an app album (asset collection), otherwise create one
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        if let first_Obj:AnyObject = collection.firstObject {
            // we found the album
            self.albumFound = true
            self.assetCollection = collection.firstObject as PHAssetCollection  // THIS ASSUMES THERE IS ONLY ONE FOLDER CALLED "ANNE'S PHOTO APP"
        } else {
            // create the folder
            var albumPlaceholder:PHObjectPlaceholder!
            
            NSLog("\nFolder %@ does not exist\ncreating now...", albumName)
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)
                albumPlaceholder = request.placeholderForCreatedAssetCollection
                },
                completionHandler: {(success:Bool, error:NSError!) -> Void in
                    if(success){
                        println("Successfully created folder")
                        self.albumFound = true
                        let collection = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([albumPlaceholder.localIdentifier], options: nil)
                        self.assetCollection = collection?.firstObject as PHAssetCollection
                    } else {
                        println("Error creating folder")
                        self.albumFound = false
                    }
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        let scale:CGFloat = UIScreen.mainScreen().scale
        let cellSize = (self.collectionView.collectionViewLayout as UICollectionViewFlowLayout).itemSize
        self.assetThumbnailSize = CGSizeMake(cellSize.width, cellSize.height)
        
        // fetch the photos from the collection every time this page loads
        self.navigationController?.hidesBarsOnTap = false
        self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
        
        if let photoCnt = self.photosAsset?.count {
            if (photoCnt == 0){
                self.noPhotoLabel.hidden = false
            } else {
                self.noPhotoLabel.hidden = true
            }
        }
        
        self.collectionView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UICollectionViewDataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if (self.photosAsset != nil) {
            count = self.photosAsset.count
        }
        return count;
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: PhotoThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as PhotoThumbnail
        
        //Modify the cell
        let asset : PHAsset = self.photosAsset[indexPath.item] as PHAsset
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize:assetThumbnailSize, contentMode:.AspectFill, options: nil) {(result, info) -> Void in
            cell.setThumbnailImage(result)
        }
        
        
        cell.backgroundColor = UIColor.redColor()
        return cell
    } // end func
    
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier as String! == "SHOW_DETAIL_PHOTO"){
            let controller:ViewPhoto = segue.destinationViewController as ViewPhoto
            let indexPath: NSIndexPath = self.collectionView.indexPathForCell(sender as UICollectionViewCell)!
            controller.index = indexPath.item
            controller.photosAsset = self.photosAsset
            controller.assetCollection = self.assetCollection
        }
    }
    
    //UICollectionViewDelegateFlowLayout Methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 4
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    //UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        let image = info.objectForKey("UIImagePickerControllerOriginalImage") as UIImage
//        let editedImage = info.objectForKey("UIImagePickerControllerEditedImage") as UIImage
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0), { () -> Void in
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection, assets: self.photosAsset)
                albumChangeRequest.addAssets([assetPlaceholder])
                }, completionHandler: { (success, error) -> Void in
                    NSLog("Adding Image to Library -> %@", (success ? "Success" : "Error!"))
                    picker.dismissViewControllerAnimated(true , completion: nil)
            })
        })
        } // closes imagePickerControllerDelegate function
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true , completion: nil)
    }
    


}

