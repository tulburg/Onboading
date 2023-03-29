//
//  File.swift
//  
//
//  Created by Tolu Oluwagbemi on 20/03/2023.
//

import UIKit

@available(iOS 15, *)
public class OnboardingCell: UICollectionViewCell, UITextFieldDelegate, VerificationCodeProtocol, CountryPickerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    public var textInput: UITextField!
    public var textView: UITextView!
    var datePicker: UIDatePicker!
    var rangePicker: UIPickerView!
    var question: String!
    var config: OBFormConfig!
    public var delegate: OBDelegate!
    var phoneInput: UITextField!
    var tableView: UITableView!
    var selectedCountry: Country!
    
    public var questionLabel: UILabel!
    var inputContainer: UIView!
    var verificationCode: VerificationCode!
    var dateContainer: UIView!
    var dateLabel: UILabel!
    var selectedDate: Date?
    var phoneContainer: UIView!
    var countryCode: UILabel!
    var selectContainer: UIView!
    var textViewContainer: UIView!
    var rangeContainer: UIView!
    public var rangeLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        questionLabel = buildQuestion()
        inputContainer = buildTextInput()
        verificationCode = buildVerificationCode()
        dateContainer = buildDatePicker()
        phoneContainer = buildPhone()
        selectContainer = buildSelect()
        textViewContainer = buildTextView()
        rangeContainer = buildRange()
        
        contentView.backgroundColor = .background
    }
    
    public func build(_ config: OBFormConfig) {
        self.config = config
        questionLabel.text = config.title
        textInput.placeholder = config.placeholder
        
        if config.type == .Name {
            textInput.keyboardType = .default
            textInput.textContentType = .name
        }else if config.type == .Username {
            textInput.textContentType = .username
            textInput.autocapitalizationType = .none
        }else if config.type == .Email {
            textInput.autocapitalizationType = .none
            textInput.textContentType = .emailAddress
            textInput.keyboardType = .emailAddress
        }else if config.type == .Phone {
            phoneInput.textContentType = .telephoneNumber
            phoneInput.keyboardType = .phonePad
        }
        if (config.type == .Name || config.type == .Email || config.type == .Username) {
            questionLabel.isHidden = false
            inputContainer.isHidden = false
            
            contentView.add().vertical(24).view(questionLabel).gap(40)
                .view(inputContainer, ">=40").end(">=24")
            contentView.constrain(type: .horizontalFill, questionLabel, inputContainer, margin: 24)
        }
        if (config.type == .VerificationCode) {
            questionLabel.isHidden = false
            verificationCode.isHidden = false
            contentView.add().vertical(24).view(questionLabel).gap(40)
                .view(verificationCode, 64).end(">=24")
            contentView.constrain(type: .horizontalFill, questionLabel, margin: 24)
            contentView.add().horizontal(24).view(verificationCode).end(">=0")
        }
        
        if (config.type == .Date) {
            dateContainer.isHidden = false
            questionLabel.isHidden = false
            if config.datePickerConfig != nil {
                datePicker.date = selectedDate ?? config.datePickerConfig!.date
                datePicker.minimumDate = config.datePickerConfig?.minDate
                datePicker.maximumDate = config.datePickerConfig?.maxDate
            }
            selectedDate = datePicker.date
            
            contentView.add().vertical(24).view(questionLabel).gap(0)
                .view(dateContainer).end(">=24")
            contentView.constrain(type: .horizontalFill, questionLabel, dateContainer, margin: 24)
        }
        
        if config.type == .Phone {
            questionLabel.isHidden = false
            phoneContainer.isHidden = false
            selectedCountry = Country(isoCode: "US")
            contentView.add().vertical(24).view(questionLabel).gap(40)
                .view(phoneContainer).end(">=24")
            contentView.constrain(type: .horizontalFill, questionLabel, phoneContainer, margin: 24)
        }
        
        if config.type == .Select {
            questionLabel.isHidden = false
            selectContainer.isHidden = false
            
            tableView.allowsMultipleSelection = (config.selectConfig?.multipleChoice)!
            contentView.add().vertical(24).view(questionLabel).gap(40)
                .view(selectContainer).end(safeAreaInsets.bottom + 126)
            contentView.constrain(type: .horizontalFill, questionLabel, selectContainer, margin: 24)
        }
        
        if config.type == .LargeText {
            questionLabel.isHidden = false
            textViewContainer.isHidden = false
            textView.placeholder = config.placeholder
            contentView.add().vertical(24).view(questionLabel).gap(24)
                .view(textViewContainer, ">=96").end(">=24")
            contentView.constrain(type: .horizontalFill, questionLabel, textViewContainer, margin: 24)
        }
        
        if config.type == .Range {
            rangeContainer.isHidden = false
            questionLabel.isHidden = false
            rangePicker.selectRow(config.range!.count / 2, inComponent: 0, animated: false)
            
            contentView.add().vertical(24).view(questionLabel).gap(0)
                .view(rangeContainer).end(">=24")
            contentView.constrain(type: .horizontalFill, questionLabel, rangeContainer, margin: 24)
        }
        
        let line = UIView()
        line.backgroundColor = .separatorLight
        contentView.add().vertical(0).view(line, 1).end(">=0")
        contentView.constrain(type: .horizontalFill, line)
    }
    
    public override func prepareForReuse() {
        contentView.removeConstraints(contentView.constraints)
        [questionLabel, inputContainer, verificationCode, dateContainer, phoneContainer, selectContainer, textViewContainer, rangeContainer].forEach{ $0?.isHidden = true }
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func buildQuestion() -> UILabel {
        let label = UILabel("", .titleText, .systemFont(ofSize: 28, weight: .semibold))
        label.numberOfLines = 3
        return label
    }
    
    public func buildTextInput() -> UIView {
        let container = UIView()
        let line = UIView()
        line.backgroundColor = .gray
        textInput = UITextField()
        textInput.backgroundColor = UIColor.clear
        textInput.textColor = .accent
        textInput.delegate = self
        textInput.font = .systemFont(ofSize: 28, weight: .semibold)
        container.add().vertical(0).view(textInput, 40).gap(0).view(line, 2).end(0)
        container.constrain(type: .horizontalFill, textInput, line)
        return container
    }
    
    public func buildTextView() -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 12
        container.backgroundColor = .separatorLight
        textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.textColor = .darkText
        textView.delegate = self
        textView.font = .systemFont(ofSize: 17)
        container.add().vertical(16).view(textView, 96).end(16)
        container.constrain(type: .horizontalFill, textView, margin: 16)
        return container
    }
    
    public func buildVerificationCode() -> VerificationCode {
        let verificationCode = VerificationCode(6, itemWidth: (contentView.frame.width / 6) - 16 )
        verificationCode.textColor = .blackWhite
        verificationCode.delegate = self
        
        return verificationCode
    }
    
    public func buildDatePicker() -> UIView {
        let container = UIView()
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.alpha = 1
        datePicker.backgroundColor = .background
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        datePicker.layer.cornerRadius = 12
        datePicker.clipsToBounds = true
        datePicker.inputView?.tintColor = .accent
        dateLabel = UILabel("12 December 2019", .accent, .systemFont(ofSize: 28, weight: .semibold))
        
        container.add().vertical(0).view(dateLabel, 32).gap(0).view(datePicker, 320).end(">=0")
        container.constrain(type: .horizontalFill, dateLabel, datePicker)
        
        return container
    }
    
    public func buildPhone() -> UIView {
        let container = UIView()
        let country = UIView()
        country.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseCountry)))
        let chevron = UIImageView(image: UIImage(systemName: "chevron.down")?.withTintColor(.primary).resize(CGSize(width: 16, height: 8)))
        chevron.contentMode = .center
        countryCode = UILabel("🇺🇸 +1", .text, .systemFont(ofSize: 28, weight: .semibold))
        if let countryNumber = UserDefaults.standard.string(forKey: "ob_phone_country") {
            countryCode.text = countryNumber
        }
        let line = UIView()
        line.backgroundColor = .gray
        country.add().vertical(0).view(countryCode, 40).gap(0).view(line, 2).end(">=0")
        country.constrain(type: .horizontalFill, countryCode, line)
        
        let input = UIView()
        let inputLine = UIView()
        inputLine.backgroundColor = .gray
        phoneInput = UITextField()
        phoneInput.backgroundColor = UIColor.clear
        phoneInput.textColor = .accent
        phoneInput.delegate = self
        phoneInput.font = .systemFont(ofSize: 28, weight: .semibold)
        input.add().vertical(0).view(phoneInput, 40).gap(0).view(inputLine, 2).end(0)
        input.constrain(type: .horizontalFill, phoneInput, inputLine)
        
        container.add().horizontal(0).view(country, 120).gap(16).view(input).end(0)
        container.constrain(type: .verticalFill, country, input)
        return container
    }
    
    public func buildSelect() -> UIView {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.register(OBSelectCell.self, forCellReuseIdentifier: "ob_select_cell")
        tableView.register(OBSelectCell.self, forCellReuseIdentifier: "ob_select_cell_multiple")
        tableView.separatorInset = .zero
        tableView.alwaysBounceVertical = false
        return tableView
    }
    
    public func buildRange() -> UIView {
        let container = UIView()
        rangePicker = UIPickerView()
        rangePicker.dataSource = self
        rangePicker.delegate = self
        rangePicker.backgroundColor = .background
        rangePicker.clipsToBounds = true
        rangePicker.inputView?.tintColor = .accent
        rangeLabel = UILabel("", .accent, .systemFont(ofSize: 28, weight: .semibold))
        container.add().vertical(0).view(rangeLabel, 32).gap(0).view(rangePicker, 320).end(">=0")
        container.constrain(type: .horizontalFill, rangeLabel, rangePicker)
        return container
    }
    
    // MARK: - Picker delegate functions
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let item = config.range![row]
        if view != nil {
            (view as? PickerView)?.label.text = item as? String
            return view!
        }
        let pickerView = PickerView()
        pickerView.label.text = item as? String
        return pickerView
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return config.range!.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 48
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.OBControllerToggleReadyState(ready: true)
        delegate?.OBControllerUpdateValueForKey(key: config.key, value: config.range![row])
        rangeLabel.text = "\(config.range![row])"
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        hideKeyboard()
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        checkReadyState(config)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkReadyState(config)
        return true
    }
    
    public func checkReadyState(_ config: OBFormConfig) {
        if config.type == .Name {
            self.delegate?.OBControllerToggleReadyState(ready: textInput.text!.count > 0)
            self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: textInput.text!)
        }
        if config.type == .Username {
            let regex = "^[a-z0-9_]{3,32}$"
            let pred = NSPredicate(format: "SELF MATCHES %@", regex)
            self.delegate?.OBControllerToggleReadyState(ready: pred.evaluate(with: textInput.text!))
            self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: textInput.text!)
        }
        if config.type == .Email {
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format: "SELF MATCHES %@", regex)
            self.delegate?.OBControllerToggleReadyState(ready: emailPred.evaluate(with: textInput.text!))
            self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: textInput.text!)
        }
        if config.type == .Date {
            self.delegate?.OBControllerToggleReadyState(ready: true)
            self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: selectedDate!)
        }
        if config.type == .VerificationCode {
            self.delegate?.OBControllerToggleReadyState(ready: verificationCode.numel == verificationCode.text?.count)
            if let text = verificationCode.text {
                self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: text)
            }
        }
        if config.type == .Phone {
            self.delegate?.OBControllerToggleReadyState(ready: phoneInput.text!.count > 5)
            self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: "+" + selectedCountry.phoneCode +  phoneInput.text!)
        }
        
        if config.type == .LargeText {
            self.delegate?.OBControllerToggleReadyState(ready: textView.text!.count > 0)
            self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: textView.text!)
        }
    }
    
    public func hideKeyboard() {
        if textInput.isFirstResponder {
            textInput.resignFirstResponder()
        }
        if verificationCode.isFirstResponder {
            verificationCode.resignFirstResponder()
        }
        if phoneInput.isFirstResponder {
            phoneInput.resignFirstResponder()
        }
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    public func shouldSubmit() -> Bool {
        return true
    }
    
    public func becomeActive(_ config: OBFormConfig) {
        DispatchQueue.main.async { [self] in
            if config.type == .Name || config.type == .Username || config.type == .Email {
                textInput.becomeFirstResponder()
            }
            if config.type == .Phone {
                phoneInput.becomeFirstResponder()
            }
            if config.type == .VerificationCode {
                self.verificationCode.becomeFirstResponder()
            }
            if config.type == .LargeText {
                textView.becomeFirstResponder()
            }
        }
        checkReadyState(config)
    }
    
    public func resignActive(_ config: OBFormConfig) {
        DispatchQueue.main.async { [self] in
            if config.type == .Name || config.type == .Username || config.type == .Email {
                textInput.resignFirstResponder()
            }
            if config.type == .Phone {
                phoneInput.resignFirstResponder()
            }
            if config.type == .VerificationCode {
                self.verificationCode.resignFirstResponder()
            }
            if config.type == .LargeText {
                textView.resignFirstResponder()
            }
        }
    }
    
    // MARK: - Text delegate functions
    
    public func textFieldValueChanged(_ textField: VerificationCode) {
        guard let count = textField.text?.count, count != 0 else {
            textField.resignFirstResponder()
            return
        }
        if count == textField.numel {
            delegate?.OBControllerToggleReadyState(ready: true)
            self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: textField.text!)
        }else {
            delegate?.OBControllerToggleReadyState(ready: false)
            self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: textField.text!)
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            delegate?.OBControllerToggleReadyState(ready: false)
            self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: textView.text!)
        }else {
            delegate?.OBControllerToggleReadyState(ready: true)
            self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: textView.text!)
        }
        checkReadyState(config)
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker, value: Any) {
        dateLabel.text = sender.date.string(with: "d MMMM YYYY")
        selectedDate = sender.date
        checkReadyState(config)
    }
    
    @objc func chooseCountry() {
        let countryPicker = CountryPickerViewController()
        countryPicker.selectedCountry = "US"
        countryPicker.delegate = self
        (delegate as? OnboardingController)?.present(countryPicker, animated: true)
        DispatchQueue.main.async {
            countryPicker.searchTextField.becomeFirstResponder()
        }
    }
    
    public func countryPicker(didSelect country: Country) {
        countryCode.text = country.isoCode.getFlag() + " +" + country.phoneCode
        selectedCountry = country
        DispatchQueue.main.async {
            self.phoneInput.becomeFirstResponder()
        }
        checkReadyState(config)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let selectConfig = config.selectConfig {
            let cell = tableView.dequeueReusableCell(withIdentifier: (config.selectConfig?.multipleChoice)! ? "ob_select_cell_multiple" : "ob_select_cell") as? OBSelectCell
            let item = config.selectConfig!.options[indexPath.row]
            cell?.build(key: item.0, title: item.1, isMultiple: selectConfig.multipleChoice ?? false)
            
            return cell!
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return config.selectConfig?.options.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? OBSelectCell
        self.delegate?.OBControllerToggleReadyState(ready: true)
        let item = config.selectConfig!.options[indexPath.row]
        self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: item)
        cell?.check()
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? OBSelectCell
        self.delegate?.OBControllerToggleReadyState(ready: false)
        if let item = config.selectConfig?.options {
            self.delegate?.OBControllerUpdateValueForKey(key: config.key, value: item)
        }
        cell?.uncheck()
    }
}

