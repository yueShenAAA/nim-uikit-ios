
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class UserSettingBaseCell: CornerCell {
  var model: UserSettingCellModel?

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = NEConstant.hexRGB(0x333333)
    label.font = NEConstant.defaultTextFont(16.0)
    return label
  }()

  public lazy var arrow: UIImageView = {
    let imageView = UIImageView(image: coreLoader.loadImage("arrowRight"))
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    showDefaultLine = true
    edgeInset = UIEdgeInsets(top: 0, left:0, bottom: 0, right: 0)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func configure(_ anyModel: Any) {
    if let m = anyModel as? UserSettingCellModel {
      model = m
      cornerType = m.cornerType
      titleLabel.text = m.cellName
    }
  }
}
