/*
 * Copyright (c) 2016-2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift

class MainViewController: UIViewController {

  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    let bag = DisposeBag()
    let images = Variable<[UIImage]>([])

  override func viewDidLoad() {
    super.viewDidLoad()
    images.asObservable()
        .subscribe(onNext: { [weak self] photos in
            guard let preview = self?.imagePreview else { return}
            
            preview.image = UIImage.collage(images: photos, size:preview.frame.size )
            
        })
        .disposed(by: bag)
    
    images.asObservable()
        .subscribe(onNext: { [weak self] photos in
            
            self?.updateUI(photos: photos)
            
        })
        .disposed(by: bag)

  }
    
    func updateUI(photos: [UIImage]){
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count ) photos" : "Collage"
    }
  
  @IBAction func actionClear() {
    images.value = []

  }

  @IBAction func actionSave() {
    guard let image = self.imagePreview.image else { return}
    PhotoWriter.save(image)
        .subscribe { [weak self] id in
            self?.showMessage("saved id \(id)")
            self?.actionClear()
        } onError: { [weak self] error in
            self?.showMessage("error", description: error.localizedDescription)
        }
    
        .disposed(by: bag)


  }

  @IBAction func actionAdd() {
    //images.value.append(UIImage(named: "Barcelona.jpg")!)
    
    if #available(iOS 13.0, *) {
        let photosViewController = storyboard!.instantiateViewController(identifier: "PhotosViewController") as! PhotosViewController
        photosViewController.selectedPhotos.subscribe { [weak self] newImage in
            guard let images = self?.images else{ return}
            images.value.append(newImage)
            
        } onDisposed: {
            print("completed photo selection")
        }
        
        .disposed(by: bag)

        
        navigationController!.pushViewController(photosViewController, animated: true)
    } else {
        // Fallback on earlier versions
    }

  }

  func showMessage(_ title: String, description: String? = nil) {
    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
    present(alert, animated: true, completion: nil)
  }
}
