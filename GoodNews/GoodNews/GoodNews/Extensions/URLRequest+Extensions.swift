//
//  URLRequest+Extensions.swift
//  GoodNews
//
//  Created by Mdo on 09/06/2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

struct Resource<T:Decodable> {
    let url:URL
}

extension URLRequest{
    
    static func load<T>(resource:Resource<T>)->Observable<T?>{
        
        return Observable.from([resource.url])
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.data(request: request)
            }
            .map { data -> T? in
                return try? JSONDecoder().decode(T.self, from: data)
            }
            .asObservable()
    }
}
