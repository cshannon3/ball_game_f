import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';



class InnerApp2 extends StatefulWidget {
  final Size screenSize;
  final EdgeInsets padding;




  const InnerApp2({Key key, this.screenSize,  this.padding}) : super(key: key);

  @override
  _InnerAppState createState() => new _InnerAppState();
}

class _InnerAppState extends State<InnerApp2> with TickerProviderStateMixin {

  Animation<double> animation;
  AnimationController controller;
  BallPositionInfo ballPositionInfo;

  BallState ballstate;


  Offset dragStart;
  Offset dragPosition;


 // double currentpositiony;
  Offset currentposition;
 // double topBound;
 // double bottombound;



  initState() {
    super.initState();

    ballstate = BallState.idle;
    ballPositionInfo = new BallPositionInfo();
   ballPositionInfo.minYpercent = widget.padding.top/widget.screenSize.height;
    ballPositionInfo.maxYpercent = (widget.screenSize.height-widget.padding.bottom)/widget.screenSize.height;
    ballPositionInfo.maxXpercent = (widget.screenSize.width- widget.padding.right)/widget.screenSize.width;
    ballPositionInfo.minXpercent = widget.padding.left/widget.screenSize.width;

    ballPositionInfo.addListener((){
      setState(() {

      });
    });
    controller = AnimationController(
        vsync: this);


    //acceleration = 1540.0;
   // currentpositiony = topbound;
   // currentposition = Offset(0.0, topbound);
    //ballPositionInfo.currentxposition = 0.0;
    //ballPositionInfo.currentyposition = topbound;
    /* duration = Duration(milliseconds: (pow(2*initdistance/acceleration, 0.5)*1000).toInt());



    controller = AnimationController(
      duration: duration,
        vsync: this);
   // _dropBall();*/
  }

  _dropBall() {
    setState(() {
      ballstate = BallState.falling;
      ballPositionInfo.Falling();
     // print(ballPositionInfo.duration);
      controller.duration = ballPositionInfo.duration;
    });



    animation = Tween(begin: 0.0, end: 1.0 ).animate(controller)
      ..addListener(() {
        setState(() {
          ballPositionInfo.animationvalue = animation.value;

        });
      })
      ..addStatusListener((status) {
        if (animation.isCompleted ) {

          if (!ballPositionInfo.isStopped()/*currentpeakminYpercent*/) {
            setState(() {
              switch (ballstate) {
                case BallState.falling:
                  ballstate = BallState.rising;
                  ballPositionInfo.Rising();
                  break;

                case BallState.rising:
                  ballstate = BallState.falling;
                  ballPositionInfo.Falling();
                  break;

                case BallState.idle:
                  break;
                case BallState.bouncing:
                  break;
              }

              controller.duration = ballPositionInfo.duration;
              controller.reset();
              controller.forward();
            });
          } else {
            controller.stop();
            controller.dispose();
          }
       }
      });
    controller.forward();

  }


