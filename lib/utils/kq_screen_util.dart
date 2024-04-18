import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' show min, max;
import 'dart:ui' as ui show FlutterView;

import 'package:flutter/material.dart';

/// 屏幕适配工具
class KqScreenUtil {
  static const Size defaultSize = Size(414, 736);
  static final KqScreenUtil _instance = KqScreenUtil._();

  /// UI设计中手机尺寸 , dp
  /// Size of the phone in UI Design , dp
  late Size _uiSize;

  ///屏幕方向
  late Orientation _orientation;

  late bool _minTextAdapt;
  late MediaQueryData _data;

  bool Function(MediaQueryData data)? _disableScale;

  KqScreenUtil._();

  factory KqScreenUtil() => _instance;

  /// Manually wait for window size to be initialized
  ///
  /// `Recommended` to use before you need access window size
  /// or in custom splash/bootstrap screen [FutureBuilder]
  ///
  /// example:
  /// ```dart
  /// ...
  /// KqScreenUtil.init(context, ...);
  /// ...
  ///   FutureBuilder(
  ///     future: Future.wait([..., ensureScreenSize(), ...]),
  ///     builder: (context, snapshot) {
  ///       if (snapshot.hasData) return const HomeScreen();
  ///       return Material(
  ///         child: LayoutBuilder(
  ///           ...
  ///         ),
  ///       );
  ///     },
  ///   )
  /// ```
  static Future<void> ensureScreenSize([
    ui.FlutterView? window,
    Duration duration = const Duration(milliseconds: 10),
  ]) async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    binding.deferFirstFrame();

    await Future.doWhile(() {
      window ??= binding.platformDispatcher.implicitView;

      if (window == null || window!.physicalSize.isEmpty) {
        return Future.delayed(duration, () => true);
      }

      return false;
    });

    binding.allowFirstFrame();
  }

  Set<Element>? _elementsToRebuild;

  /// ### Experimental
  /// Register current page and all its descendants to rebuild.
  /// Helpful when building for web and desktop
  static void registerToBuild(
    BuildContext context, [
    bool withDescendants = false,
  ]) {
    (_instance._elementsToRebuild ??= {}).add(context as Element);

    if (withDescendants) {
      context.visitChildren((element) {
        registerToBuild(element, true);
      });
    }
  }

  static void configure({
    MediaQueryData? data,
    Size? designSize,
    bool? minTextAdapt,
    bool Function(MediaQueryData data)? disableScale,
  }) {
    try {
      if (data != null) {
        _instance._data = data;
      } else {
        data = _instance._data;
      }

      if (designSize != null) {
        _instance._uiSize = designSize;
      } else {
        designSize = _instance._uiSize;
      }
    } catch (_) {
      throw Exception(
          'You must either use KqScreenUtil.init or KqScreenUtilInit first');
    }

    final MediaQueryData? deviceData = data.nonEmptySizeOrNull();
    final Size deviceSize = deviceData?.size ?? designSize;

    final orientation = deviceData?.orientation ??
        (deviceSize.width > deviceSize.height
            ? Orientation.landscape
            : Orientation.portrait);

    _instance
      .._minTextAdapt = minTextAdapt ?? _instance._minTextAdapt
      .._orientation = orientation
      .._disableScale = disableScale;

    _instance._elementsToRebuild?.forEach((el) => el.markNeedsBuild());
  }

  /// Initializing the library.
  static void init(
    BuildContext context, {
    Size designSize = defaultSize,
    bool minTextAdapt = false,
    bool Function(MediaQueryData data)? disableScale,
  }) {
    return configure(
      data: MediaQuery.maybeOf(context),
      designSize: designSize,
      minTextAdapt: minTextAdapt,
      disableScale: disableScale,
    );
  }

  static Future<void> ensureScreenSizeAndInit(
    BuildContext context, {
    Size designSize = defaultSize,
    bool minTextAdapt = false,
    bool Function(MediaQueryData data)? disableScale,
  }) {
    return KqScreenUtil.ensureScreenSize().then((_) {
      return configure(
        data: MediaQuery.maybeOf(context),
        designSize: designSize,
        minTextAdapt: minTextAdapt,
        disableScale: disableScale,
      );
    });
  }

  ///获取屏幕方向
  ///Get screen orientation
  Orientation get orientation => _orientation;

  /// 每个逻辑像素的字体像素数，字体的缩放比例
  /// The number of font pixels for each logical pixel.
  double get textScaleFactor => _data.textScaleFactor;

  /// 设备的像素密度
  /// The size of the media in logical pixels (e.g, the size of the screen).
  double? get pixelRatio => _data.devicePixelRatio;

  /// 当前设备宽度 dp
  /// The horizontal extent of this size.
  double get screenWidth => _data.size.width;

  ///当前设备高度 dp
  ///The vertical extent of this size. dp
  double get screenHeight => _data.size.height;

  /// 状态栏高度 dp 刘海屏会更高
  /// The offset from the top, in dp
  double get statusBarHeight => _data.padding.top;

  /// 底部安全区距离 dp
  /// The offset from the bottom, in dp
  double get bottomBarHeight => _data.padding.bottom;

  /// 实际尺寸的较小边与UI设计的比例
  double get scaleMin => (_disableScale?.call(_data) ?? false)
      ? 1.0
      : min(screenWidth, screenHeight) / min(_uiSize.width, _uiSize.height);

  /// 实际尺寸的较大边与UI设计的比例
  double get scaleMax => (_disableScale?.call(_data) ?? false)
      ? 1.0
      : max(screenWidth, screenHeight) / max(_uiSize.width, _uiSize.height);

  /// 实际尺寸的宽与UI设计的宽的比例
  double get scaleWidth =>
      (_disableScale?.call(_data) ?? false) ? 1.0 : screenWidth / _uiSize.width;

  double get scaleText => _minTextAdapt ? scaleMin : scaleMax;

  ///根据宽度或高度中的较小值进行适配
  ///Adapt according to the smaller of width or height
  double radius(num r) => toIntDp(r * scaleMin);

  /// Adapt according to the maximum value of scale width and scale height
  double diameter(num d) => toIntDp(d * scaleMax);

  /// 根据当前宽度/UI图的宽度进行适配
  double setWidth(num w) => toIntDp(w * scaleWidth);

  ///字体大小适配方法
  ///- [fontSize] UI设计上字体的大小,单位dp.
  ///Font size adaptation method
  ///- [fontSize] The size of the font on the UI design, in dp.
  double setSp(num fontSize) => toIntDp(fontSize * scaleText);

  /// 使用dp值转成px后四舍五入取整，然后再转回dp
  /// 为了让屏幕绘制整数像素
  double toIntDp(num dp) {
    var pr = pixelRatio!;
    var value = dp * pr;
    if (value == 0) {
      return 0;
    }
    if (value.abs() < 1) {
      if (value > 0) {
        value = 1;
      } else {
        value = -1;
      }
    } else {
      value = value.round().toDouble();
    }
    return value / pr;
  }

  DeviceType deviceType() {
    DeviceType deviceType;
    switch (Platform.operatingSystem) {
      case 'android':
      case 'ios':
        deviceType = DeviceType.mobile;
        if ((orientation == Orientation.portrait && screenWidth < 600) ||
            (orientation == Orientation.landscape && screenHeight < 600)) {
          deviceType = DeviceType.mobile;
        } else {
          deviceType = DeviceType.tablet;
        }
        break;
      case 'linux':
        deviceType = DeviceType.linux;
        break;
      case 'macos':
        deviceType = DeviceType.mac;
        break;
      case 'windows':
        deviceType = DeviceType.windows;
        break;
      case 'fuchsia':
        deviceType = DeviceType.fuchsia;
        break;
      default:
        deviceType = DeviceType.web;
    }
    return deviceType;
  }
}

