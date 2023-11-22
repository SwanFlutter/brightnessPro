import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BrightnessProDragDirection extends StatefulWidget {
  final double width;
  final double height;
  final double? textFontSize;
  final Color? textColor;
  final Color? iconColor;
  final IconData? brightnessIcon;
  const BrightnessProDragDirection({
    super.key,
    Key? thisKey,
    this.textFontSize,
    this.textColor,
    this.iconColor,
    this.brightnessIcon,
    this.width = 50,
    this.height = 250,
  });

  @override
  State<BrightnessProDragDirection> createState() =>
      _BrightnessProDragDirectionState();
}

class _BrightnessProDragDirectionState extends State<BrightnessProDragDirection> {
  double _brightnessLevel = 0.5;
  final double _brightnessIncrement = 0.05;
  double _opacityIcons = 0;
  double _opacityText = 0;
  late Timer _timer;

  Future<void> setBrightness(double brightness) async {
    try {
      double brightnessValue =
      brightness.clamp(0.0, 0.9); // Clamp the value between 0 and 0.9
      await ScreenBrightness().setScreenBrightness(brightnessValue);
      setState(() {
        _brightnessLevel =
        (brightnessValue * 100); // Convert to a percentage for display
      });
    } catch (e) {
      if (kDebugMode) {
        print(kDebugMode);
      }
      throw Exception('Failed to set brightness');
    }
  }

  void increaseBrightness() {
    double newLevel = _brightnessLevel + _brightnessIncrement;
    if (newLevel <= 90) {
      setBrightness(
          newLevel / 100); // Convert back to a value between 0 and 0.9
    }
  }

  void decreaseBrightness() {
    double newLevel = _brightnessLevel - _brightnessIncrement;
    if (newLevel >= 0) {
      setBrightness(
          newLevel / 100); // Convert back to a value between 0 and 0.9
    }
  }

  @override
  void initState() {
    super.initState();
    setBrightness(_brightnessLevel);
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _opacityIcons = 0;
        _opacityText = 0;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdateHandler,
      behavior: HitTestBehavior.translucent,
      dragStartBehavior: DragStartBehavior.start,
      onVerticalDragEnd: _onVerticalDragEndHandler,
      child: Column(
        children: [
          AnimatedOpacity(
            opacity: _opacityIcons,
            duration: const Duration(milliseconds: 700),
            child: Icon(
              widget.brightnessIcon ?? CupertinoIcons.brightness_solid,
              size: 50,
              color: widget.iconColor ?? Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 5.0),
          AnimatedOpacity(
            opacity: _opacityText,
            duration: const Duration(milliseconds: 300),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                "${_brightnessLevel.toStringAsFixed(0)}%",
                style: TextStyle(
                  fontSize: widget.textFontSize ??
                      Theme.of(context).textTheme.bodyMedium!.fontSize,
                  color: widget.textColor ?? Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onVerticalDragUpdateHandler(DragUpdateDetails details) {
    double dragPercentage = 1 - (details.localPosition.dy / widget.height);
    setBrightness(dragPercentage);
    setState(() {
      _opacityIcons = 1;
      _opacityText = 1;
      _timer.cancel();
      _timer = Timer(const Duration(seconds: 3), () {
        setState(() {
          _opacityIcons = 0;
          _opacityText = 0;
        });
      });
    });
  }

  void _onVerticalDragEndHandler(DragEndDetails details) {
    setState(() {
      _brightnessLevel;
    });
  }
}
