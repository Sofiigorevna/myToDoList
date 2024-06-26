//
//  DetailViewController.swift
//  myToDoList
//
//  Created by 1234 on 18.06.2024.
//

import UIKit

protocol TaskUpdateDelegate: AnyObject {
    func didUpdateTask(_ task: Task)
}

class DetailViewController: UIViewController {
    
    private var isEdit = Bool()
    private var image: Data? = nil
    
    private let datePicker = UIDatePicker()
    private var pickerView = UIPickerView()
    
    var task: Task?
    weak var delegate: TaskUpdateDelegate?
    let dynamicColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
    }
    
    // MARK: - Outlets
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentViewForStack: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private let textFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.layer.masksToBounds = true
        stackView.backgroundColor = .systemGray6
        return stackView
    }()
    
    lazy var nameTaskTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = task?.name
        textField.placeholder = "Name task"
        textField.autocapitalizationType = .words
        textField.returnKeyType = .done
        textField.autocapitalizationType = .words
        textField.textColor = dynamicColor
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.tintColor = UIColor.systemGray
        textField.autocapitalizationType = .none
        textField.isUserInteractionEnabled = false
        let image = UIImage(systemName: "person")
        
        if let image = image{
            textField.setLeftIcon(image)
        }
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
        return textField
    }()
    
    private lazy var icon: UIImageView = {
        var imageView = UIImageView()
        if let imageData = task?.image {
            imageView = UIImageView(image: UIImage(data: imageData))
        } else {
            imageView = UIImageView(image: UIImage(systemName: "person.fill"))
            
        }
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var buttonOpenGallery: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Open Gallery", for: .normal)
        button.backgroundColor = dynamicColor
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(openGalleryTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var textFieldDate: UITextField = {
        let textField = UITextField()
        textField.text = task?.date
        textField.placeholder = "Date of completion"
        textField.textAlignment = .left
        textField.keyboardType = .default
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .done
        textField.textColor = dynamicColor
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.tintColor = UIColor.systemGray
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
        
        let image = UIImage(systemName: "calendar")
        if let image = image{
            textField.setLeftIcon(image)
        }
        
        return textField
    }()
    
    private lazy var textFieldDescription: UITextField = {
        let textField = UITextField()
        textField.text = task?.descriptionTask
        textField.placeholder = "Task description"
        textField.textAlignment = .natural
        textField.keyboardType = .default
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.returnKeyType = .done
        textField.textColor = dynamicColor
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.tintColor = UIColor.systemGray
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
        
        let image = UIImage(systemName: "person.2.circle")
        if let image = image{
            textField.setLeftIcon(image)
        }
        
        return textField
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1.5
        button.layer.masksToBounds = true
        button.tintColor = .white
        var config = UIButton.Configuration.borderedTinted()
        config.baseBackgroundColor = .clear
        config.title = "Edit"
        config.titleAlignment = .center
        button.configuration = config
        button.addTarget(self, action: #selector(editButtonPressed),
                         for: .allEvents)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //  setupNavigationBar()
        setupView()
        setupHierarhy()
        setupLayout()
        setupDatePickerDate()
        prepareNavBar()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.scrollIndicatorInsets = view.safeAreaInsets
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        lazy var buttonEdit = UIBarButtonItem(customView: editButton)
        navigationItem.rightBarButtonItem = buttonEdit
        
        if let navigationController = navigationController {
            navigationController.navigationBar.tintColor = .white
        }
    }
    
    private func setupDatePickerDate() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        textFieldDate.inputView = datePicker
        textFieldDate.inputAccessoryView = toolBar
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexSpace,doneButton], animated: true)
        
        let dateOfBirthMinimum = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        let dateOfBirthMax = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        datePicker.minimumDate = dateOfBirthMinimum
        datePicker.maximumDate = dateOfBirthMax
    }
    
    private func setupView() {
        view.backgroundColor = .black
    }
    
    private func setupHierarhy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addSubview(icon)
        scrollView.addSubview(contentViewForStack)
        contentViewForStack.addSubview(textFieldStackView)
        
        textFieldStackView.addArrangedSubview(buttonOpenGallery)
        textFieldStackView.addArrangedSubview(nameTaskTextField)
        textFieldStackView.addArrangedSubview(textFieldDate)
        textFieldStackView.addArrangedSubview(textFieldDescription)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            
            icon.topAnchor.constraint(equalTo: view.topAnchor),
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            icon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            icon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            contentViewForStack.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentViewForStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentViewForStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentViewForStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            textFieldStackView.topAnchor.constraint(equalTo: contentViewForStack.topAnchor, constant: 14),
            textFieldStackView.leadingAnchor.constraint(equalTo: contentViewForStack.leadingAnchor, constant: 14),
            textFieldStackView.trailingAnchor.constraint(equalTo: contentViewForStack.trailingAnchor, constant: -14),
            textFieldStackView.bottomAnchor.constraint(equalTo: contentViewForStack.bottomAnchor, constant: -14),
            
            buttonOpenGallery.heightAnchor.constraint(equalToConstant: 50),
            nameTaskTextField.heightAnchor.constraint(equalToConstant: 50),
            textFieldDate.heightAnchor.constraint(equalToConstant: 50),
            textFieldDescription.heightAnchor.constraint(equalToConstant: 50),
            
            editButton.widthAnchor.constraint(equalToConstant: 70),
            editButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    private func prepareNavBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.tintColor = .systemBackground
        
        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        navigationItem.compactAppearance = navigationBarAppearance
    }
    
    //MARK: — Status Bar Appearance
    
    private var shouldHideStatusBar: Bool {
        let frame = contentViewForStack.convert(contentViewForStack.bounds, to: nil)
        return frame.minY < view.safeAreaInsets.top
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    // MARK: - Actions
    
    @objc
    private func openGalleryTapped() {
        let imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        imagepicker.allowsEditing = true
        imagepicker.sourceType = .savedPhotosAlbum
        present(imagepicker, animated: true)
    }
    
    @objc private func doneAction() {
        getDateFromPicker()
        view.endEditing(true)
    }
    
    func getDateFromPicker() {
        let formater = DateFormatter()
        formater.dateFormat = "dd.MM.yyyy"
        textFieldDate.text = formater.string(from: datePicker.date)
    }
    
    @objc func saveButtonTapped() {
        
        if let updatedTitle = nameTaskTextField.text, !updatedTitle.isEmpty {
            task?.name = updatedTitle
        }
        
        if let updatedDescription = textFieldDescription.text, !updatedDescription.isEmpty {
            task?.descriptionTask = updatedDescription
        }
        
        if let updatedImage = image, !updatedImage.isEmpty {
            task?.image = updatedImage
        }
        
        if let updatedDate = textFieldDate.text, !updatedDate.isEmpty {
            task?.date = updatedDate
        }
        
        if let updatedTask = task {
            delegate?.didUpdateTask(updatedTask)
        }
    }
    
    @objc private func editButtonPressed() {
        
        isEdit.toggle()
        if isEdit {
            editButton.configuration?.title = "Save"
            editButton.configuration?.baseBackgroundColor = .magenta
            
            buttonOpenGallery.isHidden = false
            
            nameTaskTextField.isUserInteractionEnabled = true
            nameTaskTextField.borderStyle = .bezel
            
            textFieldDate.isUserInteractionEnabled = true
            textFieldDate.borderStyle = .bezel
            
            textFieldDescription.isUserInteractionEnabled = true
            textFieldDescription.borderStyle = .bezel
            
        } else {
            editButton.configuration?.title =  "Edit"
            editButton.configuration?.baseBackgroundColor = .clear
            
            buttonOpenGallery.isHidden = true
            
            nameTaskTextField.isUserInteractionEnabled = false
            nameTaskTextField.borderStyle = .none
            
            textFieldDate.isUserInteractionEnabled = false
            textFieldDate.borderStyle = .none
            
            textFieldDescription.isUserInteractionEnabled = false
            textFieldDescription.borderStyle = .none
            
            guard let personName = nameTaskTextField.text,
                  !personName.isEmpty else {
                ShowAlert.shared.alert(view: self, title: "Sorry", message: "Please enter the name in textfield", completion: nil)
                return
            }
            saveButtonTapped()
        }
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var previousStatusBarHidden = false
        
        if  previousStatusBarHidden != shouldHideStatusBar {
            
            UIView.animate(withDuration: 0.2, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            })
            previousStatusBarHidden = shouldHideStatusBar
        }
    }
}



extension DetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editButtonPressed()
        return true
    }
}

extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            
            icon.contentMode = .scaleAspectFit
            icon.image = image
            
            DispatchQueue.main.async {
                self.image = image.pngData()
            }
            
        } else if let image = info[.originalImage] as? UIImage {
            icon.image = image
            
            DispatchQueue.main.async {
                self.image = image.pngData()
            }
        }
        dismiss(animated: true)
    }
}