extension on MediaQueryData? {
  MediaQueryData? nonEmptySizeOrNull() {
    if (this?.size.isEmpty ?? true) {
      return null;
    } else {
      return this;
    }
  }
}

enum DeviceType { mobile, tablet, web, mac, windows, linux, fuchsia }

extension SizeExtension on num {
  ///[KqScreenUtil.radius]
  double get r => KqScreenUtil().radius(this);

  ///[KqScreenUtil.diameter]
  double get dm => KqScreenUtil().diameter(this);

  ///[KqScreenUtil.setWidth]
  double get w => KqScreenUtil().setWidth(this);

  ///[KqScreenUtil.setSp]
  double get sp => KqScreenUtil().setSp(this);
}

extension EdgeInsetsExtension on EdgeInsets {
  /// Creates adapt insets using r [SizeExtension].
  EdgeInsets get r => copyWith(
        top: top.r,
        bottom: bottom.r,
        right: right.r,
        left: left.r,
      );

  EdgeInsets get dm => copyWith(
        top: top.dm,
        bottom: bottom.dm,
        right: right.dm,
        left: left.dm,
      );

  EdgeInsets get w => copyWith(
        top: top.w,
        bottom: bottom.w,
        right: right.w,
        left: left.w,
      );
}

extension BorderRaduisExtension on BorderRadius {
  /// Creates adapt BorderRadius using r [SizeExtension].
  BorderRadius get r => copyWith(
        bottomLeft: bottomLeft.r,
        bottomRight: bottomRight.r,
        topLeft: topLeft.r,
        topRight: topRight.r,
      );

  BorderRadius get dm => copyWith(
        bottomLeft: bottomLeft.dm,
        bottomRight: bottomRight.dm,
        topLeft: topLeft.dm,
        topRight: topRight.dm,
      );

  BorderRadius get w => copyWith(
        bottomLeft: bottomLeft.w,
        bottomRight: bottomRight.w,
        topLeft: topLeft.w,
        topRight: topRight.w,
      );
}

extension RaduisExtension on Radius {
  /// Creates adapt Radius using r [SizeExtension].
  Radius get r => Radius.elliptical(x.r, y.r);

  Radius get dm => Radius.elliptical(x.dm, y.dm);

  Radius get w => Radius.elliptical(x.w, y.w);
}

