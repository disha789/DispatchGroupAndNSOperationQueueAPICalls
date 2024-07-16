//
//  ViewController.swift
//  DispatchGroupAPICalling
//
//  Created by Disha patel on 7/16/24.
//
import UIKit

class ViewController: UIViewController {
    
    let urls = [
        URL(string: Constants.userInfoServerURL.rawValue)!,
        URL(string: Constants.movieServerURL.rawValue)!,
        URL(string: Constants.newsServerURL.rawValue)!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchAPIsAndNavigateUsingDispatchGroup()
        fetchAPIsAndNavigateUsingNSOperation()
    }
    
    // MARK: API Fetching Function
    
    func fetchAPI(url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data from \(url): \(String(describing: error))")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
    
    // MARK: DispatchGroup
    
    func fetchAPIsAndNavigateUsingDispatchGroup() {
        let dispatchGroup = DispatchGroup()
        
        for url in urls {
            dispatchGroup.enter()
            fetchAPI(url: url) { data in
                if let data = data {
                    print("Data received from \(url)")
                } else {
                    print("No data received from \(url)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            print("<-----All DispatchGroup API calls completed, navigate to next screen----->")
            self.navigateToNextScreen()
        }
    }
    
    // MARK: NSOperationQueue
    
    func fetchAPIsAndNavigateUsingNSOperation() {
        let operationQueue = OperationQueue()
        var completionOperations: [Operation] = []
        
        for url in urls {
            let operation = BlockOperation {
                self.fetchAPI(url: url) { data in
                    if let data = data {
                        print("Data received from \(url)")
                    } else {
                        print("No data received from \(url)")
                    }
                }
            }
            completionOperations.append(operation)
            operationQueue.addOperation(operation)
        }
        
        let completionOperation = BlockOperation {
            DispatchQueue.main.async {
                print("<-----All NSOperationQueue API calls completed, navigate to next screen----->")
                self.navigateToNextScreen()
            }
        }
        
        for operation in completionOperations {
            completionOperation.addDependency(operation)
        }
        operationQueue.addOperation(completionOperation)
    }
    
    // MARK: - Navigation
    
    func navigateToNextScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "NextViewController") as! NextViewController
        
        self.navigationController?.pushViewController(newVC, animated: true)
    }
}
