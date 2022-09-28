
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import NEKitCommon
import RSKPlaceholderTextView

public enum ChatMenuType {
  case text
  case audio
  case emoji
  case image
  case file
  case more
}

public protocol ChatInputViewDelegate: AnyObject {
  func sendText(text: String?)
  func willSelectItem(button: UIButton, index: Int)
  @discardableResult
  func textChanged(text: String) -> Bool
  func textDelete(range: NSRange, text: String) -> Bool
  func startRecord()
  func moveOutView()
  func moveInView()
  func endRecord(insideView: Bool)
  func textFieldDidChange(_ textField: UITextView)
  func textFieldDidEndEditing(_ textField: UITextView)
  func textFieldDidBeginEditing(_ textField: UITextView)
  func longPressClickEvent(sender:UILongPressGestureRecognizer)
}

public class ChatInputView: UIView, UITextFieldDelegate, ChatRecordViewDelegate,
  InputEmoticonContainerViewDelegate, UITextViewDelegate,ChatBottomMoreViewDelegate {
  public weak var delegate: ChatInputViewDelegate?
  public var currentType: ChatMenuType = .text
  public var menuHeight = 100.0
  public var contentHeight = 100.0
  public var atCache: NIMInputAtCache?

  var textField = RSKPlaceholderTextView()
  var contentView = UIView()
  public var contentSubView: UIView?
  private var greyView = UIView()
  var recordView = ChatRecordView(frame: .zero)
  var voiceButton = UIButton(type: .custom)
  var mojiButton = UIButton(type: .custom)
  var addButton = UIButton(type: .custom)
  var pressOnSayButton = UIButton(type: .custom)
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func commonUI() {
    backgroundColor = UIColor(hexString: "#FFFFFF")
      let lineV = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 0.5))
      lineV.backgroundColor = UIColor(hexString: "#FAFAF7")
      addSubview(lineV)
      voiceButton.setImage(UIImage(named: "Frame 9_1"), for: .normal)
      voiceButton.setImage(UIImage(named: "Frame 13"), for: .selected)
      voiceButton.translatesAutoresizingMaskIntoConstraints = false
      voiceButton.addTarget(self, action: #selector(voiceClickEvent), for: .touchUpInside)
      addSubview(voiceButton)
      NSLayoutConstraint.activate([
        voiceButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 21),
        voiceButton.topAnchor.constraint(equalTo: topAnchor, constant: 13),
        voiceButton.widthAnchor.constraint(equalToConstant: 28),
        voiceButton.heightAnchor.constraint(equalToConstant: 28)
      ])
      
      addButton.setImage(UIImage(named: "Group 708"), for: .normal)
      addButton.translatesAutoresizingMaskIntoConstraints = false
      addButton.addTarget(self, action: #selector(moreClickEvent), for: .touchUpInside)
      addSubview(addButton)
      NSLayoutConstraint.activate([
        addButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -17),
        addButton.centerYAnchor.constraint(equalTo: voiceButton.centerYAnchor),
        addButton.widthAnchor.constraint(equalToConstant: 28),
        addButton.heightAnchor.constraint(equalToConstant: 28)
      ])
      mojiButton.setImage(UIImage(named: "Slice 22"), for: .normal)
      mojiButton.translatesAutoresizingMaskIntoConstraints = false
      mojiButton.addTarget(self, action: #selector(mojiClickEvent), for: .touchUpInside)
      addSubview(mojiButton)
      NSLayoutConstraint.activate([
        mojiButton.rightAnchor.constraint(equalTo: addButton.leftAnchor, constant: -14),
        mojiButton.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
        mojiButton.widthAnchor.constraint(equalToConstant: 28),
        mojiButton.heightAnchor.constraint(equalToConstant: 28)
      ])
    textField.layer.cornerRadius = 4
    textField.clipsToBounds = true
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.backgroundColor = UIColor(hexString: "#F7F7F7")
    //        textField.leftViewMode = .always
    textField.returnKeyType = .send
    //        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
    textField.delegate = self
    textField.allowsEditingTextAttributes = true
      textField.font = UIFont(name: "PingFang SC", size: 14)
    addSubview(textField)
    NSLayoutConstraint.activate([
        textField.leftAnchor.constraint(equalTo: voiceButton.rightAnchor, constant: 11),
        textField.centerYAnchor.constraint(equalTo: voiceButton.centerYAnchor),
        textField.rightAnchor.constraint(equalTo: mojiButton.leftAnchor, constant: -11),
      textField.heightAnchor.constraint(equalToConstant: 36),
    ])
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(textFieldChangeNoti),
      name: UITextField.textDidChangeNotification,
      object: nil
    )
      
      pressOnSayButton.layer.cornerRadius = 4
      pressOnSayButton.clipsToBounds = true
      pressOnSayButton.translatesAutoresizingMaskIntoConstraints = false
      pressOnSayButton.backgroundColor = UIColor(hexString: "#F7F7F7")
      pressOnSayButton.isHidden = true
