
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NEKitChat
import NEKitCoreIM
import NIMSDK

protocol UserSettingViewModelDelegate: AnyObject {
  func didNeedRefreshUI()
  func didError(_ error: Error)
}

public class UserSettingViewModel {
  var repo = ChatRepo()

  var userInfo: User?

  var cellDatas = [UserSettingCellModel]()

  var delegate: UserSettingViewModelDelegate?

  func getUserSettingModel(_ userId: String) {
    guard let user = repo.getUserInfo(userId: userId) else {
      return
    }
    userInfo = user
    weak var weakSelf = self
    let remind = UserSettingCellModel()
    remind.cellName = localizable("message_remind")
      remind.cornerType = .none
    if let isNotiMsg = user.imUser?.notifyForNewMsg() {
      remind.switchOpen = isNotiMsg
    }

    remind.swichChange = { isOpen in
      if let uid = weakSelf?.userInfo?.userId {
        weakSelf?.repo.updateNotifyState(uid, isOpen) { error in
          if let err = error {
            weakSelf?.delegate?.didNeedRefreshUI()
            weakSelf?.delegate?.didError(err)
          } else {
            remind.switchOpen = isOpen
          }
        }
      }
    }

    let searchHistory = UserSettingCellModel()
    searchHistory.cellName = "查找聊天内容"

      
    let feedback = UserSettingCellModel()
    feedback.cellName = "反馈"
    /*
     let blackList = UserSettingCellModel()
     blackList.cornerType = .bottomRight.union(.bottomLeft)
     blackList.cellName = "加入黑名单"
     if let isBlack = user.imUser?.isInMyBlackList() {
         blackList.switchOpen = isBlack
     }
     blackList.swichChange = { isOpen in
         if let uid = weakSelf?.userInfo?.userId {
             if isOpen {
                 weakSelf?.repo.addBlackList(account: uid, { error in
                     print("add black list : ", error as Any)
                 })
             }else {
                 weakSelf?.repo.removeFromBlackList(account: uid, { error in
                     print("remo black list : ", error as Any)
                 })
             }
         }
     }
     */
    cellDatas.append(contentsOf: [remind, searchHistory,feedback])
  }
}
