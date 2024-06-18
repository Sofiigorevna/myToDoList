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
    
    // MARK: - Outlets
    
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
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(openGalleryTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var viewContainer: UIView = {
        var view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGroupedBackground
        return view
    }()
    
    private lazy var textFieldStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textFieldName,textFieldDate,textFieldDescription])
        stack.axis = .vertical
        stack.alignment = .center
        stack.setCustomSpacing(2, after: textFieldName)
        stack.setCustomSpacing(2, after: textFieldDate)
        stack.setCustomSpacing(2, after: textFieldDescription)
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var textFieldName: UITextField = {
        let textField = UITextField()
        textField.text = task?.name
        textField.placeholder = "Name task"
        textField.autocapitalizationType = .words
        textField.keyboardType = .default
        textField.textAlignment = .natural
        textField.tintColor = .white
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(systemName: "person")
        if let image = image{
            textField.setLeftIcon(image)
        }
        
        return textField
    }()
    
    private lazy var textFieldDate: UITextField = {
        let textField = UITextField()
        textField.text = task?.date
        textField.placeholder = "Date of completion"
        textField.textAlignment = .left
        textField.tintColor = .white
        textField.keyboardType = .default
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
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
        textField.tintColor = .white
        textField.keyboardType = .default
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
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
        view.backgroundColor = .systemIndigo
        setupNavigationBar()
        setupView()
        setupHierarhy()
        setupLayout()
        setupDatePickerDate()
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        lazy var buttonEdit = UIBarButtonItem(customView: editButton)
        navigationItem.rightBarButtonItem = buttonEdit
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
        view.backgroundColor = .systemIndigo
    }
    
    private func setupHierarhy() {
        view.addSubview(viewContainer)
        viewContainer.addSubview(icon)
        view.addSubview(buttonOpenGallery)
        view.addSubview(textFieldStack)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            viewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 130),
            viewContainer.widthAnchor.constraint(equalToConstant: 250),
            viewContainer.heightAnchor.constraint(equalToConstant: 250),
            
            icon.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor),
            
            icon.widthAnchor.constraint(equalToConstant: 250),
            icon.heightAnchor.constraint(equalToConstant: 250),
            
            buttonOpenGallery.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            buttonOpenGallery.bottomAnchor.constraint(equalTo: textFieldStack.topAnchor, constant: -10),
            
            
            textFieldStack.topAnchor.constraint(equalTo: viewContainer.bottomAnchor, constant: 60),
            textFieldStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 11),
            textFieldStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14),
            textFieldStack.heightAnchor.constraint(equalToConstant: 180),
            
            textFieldName.widthAnchor.constraint(equalToConstant: 355),
            textFieldDate.widthAnchor.constraint(equalToConstant: 355),
            textFieldDescription.widthAnchor.constraint(equalToConstant: 355),
            
            editButton.widthAnchor.constraint(equalToConstant: 70),
            editButton.heightAnchor.constraint(equalToConstant: 30),
        ])
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
        guard let updatedTitle = textFieldName.text,
              let updatedDescription = textFieldDescription.text,
              let updatedImage = image,
              let updatedDate = textFieldDate.text  else { return }
         
         task?.name = updatedTitle
         task?.descriptionTask = updatedDescription
         task?.date = updatedDate
         task?.image = updatedImage
         
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
            
            textFieldName.isUserInteractionEnabled = true
            textFieldName.borderStyle = .bezel
            
            textFieldDate.isUserInteractionEnabled = true
            textFieldDate.borderStyle = .bezel
            
            textFieldDescription.isUserInteractionEnabled = true
            textFieldDescription.borderStyle = .bezel
            
        } else {
            editButton.configuration?.title =  "Edit"
            editButton.configuration?.baseBackgroundColor = .clear
            
            buttonOpenGallery.isHidden = true
            
            textFieldName.isUserInteractionEnabled = false
            textFieldName.borderStyle = .none
            
            textFieldDate.isUserInteractionEnabled = false
            textFieldDate.borderStyle = .none
            
            textFieldDescription.isUserInteractionEnabled = false
            textFieldDescription.borderStyle = .none
            
            guard let personName = textFieldName.text,
                  !personName.isEmpty else {
                ShowAlert.shared.alert(view: self, title: "Sorry", message: "Please enter the name in textfield", completion: nil)
                return
            }
            saveButtonTapped()
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