//      pressOnSayButton.addTarget(self, action: #selector(longPressOnClick), for: .touchUpInside)
      pressOnSayButton.titleLabel?.font = UIFont(name: "PingFang SC", size: 14)
      pressOnSayButton.setTitle("按住说话", for: .normal)
      pressOnSayButton.setTitleColor(UIColor(hexString: "#808080"), for: .normal)
      let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnClick))
      pressOnSayButton.addGestureRecognizer(longPress)
      addSubview(pressOnSayButton)
      NSLayoutConstraint.activate([
        pressOnSayButton.leftAnchor.constraint(equalTo: textField.leftAnchor, constant: 0),
        pressOnSayButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
        pressOnSayButton.rightAnchor.constraint(equalTo: textField.rightAnchor, constant: 0),
        pressOnSayButton.heightAnchor.constraint(equalTo: textField.heightAnchor),
      ])

    //        let imageNames = ["mic","emoji","photo","file","add"]
//    let imageNames = ["mic", "emoji", "photo", "chat_video", "add"]

//    var items = [UIButton]()
//    for i in 0 ... 4 {
//      let button = UIButton(type: .custom)
//      button.setImage(UIImage.ne_imageNamed(name: imageNames[i]), for: .normal)
//      button.translatesAutoresizingMaskIntoConstraints = false
//      button.addTarget(self, action: #selector(buttonEvent), for: .touchUpInside)
//      button.tag = i + 5
//      items.append(button)
//      if i == 4 {
//        button.alpha = 0.5
//      }
//    }
//    let stackView = UIStackView(arrangedSubviews: items)
//    stackView.translatesAutoresizingMaskIntoConstraints = false
//    stackView.distribution = .fillEqually
//    addSubview(stackView)
//    NSLayoutConstraint.activate([
//      stackView.leftAnchor.constraint(equalTo: leftAnchor),
//      stackView.rightAnchor.constraint(equalTo: rightAnchor),
//      stackView.heightAnchor.constraint(equalToConstant: 54),
//      stackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 0),
//    ])

