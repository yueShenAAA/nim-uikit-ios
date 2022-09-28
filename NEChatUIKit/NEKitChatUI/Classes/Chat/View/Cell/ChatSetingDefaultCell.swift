//
//  ChatSetingDefaultCell.swift
//  NEKitChatUI
//
//  Created by lqy on 2022/9/20.
//

class ChatSetingDefaultCell: UITableViewCell {
    
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = NEConstant.hexRGB(0x333333)
    label.font = NEConstant.defaultTextFont(16.0)
    return label
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
      contentView.addSubview(titleLabel)
    NSLayoutConstraint.activate([
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -84),
    ])
      let moreBtn = UIButton(type: .custom)
      moreBtn.setImage(UIImage(named: "声望饱和度"), for: .normal)
      moreBtn.translatesAutoresizingMaskIntoConstraints = false
      contentView.addSubview(moreBtn)
      NSLayoutConstraint.activate([
        moreBtn.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
        moreBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        moreBtn.heightAnchor.constraint(equalToConstant: 16),
        moreBtn.widthAnchor.constraint(equalToConstant: 16)
      ])
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
        titleLabel.text = m.cellName
      }
    }
}