public enum OBFormType: String {
    case Name
    case Username
    case Email
    case VerificationCode
    case Date
    case Phone
    case Select
    case LargeText
    case Range
    
    public func Config(_ key: String, _ title: String, _ placeholder: String) -> OBFormConfig {
        return .init(key: key, type: self, title: title, placeholder: placeholder)
    }
    
    public func Config(_ key: String, _ title: String, datePickerConfig: OBDatePickerConfig) -> OBFormConfig {
        return .init(key: key, type: self, title: title, datePickerConfig: datePickerConfig)
    }
    
    public func Config(_ key: String, _ title: String, selectConfig: OBSelectConfig) -> OBFormConfig {
        return .init(key: key, type: self, title: title, selectConfig: selectConfig)
    }
    
    public func Config(_ key: String, _ title: String, range: Array<Any>) -> OBFormConfig {
        return .init(key: key, type: self, title: title, range: range)
    }
}

public struct OBDatePickerConfig {
    public var minDate: Date?
    public var maxDate: Date?
    public var date: Date
    public init(minDate: Date?, maxDate: Date?, date: Date) {
        self.minDate = minDate
        self.maxDate = maxDate
        self.date = date
    }
}

public struct OBSelectConfig {
    public var options: [(String, String)]
    public var multipleChoice: Bool?
    public var minSelection: Int?
    public var maxSelection: Int?
    public init(options: [(String, String)], multipleChoice: Bool?, minSelection: Int?, maxSelection: Int?) {
        self.options = options
        self.multipleChoice = multipleChoice
        self.minSelection = minSelection
        self.maxSelection = maxSelection
    }
}