//    greyView.translatesAutoresizingMaskIntoConstraints = false
//    greyView.backgroundColor = UIColor(hexString: "#EFF1F3")
//    greyView.isHidden = true
//    addSubview(greyView)
//    NSLayoutConstraint.activate([
//      greyView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
//      greyView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
//      greyView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
//      greyView.heightAnchor.constraint(equalToConstant: 34),
//    ])
    addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.leftAnchor.constraint(equalTo: leftAnchor),
      contentView.rightAnchor.constraint(equalTo: rightAnchor),
      contentView.heightAnchor.constraint(equalToConstant: contentHeight),
      contentView.topAnchor.constraint(equalTo:textField.bottomAnchor, constant: 0),
    ])

    recordView.isHidden = true
    recordView.translatesAutoresizingMaskIntoConstraints = false
    recordView.delegate = self
    contentView.addSubview(recordView)
    NSLayoutConstraint.activate([
      recordView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
      recordView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
      recordView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
      recordView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
    ])

    contentView.addSubview(emojiView)
    //        NSLayoutConstraint.activate([
    //            emojiView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0),
    //            emojiView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0),
    //            emojiView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
    //            emojiView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -25)
    //        ])
    contentView.addSubview(moreView)
  }
    
    @objc func longPressOnClick(sender:UILongPressGestureRecognizer) {
        delegate?.longPressClickEvent(sender: sender)
    }

  func addRecordView() {
    if currentType != .audio {
      currentType = .audio
      textField.resignFirstResponder()
      contentSubView?.isHidden = true
      contentSubView = recordView
      contentSubView?.isHidden = false
    }
      contentSubView?.isHidden = false
  }

  func addEmojiView() {
    if currentType != .emoji {
      currentType = .emoji
      textField.resignFirstResponder()
      contentSubView?.isHidden = true
      contentSubView = emojiView
      contentSubView?.isHidden = false
    }
      contentSubView?.isHidden = false
  }
    
    func addMoreView() {
        if currentType != .more {
          currentType = .more
          textField.resignFirstResponder()
          contentSubView?.isHidden = true
          contentSubView = moreView
          contentSubView?.isHidden = false
        }
        contentSubView?.isHidden = false
    }

  //    func doButtonDeleteText(){
  //        let range = delRangeForLastComponent()
  //        if range.count == 1 {
  //
  //        }
  //        print("\(textField.selectedTextRange?.start)")
  //        textField.deleteBackward()
  //    }

  //    func delRangeForLastComponent() -> NSRange{
  //        let text = textField.text as? NSString
  //        let selectedRange = self.textField.selectedRange
  //        if selectedRange.location == 0 {
  //            return NSRange.init(location: 0, length: 0)
  //        }
  //
  //        let range:NSRange?
  //        let subRange =
  //        if selectedRange?.start >= 2 {
  //            let subStr = text?.substring(with: NSRange.init(location: selectedRange?.start - 2, length: 2))
  //            isEmoji = sub
  //        }
  //    }

  //    func rangeForPrefix(prefix:String,suffix:String) ->NSRange {
  //        let text = textField.text as? NSString
  //        let range = textField.selectedRange
  //        var selectedText:String?
  //        if range.length > 0 {
  //            selectedText = text?.substring(with: range)
  //        }else {
  //            selectedText = text as? String
  //        }
  //        let endLocaiton = range.location
  //        if endLocaiton <= 0{
  //            return NSMakeRange(NSNotFound, 0)
  //        }
  //        let index = -1
  //
  //        if let selectStr = selectedText,selectStr.hasSuffix(suffix) {
  //            let p = 20
  //            for index = endLocaiton in
  //
  //
  //
  //        }else {
  //            return NSMakeRange(NSNotFound, 0)
  //
  //        }
  //
  //
  //
  //    }

  // MARK: ===================== lazy method =====================

  public lazy var emojiView: InputEmoticonContainerView = {
    let view =
      InputEmoticonContainerView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 200))
    //        view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    view.delegate = self
    return view
  }()
    
  lazy var moreView: ChatBottomMoreView = {
        let view =
        ChatBottomMoreView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 56))
        //        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.isHidden = true
        return view
    }()

  public func textViewDidEndEditing(_ textView: UITextView) {
    delegate?.textFieldDidEndEditing(textView)
  }

  public func textFieldDidEndEditing(_ textField: UITextField) {
    //        delegate?.textFieldDidEndEditing(textField)
  }

  public func textViewDidBeginEditing(_ textView: UITextView) {
    delegate?.textFieldDidBeginEditing(textView)
  }

  public func textFieldDidBeginEditing(_ textField: UITextField) {
    //        delegate?.textFieldDidBeginEditing(textField)
  }

  public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
      if currentType == .more{
          moreView.isHidden = true
      }
      if currentType == .emoji{
          emojiView.isHidden = true
      }
      if currentType == .audio{
          recordView.isHidden = true
      }
    currentType = .text
    return true
  }

  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    currentType = .text
      
    return true
  }

  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                       replacementText text: String) -> Bool {
    if text == "\n" {
      guard let text = getRealSendText(textField.attributedText)?
        .trimmingCharacters(in: CharacterSet.whitespaces) else {
        return true
      }
      delegate?.sendText(text: text)
      textField.text = ""
//            textView.resignFirstResponder()
      return false
    }

    print("range:\(range) string:\(text)")
    if text.count == 0 {
      if let delegate = delegate {
        return delegate.textDelete(range: range, text: text)
      }
    } else {
      delegate?.textChanged(text: text)
    }

    return true
  }

  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let text = textField.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
      return true
    }
    textField.text = ""
    delegate?.sendText(text: text)
    return true
  }

  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                        replacementString string: String) -> Bool {
    print("range:\(range) string:\(string)")
    if string.count == 0 {
      if let delegate = delegate {
        return delegate.textDelete(range: range, text: string)
      }
    } else {
      delegate?.textChanged(text: string)
    }
    return true
  }
    
    @objc func mojiClickEvent(button: UIButton) {
        addEmojiView()
        delegate?.willSelectItem(button: button, index: 1)
        pressOnSayButton.isHidden = true
        textField.isHidden = false
        voiceButton.isSelected = false
    }
    @objc func voiceClickEvent(button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            //按住说话
            pressOnSayButton.isHidden = false
            textField.isHidden = true
            textField.resignFirstResponder()
            contentSubView?.isHidden = true
            delegate?.willSelectItem(button: button, index: 6)
        }else{
            pressOnSayButton.isHidden = true
            textField.isHidden = false
            textField.becomeFirstResponder()
        }