extension BoxConstraintsExtension on BoxConstraints {
  /// Creates adapt BoxConstraints using r [SizeExtension].
  BoxConstraints get r => copyWith(
        maxHeight: maxHeight.r,
        maxWidth: maxWidth.r,
        minHeight: minHeight.r,
        minWidth: minWidth.r,
      );

  BoxConstraints get dm => copyWith(
        maxHeight: maxHeight.dm,
        maxWidth: maxWidth.dm,
        minHeight: minHeight.dm,
        minWidth: minWidth.dm,
      );

  BoxConstraints get w => copyWith(
        maxHeight: maxHeight.w,
        maxWidth: maxWidth.w,
        minHeight: minHeight.w,
        minWidth: minWidth.w,
      );
}

class KqScreenUtilInit extends StatefulWidget {
  /// A helper widget that initializes [KqScreenUtil]
  const KqScreenUtilInit({
    Key? key,
    this.builder,
    this.child,
    this.rebuildFactor = RebuildFactors.size,
    this.designSize = KqScreenUtil.defaultSize,
    this.minTextAdapt = false,
    this.disableScale,
    this.useInheritedMediaQuery = false,
    this.ensureScreenSize,
    this.responsiveWidgets,
  }) : super(key: key);

  final ScreenUtilInitBuilder? builder;
  final Widget? child;
  final bool minTextAdapt;
  final bool useInheritedMediaQuery;
  final bool? ensureScreenSize;
  final RebuildFactor rebuildFactor;

  ///  是否禁用缩放
  final bool Function(MediaQueryData data)? disableScale;

  /// The [Size] of the device in the design draft, in dp
  final Size designSize;
  final Iterable<String>? responsiveWidgets;

  @override
  State<KqScreenUtilInit> createState() => _KqScreenUtilInitState();
}

