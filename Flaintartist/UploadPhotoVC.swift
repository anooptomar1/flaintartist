//
//  UploadPhotoVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/20/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import TOCropViewController
import Photos
#if os(iOS)
    import PhotosUI
#endif


private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}


class UploadPhotoVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, TOCropViewControllerDelegate {

    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var indexPath = NSIndexPath()
    var asset: PHAsset!
    var imageArray = [UIImage]()
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var descLbl: UILabel!
    @IBOutlet var nextBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self as PHPhotoLibraryChangeObserver)
        
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let cellSize = layout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CaptureDetailsVC" {
            
        guard let destination = segue.destination as? CaptureDetailsVC
            else { fatalError("unexpected view controller for segue") }
        destination.artImg = sender as! UIImage
            
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    

    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        let tabBarVC = storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
        self.present(tabBarVC!, animated: true, completion: nil)
    }
    
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "CaptureDetailsVC", sender: self.photoImageView.image)
    }
    

    // MARK: UICollectionView
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
        
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UploadPhotoCell.self), for: indexPath) as? UploadPhotoCell
            else { fatalError("unexpected cell in collection view") }

        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        //let cell = collectionView.cellForItem(at: indexPath)
        //let imageView = cell?.viewWithTag(1) as! UIImageView
        DispatchQueue.main.async {
            self.asset = self.fetchResult.object(at: indexPath.item)
            self.crop()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Compute the dimension of a cell for an NxN layout with space S between
        // cells.  Take the collection view's width, subtract (N-1)*S points for
        // the spaces between the cells, and then divide by N to find the final
        // dimension for the cell's width and height.
        
        let cellsAcross: CGFloat = 3
        let spaceBetweenCells: CGFloat = 1
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim)
    }

    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        self.descLbl.isHidden = true
        self.photoImageView.image = image
        self.nextBtn.isEnabled = true
    }
    
    
    func crop() {
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            // Handler might not be called on the main queue, so re-dispatch for UI work.
            DispatchQueue.main.sync {
                //self.progressView.progress = Float(progress)
            }
        }
        
        
        var targetSize: CGSize {
            let scale = UIScreen.main.scale
            return CGSize(width: self.photoImageView.bounds.width * scale,
                          height: self.photoImageView.bounds.height * scale)
        }
        
        
        PHImageManager.default().requestImage(for: self.asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { image, _ in
            // Hide the progress view now the request has completed.
            //self.progressView.isHidden = true
            
            // If successful, show the image view and display the image.
            guard let image = image else { return }
            
            // Now that we have the image, show it.
            #if os(iOS)
                //self.livePhotoView.isHidden = true
            #endif
            let cropController:TOCropViewController = TOCropViewController(image: image)
            cropController.delegate = self
            self.present(cropController, animated: true, completion: nil)
        })
    
    }
    
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    

    
    // MARK: Asset Caching
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let preheatRect = view!.bounds.insetBy(dx: 0, dy: -0.5 * view!.bounds.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}

    // MARK: PHPhotoLibraryChangeObserver
    extension UploadPhotoVC: PHPhotoLibraryChangeObserver {
        func photoLibraryDidChange(_ changeInstance: PHChange) {
            
            guard let changes = changeInstance.changeDetails(for: fetchResult)
                else { return }
            
            // Change notifications may be made on a background queue. Re-dispatch to the
            // main queue before acting on the change as we'll be updating the UI.
            DispatchQueue.main.sync {
                // Hang on to the new fetch result.
                fetchResult = changes.fetchResultAfterChanges
                if changes.hasIncrementalChanges {
                    // If we have incremental diffs, animate them in the collection view.
                    guard let collectionView = self.collectionView else { fatalError() }
                    collectionView.performBatchUpdates({
                        // For indexes to make sense, updates must be in this order:
                        // delete, insert, reload, move
                        if let removed = changes.removedIndexes, removed.count > 0 {
                            collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                        }
                        if let inserted = changes.insertedIndexes, inserted.count > 0 {
                            collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                        }
                        if let changed = changes.changedIndexes, changed.count > 0 {
                            collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                        }
                        changes.enumerateMoves { fromIndex, toIndex in
                            collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                    to: IndexPath(item: toIndex, section: 0))
                        }
                    })
                } else {
                    // Reload the collection view if incremental diffs are not available.
                    self.collectionView!.reloadData()
                }
                resetCachedAssets()
            }
        }
     }


