//
//  File.swift
//  NEKitChatUI
//
//  Created by lqy on 2022/9/19.
//

import UIKit

protocol ChatBottomMoreViewDelegate: AnyObject {
    func selectItem(tag:Int,button:UIButton)
}

class ChatBottomMoreView: UIView, UIGestureRecognizerDelegate {
  public weak var delegate: ChatBottomMoreViewDelegate?
  private var outView = false
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func commonUI() {
      let imageNames = ["Slice 9","Slice 10","Slice 11"]
      var items = [UIButton]()
      for i in 0 ... 2 {
        let button = UIButton(type: .custom)
          button.setImage(UIImage(named: imageNames[i]), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonEvent), for: .touchUpInside)
        button.tag = i
        items.append(button)
//        if i == 4 {
//          button.alpha = 0.5
//        }
      }
      let stackView = UIStackView(arrangedSubviews: items)
      stackView.translatesAutoresizingMaskIntoConstraints = false
      stackView.distribution = .fillEqually
      addSubview(stackView)
      NSLayoutConstraint.activate([
        stackView.leftAnchor.constraint(equalTo: leftAnchor),
        stackView.rightAnchor.constraint(equalTo: rightAnchor),
        stackView.heightAnchor.constraint(equalToConstant: 32),
        stackView.topAnchor.constraint(equalTo: topAnchor,constant: 18),
      ])
      
      let lineV  = UIView()
      lineV.backgroundColor = UIColor(hexString: "#FAFAF7")
      lineV.translatesAutoresizingMaskIntoConstraints = false
      addSubview(lineV)
      NSLayoutConstraint.activate([
        lineV.leftAnchor.constraint(equalTo: leftAnchor),
        lineV.rightAnchor.constraint(equalTo: rightAnchor),
        lineV.heightAnchor.constraint(equalToConstant: 0.5),
        lineV.topAnchor.constraint(equalTo: stackView.topAnchor,constant: -6),
      ])
  }

    @objc func buttonEvent(button: UIButton) {
        delegate?.selectItem(tag: button.tag,button: button)
    }
}
