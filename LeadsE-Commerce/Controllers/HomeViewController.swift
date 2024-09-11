//
//  HomeViewController.swift
//  LeadsE-Commerce
//
//  Created by Abdullah Al-Mamun on 5/9/24.
//

//
//  HomeViewController.swift
//  Shopping-App-eCommerce
//
//  Created by Osman Emre Ömürlü on 27.01.2023.
//

import UIKit

class HomeViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    static var productList: [ProductModel] = []
    static var categoryList: [CategoryModel] = []
    override func viewDidLoad() {
           super.viewDidLoad()
           collectionSetup()
           tabBarSetup()
       }
       
       override func viewWillAppear(_ animated: Bool) {
           fetchCategories()
           fetchProducts()
       }
       
       override func viewWillDisappear(_ animated: Bool) {
           HomeViewController.categoryList = []
       }
       
       //MARK: - Functions
       func fetchProducts() {
           HomeViewController.productList  = []
           guard let url = URL(string: K.Network.baseURL) else {
               print("Invalid URL")
               return
           }
           
           URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   print("Error fetching products: \(error)")
                   return
               }
               
               guard let data = data else {
                   print("No data received")
                   return
               }
               
               do {
                   let productData = try JSONDecoder().decode([ProductData].self, from: data)
                   for data in productData {
                       HomeViewController.productList.append(ProductModel(id: data.id, title: data.title, price: Float(data.price), image: data.image, rate: Float(data.rating.rate), category: data.category, description: data.description, count: data.rating.count))
                   }
                   DispatchQueue.main.async {
                       self.productCollectionView.reloadData()
                   }
               } catch let error {
                   print("Error decoding product data: \(error)")
               }
           }.resume()
       }
       
       func fetchCategories() {
           guard let url = URL(string: K.Network.categoriesURL) else {
               print("Invalid URL")
               return
           }
           
           URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   print("Error fetching categories: \(error)")
                   return
               }
               
               guard let data = data else {
                   print("No data received")
                   return
               }
               
               do {
                   let categories = try JSONDecoder().decode([String].self, from: data)
                   for category in categories {
                       HomeViewController.categoryList.append(CategoryModel(category: category))
                   }
                   DispatchQueue.main.async {
                       self.categoryCollectionView.reloadData()
                   }
               } catch let error {
                   print("Error decoding categories: \(error)")
               }
           }.resume()
       }
       
       func tabBarSetup() {
           self.tabBarController?.navigationItem.hidesBackButton = true
           tabBarController!.tabBar.items?[1].badgeValue = "0"
       }
       
       //MARK: - CollectionCells Setup
       func collectionSetup() {
           categoryCollectionView.register(UINib(nibName: K.CollectionViews.topCollectionViewNibNameAndIdentifier, bundle: nil), forCellWithReuseIdentifier: K.CollectionViews.topCollectionViewNibNameAndIdentifier)
           categoryCollectionView.collectionViewLayout = TopCollectionViewColumnFlowLayout(sutunSayisi: 2, minSutunAraligi: 5, minSatirAraligi: 5)
           
           productCollectionView.register(UINib(nibName: K.CollectionViews.bottomCollectionViewNibNameAndIdentifier, bundle: nil), forCellWithReuseIdentifier: K.CollectionViews.bottomCollectionViewNibNameAndIdentifier)
           productCollectionView.collectionViewLayout = BottomCollectionViewColumnFlowLayout(sutunSayisi: 2, minSutunAraligi: 5, minSatirAraligi: 5)
       }
       
       //MARK: - Functions
       func changeVCcategoryToTableView(category: String) {
           switch category {
           case "electronics":
               CategorizedViewController.selectedCategory = "electronics"
           case "jewelery":
               CategorizedViewController.selectedCategory = "jewelery"
           case "men's clothing":
               CategorizedViewController.selectedCategory = "men's%20clothing"
           case "women's clothing":
               CategorizedViewController.selectedCategory = "women's%20clothing"
           default:
               DuplicateFuncs.alertMessage(title: "Category Error", message: "", vc: self)
           }
           
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let vc = storyboard.instantiateViewController(withIdentifier: K.Segues.categoryTableView)
           show(vc, sender: self)
       }
       
       func changeVCHomeToProductDetail(id: Int) {
           ProductDetailViewController.selectedProductID = id
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let vc = storyboard.instantiateViewController(withIdentifier: K.Segues.productDetailViewController)
           show(vc, sender: self)
       }
   }

   //MARK: - Extensions
   extension HomeViewController: UICollectionViewDataSource {
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           switch collectionView {
           case categoryCollectionView:
               return HomeViewController.categoryList.count
           case productCollectionView:
               return HomeViewController.productList.count
           default:
               return 0
           }
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           switch collectionView {
           case categoryCollectionView:
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CollectionViews.topCollectionViewNibNameAndIdentifier, for: indexPath) as! CategoriesCollectionViewCell
               let category = HomeViewController.categoryList[indexPath.row].category
               cell.categoryLabel.text = category?.capitalized
               
               switch category {
               case "electronics":
                   cell.categoryImageView.image = UIImage(named: "electronics.png")
               case "jewelery":
                   cell.categoryImageView.image = UIImage(named: "jewelery.png")
               case "men's clothing":
                   cell.categoryImageView.image = UIImage(named: "man.png")
               case "women's clothing":
                   cell.categoryImageView.image = UIImage(named: "woman.png")
               default:
                   cell.categoryImageView.image = UIImage(systemName: "questionmark.square.dashed")
               }
               return cell
               
           case productCollectionView:
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CollectionViews.bottomCollectionViewNibNameAndIdentifier, for: indexPath) as! ProductsCollectionViewCell
               let u = HomeViewController.productList[indexPath.row]
               cell.productNameLabel.text = u.title
               cell.productRateLabel.text = "★ \(u.rate!) "
               cell.productPriceLabe.text = "$\(u.price!)"
               
               if let imageUrl = u.image, let url = URL(string: imageUrl) {
                   loadImage(from: url) { image in
                       DispatchQueue.main.async {
                           cell.productImageView.image = image
                       }
                   }
               } else {
                   cell.productImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
               }
               
               return cell
               
           default:
               return UICollectionViewCell()
           }
       }
       
       // Function to load images asynchronously
       func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
           URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   print("Error loading image: \(error)")
                   completion(nil)
                   return
               }
               
               guard let data = data, let image = UIImage(data: data) else {
                   print("Failed to load image data")
                   completion(nil)
                   return
               }
               
               completion(image)
           }.resume()
       }
   }

   extension HomeViewController: UICollectionViewDelegate {
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           switch collectionView {
           case categoryCollectionView:
               if let category = HomeViewController.categoryList[indexPath.row].category {
                   changeVCcategoryToTableView(category: category)
               }
           case productCollectionView:
               if let idd = HomeViewController.productList[indexPath.row].id {
                   changeVCHomeToProductDetail(id: idd)
               }
           default:
               print("Error at didSelectItemAt")
           }
       }
   }

