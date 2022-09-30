import UIKit

class ProfileViewController: UIViewController {
  private let imagePicker = UIImagePickerController()
  var memberId: Int = 0
  private lazy var ImageProvider: ImageProvider = { return FinalFundamentalIOS.ImageProvider() }()
  @IBOutlet var editProfile: UIImageView!
  @IBOutlet var titleProfile: UILabel!
  @IBOutlet var emailProfile: UILabel!
  @IBOutlet var nameProfile: UILabel!
  @IBOutlet var linkedinProfile: UILabel!
  @IBOutlet var imageProfile: UIImageView!
  @IBOutlet var saveButton: UIButton!
  @IBOutlet var saveView: UIView!
  @IBOutlet var switchMode: UISwitch!
  @IBOutlet var sunImage: UIImageView!
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    UIMode()
    loadImage()
  }
  override func viewWillAppear(_ animated: Bool) {
    AccountModel.synchronize()
    UIMode()
    setupData()
  }
  @IBAction func editProfile(_ sender: Any) {
    let alert = UIAlertController(title: "Warning", message: "Do you want to change this profile?", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
      self.performSegue(withIdentifier: "editProfile", sender: self)
    })
    
    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func editImage(_ sender: Any) {
    self.present(imagePicker, animated: true, completion: nil)
    
  }
  @IBAction func saveImage(_ sender: Any) {
    if let image = imageProfile.image, let data = image.pngData() as NSData? {
      ImageProvider.createImage(data as Data) {
        DispatchQueue.main.async {
          let alert = UIAlertController(title: "Successful", message: "Image created", preferredStyle: .alert)
          
          alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
          })
          self.present(alert, animated: true, completion: nil)
          
        }
        self.saveView.alpha = 0
        self.saveButton.isEnabled = false
      }
    }
  }
  
  @IBAction func modeSwitch(_ sender: Any) {
    if switchMode.isOn == true {
      self.sunImage.tintColor = UIColor(named: "TabBarDarkTint")
      overrideUserInterfaceStyle = .dark
      self.titleProfile.textColor = UIColor(named: "TabBarDarkTint")
      self.editProfile.tintColor = UIColor(named: "TabBarDarkTint")
      AccountModel.stateUI = true
    } else {
      AccountModel.stateUI = false
      self.sunImage.tintColor = UIColor(named: "AccentColor")
      self.titleProfile.textColor = UIColor(named: "AccentColor")
      self.editProfile.tintColor = UIColor(named: "AccentColor")
      overrideUserInterfaceStyle = .light
    }
  }
  // swiftlint:disable empty_parentheses_with_trailing_closure
  private func loadImage() {
    ImageProvider.getImage() { account in
      DispatchQueue.main.async {
        if let image = account.image {
          self.imageProfile.image = UIImage(data: image)
          
        }
      }
    }
  }
  
  private func setupView() {
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.sourceType = .photoLibrary
    imageProfile.clipsToBounds = true
  }
  
  private func setupData() {
    nameProfile.text = "\(AccountModel.name)"
    emailProfile.text = "\(AccountModel.email)"
    linkedinProfile.text = "\(AccountModel.linkedin)"
  }
  func UIMode( ) {
    if AccountModel.stateUI {
      overrideUserInterfaceStyle = .dark
      self.titleProfile.textColor = UIColor(named: "TabBarDarkTint")
      self.editProfile.tintColor = UIColor(named: "TabBarDarkTint")
    } else {
      overrideUserInterfaceStyle = .light
      self.titleProfile.textColor = UIColor(named: "AccentColor")
      self.editProfile.tintColor = UIColor(named: "AccentColor")
    }
  }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  // Kedua function ada berkat extension kelas UIImagePickerController dan UINavigationControllerDelegate. Function imagePickerController akan bekerja ketika pengguna memutuskan untuk memilih gambar tertentu dalam galeri. Gambar yang sudah didapat akan diparsing ke UIImage dan ditampilkan ke imageProfile.
  // Lalu untuk function imagePickerControllerDidCancel akan bekerja ketika pengguna membatalkan pemilihan gambar dalam galeri.
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    if let result = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      self.imageProfile.contentMode = .scaleToFill
      self.imageProfile.image = result
      saveView.alpha = 1
      saveButton.isEnabled = true
      dismiss(animated: true, completion: nil)
    } else {
      let alert = UIAlertController(title: "Failed", message: "Image can't be loaded.", preferredStyle: .actionSheet)
      alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
}
