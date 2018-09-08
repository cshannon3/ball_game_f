

import 'dart:math';

import 'package:ball_game_f/myGravitySimulation.dart';
import 'package:ball_game_f/new.dart';
import 'package:flutter/material.dart';

import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';



class InnerApp4 extends StatefulWidget {
  final Size screenSize;
  final EdgeInsets padding;




  const InnerApp4({Key key, this.screenSize,  this.padding}) : super(key: key);

  @override
  _InnerAppState createState() => new _InnerAppState();
}

class _InnerAppState extends State<InnerApp4> with TickerProviderStateMixin {

  //Animation<double> animation;
  //AnimationController controller;
  BallPositionController ballPositionInfo;

  BallState ballstate;


  Offset dragStart;
  Offset dragPosition;


  // double currentpositiony;
  Offset currentposition;
   double xposition;
   double yposition;



  initState() {
    super.initState();
    xposition = 0.0;
    yposition = 0.0;

    ballstate = BallState.idle;
    ballPositionInfo = new BallPositionController(
      minYpercent: widget.padding.top / widget.screenSize.height,
      maxYpercent: (widget.screenSize.height - widget.padding.bottom) /
          widget.screenSize.height,
      minXpercent: widget.padding.left / widget.screenSize.width,
      maxXpercent: (widget.screenSize.width - widget.padding.right) /
          widget.screenSize.width,
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          xposition =
              ballPositionInfo.currentXpercent * widget.screenSize.width;
          yposition =
              ballPositionInfo.currentYpercent * widget.screenSize.height;
        });
      });
  }


  void _onPanStart(DragStartDetails details){
    Offset off = Offset(widget.screenSize.width*ballPositionInfo.currentXpercent, widget.screenSize.height*ballPositionInfo.currentYpercent);
    dragStart = details.globalPosition- off;
    // Prevents animation from trying to start while it is already running

  }

  void _onPanUpdate(DragUpdateDetails details){
    setState(() {
      dragPosition = details.globalPosition;
      ballPositionInfo.currentXpercent = (dragPosition.dx - dragStart.dx)/widget.screenSize.width;
      ballPositionInfo.currentYpercent = (dragPosition.dy - dragStart.dy)/widget.screenSize.height;
    });
  }

  void _onPanEnd(DragEndDetails details){
    setState(() {
      Velocity v = details.velocity;
      double velocityx = v.pixelsPerSecond.dx/(widget.screenSize.width*1000);
      double velocityy = v.pixelsPerSecond.dy/(widget.screenSize.height*1000);
      ballPositionInfo.onDragEnd(velocityx, velocityy);
      //_dropBall();

    });

  }

  @override
  Widget build(BuildContext context) {
    double xposition = ballPositionInfo.currentXpercent * widget.screenSize.width;
    double yposition = ballPositionInfo.currentYpercent * widget.screenSize.height;
    return new Stack(
      children: <Widget>[
        Transform(
          alignment: Alignment.topLeft,
          transform: new Matrix4.translationValues(xposition, yposition, 0.0),
          child:
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            height: 50.0, //animation.value,
            width: 50.0, //animation.value,
            child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: FlutterLogo()
            ),
          ),
        ),
  /*      Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: widget.padding.bottom,
            color: Colors.red,
          ),
        ),*/
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.topRight,
            child: RaisedButton(
                onPressed: () {/*_dropBall(); */ }
            ),
          ),
        ),


      ],


    );
  }
}

enum BallState
{
  idle,
  rising,
  falling,
  bouncing,
  dragging,
}


class BallPositionController extends ChangeNotifier{


  final TickerProvider _vsync;

  BallState _state = BallState.idle;
  double _velocityx;
  double _velocityy = 0.0;
  double _minYpercent ;
  double _maxYpercent;
  double _currentYpercent=0.0;
  double _currentpeakminYpercent;

  double _minXpercent ;
  double _maxXpercent;
  double _currentXpercent=0.0;

  double _xvalueatanimationstart;
  double animationvalueatwallhit;

  double _animationvalue;


  double _bounceupvelocity;
  bool _goingleft = false;
  bool _hit;

  Duration _duration;

  GravitySimulation _simulationfalling;

  MyGravitySimulation _simulationrising;



  double _frictionloss = 0.0;
  final double _acceleration = 0.001;
  double yinit;
  double bouncetime = 0.0;
  double initvelocity = 0.0;



  Ticker _Ticker;

  double _tickerTime;

  BallPositionController({
    double minYpercent = 0.0,
    double maxYpercent=1.0,
    double minXpercent=0.0,
    double maxXpercent= 1.0,
    vsync,
  })
      : _vsync = vsync,
        _minYpercent = minYpercent,
        _maxYpercent = maxYpercent,
        _minXpercent = minXpercent,
        _maxXpercent = maxXpercent;





  double get acceleration => _acceleration;

  Duration get duration => _duration;

/*
  Y Related values


  set minYpercent(double newValue){
    _minYpercent = newValue;
    _currentpeakminYpercent = _minYpercent;
    _currentYpercent = _minYpercent;
    notifyListeners();
  }

  set maxYpercent(double newValue){
    _maxYpercent = newValue;
    notifyListeners();
  }
  */

  set currentpeakminYpercent(double newValue){
    _currentpeakminYpercent = newValue;
    yinit = _currentpeakminYpercent;
    _currentYpercent = _minYpercent;
    notifyListeners();
  }

  double get currentYpercent => _currentYpercent;

