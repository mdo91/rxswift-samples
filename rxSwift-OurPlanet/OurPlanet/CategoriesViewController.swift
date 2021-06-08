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
import RxCocoa

class CategoriesViewController: UIViewController {

  @IBOutlet var tableView: UITableView!
  
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    let categories = Variable<[EOCategory]>([])
  
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    

    activityIndicator.startAnimating()
    
    categories.asObservable()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext:{ [weak self] _ in

            self?.tableView.reloadData()

        },onCompleted: {
            print("completed..")

        })
        .disposed(by: disposeBag)
        

    startDownload()
  }

  func startDownload() {
    
    let eoCategories = EONET.categories
    
//    eoCategories
//        .bind(to: categories)
//        .disposed(by: disposeBag)
    
    // for optimiztion
   // let downloadedEvents = EONET.events(forLast: 360)
    
    let downloadedEvents = eoCategories.flatMap { categories in
        Observable.from(categories.map{
            category in
            EONET.events(forLast: 360, category: category)
           // return
        })
        .merge(maxConcurrent:2)
        
        
    }
    
    // for optimiztion
    
//    let updatedCategories = Observable.combineLatest(eoCategories, downloadedEvents){
//        categories, events  -> [EOCategory]in
//        categories.map { category in
//
//            var cat = category
//            cat.events = events.filter{ $0.categories.contains(category.id)
//            }
//
//            return cat
//        }
//    }
    let updatedCategories = eoCategories.flatMap { categories in
        
        downloadedEvents.scan(categories) { updated, events in
            
            updated.map{ category in
                let eventsForCaregory = EONET.filteredEvents(events: events, forCategory: category)
                
                if !eventsForCaregory.isEmpty{
                    
                    var cat = category
                    cat.events = cat.events + eventsForCaregory
                    return cat
                }
                
                return category
                
            }
            
        }
        .observeOn(MainScheduler.instance)
        .do(onCompleted:{ [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
        })
    }
    
    
    eoCategories
        .concat(updatedCategories)
        .bind(to: categories)
        .disposed(by: disposeBag)
    
  }
}

extension CategoriesViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell")!
    
    let category = categories.value[indexPath.row]
    cell.textLabel?.text = "\(category.name) (\(category.events.count))"
    cell.accessoryType = category.events.count > 0 ? .disclosureIndicator : .none
    return cell
  }
}

extension CategoriesViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if #available(iOS 13.0, *) {
        let eventController =  storyboard!.instantiateViewController(identifier: "events") as! EventsViewController
        
        let category = categories.value[indexPath.row]
        if !category.events.isEmpty{
            eventController.title = category.name
            eventController.events.value = category.events
            navigationController?.pushViewController(eventController, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }

    } else {
        // Fallback on earlier versions
    }
   
  }
}
