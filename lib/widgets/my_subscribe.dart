import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sail/constant/app_colors.dart';
import 'package:sail/entity/user_subscribe_entity.dart';
import 'package:sail/models/app_model.dart';
import 'package:sail/utils/transfer_util.dart';

import '../utils/navigator_util.dart';

class MySubscribe extends StatefulWidget {
  const MySubscribe({Key? key, required this.isLogin, required this.isOn, required this.userSubscribeEntity})
      : super(key: key);

  final bool isLogin;
  final bool isOn;
  final UserSubscribeEntity? userSubscribeEntity;

  @override
  MySubscribeState createState() => MySubscribeState();
}

class MySubscribeState extends State<MySubscribe> {
  late AppModel _appModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appModel = Provider.of<AppModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(75)),
          child: Text(
            "我的订阅",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                color: widget.isOn ? AppColors.grayColor : Colors.grey[400],
                fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(30)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(10)),
          child: _contentWidget(),
        )
      ],
    );
  }

  Widget _contentWidget () {
    if (widget.userSubscribeEntity?.plan == null) {
      return _emptyWidget();
    }

    if (widget.userSubscribeEntity!.expiredAt * 1000 < DateTime.now().millisecondsSinceEpoch) {
      return _timeOutWidget();
    }

    return _buildConnections();
  }

  Widget _emptyWidget() {
    return Container(
      width: ScreenUtil().setWidth(1080),
      height: ScreenUtil().setWidth(200),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(75), vertical: ScreenUtil().setWidth(0)),
      child: Material(
        elevation: widget.isOn ? 3 : 0,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
        color: widget.isOn ? Colors.white : AppColors.darkSurfaceColor,
        child: Container(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => _onTap(),
            child: Text(
              !widget.isLogin ? '请先登陆' : '请先订阅下方套餐',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setWidth(40),
                color: widget.isOn ? Colors.black : Colors.white),
                ),
            ),
        ),
      ),
    );
  }

  _onTap(){
    if (!widget.isLogin){
      print("login");
      NavigatorUtil.goLogin(context);
    } else{
      print("subscribe");
      NavigatorUtil.goPlan(context);
    }
  }
  Widget _timeOutWidget() {
    return Container(
      width: ScreenUtil().setWidth(1080),
      height: ScreenUtil().setWidth(200),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(75), vertical: ScreenUtil().setWidth(0)),
      child: Material(
        elevation: widget.isOn ? 3 : 0,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
        color: widget.isOn ? Colors.white : AppColors.darkSurfaceColor,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            '套餐已过期，请重新订阅',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setWidth(40),
                color: widget.isOn ? Colors.black : Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildConnections() {
    return Container(
        width: ScreenUtil().setWidth(1080),
        height: ScreenUtil().setWidth(240),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(75), vertical: ScreenUtil().setWidth(0)),
        child: Material(
          elevation: widget.isOn ? 3 : 0,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
          color: widget.isOn ? Colors.white : AppColors.darkSurfaceColor,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30), horizontal: ScreenUtil().setWidth(40)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userSubscribeEntity!.plan.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(35),
                              color: widget.isOn ? Colors.black : Colors.white),
                        ),
                        Padding(padding: EdgeInsets.only(left: ScreenUtil().setWidth(15))),
                        Text(
                          widget.userSubscribeEntity?.expiredAt != null
                              ? '${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(widget.userSubscribeEntity!.expiredAt * 1000))}过期'
                              : '长期有效',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(35),
                              color: widget.isOn ? Colors.black : Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(480),
                          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(15)),
                          child: LinearProgressIndicator(
                            backgroundColor: widget.isOn ? Colors.black : Colors.white,
                            valueColor: AlwaysStoppedAnimation(Colors.yellow[600]),
                            value: double.parse(
                                ((widget.userSubscribeEntity!.u ?? 0 + widget.userSubscribeEntity!.d ?? 0) /
                                            widget.userSubscribeEntity!.transferEnable ??
                                        1)
                                    .toStringAsFixed(2)),
                          ),
                        ),
                        Text(
                          '已用 ${TransferUtil().toHumanReadable(widget.userSubscribeEntity!.u + widget.userSubscribeEntity!.d)} / 总计 ${TransferUtil().toHumanReadable(widget.userSubscribeEntity!.transferEnable)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(26),
                              color: widget.isOn ? Colors.black : Colors.white),
                        )
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(160),
                      height: ScreenUtil().setWidth(90),
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                      child:
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              foregroundColor: Colors.yellow[700],
                              disabledForegroundColor: Colors.black,
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            ),
                            onPressed: () {
                              _appModel.getTunnelLog();
                            },
                            child: Text(
                              '续费',
                              style: TextStyle(color: Colors.black87, fontSize: ScreenUtil().setSp(36)),
                            ),
                          ),
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(160),
                      height: ScreenUtil().setWidth(90),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.yellow[700],
                          disabledForegroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        ),
                        onPressed: () {
                          _appModel.getTunnelConfiguration();
                        },
                        child: Text(
                          '重置',
                          style: TextStyle(color: Colors.black87, fontSize: ScreenUtil().setSp(36)),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
