//
//  CreateAccountViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/23.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var selectUserTypeSegmentedControl: UISegmentedControl!
    
    var isAdmin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tappedSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            isAdmin = false
        case 1:
            isAdmin = true
        default:
            break
        }
    }
    
    @IBAction func tapRegisterButton(_ sender: Any) {
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            // ①FirebaseAuthにemailとpasswordでアカウントを作成する
            Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
                if let user = result?.user {
                    print("ユーザー作成完了 uid:" + user.uid)
                    // ②FirestoreのUsersコレクションにdocumentID = ログインしたuidでデータを作成する
                    Firestore.firestore().collection("users").document(user.uid).setData([
                        "isAdmin": self.isAdmin
                    ], completion: { error in
                        if let error = error {
                            // ②が失敗した場合
                            print("Firestore 新規登録失敗 " + error.localizedDescription)
                            let dialog = UIAlertController(title: "新規登録失敗", message: error.localizedDescription, preferredStyle: .alert)
                            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(dialog, animated: true, completion: nil)
                        } else {
                            if self.isAdmin {
                                
                            } else {
                                let storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                                let setSchoolCodeViewController = storyboard.instantiateViewController(withIdentifier: "SetSchoolCodeViewController") as! SetSchoolCodeViewController
                                setSchoolCodeViewController.modalPresentationStyle = .fullScreen
                                self.present(setSchoolCodeViewController, animated: true, completion: nil)
                            }
                        }
                    })
                } else if let error = error {
                    // ①が失敗した場合
                    print("Firebase Auth 新規登録失敗 " + error.localizedDescription)
                    let dialog = UIAlertController(title: "新規登録失敗", message: error.localizedDescription, preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(dialog, animated: true, completion: nil)
                }
            })
        }
    }
}