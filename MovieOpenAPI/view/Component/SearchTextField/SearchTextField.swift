//
//  SearchTextField.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import UIKit

class SearchTextField: UIView {
    @IBOutlet private weak var textfield: UITextField!
    
    var onTextChanged: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        let nib = UINib(nibName: "SearchTextField", bundle: nil)
        guard let view = nib.instantiate(withOwner: self).first as? UIView else {return}
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        setupUI()
    }
    
    func setupUI() {
        textfield.layer.cornerRadius = 10
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.systemGray4.cgColor
        
        textfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange() {
        onTextChanged?(textfield.text ?? "")
    }
}
