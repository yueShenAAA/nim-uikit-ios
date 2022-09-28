
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import NIMSDK

@objcMembers
open class P2PChatViewController: ChatViewController {
  override open func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
 
    public override func pushLocationVC() {
        super.pushLocationVC()
        
    }

  override open func getSessionInfo(session: NIMSession) {
    viewmodel.getUserInfo(userId: session.sessionId)
    let user = viewmodel.getUserInfo(userId: session.sessionId)
    let title = user?.showName() ?? ""
    self.title = title
    titleContent = title
    // self.menuView.textField.placeholder = localizable("send_to") + title
//    menuView.textField.placeholder = localizable("send_to") + title as NSString
      menuView.textField.placeholder = "输入聊天内容";
  }

  /// 创建个人聊天页构造方法
  /// - Parameter sessionId: 会话id
  public init(sessionId: String) {
    let session = NIMSession(sessionId, type: .P2P)
    super.init(session: session)
  }

  /// 重写父类的构造方法
  /// - Parameter session: sessionId
  override public init(session: NIMSession) {
    super.init(session: session)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