public struct OBFormConfig {
    public var key: String
    public var type: OBFormType
    public var title: String
    public var placeholder: String?
    public var range: Array<Any>?
    public var datePickerConfig: OBDatePickerConfig?
    public var selectConfig: OBSelectConfig?
}

public protocol OBDelegate {
    func OBControllerToggleReadyState(ready: Bool)
    func OBControllerUpdateValueForKey(key: String, value: Any)
}

@available(iOS 13.0, *)
public class OBSelectCell: UITableViewCell {
    
    public var label: UILabel!
    public var checkView: UIView!
    public var image: UIImageView!
    public var checked: Bool = false
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label = UILabel("", .text, .systemFont(ofSize: 20))
        checkView = UIView()
        checkView.backgroundColor = .separatorLight
        let isMultiple = reuseIdentifier!.contains("multiple")
        if isMultiple {
            checkView.layer.cornerRadius = 4
            image = UIImageView(image: .init(systemName: "checkmark.square.fill")?.withTintColor(.primary))
        }else {
            checkView.layer.cornerRadius = 12
            image = UIImageView(image: .init(systemName: "record.circle.fill")?.withTintColor(.primary))
        }
        checkView.addSubview(image)
        checkView.constrain(type: .verticalFill, image)
        checkView.constrain(type: .horizontalFill, image)
        image.isHidden = true
        contentView.backgroundColor = .background
        let line = UIView()
        line.backgroundColor = .separatorLight
        contentView.add().horizontal(8).view(label).view(checkView, 24).end(8)
        contentView.add().vertical(">=0").view(checkView, 24).end(">=0")
        contentView.add().vertical(">=0").view(line, 1).end(0)
        contentView.constrain(type: .verticalCenter, label, checkView, margin: 12)
        contentView.constrain(type: .horizontalFill, line)
    }
    
    public func build(key: String, title: String, isMultiple: Bool) {
        label.text = title
    }
    
    func check() {
        image.isHidden = false
        checked = true
    }
    
    func uncheck() {
        image.isHidden = true
        checked = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

@available(iOS 13.0, *)
public class PickerView: UIView {
    public var label: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel("Undefined", .darkText, .systemFont(ofSize: 28))
        label.textAlignment = .center
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        add().vertical(8).view(label, 32).end(8)
        constrain(type: .horizontalFill, label, margin: 16)
    }
}
