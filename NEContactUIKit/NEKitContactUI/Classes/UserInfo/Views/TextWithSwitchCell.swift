
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
typealias ValueChangeBlock = (_ title: String?, _ value: Bool) -> Void
class TextWithSwitchCell: TextBaseCell {
  public var block: ValueChangeBlock?
  public var switchButton = UISwitch()
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    switchButton.translatesAutoresizingMaskIntoConstraints = false
    switchButton.onTintColor = UIColor(hexString: "#337EFF")
    switchButton.addTarget(self, action: #selector(valueChanged), for: .touchUpInside)

    contentView.addSubview(switchButton)
    NSLayoutConstraint.activate([
      switchButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
      switchButton.widthAnchor.constraint(equalToConstant: 46),
      switchButton.heightAnchor.constraint(equalToConstant: 28),
      switchButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func valueChanged(switchBtn: UISwitch) {
    print("switchBtn:\(switchBtn.isOn)")
    if let block = block {
      block(titleLabel.text, switchBtn.isOn)
    }
  }
}