  set currentYpercent(double newValue){
    _currentYpercent = newValue;
    notifyListeners();
  }
  /*
  X Related Values

   */
  set maxXpercent(double newValue){
    _maxXpercent = newValue;
    notifyListeners();
  }
  set minXpercent(double newValue){

    _minXpercent = newValue;
    _currentXpercent = _minXpercent;

    notifyListeners();
  }

  set xvalueatanimationstart(double newValue){

    _xvalueatanimationstart = newValue;
    // _currentXpercent = _xvalueatanimationstart;

    notifyListeners();
  }

  double get currentXpercent => _currentXpercent;


  set currentXpercent(double newValue){
    _currentXpercent = newValue;
    notifyListeners();
  }


  void Falling() {
    print("max velocity ${pow(2*_acceleration*(_maxYpercent), 0.5)}");

    _hit = false;
    animationvalueatwallhit = 0.0;
    //_currentYpercent = _maxydistance - _currentydistance;
    _xvalueatanimationstart = _currentXpercent;

    notifyListeners();
    _dropBall();
  }

  void Rising(){
    print("hello");
    _hit = false;
    //_maxydistance =  _maxYpercent - _minYpercent;
    double maxv = pow(2*_acceleration*(_maxYpercent), 0.5);
    _bounceupvelocity = -_velocityy+ _frictionloss;
    double bounceheight = (-_bounceupvelocity<maxv)
        ? (pow(_bounceupvelocity,2)/(2*_acceleration))
        : _maxYpercent-_minYpercent;


  //  print(_bounceupvelocity);
    //print(bounceheight);
    _currentpeakminYpercent = _maxYpercent - bounceheight;
    print("cure $_currentpeakminYpercent");
   /* double time = 2*bounceheight/(_bounceupvelocity+pow(pow(_bounceupvelocity,2)+2*_acceleration*bounceheight,0.5));
    print("Rising ${time*1000}");


    _duration = Duration(
        milliseconds:// (-_bounceupvelocity * 1000 / _acceleration)
        (time*1000)
            .round()
    );
    // print(duration.inMilliseconds);


*/
    animationvalueatwallhit = 0.0;
    //  _currentYpercent = _currentpeakminYpercent;
    _xvalueatanimationstart = _currentXpercent;


    notifyListeners();
    _dropBall();
  }

  bool isStopped(){
    if (_maxYpercent-_currentpeakminYpercent < 0.05) {
      return true;
    }else {
      return false;
    }


  }

  void onDragStart() {
    if (_Ticker != null){
      _Ticker
        ..stop()
          ..dispose();
    }
    _state = BallState.dragging;

  }
  void onDragEnd(double velocityx, double velocityy){
    _state  = (velocityy>0)
          ? BallState.falling
          : BallState.rising;
    _state = BallState.falling;
    _currentpeakminYpercent = _currentYpercent;
    yinit = _currentYpercent;
    _xvalueatanimationstart = _currentXpercent;
    //_velocityy = velocityy;
    _velocityx = velocityx;
   // print(_currentYpercent);
    notifyListeners();
    _dropBall();



  }

  void _dropBall(){

   /* print("Currentpeak $_currentpeakminYpercent");
    _simulationfalling = GravitySimulation(
      (_state==BallState.falling) ?  _acceleration: _acceleration,
      (_state==BallState.falling) ? 0.1/*_currentpeakminYpercent*/: _maxYpercent,//-_maxYpercent,
         (_state==BallState.falling) ? _maxYpercent:  _currentpeakminYpercent,
      (_state==BallState.falling) ? 0.0:_bounceupvelocity ,
      //  (_state==BallState.falling) ? false: true,

    );*/
    _simulationrising = MyGravitySimulation(
      _acceleration,
      _currentpeakminYpercent,
      0.0,
    );

    _tickerTime = 0.0;
    //print(_tickerTime);

    _Ticker = _vsync.createTicker(_springTick)..start();

  }

  void _springTick(Duration deltaTime) {
    _currentYpercent = yinit + initvelocity*(_tickerTime)+0.5*_acceleration*(_tickerTime)*(_tickerTime);
    _velocityy = initvelocity + (_tickerTime)*_acceleration;
    if(_currentYpercent>=(_maxYpercent-0.03)){
      _tickerTime= 0.0;
      initvelocity = -_velocityy+0.001;
      yinit = _maxYpercent;

    }
    _tickerTime += deltaTime.inMilliseconds.toDouble() / 1000.0;


    /* else if (_currentYpercent<=_minYpercent){
     // _Ticker.stop();

     // _Ticker.start();
    }*/
  //  print(_currentYpercent);


    // set action if the spring is done
  /*  if(_simulationrising.isDone(_tickerTime)) {

     /* if (isStopped()) {
        _Ticker
          ..stop()
          ..dispose();
        _Ticker = null;
        _state = BallState.idle;
      } else {*/
      print("prob $_tickerTime");
        _Ticker
          ..stop()
        ..dispose();
      _Ticker = null;
       // _tickerTime = 0.0;

        //}
        switch (_state) {
          case BallState.falling:

            _state = BallState.rising;
            notifyListeners();
            Rising();
            break;

          case BallState.rising:
            _state = BallState.falling;
            notifyListeners();
            Falling();
            break;

          case BallState.idle:
            break;
          case BallState.bouncing:
            break;
          case BallState.dragging:
            break;
        }
      }
    //}
*/
    notifyListeners();
  }

}