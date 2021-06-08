//
//  PHPhotoLibrary+rx.swift
//  Combinestagram
//
//  Created by Mdo on 08/01/2021.
//  Copyright © 2021 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RxSwift

extension PHPhotoLibrary{
    
    static var authorized:Observable<Bool>{
        
        return Observable.create {  observer in
            
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized{
                    observer.onNext(true)
                    observer.onCompleted()
                }else{
                    observer.onNext(false)
                    requestAuthorization { newStatue in
                        
                       
                        observer.onNext(newStatue == .authorized)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
            
        
    }
}
