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
    
    var fetchResult : PHFetchResult<PHAsset>!
    var assets = [PHAsset]()
    lazy var imageManager = {
        return PHCachingImageManager()
    }()


    // MARK: - UICollectionViewDataSource protocol
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height:200)
    }
    
    // tell the collection view how many cells to make
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    // make a cell for each cell index path
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        cell.backgroundColor = UIColor.red

        imageManager.requestImage(for: assets[indexPath.row], targetSize: CGSize(width: 150.0, height: 150.0), contentMode: .default, options: nil, resultHandler: { (image, info) in
            let imageView = UIImageView(frame: CGRect(x:0, y:0, width:cell.frame.size.width, height:cell.frame.size.height))
            imageView.image = image
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            cell.addSubview(imageView)

        })
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        let data = self.assets[indexPath.item]
        
        self.playVideo(view: self, videoAsset: data)
    }
    
    fileprivate func getAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true) ]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: options)
        fetchResult.enumerateObjects({(asset, index, stop) in
            self.assets.append(asset)
                        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "VIDEOS"
        collectionView?.backgroundColor = UIColor.blue
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.dataSource = self
        getAssets()
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isSynchronous = false
        imageRequestOptions.resizeMode = .exact
        imageRequestOptions.deliveryMode = .highQualityFormat
        imageRequestOptions.version = .current
        imageRequestOptions.isNetworkAccessAllowed = false

        self.imageManager.startCachingImages(for: assets, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: imageRequestOptions)

        /*
        var cameraRollAssets = results.filteredArrayUsingPredicate(NSPredicate(format: "assetSource == %@", argumentArray: [3]))
        results = NSMutableArray(array: cameraRollAssets)*/
        // Do any additional setup after loading the view, typically from a nib.
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
        
        imageManager.requestAVAsset(forVideo: videoAsset, options: nil) { (asset, audioMix, args) in
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

