//
//  UploadPhotoVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/20/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import Photos
import TOCropViewController

class UploadPhotoVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, TOCropViewControllerDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var photoImageView: UIImageView!
    var imageArray = [UIImage]()
    let imgManager = PHImageManager.default()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        grabPhoto()
    }
    
    
    func grabPhoto(){
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
//        requestOptions.version = .unadjusted
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        
        let imageSize = CGSize(width: 800, height: 800)
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult = PHAsset.fetchAssets(with: .image, options: nil ) as? PHFetchResult {
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count {
                    imgManager.requestImage(for: fetchResult.object(at: i), targetSize: imageSize, contentMode: .aspectFill , options: nil, resultHandler: { (image, error) in
                        self.imageArray.append(image!)
                        self.photoImageView.image = self.imageArray.first
                        print("Result Size Is \(image?.size)")
                        self.collectionView.reloadData()
                    })
                }
             }
           } else {
            print("you got no Photos!")
         }
     }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        let tabBarVC = storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
        self.present(tabBarVC!, animated: true, completion: nil)
    }
    
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "CaptureDetailsVC", sender: photoImageView.image)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "CaptureDetailsVC" {
          let vc = segue.destination as! CaptureDetailsVC
             if let img = sender as? UIImage {
               vc.artImg = img
           }
       }
    }



    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadPhotoCell", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = imageArray[indexPath.row]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenRect: CGRect = UIScreen.main.bounds
        let screenWidth: CGFloat = collectionView.frame.width
        let cellWidth: CGFloat = screenWidth / 3.1
        //Replace the divisor with the column count requirement. Make sure to have it in float.
        let size = CGSize(width: CGFloat(cellWidth), height: CGFloat(cellWidth))
        return size
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets.zero
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = collectionView.cellForItem(at: indexPath)
        let imageView = cell?.viewWithTag(1) as! UIImageView
        DispatchQueue.main.async {
            self.photoImageView.image = imageView.image
            let cropController:TOCropViewController = TOCropViewController(image: imageView.image!)
            cropController.delegate = self
            self.present(cropController, animated: true, completion: nil)
        }
    }

    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.photoImageView.image = image
        }
    }
    
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
