// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'container_hand.dart';
import 'drawn_hand.dart';

/// Total distance traveled by a milisecond
final radiansPerMili = radians(360 / (1000 * 60));

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _condition = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _condition = widget.model.weatherString;
    });
  }

  String _getHour(DateTime now) {
    return DateFormat('kk').format(now).toString();
  }

  String _getMinute(DateTime now) {
    return DateFormat('mm').format(now).toString();
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(milliseconds: 10),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).copyWith(
      primaryColor: Color(0xFFD2E3FC),
      highlightColor: Color(0xFF4285F4),
      accentColor: Color(0xFF8AB4F8),
      backgroundColor: Color(0xFF181726),
    );

    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature,
              style: GoogleFonts.robotoCondensed(
                  fontSize: 21.0, color: Colors.white70)),
          Text(_condition,
              style: GoogleFonts.roboto(fontSize: 21.0, color: Colors.white70)),
        ],
      ),
    );

    final clockInfo = RichText(
      text: TextSpan(
        style: GoogleFonts.quicksand(fontSize: 36.0),
        children: [
          TextSpan(text: _getHour(_now)),
          TextSpan(
            text: ":",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _now.second % 2 == 0
                    ? customTheme.backgroundColor
                    : Colors.white),
          ),
          TextSpan(text: _getMinute(_now)),
        ],
      ),
    );

    final dateInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(DateFormat('EEE').format(_now).toString().toUpperCase(),
            style: GoogleFonts.raleway(fontSize: 32.0, color: Colors.white54)),
        Text(DateFormat('d MMM').format(_now).toString(),
            style: GoogleFonts.raleway(fontSize: 24.0, color: Colors.white54)),
      ],
    );

    return Container(
      color: customTheme.backgroundColor,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: weatherInfo,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: clockInfo,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: dateInfo,
            ),
          ),
          DrawnHand(
            color: customTheme.accentColor,
            thickness: 2,
            size: 0.95,
            angleRadians: (_now.millisecond * radiansPerMili) +
                (_now.second * radiansPerTick),
          ),
          ContainerHand(
            color: Colors.transparent,
            size: 0.5,
            angleRadians: (_now.second * radiansPerTick / 60) +
                (_now.minute * radiansPerTick),
            child: Transform.translate(
              offset: Offset(0.0, -90),
              child: Container(
                width: 16,
                height: 205,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25), bottom: Radius.circular(15)),
                  color: customTheme.highlightColor,
                ),
              ),
            ),
          ),
          ContainerHand(
            color: Colors.transparent,
            size: 0.5,
            angleRadians: (_now.hour * radiansPerHour) +
                (_now.minute / 60) * radiansPerHour,
            child: Transform.translate(
              offset: Offset(0.0, -50.0),
              child: Container(
                width: 30,
                height: 135,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25), bottom: Radius.circular(15)),
                  color: customTheme.primaryColor,
                ),
              ),
            ),
          ),
          Center(
            child: CircleAvatar(
              radius: 4,
            ),
          ),
        ],
      ),
    );
  }
}
