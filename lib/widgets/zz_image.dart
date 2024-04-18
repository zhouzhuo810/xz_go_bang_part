import 'package:flutter/material.dart';
// import 'package:mpflutter_core/mpflutter_core.dart';

/// 图片处理
class ZzImage extends StatelessWidget {
  final String url;

  final double width;
  final double height;

  final String placeHolder;

  const ZzImage(
      {Key? key,
      required this.url,
      required this.width,
      required this.height,
      required this.placeHolder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return SizedBox(
          width: width, height: height, child: Image.asset(placeHolder));
    }

    return SizedBox(
      width: width,
      height: height,
      child: Image.network(
        // useNativeCodec(url),
        url,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          return Image.asset(placeHolder);
        },
        errorBuilder: (context, error, stackTrace) {
          print(error);
          return Image.asset(placeHolder);
        },
      ),
    );
  }
}
