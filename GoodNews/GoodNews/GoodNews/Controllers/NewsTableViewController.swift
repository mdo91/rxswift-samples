//
//  ViewController.swift
//  GoodNews
//
//  Created by Mdo on 08/06/2021.
//

import UIKit
import RxCocoa
import RxSwift

class NewsTableViewController: UITableViewController{
    
    
    //MARK: - properties
    let bag = DisposeBag()

    
    var articles = [Article]()
    
    
    //MARK: - view controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        // Do any additional setup after loading the view.
        updateNews()
    }
    
    //MARK: - API Requests
    
    private func updateNews(){
       // let url = URL(string:"https://newsapi.org/v2/top-headlines?country=us&apiKey=3c6584159e9644cf99bb8ec702fef4d6")!
        
    // one way to retrive data
        
//        Observable.just(url)
//            .flatMap { url -> Observable<Data> in
//                let request = URLRequest(url: url)
//                return URLSession.shared.rx.data(request: request)
//            }
//            .map({ (data) -> [Article]? in
//                return try? JSONDecoder().decode(ArticleList.self, from: data).articles
//            })
//            .subscribe(onNext: { [weak self] value in
//                guard let self = self else {return}
//                if let articles = value{
//                    print(articles)
//                    DispatchQueue.main.async {
//                        self.articles = articles
//                        self.tableView.reloadData()
//                    }
//
//                } else{
//
//            }
//            }).disposed(by:bag)
        // second way
        
    
       // let resource  = Resource<ArticleList>(url: url)
        URLRequest.load(resource: ArticleList.all)
            .subscribe(onNext: {
                [weak self] articles in
                
                guard let self = self else{return}
                
                if let result = articles {
                    self.articles = result.articles
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else{
                    
                }
            }).disposed(by: bag)
        
    }


}
//MARK: - tableView delegates
extension NewsTableViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? NewsCell else{
            fatalError("could not init \(NewsCell.self)")
        }
        cell.titleLable.text = self.articles[indexPath.row].title
        cell.descriptionLable.text = self.articles[indexPath.row].description
        return cell
    }
    
    
}

