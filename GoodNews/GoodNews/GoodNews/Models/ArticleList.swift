//
//  ArticleList.swift
//  GoodNews
//
//  Created by Mdo on 08/06/2021.
//

import Foundation


struct ArticleList:Decodable {
    let articles:[Article]
    let totalResults: Int
}
extension ArticleList{
    static var all:Resource<ArticleList> = {
        let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=3c6584159e9644cf99bb8ec702fef4d6")!
        return Resource(url: url)
    }()
}
