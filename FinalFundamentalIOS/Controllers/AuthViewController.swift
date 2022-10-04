import UIKit

class AuthViewController: UIViewController {
  
  @IBOutlet var titleAuth: UILabel!
  @IBOutlet var nameField: UITextField!
  @IBOutlet var emailField: UITextField!
  @IBOutlet var linkedinField: UITextField!
  @IBOutlet var mainButton: UIButton!
  @IBOutlet var authView: UIView!
  @IBOutlet var backButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if AccountModel.stateLogin == true {
      titleAuth.text = "Edit"
      self.mainButton.setTitle("Save", for: .normal)
      self.backButton.alpha = 1
      self.backButton.isEnabled = true
    } else {
      titleAuth.text = "Sign Up"
      self.mainButton.setTitle("Create", for: .normal)
      self.backButton.alpha = 0
      self.backButton.isEnabled = false
    }
    UIMode()
    cardAnimate()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    nameField.text = "\(AccountModel.name)"
    emailField.text = "\(AccountModel.email)"
    linkedinField.text = "\(AccountModel.linkedin)"
  }
  
  @IBAction func saveButton(_ sender: Any) {
    if let name = nameField.text, let email = emailField.text, let linkedin = linkedinField.text {
      if name.isEmpty {
        textEmpty("Name")
      } else if email.isEmpty {
        textEmpty("Email")
      } else if linkedin.isEmpty {
        textEmpty("Linkedin")
      } else {
        if AccountModel.stateLogin {
          saveProfile(name, email, linkedin)
          self.performSegue(withIdentifier: "moveToHome", sender: self)
        } else {
          let alert = UIAlertController(title: "Warning", message: "Do you want to save this profile?", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Yes", style: .default) { [self] _ in
            saveProfile(name, email, linkedin)
            self.performSegue(withIdentifier: "moveToHome", sender: self)
          })
          
          alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
          self.present(alert, animated: true, completion: nil)
        }
      }
    }
  }
  
  func saveProfile(_ name: String, _ email: String, _ linkedin: String) {
    AccountModel.stateLogin = true
    AccountModel.name = name
    AccountModel.email = email
    AccountModel.linkedin = linkedin
  }
  
  func cardAnimate() {
    UIView.animate(withDuration: 1.0, delay: 0.75, options: .curveEaseInOut) {
      self.authView.alpha = 1
      self.authView.frame = self.authView.frame.offsetBy(dx: 0, dy: -400)
    }
  }
  
  func textEmpty(_ field: String) {
    let alert = UIAlertController(
      title: "Alert",
      message: "\(field) is empty",
      preferredStyle: UIAlertController.Style.alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func UIMode() {
    if AccountModel.stateUI {
      overrideUserInterfaceStyle = .dark
    } else {
      overrideUserInterfaceStyle = .light
    }
  }
  @IBAction func backButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
}
