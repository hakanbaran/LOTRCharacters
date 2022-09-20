//
//  CharacterTraits.swift
//  LOTR Characters
//
//  Created by Hakan Baran on 8.09.2022.
//

import UIKit
import CoreData

class CharacterTraits: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var saveButton: UIButton!
    var chosenCharacter = ""
    var chosenCharacterID : UUID?
    @IBOutlet weak var charactersImage: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var raceText: UITextField!
    @IBOutlet weak var CountryText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenCharacter != "" {
            
            saveButton.isHidden = true
            //CoreData
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Characters")
            
            let idString = chosenCharacterID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let LOTRCharacters = try context.fetch(fetchRequest)
                
                if LOTRCharacters.count > 0 {
                    for character in LOTRCharacters as! [NSManagedObject] {
                        
                        if let name = character.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let race = character.value(forKey: "race") as? String {
                            raceText.text = race
                        }
                        if let country = character.value(forKey: "country") as? String {
                            CountryText.text = country
                        }
                        if let age = character.value(forKey: "age") as? Int{
                            ageText.text = String(age)
                        }
                        if let imageData = character.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            charactersImage.image = image
                        }
                    }
                }
            } catch {
                print("Error 4")
            }
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        charactersImage.isUserInteractionEnabled = true
        
        let characterImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectCharacterImage))
        charactersImage.addGestureRecognizer(characterImageRecognizer)
    }

    @objc func selectCharacterImage() {
        
        let characterpicker = UIImagePickerController()
        characterpicker.delegate = self
        characterpicker.sourceType = .photoLibrary
        //characterpicker.allowsEditing = true
        present(characterpicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        charactersImage.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    @IBAction func saveClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newCharacter = NSEntityDescription.insertNewObject(forEntityName: "Characters", into: context)
        newCharacter.setValue(nameText.text!, forKey: "name")
        newCharacter.setValue(raceText.text!, forKey: "race")
        newCharacter.setValue(CountryText.text, forKey: "country")
        
        if let age = Int(ageText.text!){
            newCharacter.setValue(age, forKey: "age")
        }
        newCharacter.setValue(UUID(), forKey: "id")
        let data = charactersImage.image!.jpegData(compressionQuality: 0.5)
        newCharacter.setValue(data, forKey: "image")
        
        do{
            try context.save()
        } catch {
            print("Error 1")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
