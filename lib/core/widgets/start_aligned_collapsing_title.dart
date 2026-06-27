import 'package:flutter/widgets.dart';

class StartAlignedCollapsingTitle extends StatefulWidget {
  final String title;
  final TextStyle style;

  const StartAlignedCollapsingTitle({
    super.key,
    required this.title,
    required this.style,
  });

  @override
  State<StartAlignedCollapsingTitle> createState() => _StartAlignedCollapsingTitleState();
}

class _StartAlignedCollapsingTitleState extends State<StartAlignedCollapsingTitle> {
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _setupListener();
  }

  void _setupListener() {
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_onScroll);
  }

  void _removeListener() {
    _position?.removeListener(_onScroll);
  }

  void _onScroll() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double offset = (_position?.hasContentDimensions == true) ? _position!.pixels : 0.0;
    // Fade in as it collapses (fully visible when offset >= 52.0)
    final double opacity = (offset / 52.0).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          widget.title,
          style: widget.style.copyWith(
            fontSize: 17, // Standard collapsed title size
          ),
        ),
      ),
    );
  }
}
