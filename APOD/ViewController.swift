//
//  ViewController.swift
//  APOD
//
//  Created by Atmaja Kadam on 2022/03/19.
//  Copyright © 2022 my. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var searchTxtFld: UITextField!
    @IBOutlet weak var imageLoader: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var apodViewModel = ApodViewModel()
    var parameter : [String: String]?
    var dateForApod: String?
    var favList = [String]()
    
     var reachability : Reachability?
    
    var activityView: UIActivityIndicatorView?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageLoader.isHidden = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.contentSize = CGSize(width: view.frame.width, height: 1000)
        reachability = try? Reachability()
        if (reachability?.connection == .unavailable){
            retrieveCacheAndDisplayForOffline()
        }else{
            getHomeApod()
        }
        
    }

    // MARK: - Service calls
    func getHomeApod(){
        showActivityIndicator()
        if dateForApod != nil{
            parameter = [String : String]()
            parameter?["date"] = dateForApod
        }
        image.image = nil
        apodViewModel.hitRequestWithParameter(param:parameter, success: {[unowned weakSelf = self] (response) in
            DispatchQueue.main.async {

                weakSelf.hideActivityIndicator()
                weakSelf.titleLbl.text = response.title
                weakSelf.dateLbl.text = response.date
                weakSelf.descriptionLbl.text = response.explanation
                if let imageUrl = response.url{
                    weakSelf.downloadImage(from: URL.init(string:imageUrl)!)
                }
            }
        }) { [unowned weakSelf = self] (error) in
            DispatchQueue.main.async {
                weakSelf.hideActivityIndicator()
            }
        }
    }
    func downloadImage(from url: URL) {
        imageLoader.isHidden = false
        imageLoader.startAnimating()
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.imageLoader.isHidden = true
                self?.imageLoader.stopAnimating()
                self?.image.image = UIImage(data: data)
                self?.createCacheForOffline()
            }
        }
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    // MARK: - Search APOD for specific date
    @IBAction func searchApodWithDate(_ sender: Any) {
        if (reachability?.connection == .unavailable){
            let alert = UIAlertController(title: "Alert", message: "No internet connection", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
        if (validateDate(date: searchTxtFld.text ?? "")){
            dateForApod = searchTxtFld.text
            getHomeApod()
            dateForApod = nil
            searchTxtFld.text = nil
        }else{
            dateForApod = nil
            searchTxtFld.text = nil
            let alert = UIAlertController(title: "Alert", message: "Enter date in yyyy-MM-dd format", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        }
    }
    func validateDate(date: String) -> Bool{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.date(from: date)
        if result != nil {
            return true
        }else{
            return false
        }
    }
    @IBAction func addToFavorite(_ sender: Any) {

        let model = apodViewModel.getModelForCoredata()
        favList = UserDefaults.standard.array(forKey: "favList") as! [String]
        if favList.count > 0{
            for item in favList{
                if(model.title == item){
                    let alert = UIAlertController(title: "Alert", message: "APOD already added in favorites", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
            favList.append(model.title)
            UserDefaults.standard.setValue(favList, forKeyPath: "favList")
        }else{
            favList.append(model.title)
            UserDefaults.standard.setValue(favList, forKeyPath: "favList")
        }
        
    }
    // MARK: - Coredata
    
    func createCacheForOffline(){
        //************* code to add data in coredata *******************//
//        let model = apodViewModel.getModelForCoredata()
//        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        let managedContext = appdelegate.persistentContainer.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: "ApodModelCD", in: managedContext)
//        entity?.setValue(model.date, forKeyPath: "date")
//        entity?.setValue(model.title, forKeyPath: "title")
//        entity?.setValue(model.explanation, forKeyPath: "explaination")
//        do {
//            try managedContext.save()
//        }
//        catch{
//            print("Error while saving to coredata")
//        }
        let model = apodViewModel.getModelForCoredata()
        UserDefaults.standard.set(model.date, forKey: "date")
        UserDefaults.standard.set(model.title, forKey: "title")
        UserDefaults.standard.set(model.explanation, forKey: "explaination")
        UserDefaults.standard.set(image.image?.pngData(), forKey: "image")
    }
    func retrieveCacheAndDisplayForOffline(){
        //************* code to add data in coredata *******************//
//        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        let managedContext = appdelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ApodModelCD")
//
//        do {
//            let result = try managedContext.fetch(fetchRequest) //as? [ApodModelCD]
////            titleLbl.text = result?[0].title
////            dateLbl.text = result?[0].date
////            descriptionLbl.text = result?[0].explaination
//        }
//        catch{
//            print("Error while saving to coredata")
//        }
        
        titleLbl.text = UserDefaults.standard.string(forKey: "title")
        dateLbl.text = UserDefaults.standard.string(forKey: "date")
        descriptionLbl.text = UserDefaults.standard.string(forKey: "explaination")
        image.image = UIImage(data : UserDefaults.standard.data(forKey: "image") ?? Data())
    }
    //************* code to add data in coredata *******************//
    func retrieveCacheAndDeleteForOffline(){
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ApodModelCD")
        
        do {
            let result = try managedContext.fetch(fetchRequest) as? [ApodModelCD]
            if result?.count == 0{
                return
            }else{
                managedContext.delete((result?[0])!)
                do {
                try managedContext.save()
                } catch {
                
                }
            }
        }
        catch{
            print("Error while saving to coredata")
        }
    }
    // MARK: - Utils
    func showActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .gray)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    func hideActivityIndicator(){
        if (activityView != nil){
            activityView?.stopAnimating()
            activityView?.removeFromSuperview()
        }
    }
}


