//
//  ClassMultipleImagePicker.swift
//  PHPickerViewController
//
//  Created by iMac on 27/04/22.
//

import Foundation
import UIKit
import PhotosUI
import MBProgressHUD

protocol MultipleImagePickerDelegate {
    func selectedMedia(allMedia:[MultipleImagePicker.resultData])
}

public class MultipleImagePicker:NSObject{
    
    //MARK:- Varible's
    public static let shared = MultipleImagePicker()
    
    private let videoIdentifier = UTType.movie.identifier
    private let imageIdentifier = UTType.image.identifier
    private let jpegImageIdentifier = UTType.jpeg.identifier
    
    private var superVC = UIViewController()
    private var arrResult = [resultData]()
    private var delegate:MultipleImagePickerDelegate?
    private var arrAllselectedMedia = [PHPickerResult]()
    
    enum mediaType{
        case img
        case livePhoto
        case videoUrl
    }
    
    struct resultData {
        var img:UIImage? = nil
        var url:URL? = nil
        var livePhotot:PHLivePhoto? = nil
        var mediaType:mediaType
    }
    
    //MARK:- Funstion's
    
    private func loader(isStart:Bool = true){
        DispatchQueue.main.async {
            [self] in
            
            if isStart{
                MBProgressHUD.showAdded(to: superVC.view, animated: true)
            }else{
                MBProgressHUD.hide(for: superVC.view, animated: true)
            }
        }
    }
    
    func openImagePicker(maxSelection:Int = 5,
                         openFor:[PHPickerFilter] = [PHPickerFilter.images,
                                                     PHPickerFilter.videos,
                                                     PHPickerFilter.livePhotos],
                         tempDelegate:MultipleImagePickerDelegate,
                         vc:UIViewController){
        superVC = vc
        delegate = tempDelegate
        
        var config = PHPickerConfiguration()
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = maxSelection
        config.filter = PHPickerFilter.any(of: openFor)
        
        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        superVC.present(pickerViewController, animated: true, completion: nil)
    }
    
    private func getVideo(provider:NSItemProvider,
                          completion:@escaping ((URL?,Error?) -> Void)){
        
        provider.loadItem(forTypeIdentifier: videoIdentifier, options: [:]) { (videoURL, videoErr) in

            if let videoURL = videoURL as? URL{
                completion(videoURL,nil)
            }else{
                print("Get Video Error :- ",videoErr?.localizedDescription ?? "")
                completion(nil,videoErr)
            }
        }
    }
    
    private func getLiveImage(provider:NSItemProvider,
                              completion:@escaping ((PHLivePhoto?,Error?) -> Void)){
        
        provider.loadObject(ofClass: PHLivePhoto.self) { (livePhoto, liveImgErr) in
            if let livePhoto = livePhoto as? PHLivePhoto{
                completion(livePhoto,nil)
            }else{
                print("Get LivePhoto Error :- ",liveImgErr?.localizedDescription ?? "")
                completion(nil,liveImgErr)
            }
        }
    }
    
    private func getImage(provider:NSItemProvider,
                          completion:@escaping ((UIImage?,Error?) -> Void)){
        
        provider.loadObject(ofClass: UIImage.self) { [self] (imgObject, imgErr) in
            if let imgObject = imgObject as? UIImage{
                completion(imgObject,nil)
            }else{
                let tempErrorMsg = imgErr?.localizedDescription ?? ""
                if tempErrorMsg.contains(jpegImageIdentifier)
                {
                    let tempId = tempErrorMsg.contains(jpegImageIdentifier) ? jpegImageIdentifier : ""
                    
                    getImgforErr(provider: provider,forTypeIdentifier: tempId) { (img, err) in
                        completion(img,err)
                    }
                }else{
                    print("Get Img Error :- ",tempErrorMsg)
                    completion(nil,imgErr)
                }
            }
        }
    }
    
    private func getImgforErr(provider:NSItemProvider,
                              forTypeIdentifier:String,
                              completion:@escaping ((UIImage?,Error?) -> Void)){
        
        provider.loadItem(forTypeIdentifier: forTypeIdentifier, options: [:]) { (imgURL, imgError) in
            if let imgURL = imgURL as? URL{
//                let imgData = try Data(contentsOf: imgURL)
//                let img = UIImage(data: imgData)
                let img = UIImage(contentsOfFile: imgURL.path)
                completion(img,nil)
            }else{
                print("Get Img URL Error :- ",imgError?.localizedDescription ?? "")
                completion(nil,imgError)
            }
        }
    }
}

extension MultipleImagePicker:PHPickerViewControllerDelegate{
    
    public func picker(_ picker: PHPickerViewController,
                       didFinishPicking results: [PHPickerResult]) {
        
        arrAllselectedMedia = results
        
        picker.dismiss(animated: true) {
            [self] in
            if arrAllselectedMedia.count > 0{
                loader()
                getAllSelectedMedia()
            }
        }
    }
    
    private func getAllSelectedMedia(){
        if arrAllselectedMedia.count == 0{
            loader(isStart: false)
            delegate?.selectedMedia(allMedia: arrResult)
        }else{
            
            if let selectedItem = arrAllselectedMedia.first?.itemProvider{
                
                if selectedItem.hasItemConformingToTypeIdentifier(videoIdentifier){
                    getVideo(provider: selectedItem) { [self] (reslutUrl,resultError) in
                        
                        if let reslutUrl = reslutUrl{
                            arrResult.append(resultData(url: reslutUrl, mediaType: .videoUrl))
                        }
                        removeValAndGetOtherVal()
                    }
                }
                else if selectedItem.canLoadObject(ofClass: PHLivePhoto.self){
                    getLiveImage(provider: selectedItem) { [self] (resLivePhoto,resultError) in
                        
                        if let resLivePhoto = resLivePhoto{
                            arrResult.append(resultData(livePhotot: resLivePhoto, mediaType: .livePhoto))
                        }
                        removeValAndGetOtherVal()
                    }
                }
                else if selectedItem.canLoadObject(ofClass: UIImage.self){
                    getImage(provider: selectedItem) { [self] (resImg,resultError) in
                        if let resImg = resImg{
                            arrResult.append(resultData(img: resImg, mediaType: .img))
                        }
                        removeValAndGetOtherVal()
                    }
                }
                else{
                    removeValAndGetOtherVal()
                }
            }
        }
    }
    
    private func getAsset(){
//        let identifiers = results.compactMap(\.assetIdentifier)
//        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
    }
    
    private func removeValAndGetOtherVal(){
        arrAllselectedMedia.remove(at: 0)
        getAllSelectedMedia()
    }
}
