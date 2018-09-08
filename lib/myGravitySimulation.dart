import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// A simulation that applies a constant accelerating force.
///
/// Models a particle that follows Newton's second law of motion. The simulation
/// ends when the position reaches a defined point.
///
/// ## Sample code
///
/// This method triggers an [AnimationController] (a previously constructed
/// `_controller` field) to simulate a fall of 300 pixels.
///
/// ```dart
/// void _startFall() {
///   _controller.animateWith(new GravitySimulation(
///     10.0, // acceleration, pixels per second per second
///     0.0, // starting position, pixels
///     300.0, // ending position, pixels
///     0.0, // starting velocity, pixels per second
///   ));
/// }
/// ```
///
/// This [AnimationController] could be used with an [AnimatedBuilder] to
/// animate the position of a child as if it was falling.
///
/// See also:
///
///  * [Curves.bounceOut], a [Curve] that has a similar aesthetics but includes
///    a bouncing effect.
class MyGravitySimulation  extends ChangeNotifier {
  /// Creates a [GravitySimulation] using the given arguments, which are,
  /// respectively: an acceleration that is to be applied continually over time;
  /// an initial position relative to an origin; the magnitude of the distance
  /// from that origin beyond which (in either direction) to consider the
  /// simulation to be "done", which must be positive; and an initial velocity.
  ///
  /// The initial position and maximum distance are measured in arbitrary length
  /// units L from an arbitrary origin. The units will match those used for [x].
  ///
  /// The time unit T used for the arguments to [x], [dx], and [isDone],
  /// combined with the aforementioned length unit, together determine the units
  /// that must be used for the velocity and acceleration arguments: L/T and
  /// L/T² respectively. The same units of velocity are used for the velocity
  /// obtained from [dx].
  MyGravitySimulation(
      double acceleration, // (percent/millisecond^2)
      double startpercent,
    //  double groundpercent,
      //double toppercent,
      double velocity, // (percent/millisecond)
    //  double minbounceheight,

      ) : assert(acceleration != null),
        assert(startpercent != null),
        assert(velocity != null),
    //    assert(groundpercent != null),
       // assert(toppercent !=null),
     //   assert(groundpercent>toppercent),

        _a = acceleration,
        _y = startpercent,
        _v = velocity;
     // _top = toppercent,
    //  _bottom = groundpercent,
      //  _yfinal = minbounceheight;
        //_rising = rising;

  double _y;
  double _v;
  final double _a;
//  final double _yfinal;
  //final double _top;
  //final double _bottom;
  double _bouncetime = 0.0;


  void onBounce(double bouncetime, double bouncevelocity, double bottom){
    _bouncetime = bouncetime;
    _v = bouncevelocity;
    _y = bottom;
    notifyListeners();
    print("bouncetime");
  }

  @override
  double y(double time) => _y + _v * (time-_bouncetime) + 0.5 * _a * (time-_bouncetime) * (time-_bouncetime);

  @override
  double dy(double time) => _v + (time-_bouncetime) * _a;

  @override
  bool isDone(double time) =>  time>= 10000.0; //y(time).abs() <= _yfinal;



}