  dispose() {
    controller.dispose();
    super.dispose();
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
      double velocityx = v.pixelsPerSecond.dx/widget.screenSize.width;
      double velocityy = v.pixelsPerSecond.dy/widget.screenSize.height;
      ballPositionInfo.onPanEnd(velocityx, velocityy);
      _dropBall();

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
       Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: widget.padding.bottom,
            color: Colors.red,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.topRight,
            child: RaisedButton(
                onPressed: () {_dropBall();  }
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
}


class BallPositionInfo extends ChangeNotifier{

  double _velocityx;
  double _velocityy;
  double _minYpercent = 0.0;
  double _maxYpercent = 0.0;
  double _currentYpercent;
  double _currentpeakminYpercent;

  double _minXpercent = 0.0;
  double _maxXpercent = 0.0;
  double _currentXpercent = 0.0;

  double _xvalueatanimationstart;
  double animationvalueatwallhit;

  double _animationvalue;




  double _bounceupvelocity;
  bool _goingleft = false;
  bool _hit;

  Duration _duration;

  GravitySimulation _simulation;



  double _frictionloss = 0.0;
  final double _acceleration = 2.0;


  double get acceleration => _acceleration;

  Duration get duration => _duration;

/*
  Y Related values

  */
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

  set currentpeakminYpercent(double newValue){
    _currentpeakminYpercent = newValue;
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



  set animationvalue(double newValue) {
    _animationvalue=newValue;

    if(_goingleft){
      if((_xvalueatanimationstart-_velocityx*_animationvalue)<=_minXpercent){
        _hit = true;
        _goingleft = false;
        animationvalueatwallhit = _animationvalue;
        _currentXpercent = _minXpercent;
      } else if (_hit){
        _currentXpercent = _maxXpercent-((_animationvalue-animationvalueatwallhit)*_velocityx);
      } else{
        _currentXpercent = _xvalueatanimationstart-_animationvalue*_velocityx;
      }
    } else {
      if((_xvalueatanimationstart+_animationvalue*_velocityx)>=_maxXpercent){
        _hit = true;
        _goingleft = true;
        animationvalueatwallhit = _animationvalue;
        _currentXpercent = _maxXpercent;
      } else if (_hit){
        _currentXpercent = _minXpercent + (_animationvalue-animationvalueatwallhit)*_velocityx;
      } else{
        _currentXpercent = _xvalueatanimationstart+_animationvalue*_velocityx;
      }

    }
   /* if(_goingleft){
      if((_xvalueatanimationstart-_animationvalue/4)<_minXpercent){
        _hit = true;
        _goingleft = false;
        animationvalueatwallhit = _animationvalue;
        _currentXpercent = _minXpercent;
      } else if (_hit){
        _currentXpercent = _maxXpercent-((_animationvalue-animationvalueatwallhit)/4);
      } else{
        _currentXpercent = _xvalueatanimationstart-_animationvalue/4;
      }
    } else {
      if((_xvalueatanimationstart+_animationvalue/4)>_maxXpercent){
        _hit = true;
        _goingleft = true;
        animationvalueatwallhit = _animationvalue;
        _currentXpercent = _maxXpercent;
      } else if (_hit){
        _currentXpercent = _minXpercent + (_animationvalue-animationvalueatwallhit)/4;
      } else{
       _currentXpercent = _xvalueatanimationstart+_animationvalue/4;
      }

    }*/

    _velocityy = _simulation.dx((_duration.inMilliseconds) * (_animationvalue / 1000));
    print(_velocityy);
    _currentYpercent  = _simulation.x((_duration.inMilliseconds) * ((_animationvalue) / 1000));
    print(_currentYpercent);
  notifyListeners();
  }

   void Falling() {
     print("max velocity ${pow(2*_acceleration*(_maxYpercent), 0.5)}");
    // if (_duration==null) {
     if (_velocityy<0){ _velocityy=_velocityy*-1;}
       double distancetoground = _maxYpercent-_currentpeakminYpercent;// distancetoground in percent
       double time = 2*distancetoground/(_velocityy+pow(pow(_velocityy,2)+2*_acceleration*distancetoground,0.5));
       _duration =
       Duration(
           milliseconds: (/*pow(2 *(_maxYpercent-_currentpeakminYpercent) / _acceleration, 0.5) */ time* 1000)
               .toInt());
   //  }

     print("falling ${time*1000}");
    _hit = false;
    animationvalueatwallhit = 0.0;
    //_currentYpercent = _maxydistance - _currentydistance;
    _xvalueatanimationstart = _currentXpercent;

    _simulation = GravitySimulation(
        _acceleration,
        _currentpeakminYpercent, // falling from
        _maxYpercent, // falling to
        _velocityy,
    );
    notifyListeners();
  }
    void Rising(){
      _hit = false;
      //_maxydistance =  _maxYpercent - _minYpercent;
      double maxv = pow(2*_acceleration*(_maxYpercent), 0.5);
      _bounceupvelocity = -_velocityy+ _frictionloss;
      double bounceheight = (-_bounceupvelocity<maxv)
       ? (pow(_bounceupvelocity,2)/(2*_acceleration))
      : _maxYpercent-_minYpercent;


      print(_bounceupvelocity);
      print(bounceheight);
      _currentpeakminYpercent = _maxYpercent- bounceheight;
      double time = 2*bounceheight/(_bounceupvelocity+pow(pow(_bounceupvelocity,2)+2*_acceleration*bounceheight,0.5));
      print("Rising ${time*1000}");


      _duration = Duration(
          milliseconds:// (-_bounceupvelocity * 1000 / _acceleration)
          (time*1000)
              .round()
      );
     // print(duration.inMilliseconds);



      animationvalueatwallhit = 0.0;
    //  _currentYpercent = _currentpeakminYpercent;
      _xvalueatanimationstart = _currentXpercent;

      _simulation = GravitySimulation(
          _acceleration,
          _maxYpercent,// _which should be _currentYpercent, // rising from
          _currentpeakminYpercent, // rising to
          _bounceupvelocity
      );

      notifyListeners();
    }

    bool isStopped(){
      if (_maxYpercent-_currentpeakminYpercent < 0.05) {
        return true;
      }else {
        return false;
      }


    }

    void onPanEnd(double velocityx, double velocityy){
      _currentpeakminYpercent = _currentYpercent;
      _xvalueatanimationstart = _currentXpercent;
      _velocityy = velocityy;
      _velocityx = velocityx;

      notifyListeners();
    }

}