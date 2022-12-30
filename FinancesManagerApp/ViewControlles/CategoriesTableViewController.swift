//
//  CategoriesTableViewController.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 24.12.2022.
//

import RealmSwift

protocol CategoriesVCDelegate {
    func getCategory(category: Category)
}

class CategoriesTableViewController: UITableViewController {

    private var categories: Results<Category>!
    var delegate: CategoriesVCDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        categories = StorageManager.shared.realm.objects(Category.self)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let category = categories[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = category.name
        cell.contentConfiguration = content

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        delegate?.getCategory(category: category)
        navigationController?.popViewController(animated: true)
    }
    

    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert(title: "Add new Category")
    }
}


extension CategoriesTableViewController {
    private func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = UIUserInterfaceStyle.dark
        alert.addCategory { name in
            self.makeCategory(name: name)
        }
        
        present(alert, animated: true)
    }
    
    private func makeCategory(name: String) {
        let newCategory = Category()
        newCategory.name = name
        
        DispatchQueue.main.async {
            StorageManager.shared.saveNewCategory(category: newCategory)
            let rowIndex = IndexPath(row: self.categories.count - 1, section: 0)
            self.tableView.insertRows(at: [rowIndex], with: .automatic)
        }
        
    }
}