//        addRecordView()
//        delegate?.willSelectItem(button: button, index: 0)
    }
    
    @objc func moreClickEvent(button: UIButton) {
        addMoreView()
        delegate?.willSelectItem(button: button, index: 5)
    }
    
  @objc func buttonEvent(button: UIButton) {
    switch button.tag - 5 {
    case 0:
      addRecordView()
    case 1:
      addEmojiView()
    default:
      print("default")
    }
    delegate?.willSelectItem(button: button, index: button.tag - 5)
  }

  // MARK: InputEmoticonContainerViewDelegate

  public func selectedEmoticon(emoticonID: String, emotCatalogID: String, description: String) {
    if emoticonID.isEmpty { // 删除键
      //            doButtonDeleteText()
      textField.deleteBackward()
      print("delete ward")
    } else {
      if let font = textField.font {
        let attribute = NEEmotionTool.getAttWithStr(
          str: description,
          font: font,
          CGPoint(x: 0, y: -4)
        )
        print("attribute : ", attribute)
        let mutaAttribute = NSMutableAttributedString()
        if let origin = textField.attributedText {
          mutaAttribute.append(origin)
        }
        attribute.enumerateAttribute(
          NSAttributedString.Key.attachment,
          in: NSMakeRange(0, attribute.length)
        ) { value, range, stop in
          if let neAttachment = value as? NEEmotionAttachment {
            print("ne attachment bounds ", neAttachment.bounds)
          }
        }
        mutaAttribute.append(attribute)
        mutaAttribute.addAttribute(
          NSAttributedString.Key.font,
          value: font,
          range: NSMakeRange(0, mutaAttribute.length)
        )
        textField.attributedText = mutaAttribute
        textField.scrollRangeToVisible(NSMakeRange(textField.attributedText.length, 1))
//                [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];
      }
    }
  }

  public func didPressSend(sender: UIButton) {
    guard let text = getRealSendText(textField.attributedText) else {
      return
    }
    delegate?.sendText(text: text)
    textField.text = ""
    atCache?.clean()
  }

  public func stopRecordAnimation() {
    greyView.isHidden = true
    recordView.stopRecordAnimation()
  }

  //    MARK: ChatRecordViewDelegate

  func startRecord() {
    greyView.isHidden = false
    delegate?.startRecord()
  }

  func moveOutView() {
    delegate?.moveOutView()
  }

  func moveInView() {
    delegate?.moveInView()
  }

  func endRecord(insideView: Bool) {
    greyView.isHidden = true
    delegate?.endRecord(insideView: insideView)
  }

  @objc func textFieldChangeNoti() {
    delegate?.textFieldDidChange(textField)
  }

  func getRealSendText(_ attribute: NSAttributedString) -> String? {
    let muta = NSMutableString()

    attribute.enumerateAttributes(
      in: NSMakeRange(0, attribute.length),
      options: NSAttributedString.EnumerationOptions(rawValue: 0)
    ) { dics, range, stop in

      if let neAttachment = dics[NSAttributedString.Key.attachment] as? NEEmotionAttachment,
         let des = neAttachment.emotion?.tag {
        muta.append(des)
      } else {
        let sub = attribute.attributedSubstring(from: range).string
        muta.append(sub)
      }
    }
    return muta as String
  }
//    MARK: ChatBottomMoreViewDelegate

    func selectItem(tag: Int,button:UIButton) {
        delegate?.willSelectItem(button: button, index: tag + 2)
    }
}