class _KqScreenUtilInitState extends State<KqScreenUtilInit>
    with WidgetsBindingObserver {
  final _canMarkedToBuild = HashSet<String>();
  MediaQueryData? _mediaQueryData;
  final _binding = WidgetsBinding.instance;
  final _screenSizeCompleter = Completer<void>();

  @override
  void initState() {
    if (widget.responsiveWidgets != null) {
      _canMarkedToBuild.addAll(widget.responsiveWidgets!);
    }
    _validateSize().then(_screenSizeCompleter.complete);

    super.initState();
    _binding.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _revalidate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _revalidate();
  }

  MediaQueryData? _newData() {
    MediaQueryData? mq = MediaQuery.maybeOf(context);
    mq ??= MediaQueryData.fromView(View.of(context));

    return mq;
  }

  Future<void> _validateSize() async {
    if (widget.ensureScreenSize ?? false) {
      return KqScreenUtil.ensureScreenSize();
    }
  }

  void _markNeedsBuildIfAllowed(Element el) {
    final widgetName = el.widget.runtimeType.toString();
    final allowed = widget is SU ||
        _canMarkedToBuild.contains(widgetName) ||
        !(widgetName.startsWith('_') || flutterWidgets.contains(widgetName));

    if (allowed) el.markNeedsBuild();
  }

  void _updateTree(Element el) {
    _markNeedsBuildIfAllowed(el);
    el.visitChildren(_updateTree);
  }

  void _revalidate([void Function()? callback]) {
    final oldData = _mediaQueryData;
    final newData = _newData();

    if (newData == null) return;

    if (oldData == null || widget.rebuildFactor(oldData, newData)) {
      setState(() {
        _mediaQueryData = newData;
        _updateTree(context as Element);
        callback?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = _mediaQueryData;

    if (mq == null) return const SizedBox.shrink();

    return FutureBuilder<void>(
      future: _screenSizeCompleter.future,
      builder: (c, snapshot) {
        KqScreenUtil.configure(
          data: mq,
          designSize: widget.designSize,
          minTextAdapt: widget.minTextAdapt,
          disableScale: widget.disableScale,
        );

        if (snapshot.connectionState == ConnectionState.done) {
          return widget.builder?.call(context, widget.child) ?? widget.child!;
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    _binding.removeObserver(this);
    super.dispose();
  }
}

typedef RebuildFactor = bool Function(MediaQueryData old, MediaQueryData data);

typedef ScreenUtilInitBuilder = Widget Function(
  BuildContext context,
  Widget? child,
);

abstract class RebuildFactors {
  static bool size(MediaQueryData old, MediaQueryData data) {
    return old.size != data.size;
  }

  static bool orientation(MediaQueryData old, MediaQueryData data) {
    return old.orientation != data.orientation;
  }

  static bool sizeAndViewInsets(MediaQueryData old, MediaQueryData data) {
    return old.viewInsets != data.viewInsets;
  }

  static bool change(MediaQueryData old, MediaQueryData data) {
    return old != data;
  }

  static bool always(MediaQueryData _, MediaQueryData __) {
    return true;
  }

  static bool none(MediaQueryData _, MediaQueryData __) {
    return false;
  }
}

mixin SU on Widget {}

final flutterWidgets = HashSet<String>.from({
  'AbsorbPointer',
  'Accumulator',
  'Action',
  'ActionDispatcher',
  'ActionListener',
  'Actions',
  'ActivateAction',
  'ActivateIntent',
  'Align',
  'Alignment',
  'AlignmentDirectional',
  'AlignmentGeometry',
  'AlignmentGeometryTween',
  'AlignmentTween',
  'AlignTransition',
  'AlwaysScrollableScrollPhysics',
  'AlwaysStoppedAnimation',
  'AndroidView',
  'AndroidViewSurface',
  'Animatable',
  'AnimatedAlign',
  'AnimatedBuilder',
  'AnimatedContainer',
  'AnimatedCrossFade',
  'AnimatedDefaultTextStyle',
  'AnimatedFractionallySizedBox',
  'AnimatedGrid',
  'AnimatedGridState',
  'AnimatedList',
  'AnimatedListState',
  'AnimatedModalBarrier',
  'AnimatedOpacity',
  'AnimatedPadding',
  'AnimatedPhysicalModel',
  'AnimatedPositioned',
  'AnimatedPositionedDirectional',
  'AnimatedRotation',
  'AnimatedScale',
  'AnimatedSize',
  'AnimatedSlide',
  'AnimatedSwitcher',
  'AnimatedWidget',
  'AnimatedWidgetBaseState',
  'Animation',
  'AnimationController',
  'AnimationMax',
  'AnimationMean',
  'AnimationMin',
  'AnnotatedRegion',
  'AspectRatio',
  'AssetBundle',
  'AssetBundleImageKey',
  'AssetBundleImageProvider',
  'AssetImage',
  'AsyncSnapshot',
  'AutocompleteHighlightedOption',
  'AutocompleteNextOptionIntent',
  'AutocompletePreviousOptionIntent',
  'AutofillGroup',
  'AutofillGroupState',
  'AutofillHints',
  'AutomaticKeepAlive',
  'AutomaticNotchedShape',
  'BackButtonDispatcher',
  'BackButtonListener',
  'BackdropFilter',
  'BallisticScrollActivity',
  'Banner',
  'BannerPainter',
  'Baseline',
  'BaseTapAndDragGestureRecognizer',
  'BeveledRectangleBorder',
  'BlockSemantics',
  'Border',
  'BorderDirectional',
  'BorderRadius',
  'BorderRadiusDirectional',
  'BorderRadiusGeometry',
  'BorderRadiusTween',
  'BorderSide',
  'BorderTween',
  'BottomNavigationBarItem',
  'BouncingScrollPhysics',
  'BouncingScrollSimulation',
  'BoxBorder',
  'BoxConstraints',
  'BoxConstraintsTween',
  'BoxDecoration',
  'BoxPainter',
  'BoxScrollView',
  'BoxShadow',
  'BuildContext',
  'Builder',
  'BuildOwner',
  'ButtonActivateIntent',
  'CallbackAction',
  'CallbackShortcuts',
  'Canvas',
  'CapturedThemes',
  'CatmullRomCurve',
  'CatmullRomSpline',
  'Center',
  'ChangeNotifier',
  'CharacterActivator',
  'CharacterRange',
  'Characters',
  'CheckedModeBanner',
  'ChildBackButtonDispatcher',
  'CircleBorder',
  'CircularNotchedRectangle',
  'ClampingScrollPhysics',
  'ClampingScrollSimulation',
  'ClipboardStatusNotifier',
  'ClipContext',
  'ClipOval',
  'ClipPath',
  'ClipRect',
  'ClipRRect',
  'Color',
  'ColoredBox',
  'ColorFilter',
  'ColorFiltered',
  'ColorProperty',
  'ColorSwatch',
  'ColorTween',
  'Column',
  'ComponentElement',
  'CompositedTransformFollower',
  'CompositedTransformTarget',
  'CompoundAnimation',
  'ConstantTween',
  'ConstrainedBox',
  'ConstrainedLayoutBuilder',
  'ConstraintsTransformBox',
  'Container',
  'ContentInsertionConfiguration',
  'ContextAction',
  'ContextMenuButtonItem',
  'ContextMenuController',
  'ContinuousRectangleBorder',
  'CopySelectionTextIntent',
  'Cubic',
  'Curve',
  'Curve2D',
  'Curve2DSample',
  'CurvedAnimation',
  'Curves',
  'CurveTween',
  'CustomClipper',
  'CustomMultiChildLayout',
  'CustomPaint',
  'CustomPainter',
  'CustomPainterSemantics',
  'CustomScrollView',
  'CustomSingleChildLayout',
  'DebugCreator',
  'DecoratedBox',
  'DecoratedBoxTransition',
  'Decoration',
  'DecorationImage',
  'DecorationImagePainter',
  'DecorationTween',
  'DefaultAssetBundle',
  'DefaultPlatformMenuDelegate',
  'DefaultSelectionStyle',
  'DefaultTextEditingShortcuts',
  'DefaultTextHeightBehavior',
  'DefaultTextStyle',
  'DefaultTextStyleTransition',
  'DefaultTransitionDelegate',
  'DefaultWidgetsLocalizations',
  'DeleteCharacterIntent',
  'DeleteToLineBreakIntent',
  'DeleteToNextWordBoundaryIntent',
  'DesktopTextSelectionToolbarLayoutDelegate',
  'DevToolsDeepLinkProperty',
  'DiagnosticsNode',
  'DirectionalCaretMovementIntent',
  'DirectionalFocusAction',
  'DirectionalFocusIntent',
  'Directionality',
  'DirectionalTextEditingIntent',
  'DismissAction',
  'Dismissible',
  'DismissIntent',
  'DismissUpdateDetails',
  'DisplayFeatureSubScreen',
  'DisposableBuildContext',
  'DoNothingAction',
  'DoNothingAndStopPropagationIntent',
  'DoNothingAndStopPropagationTextIntent',
  'DoNothingIntent',
  'DragDownDetails',
  'DragEndDetails',
  'Draggable',
  'DraggableDetails',
  'DraggableScrollableActuator',
  'DraggableScrollableController',
  'DraggableScrollableNotification',
  'DraggableScrollableSheet',
  'DragScrollActivity',
  'DragStartDetails',
  'DragTarget',
  'DragTargetDetails',
  'DragUpdateDetails',
  'DrivenScrollActivity',
  'DualTransitionBuilder',
  'EdgeDraggingAutoScroller',
  'EdgeInsets',
  'EdgeInsetsDirectional',
  'EdgeInsetsGeometry',
  'EdgeInsetsGeometryTween',
  'EdgeInsetsTween',
  'EditableText',
  'EditableTextState',
  'ElasticInCurve',
  'ElasticInOutCurve',
  'ElasticOutCurve',
  'Element',
  'EmptyTextSelectionControls',
  'ErrorDescription',
  'ErrorHint',
  'ErrorSummary',
  'ErrorWidget',
  'ExactAssetImage',
  'ExcludeFocus',
  'ExcludeFocusTraversal',
  'ExcludeSemantics',
  'Expanded',
  'ExpandSelectionToDocumentBoundaryIntent',
  'ExpandSelectionToLineBreakIntent',
  'ExtendSelectionByCharacterIntent',
  'ExtendSelectionByPageIntent',
  'ExtendSelectionToDocumentBoundaryIntent',
  'ExtendSelectionToLineBreakIntent',
  'ExtendSelectionToNextParagraphBoundaryIntent',
  'ExtendSelectionToNextParagraphBoundaryOrCaretLocationIntent',
  'ExtendSelectionToNextWordBoundaryIntent',
  'ExtendSelectionToNextWordBoundaryOrCaretLocationIntent',
  'ExtendSelectionVerticallyToAdjacentLineIntent',
  'ExtendSelectionVerticallyToAdjacentPageIntent',
  'FadeInImage',
  'FadeTransition',
  'FileImage',
  'FittedBox',
  'FittedSizes',
  'FixedColumnWidth',
  'FixedExtentMetrics',
  'FixedExtentScrollController',
  'FixedExtentScrollPhysics',
  'FixedScrollMetrics',
  'Flex',
  'FlexColumnWidth',
  'Flexible',
  'FlippedCurve',
  'FlippedTweenSequence',
  'Flow',
  'FlowDelegate',
  'FlowPaintingContext',
  'FlutterErrorDetails',
  'FlutterLogoDecoration',
  'Focus',
  'FocusableActionDetector',
  'FocusAttachment',
  'FocusManager',
  'FocusNode',
  'FocusOrder',
  'FocusScope',
  'FocusScopeNode',
  'FocusTraversalGroup',
  'FocusTraversalOrder',
  'FocusTraversalPolicy',
  'FontWeight',
  'ForcePressDetails',
  'Form',
  'FormField',
  'FormFieldState',
  'FormState',
  'FractionallySizedBox',
  'FractionalOffset',
  'FractionalOffsetTween',
  'FractionalTranslation',
  'FractionColumnWidth',
  'FutureBuilder',
  'GestureDetector',
  'GestureRecognizerFactory',
  'GestureRecognizerFactoryWithHandlers',
  'GlobalKey',
  'GlobalObjectKey',
  'GlowingOverscrollIndicator',
  'Gradient',
  'GradientRotation',
  'GradientTransform',
  'GridPaper',
  'GridView',
  'Hero',
  'HeroController',
  'HeroControllerScope',
  'HeroMode',
  'HoldScrollActivity',
  'HSLColor',
  'HSVColor',
  'HtmlElementView',
  'Icon',
  'IconData',
  'IconDataProperty',
  'IconTheme',
  'IconThemeData',
  'IdleScrollActivity',
  'IgnorePointer',
  'Image',
  'ImageCache',
  'ImageCacheStatus',
  'ImageChunkEvent',
  'ImageConfiguration',
  'ImageFiltered',
  'ImageIcon',
  'ImageInfo',
  'ImageProvider',
  'ImageShader',
  'ImageSizeInfo',
  'ImageStream',
  'ImageStreamCompleter',
  'ImageStreamCompleterHandle',
  'ImageStreamListener',
  'ImageTilingInfo',
  'ImplicitlyAnimatedWidget',
  'ImplicitlyAnimatedWidgetState',
  'IndexedSemantics',
  'IndexedSlot',
  'IndexedStack',
  'InheritedElement',
  'InheritedModel',
  'InheritedModelElement',
  'InheritedNotifier',
  'InheritedTheme',
  'InheritedWidget',
  'InlineSpan',
  'InlineSpanSemanticsInformation',
  'InspectorSelection',
  'InspectorSerializationDelegate',
  'Intent',
  'InteractiveViewer',
  'Interval',
  'IntrinsicColumnWidth',
  'IntrinsicHeight',
  'IntrinsicWidth',
  'IntTween',
  'KeepAlive',
  'KeepAliveHandle',
  'KeepAliveNotification',
  'Key',
  'KeyboardInsertedContent',
  'KeyboardListener',
  'KeyedSubtree',
  'KeyEvent',
  'KeySet',
  'LabeledGlobalKey',
  'LayerLink',
  'LayoutBuilder',
  'LayoutChangedNotification',
  'LayoutId',
  'LeafRenderObjectElement',
  'LeafRenderObjectWidget',
  'LexicalFocusOrder',
  'LimitedBox',
  'LinearBorder',
  'LinearBorderEdge',
  'LinearGradient',
  'ListBody',
  'Listenable',
  'ListenableBuilder',
  'Listener',
  'ListView',
  'ListWheelChildBuilderDelegate',
  'ListWheelChildDelegate',
  'ListWheelChildListDelegate',
  'ListWheelChildLoopingListDelegate',
  'ListWheelElement',
  'ListWheelScrollView',
  'ListWheelViewport',
  'Locale',
  'LocalHistoryEntry',
  'Localizations',
  'LocalizationsDelegate',
  'LocalKey',
  'LogicalKeySet',
  'LongPressDraggable',
  'LongPressEndDetails',
  'LongPressMoveUpdateDetails',
  'LongPressStartDetails',
  'LookupBoundary',
  'MagnifierController',
  'MagnifierDecoration',
  'MagnifierInfo',
  'MaskFilter',
  'Matrix4',
  'Matrix4Tween',
  'MatrixUtils',
  'MaxColumnWidth',
  'MediaQuery',
  'MediaQueryData',
  'MemoryImage',
  'MergeSemantics',
  'MetaData',
  'MinColumnWidth',
  'ModalBarrier',
  'ModalRoute',
  'MouseCursor',
  'MouseRegion',
  'MultiChildLayoutDelegate',
  'MultiChildRenderObjectElement',
  'MultiChildRenderObjectWidget',
  'MultiFrameImageStreamCompleter',
  'MultiSelectableSelectionContainerDelegate',
  'NavigationToolbar',
  'Navigator',
  'NavigatorObserver',
  'NavigatorState',
  'NestedScrollView',
  'NestedScrollViewState',
  'NestedScrollViewViewport',
  'NetworkImage',
  'NeverScrollableScrollPhysics',
  'NextFocusAction',
  'NextFocusIntent',
  'NotchedShape',
  'Notification',
  'NotificationListener',
  'NumericFocusOrder',
  'ObjectKey',
  'Offset',
  'Offstage',
  'OneFrameImageStreamCompleter',
  'Opacity',
  'OrderedTraversalPolicy',
  'OrientationBuilder',
  'OutlinedBorder',
  'OvalBorder',
  'OverflowBar',
  'OverflowBox',
  'Overlay',
  'OverlayEntry',
  'OverlayPortal',
  'OverlayPortalController',
  'OverlayRoute',
  'OverlayState',
  'OverscrollIndicatorNotification',
  'OverscrollNotification',
  'Padding',
  'Page',
  'PageController',
  'PageMetrics',
  'PageRoute',
  'PageRouteBuilder',
  'PageScrollPhysics',
  'PageStorage',
  'PageStorageBucket',
  'PageStorageKey',
  'PageView',
  'Paint',
  'PaintingContext',
  'ParametricCurve',
  'ParentDataElement',
  'ParentDataWidget',
  'PasteTextIntent',
  'Path',
  'PerformanceOverlay',
  'PhysicalModel',
  'PhysicalShape',
  'Placeholder',
  'PlaceholderDimensions',
  'PlaceholderSpan',
  'PlatformMenu',
  'PlatformMenuBar',
  'PlatformMenuDelegate',
  'PlatformMenuItem',
  'PlatformMenuItemGroup',
  'PlatformProvidedMenuItem',
  'PlatformRouteInformationProvider',
  'PlatformSelectableRegionContextMenu',
  'PlatformViewCreationParams',
  'PlatformViewLink',
  'PlatformViewSurface',
  'PointerCancelEvent',
  'PointerDownEvent',
  'PointerEvent',
  'PointerMoveEvent',
  'PointerUpEvent',
  'PopupRoute',
  'Positioned',
  'PositionedDirectional',
  'PositionedTransition',
  'PreferredSize',
  'PreferredSizeWidget',
  'PreviousFocusAction',
  'PreviousFocusIntent',
  'PrimaryScrollController',
  'PrioritizedAction',
  'PrioritizedIntents',
  'ProxyAnimation',
  'ProxyElement',
  'ProxyWidget',
  'RadialGradient',
  'Radius',
  'RangeMaintainingScrollPhysics',
  'RawAutocomplete',
  'RawDialogRoute',
  'RawGestureDetector',
  'RawGestureDetectorState',
  'RawImage',
  'RawKeyboardListener',
  'RawKeyEvent',
  'RawMagnifier',
  'RawScrollbar',
  'RawScrollbarState',
  'ReadingOrderTraversalPolicy',
  'Rect',
  'RectTween',
  'RedoTextIntent',
  'RelativePositionedTransition',
  'RelativeRect',
  'RelativeRectTween',
  'RenderBox',
  'RenderNestedScrollViewViewport',
  'RenderObject',
  'RenderObjectElement',
  'RenderObjectToWidgetAdapter',
  'RenderObjectToWidgetElement',
  'RenderObjectWidget',
  'RenderSemanticsGestureHandler',
  'RenderSliverOverlapAbsorber',
  'RenderSliverOverlapInjector',
  'RenderTapRegion',
  'RenderTapRegionSurface',
  'ReorderableDelayedDragStartListener',
  'ReorderableDragStartListener',
  'ReorderableList',
  'ReorderableListState',
  'RepaintBoundary',
  'ReplaceTextIntent',
  'RequestFocusAction',
  'RequestFocusIntent',
  'ResizeImage',
  'ResizeImageKey',
  'RestorableBool',
  'RestorableBoolN',
  'RestorableChangeNotifier',
  'RestorableDateTime',
  'RestorableDateTimeN',
  'RestorableDouble',
  'RestorableDoubleN',
  'RestorableEnum',
  'RestorableEnumN',
  'RestorableInt',
  'RestorableIntN',
  'RestorableListenable',
  'RestorableNum',
  'RestorableNumN',
  'RestorableProperty',
  'RestorableRouteFuture',
  'RestorableString',
  'RestorableStringN',
  'RestorableTextEditingController',
  'RestorableValue',
  'RestorationBucket',
  'RestorationScope',
  'ReverseAnimation',
  'ReverseTween',
  'RichText',
  'RootBackButtonDispatcher',
  'RootRenderObjectElement',
  'RootRestorationScope',
  'RotatedBox',
  'RotationTransition',
  'RoundedRectangleBorder',
  'Route',
  'RouteAware',
  'RouteInformation',
  'RouteInformationParser',
  'RouteInformationProvider',
  'RouteObserver',
  'Router',
  'RouterConfig',
  'RouterDelegate',
  'RouteSettings',
  'RouteTransitionRecord',
  'Row',
  'RRect',
  'RSTransform',
  'SafeArea',
  'SawTooth',
  'ScaleEndDetails',
  'ScaleStartDetails',
  'ScaleTransition',
  'ScaleUpdateDetails',
  'Scrollable',
  'ScrollableDetails',
  'ScrollableState',
  'ScrollAction',
  'ScrollActivity',
  'ScrollActivityDelegate',
  'ScrollAwareImageProvider',
  'ScrollbarPainter',
  'ScrollBehavior',
  'ScrollConfiguration',
  'ScrollContext',
  'ScrollController',
  'ScrollDragController',
  'ScrollEndNotification',
  'ScrollHoldController',
  'ScrollIncrementDetails',
  'ScrollIntent',
  'ScrollMetricsNotification',
  'ScrollNotification',
  'ScrollNotificationObserver',
  'ScrollNotificationObserverState',
  'ScrollPhysics',
  'ScrollPosition',
  'ScrollPositionWithSingleContext',
  'ScrollSpringSimulation',
  'ScrollStartNotification',
  'ScrollToDocumentBoundaryIntent',
  'ScrollUpdateNotification',
  'ScrollView',
  'SelectableRegion',
  'SelectableRegionState',
  'SelectAction',
  'SelectAllTextIntent',
  'SelectIntent',
  'SelectionContainer',
  'SelectionContainerDelegate',
  'SelectionOverlay',
  'SelectionRegistrarScope',
  'Semantics',
  'SemanticsDebugger',
  'SemanticsGestureDelegate',
  'Shader',
  'ShaderMask',
  'ShaderWarmUp',
  'Shadow',
  'ShapeBorder',
  'ShapeBorderClipper',
  'ShapeDecoration',
  'SharedAppData',
  'ShortcutActivator',
  'ShortcutManager',
  'ShortcutMapProperty',
  'ShortcutRegistrar',
  'ShortcutRegistry',
  'ShortcutRegistryEntry',
  'Shortcuts',
  'ShortcutSerialization',
  'ShrinkWrappingViewport',
  'Simulation',
  'SingleActivator',
  'SingleChildLayoutDelegate',
  'SingleChildRenderObjectElement',
  'SingleChildRenderObjectWidget',
  'SingleChildScrollView',
  'Size',
  'SizeChangedLayoutNotification',
  'SizeChangedLayoutNotifier',
  'SizedBox',
  'SizedOverflowBox',
  'SizeTransition',
  'SizeTween',
  'SlideTransition',
  'SliverAnimatedGrid',
  'SliverAnimatedGridState',
  'SliverAnimatedList',
  'SliverAnimatedListState',
  'SliverAnimatedOpacity',
  'SliverChildBuilderDelegate',
  'SliverChildDelegate',
  'SliverChildListDelegate',
  'SliverFadeTransition',
  'SliverFillRemaining',
  'SliverFillViewport',
  'SliverFixedExtentList',
  'SliverGrid',
  'SliverGridDelegate',
  'SliverGridDelegateWithFixedCrossAxisCount',
  'SliverGridDelegateWithMaxCrossAxisExtent',
  'SliverIgnorePointer',
  'SliverLayoutBuilder',
  'SliverList',
  'SliverMultiBoxAdaptorElement',
  'SliverMultiBoxAdaptorWidget',
  'SliverOffstage',
  'SliverOpacity',
  'SliverOverlapAbsorber',
  'SliverOverlapAbsorberHandle',
  'SliverOverlapInjector',
  'SliverPadding',
  'SliverPersistentHeader',
  'SliverPersistentHeaderDelegate',
  'SliverPrototypeExtentList',
  'SliverReorderableList',
  'SliverReorderableListState',
  'SliverSafeArea',
  'SliverToBoxAdapter',
  'SliverVisibility',
  'SliverWithKeepAliveWidget',
  'SlottedRenderObjectElement',
  'SnapshotController',
  'SnapshotPainter',
  'SnapshotWidget',
  'Spacer',
  'SpellCheckConfiguration',
  'SpringDescription',
  'Stack',
  'StadiumBorder',
  'StarBorder',
  'State',
  'StatefulBuilder',
  'StatefulElement',
  'StatefulWidget',
  'StatelessElement',
  'StatelessWidget',
  'StatusTransitionWidget',
  'StepTween',
  'StreamBuilder',
  'StreamBuilderBase',
  'StretchingOverscrollIndicator',
  'StrutStyle',
  'SweepGradient',
  'SystemMouseCursors',
  'Table',
  'TableBorder',
  'TableCell',
  'TableColumnWidth',
  'TableRow',
  'TapAndDragGestureRecognizer',
  'TapAndHorizontalDragGestureRecognizer',
  'TapAndPanGestureRecognizer',
  'TapDownDetails',
  'TapDragDownDetails',
  'TapDragEndDetails',
  'TapDragStartDetails',
  'TapDragUpdateDetails',
  'TapDragUpDetails',
  'TapRegion',
  'TapRegionRegistry',
  'TapRegionSurface',
  'TapUpDetails',
  'Text',
  'TextAlignVertical',
  'TextBox',
  'TextDecoration',
  'TextEditingController',
  'TextEditingValue',
  'TextFieldTapRegion',
  'TextHeightBehavior',
  'TextInputType',
  'TextMagnifierConfiguration',
  'TextPainter',
  'TextPosition',
  'TextRange',
  'TextSelection',
  'TextSelectionControls',
  'TextSelectionGestureDetector',
  'TextSelectionGestureDetectorBuilder',
  'TextSelectionGestureDetectorBuilderDelegate',
  'TextSelectionOverlay',
  'TextSelectionPoint',
  'TextSelectionToolbarAnchors',
  'TextSelectionToolbarLayoutDelegate',
  'TextSpan',
  'TextStyle',
  'TextStyleTween',
  'Texture',
  'ThreePointCubic',
  'Threshold',
  'TickerFuture',
  'TickerMode',
  'TickerProvider',
  'Title',
  'Tolerance',
  'ToolbarItemsParentData',
  'ToolbarOptions',
  'TrackingScrollController',
  'TrainHoppingAnimation',
  'Transform',
  'TransformationController',
  'TransformProperty',
  'TransitionDelegate',
  'TransitionRoute',
  'TransposeCharactersIntent',
  'Tween',
  'TweenAnimationBuilder',
  'TweenSequence',
  'TweenSequenceItem',
  'UiKitView',
  'UnconstrainedBox',
  'UndoHistory',
  'UndoHistoryController',
  'UndoHistoryState',
  'UndoHistoryValue',
  'UndoTextIntent',
  'UniqueKey',
  'UniqueWidget',
  'UnmanagedRestorationScope',
  'UpdateSelectionIntent',
  'UserScrollNotification',
  'ValueKey',
  'ValueListenableBuilder',
  'ValueNotifier',
  'Velocity',
  'View',
  'Viewport',
  'Visibility',
  'VoidCallbackAction',
  'VoidCallbackIntent',
  'Widget',
  'WidgetInspector',
  'WidgetOrderTraversalPolicy',
  'WidgetsApp',
  'WidgetsBindingObserver',
  'WidgetsFlutterBinding',
  'WidgetsLocalizations',
  'WidgetSpan',
  'WidgetToRenderBoxAdapter',
  'WillPopScope',
  'WordBoundary',
  'Wrap'
});
