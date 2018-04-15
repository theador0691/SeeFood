//
//  ViewController.swift
//  SeeFood
//
//  Created by Andrew Taylor on 15/04/2018.
//  Copyright © 2018 Andrew Taylor. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        // edit the image that the user has taken i.e. crop the photo.
        //set to false but can extend this to true
        imagePicker.allowsEditing = false
    }
    
    //delegeate method didFinishPickingMediaWithInfo
    //tells the delegate that the user has picked a movie or picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //check that an image was picked and not nil and then set the background image to be the image taken
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            guard  let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert the image sorry :(")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        //loading up the model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("There was an error yo! Something to do with loading the coreML")
        }
        //asking the model to clasify to photo taken
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("There was an error yo! To do with getting the request of the model")
            }
            
            //check the results first item (highest confidence)
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hot Dog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                } else {
                    self.navigationItem.title = "Not Hot Dog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red

                }
            }
        }
        //setting the handler
        let handler = VNImageRequestHandler(ciImage: image)
        
        //do the request!
        do {
            try handler.perform([request])
        }catch {
            print("Error getting the request yo!")
        }
        
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        //presenting the image picker
        present(imagePicker,animated: true,completion: nil)
    
    }
    
    
    
}

