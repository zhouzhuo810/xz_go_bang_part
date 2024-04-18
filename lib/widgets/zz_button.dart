import 'package:flutter/material.dart';
import 'package:xz_go_bang_part/utils/kq_screen_util.dart';

import '../resources/images.dart';
import '../resources/theme_colors.dart';

/// 游戏风格按钮
class ZzImageButton extends StatefulWidget {
  final double width;

  final double height;

  final String text;

  final double? radius;

  final VoidCallback onTap;

  const ZzImageButton(
      {Key? key,
      required this.width,
      required this.height,
      required this.text,
      required this.onTap,
      this.radius})
      : super(key: key);

  @override
  State<ZzImageButton> createState() => _ZzImageButtonState();
}

class _ZzImageButtonState extends State<ZzImageButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      radius: widget.radius ?? 200.r,
      onTapUp: (details) {
        pressed = false;
        setState(() {});
        widget.onTap.call();
      },
      onTapCancel: () {
        pressed = false;
        setState(() {});
      },
      onTapDown: (details) {
        pressed = true;
        setState(() {});
      },
      child: Stack(
        children: [
          Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius ?? 200.r),
                  boxShadow: pressed
                      ? null
                      : [
                          BoxShadow(
                              offset: Offset(3.r, 3.r),
                              blurRadius: 2.r,
                              color: Colors.black26),
                        ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.radius ?? 200.r),
                child: Image.asset(
                  Images.btnBg,
                  fit: BoxFit.fill,
                  width: widget.width,
                  height: widget.height,
                ),
              )),
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Align(
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: ThemeColors.bgWhite),
                ),
              ))
        ],
      ),
    );
  }
}
