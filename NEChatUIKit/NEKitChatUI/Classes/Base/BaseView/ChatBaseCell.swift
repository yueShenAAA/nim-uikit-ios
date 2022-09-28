
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

public class ChatBaseCell: UITableViewCell {
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func uploadProgress(_ progress: Float) {
    fatalError("override in sub class")
  }
    
  public override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
         
            // Configure the view for the selected state
         
            if selected {
                self.backgroundColor = UIColor(hexString: "#FAFAF7")
                contentView.backgroundColor = UIColor(hexString: "#FAFAF7")
                backgroundView?.backgroundColor = UIColor(hexString: "#FAFAF7")
            }else {
                self.backgroundColor = UIColor(hexString: "#FAFAF7")
                contentView.backgroundColor = UIColor(hexString: "#FAFAF7")
                backgroundView?.backgroundColor = UIColor(hexString: "#FAFAF7")
            }
}
}
