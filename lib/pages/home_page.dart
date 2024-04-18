import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpflutter_wegame_api/mpflutter_wegame_api.dart' hide Image;
import 'package:xz_go_bang_part/utils/account_util.dart';
import 'package:xz_go_bang_part/utils/dialog_util.dart';
import 'package:xz_go_bang_part/utils/kq_screen_util.dart';
import 'package:xz_go_bang_part/utils/string_ex.dart';

import '../config/global.dart';
import '../resources/images.dart';
import '../resources/theme_colors.dart';
import '../utils/toast_util.dart';
import '../widgets/zz_button.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  GetSettingSuccessCallbackResult? _setting;

  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();

    wx.onShow((p0) {
      debugPrint("onShow");
      judgeInvite(result: p0);
    });

    _initData();
  }

  _initData() async {
    debugPrint("init data");

    _setting = wx.getSetting();

    var op = GetPrivacySettingOption();
    op.success = (p0) {
      if (p0.needAuthorization) {
        var opt = RequirePrivacyAuthorizeOption();
        opt.success = (p0) {
          debugPrint("requirePrivacyAuthorize success");
          // 判断邀请
          judgeInvite();
        };
        wx.requirePrivacyAuthorize(opt);
      } else {
        // 判断邀请
        judgeInvite();
      }
    };
    op.fail = (p0) {
      debugPrint("requirePrivacyAuthorize fail");
      // 判断邀请
      judgeInvite();
    };
    wx.getPrivacySetting(op);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Container(
                color: ThemeColors.backgroundMain,
              ),
              // child: SizedBox(
              //   width: KqScreenUtil().screenWidth,
              //   child: Image.asset(Images.bg, fit: BoxFit.cover),
              // ),
            )
          ],
        ),
        Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100.r,
                ),
                Image.asset(
                  Images.logo,
                  width: 60.r,
                  height: 60.r,
                ),
                SizedBox(
                  height: 40.r,
                ),
                SizedBox(
                  width: 180.r,
                  child: Image.asset(
                    Images.name,
                    color: ThemeColors.chessBorderColor,
                  ),
                ),
                SizedBox(
                  height: 20.r,
                ),
                Text(
                  'V 1.0.0.63',
                  style: TextStyle(
                      fontSize: 16.sp, color: ThemeColors.chessBorderColor),
                ),
                SizedBox(
                  height: 30.r,
                ),
                ZzImageButton(
                  onTap: () async {
                    await wx.getGameServerManager().login();

                    authUserInfo(true, (isOk, avatar, nickname) {
                      ZzDialog.showLoading(msg: "正在创建房间...");
                      var option = CreateRoomOption();
                      option.maxMemberNum = 2;
                      option.startPercent = 100;
                      option.needUserInfo = false;
                      option.success = (p0) {
                        // 进入好友房间
                      };
                      option.fail = (p0) {
                        KqToast.showNormal("房间创建失败，请重试");
                      };
                      option.complete = (p0) {
                        ZzDialog.closeLoading();
                      };
                      wx.getGameServerManager().createRoom(option);
                    });
                  },
                  text: '好友对战',
                  width: 200.r,
                  height: 40.r,
                ),
                SizedBox(
                  height: 30.r,
                ),
                ZzImageButton(
                  onTap: () async {
                    // 进入双人推演页面
                  },
                  text: '双人推演',
                  width: 200.r,
                  height: 40.r,
                ),
                SizedBox(
                  height: 30.r,
                ),
                ZzImageButton(
                  onTap: () async {
                    //人机，直接使用缓存的头像和昵称
                    var avatar = AccountUtils.getAvatar();
                    var nickname = AccountUtils.getNickname();
                    // 进入人机对战页面
                  },
                  text: '人机对战',
                  width: 200.r,
                  height: 40.r,
                )
              ],
            ))
      ],
    );
  }

  authUserInfo(bool useCache,
      Function(bool isOk, String? avatar, String? nickname) callback) {
    if (_userInfo != null) {
      callback(true, _userInfo!.avatarUrl, _userInfo!.nickName);
      return;
    }

    // 理论上应该把信息同步到自己的服务器上，从服务器取，先缓存到本地吧
    if (useCache) {
      var avatar = AccountUtils.getAvatar();
      var nickname = AccountUtils.getNickname();
      if (avatar.isNotNullOrEmpty && nickname.isNotNullOrEmpty) {
        callback(true, avatar, nickname);
        return;
      }
    }

    if (_setting?.authSetting.scope_userInfo == true) {
      // 已经授权，可以直接调用 getUserInfo 获取头像昵称
      debugPrint("scope_userInfo = true");
      var op = GetUserInfoOption();
      op.success = (p0) async {
        _userInfo = p0.userInfo;
        callback.call(true, _userInfo!.avatarUrl, _userInfo!.nickName);
        // 缓存起来，避免频繁调用微信api，有频率限制
        AccountUtils.setAvatar(_userInfo?.avatarUrl);
        AccountUtils.setNickname(_userInfo?.nickName);
      };
      op.fail = (p0) {
        debugPrint("getUserInfo fail : ${p0.errMsg}");
      };
      wx.getUserInfo(op);
    } else {
      // 否则，先通过 wx.createUserInfoButton 接口发起授权
      showDialog(
          context: Global.globalContext,
          useSafeArea: false,
          barrierDismissible: false,
          builder: (context) {
            debugPrint("context.height=${context.height}");
            return UnconstrainedBox(
                child: SizedBox(
                    width: 320.r,
                    height: 150.r,
                    child: Material(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.r))),
                        color: ThemeColors.bgWhite,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8.r)),
                          child: Builder(
                            builder: (context) {
                              var dy = context.height / 2 - 22.r;
                              var opt = CreateUserInfoButtonOption();
                              opt.style = OptionStyle()
                                ..textAlign = 'center'
                                ..width = 200.r
                                ..top = dy
                                ..left = 107.r
                                ..height = 45.r
                                ..lineHeight = 45.r
                                ..backgroundColor = '#00000000'
                                ..color = '#0A84FF'
                                ..borderColor = '#0A84FF'
                                ..borderWidth = 1.r
                                ..fontSize = 15.sp
                                ..borderRadius = 8.r;
                              var btn = wx.createUserInfoButton(opt);
                              btn.text = "授权获取您的头像和昵称";
                              btn.onTap((p0) {
                                Navigator.pop(context);
                                btn.hide();
                                _userInfo = p0.userInfo;
                                callback.call(true, _userInfo!.avatarUrl,
                                    _userInfo!.nickName);
                                // 缓存起来，避免频繁调用微信api，有频率限制
                                AccountUtils.setAvatar(_userInfo?.avatarUrl);
                                AccountUtils.setNickname(_userInfo?.nickName);
                              });
                              return Container();
                            },
                          ),
                        ))));
          });
    }
  }

  void judgeInvite({OnShowListenerResult? result}) async {
    String? accessInfo;
    // 对方的头像
    String? otherAvatar;
    // 对方的昵称
    String? otherNickname;
    // 对方clientId
    num? otherClientId;

    if (result != null) {
      accessInfo = result.query["accessInfo"];
      otherAvatar = result.query["avatar"];
      otherNickname = result.query["nickname"];
      otherClientId = result.query["clientId"] != null
          ? num.tryParse(result.query["clientId"])
          : null;
    } else {
      var enterOptionsSync = wx.getEnterOptionsSync();
      var scene = enterOptionsSync.scene;
      debugPrint("scene=$scene");
      if (scene == 1036) {
        // 从App 分享消息卡片进来。
        var query = enterOptionsSync.query;
        accessInfo = query['accessInfo'];
        otherAvatar = query['avatar'];
        otherNickname = query['nickname'];
        otherClientId =
        query["clientId"] != null ? num.tryParse(query["clientId"]) : null;
      }
    }
    if (otherAvatar.isNotNullOrEmpty) {
      otherAvatar = Uri.decodeComponent(otherAvatar!);
    }
    if (otherNickname.isNotNullOrEmpty) {
      otherNickname = Uri.decodeComponent(otherNickname!);
    }
    debugPrint(
        "accessInfo=$accessInfo, otherAvatar=${otherAvatar}, otherNickname=${otherNickname}, otherClientId=${otherClientId}");

    if (accessInfo.isNullOrEmpty) {
      return;
    }

    await wx.getGameServerManager().login();

    authUserInfo(true, (isOk, avatar, nickname) {
      debugPrint(
          "authUserInfo， isOk= ${isOk}, avatar=$avatar, nickname=$nickname");

      ZzDialog.showLoading(msg: "正在进入房间...");
      var option = JoinRoomOption();
      option.accessInfo = accessInfo ?? '';
      option.success = (p0) {
        // 进入好友对战页面
      };
      option.fail = (p0) {
        KqToast.showNormal("加入房间失败，房间已失效或已满");
      };
      option.complete = (p0) {
        ZzDialog.closeLoading();
      };
      wx.getGameServerManager().joinRoom(option);
    });
  }
}
