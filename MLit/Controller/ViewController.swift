//
//  ViewController.swift
//  MLit
//
//  Created by Aakash Jha on 17/03/21.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    let photoPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Camera module related setup
        imagePicker.delegate = self
        // sets the source as camera, so that camera module is presented when image input is to be given
        imagePicker.sourceType = .camera
        // the image selected can not be edited - cropped, etc
        imagePicker.allowsEditing = false

        // Photo album related setup
        photoPicker.delegate = self
        // sets the source as camera, so that camera module is presented when image input is to be given
        photoPicker.sourceType = .photoLibrary
        // the image selected can not be edited - cropped, etc
        photoPicker.allowsEditing = false
        
    }
    
    // way to let the view controller know that the user is done
    // picking up some imageand now it can be used for further work.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = imagePicked
            
            guard let cameraCIImage = CIImage(image: imagePicked) else {
                fatalError("Could not convert camera image to a CIImage")
            }
            detect(image: cameraCIImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
        if let photoPicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = photoPicked
            
            guard let libraryCIImage = CIImage(image: photoPicked) else {
                fatalError("Could not convert photo from library to a CIImage")
            }
            detect(image: libraryCIImage)
        }
        photoPicker.dismiss(animated: true, completion: nil)
    }
    
    // function to process the image converted into CIImage based on the loaded CoreML Model
    func detect(image: CIImage) {
        let config = MLModelConfiguration()
        guard let cameraModel = try? VNCoreMLModel(for: Inceptionv3(configuration: config).model) else {
            fatalError("Loading CoreML Model FAILED!!")
        }
        let req = VNCoreMLRequest(model: cameraModel) { (request, error) in
            if let results = request.results as? [VNClassificationObservation] {
//                print(results)
                if let firstResult = results.first {
                    if firstResult.identifier.contains("hotdog") {
                        self.navigationItem.title = "HotDog"
                    }
                    else {
                        self.navigationItem.title = "Not Hotdog"
                    }
                }
            }
            else {
                fatalError("Could not process VNCoreRequest...")
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([req])
        }
        catch {
            print(error)
        }
    }
    
    // opens camera module to take a picture
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // opens up photo library to select a picture
    @IBAction func addPhotoTapped(_ sender: UIBarButtonItem) {
        present(photoPicker, animated: true, completion: nil)
    }
}

