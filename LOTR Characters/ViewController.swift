//
//  ViewController.swift
//  LOTR Characters
//
//  Created by Hakan Baran on 8.09.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var selectedCharacter = ""
    var selectedCharacterID : UUID?
    var CharacterNameArray = [String]()
    var characterIDArray = [UUID]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self, action: #selector(addCharactersClicked))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    @objc func getData() {
        
        CharacterNameArray.removeAll(keepingCapacity: false)
        characterIDArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Characters")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let LOTRCharacters = try context.fetch(fetchRequest)
            
            if LOTRCharacters.count > 0 {
                for character in LOTRCharacters as! [NSManagedObject] {
                    
                    if let name = character.value(forKey: "name") as? String {
                        self.CharacterNameArray.append(name)
                    }
                    if let id = character.value(forKey: "id") as? UUID {
                        self.characterIDArray.append(id)
                    }
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("Error 2")
        }
    }
    
    @objc func addCharactersClicked() {
        
        selectedCharacter = ""
        performSegue(withIdentifier: "toCharacters", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CharacterNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var context = cell.defaultContentConfiguration()
        context.text = CharacterNameArray[indexPath.row]
        cell.contentConfiguration = context
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCharacters" {
            
            let destinationVC = segue.destination as? CharacterTraits
            destinationVC?.chosenCharacter = selectedCharacter
            destinationVC?.chosenCharacterID = selectedCharacterID
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCharacter = CharacterNameArray[indexPath.row]
        selectedCharacterID = characterIDArray[indexPath.row]
        
        performSegue(withIdentifier: "toCharacters", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Characters")
            
            let idString = characterIDArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let LOTRCharacters = try context.fetch(fetchRequest)
                if LOTRCharacters.count > 0 {
                    for character in LOTRCharacters as! [NSManagedObject]{
                        if let id = character.value(forKey: "id") as? UUID {
                            
                            if id == characterIDArray[indexPath.row] {
                                context.delete(character)
                                CharacterNameArray.remove(at: indexPath.row)
                                characterIDArray.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                            }
                            do {
                                try context.save()
                            } catch {
                                print("Error 4")
                            }
                            break
                        }
                    }
                }
            } catch {
                print("Error 5")
            }
        }
    }
}

