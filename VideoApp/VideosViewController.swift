//
//  FirstViewController.swift
//  VideoApp
//
//  Created by Lukasz Bartczak on 23.09.2017.
//  Copyright © 2017 Lukasz Bartczak. All rights reserved.
//

import UIKit
import Photos

class VideosViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    
    var uiImageArray : [UIImage] = []
    var assestArray : PHFetchResult<PHAsset>!
    var assetToNav: Int!


    // MARK: - UICollectionViewDataSource protocol
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height:200)
    }
    
    // tell the collection view how many cells to make
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uiImageArray.count
    }
    
    // make a cell for each cell index path
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        cell.backgroundColor = UIColor.red
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let imageView = UIImageView(frame: CGRect(x:0, y:0, width:cell.frame.size.width, height:cell.frame.size.height))
        let image = uiImageArray[indexPath.row]
        imageView.image = image
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        cell.addSubview(imageView)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        self.assetToNav = indexPath.item
        let data = self.assestArray[self.assetToNav]
        
        self.playVideo(view: self, videoAsset: data)
    }
    
    fileprivate func getAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true) ]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        assestArray = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: options)
        assestArray.enumerateObjects { (obj, idx, bool) -> Void in
            self.uiImageArray.append(self.getAssetThumbnail(asset: obj))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "VIDEOS"
        collectionView?.backgroundColor = UIColor.blue
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.dataSource = self
        getAssets()
        /*
        var cameraRollAssets = results.filteredArrayUsingPredicate(NSPredicate(format: "assetSource == %@", argumentArray: [3]))
        results = NSMutableArray(array: cameraRollAssets)*/
        // Do any additional setup after loading the view, typically from a nib.
    }
    
   fileprivate func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playVideo (view: UIViewController, videoAsset: PHAsset) {
        
        guard (videoAsset.mediaType == .video) else {
            print("Not a valid video media type")
            return
        }
        
        PHCachingImageManager().requestAVAsset(forVideo: videoAsset, options: nil) { (asset, audioMix, args) in
            let asset = asset as! AVURLAsset
            
            DispatchQueue.main.async {
                let player = AVPlayer(url: asset.url)
                let playerViewController = VideoPlayerViewController()
                playerViewController.player = player
                view.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
        }
    }
}

