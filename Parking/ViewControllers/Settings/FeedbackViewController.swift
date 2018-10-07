//
//  FeedbackViewController.swift
//  Parking
//
//  Created by Koh Jia Rong on 28/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FeedbackViewController: UIViewController {
    
    lazy var feedbackView: FeedbackContainerView = {
        let v = FeedbackContainerView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.textView.delegate = self
        v.textView.textColor = .lightGray
        return v
    }()
    
    var ref: DatabaseReference!
    var bottomConstraint: NSLayoutConstraint!
    var submitButton: UIBarButtonItem!
    
    let placeholderText = "Thanks for trying out this app, do let us know if there are any ways to improve this app further!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        ref = Database.database().reference()
        subscribeToKeyboardNotifications()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(feedbackView)
        
        navigationItem.title = "Feedback"
        setupLeftCloseButton(title: "Cancel")
        
        submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitButtonDidTap))
        navigationItem.rightBarButtonItem = submitButton
        submitButton.isEnabled = false
        
        navigationController?.navigationBar.tintColor = .customGreen
        
        feedbackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        feedbackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        feedbackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        bottomConstraint = feedbackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomConstraint.isActive = true
        
        feedbackView.textView.text = placeholderText
    }

    @objc func submitButtonDidTap() {
        guard let text = feedbackView.textView.text else {return}

        var userUID = ""
        if let user = Auth.auth().currentUser {
            userUID = user.uid
        }
        
        let feedbackValue = ["userUID": userUID,
                             "feedback": text,
                             "timestamp": prettyTimestamp()] as [String : Any]
        
        ref.child("feedback").childByAutoId().updateChildValues(feedbackValue) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        bottomConstraint.constant -= keyboardHeight
        
        let keyboardAnimationDuration = userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: keyboardAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 0
        
        let userInfo = notification.userInfo
        let keyboardAnimationDuration = userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: keyboardAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    
}

extension FeedbackViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        submitButton.isEnabled = toggleButtonStates(for: textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        let numberOfCharsLeft = Constants.UserDefaults.MaxCharLength - numberOfChars
        
        if numberOfCharsLeft == -1 {
            feedbackView.charactersLeftLabel.text = "0 characters left"
        } else {
            feedbackView.charactersLeftLabel.text = String(numberOfCharsLeft) + " characters left"
        }
        
        return numberOfChars < Constants.UserDefaults.MaxCharLength + 1
    }
    
}


