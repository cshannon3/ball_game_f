import 'dart:math';

import 'package:ball_game_f/new.dart';
import 'package:ball_game_f/nnn.dart';
import 'package:ball_game_f/ppp.dart';
import 'package:flutter/material.dart';

import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';


class LogoApp extends StatefulWidget {
  _LogoAppState createState() => _LogoAppState();
}

class _LogoAppState extends State<LogoApp> {


  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenheight = MediaQuery.of(context).size.height;
    final double screenwidth = MediaQuery.of(context).size.width;

    return  Scaffold(
       // body: InnerApp(screenHeight: screenheight, screenwidth: screenwidth-50.0, initPosition: 50.0,)
     //   body: InnerApp3(screenSize: screenSize, paddingBottom: 150.0, paddingTop: 50.0,)
    //  body: InnerApp2(screenSize: screenSize,padding: EdgeInsets.symmetric(vertical: 150.0, horizontal: 50.0),),
      body: InnerApp4(screenSize: screenSize,padding: EdgeInsets.symmetric(vertical: 150.0, horizontal: 50.0),),
    );
  }


}

void main() {
  runApp(MaterialApp(
      home:LogoApp()));
}

class InnerApp extends StatefulWidget {
  final double screenHeight;
  final double initPosition;
  final double screenwidth;

  const InnerApp({Key key, this.screenHeight, this.initPosition, this.screenwidth}) : super(key: key);

  @override
  _InnerAppState createState() => new _InnerAppState();
}

class _InnerAppState extends State<InnerApp> with TickerProviderStateMixin {

  Animation<double> animation;
  AnimationController controller;
  GravitySimulation simulation;
  BallPositionInfo ballPositionInfo;

  double topbound;
  double bottombound;
  double maxydistance;
  double initxvalue;

  double currentydistance;
  double distancefromtopbound;


  BallState ballstate;
  double animval;
  double xvalue;
  double animvalathit;
 // double progress;
  double velocity;
  double bounceupvelocity;
  bool goingleft;
  bool hit;

  double xbound;


  double frictionloss;

  Duration duration;
  double acceleration;


  Offset dragStart;
  Offset dragPosition;
  double currentpositiony;
  Offset currentposition;



  initState() {
    super.initState();
    ballstate = BallState.idle;
    goingleft = false;
    hit = false;

  //  initxvalue = 0.0;
    xbound = widget.screenwidth;
    topbound= widget.initPosition;
    bottombound =widget.screenHeight;// - widget.initPosition;

    xvalue = 0.0;




    //fallingdistance = initdistance;
    ballPositionInfo = new BallPositionInfo();

    acceleration = 1540.0;
    currentpositiony = topbound;
    currentposition = Offset(0.0, topbound);
    ballPositionInfo.currentxposition = 0.0;
    ballPositionInfo.currentyposition = topbound;
   /* duration = Duration(milliseconds: (pow(2*initdistance/acceleration, 0.5)*1000).toInt());


    controller = AnimationController(
      duration: duration,
        vsync: this);
   // _dropBall();*/
  }

  _dropBall() {

    setState(() {
      maxydistance = bottombound-topbound;
      currentydistance = maxydistance;
      distancefromtopbound = maxydistance-currentydistance;


      initxvalue = ballPositionInfo.currentxposition;//currentposition.dx;
      ballPositionInfo.currentxposition = 0.0;
      duration = Duration(milliseconds: (pow(2*maxydistance/acceleration, 0.5)*1000).toInt());
      print(duration);
      controller = AnimationController(
          duration: duration,
          vsync: this);


    });


    simulation = GravitySimulation(
        acceleration,
        distancefromtopbound, // falling from
        maxydistance, // falling to
        0.0
    );
     ballstate = BallState.falling;
     animvalathit= 0.0;
     //xvalue =// initxvalue;


      animation = Tween(begin: 0.0, end: 1.0/*maxydistance */).animate(controller)
        ..addListener(() {
        setState(() {

          animval = animation.value*maxydistance;
          if(goingleft){
            if((initxvalue-animval/4)<0){
              hit = true;
              goingleft = false;
              animvalathit = animval;
              ballPositionInfo.currentxposition = 0.0;
            } else if (hit){
              ballPositionInfo.currentxposition = xbound-((animval-animvalathit)/4);
            } else{
              ballPositionInfo.currentxposition = initxvalue-animval/4;
            }
          } else {
            if((initxvalue+animval/4)>xbound){
              hit = true;
              goingleft = true;
              animvalathit = animval;
              ballPositionInfo.currentxposition = xbound;
            } else if (hit){
              ballPositionInfo.currentxposition = (animval-animvalathit)/4;
            } else{
              ballPositionInfo.currentxposition = initxvalue+animval/4;
            }

          }


         //These values should fit duration
          velocity = simulation.dx((duration.inMilliseconds/*/maxydistance*/) * (animation.value / 1000));
          distancefromtopbound  = simulation.x((duration.inMilliseconds/*/maxydistance*/) * ((animation.value) / 1000));
          print(distancefromtopbound);
          ballPositionInfo.currentyposition = distancefromtopbound + topbound;
          //double fractionaldistance = newdistance/initdistance;

        //  velocity = simulation.dx((duration.inMilliseconds/newdistance/*initdistance*/) * (fractionaldistance*animation.value / 1000));
         // progress = simulation.x((duration.inMilliseconds/newdistance/*initdistance*/) * ((fractionaldistance*animation.value) / 1000));
        });
      })
      ..addStatusListener((status) {
        if (animation.isCompleted ) {
          hit=false;
          if (currentydistance > 10.0) {
            setState(() {

              switch (ballstate) {
                case BallState.falling:
                  ballstate = BallState.rising;
                  initxvalue = ballPositionInfo.currentxposition;
                  frictionloss = 50.0;
                  bounceupvelocity = -velocity + frictionloss;

                  duration = Duration(
                      milliseconds: (-bounceupvelocity * 1000 / acceleration)
                          .round()
                  );
                  currentydistance = .5 * acceleration *
                      pow(duration.inMilliseconds / 1000, 2);
                  distancefromtopbound = maxydistance-currentydistance;

                  simulation = GravitySimulation(
                      acceleration,
                      maxydistance, //starting from,
                      distancefromtopbound, //going to,
                      bounceupvelocity
                  );
                  break;

                case BallState.rising:
                  ballstate = BallState.falling;
                  initxvalue = ballPositionInfo.currentxposition;

                  //fallingfrom = progress;

                  simulation = GravitySimulation(
                      acceleration,
                      distancefromtopbound,
                      maxydistance,
                      0.0
                  );
                  break;

                case BallState.idle:
                  break;
                case BallState.bouncing:
                  break;
              }

              controller.duration = duration;
              controller.reset();
              controller.forward();
            });
          } else {
            //progress = null;
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
    Offset off = Offset(ballPositionInfo.currentxposition, ballPositionInfo.currentyposition);
    dragStart = details.globalPosition- off;
    // Prevents animation from trying to start while it is already running

  }

  void _onPanUpdate(DragUpdateDetails details){
    setState(() {
      dragPosition = details.globalPosition;
      ballPositionInfo.currentxposition = (dragPosition.dx - dragStart.dx);
      ballPositionInfo.currentyposition = (dragPosition.dy - dragStart.dy);



     /* if (null != widget.onSlideUpdate) {
        // This keeps the parent up to date on any sliding
        widget.onSlideUpdate(cardOffset.distance);
      }*/
    });
  }

  void _onPanEnd(DragEndDetails details){
    setState(() {
      Velocity v = details.velocity;
      v.pixelsPerSecond.dx;
      print(v.pixelsPerSecond.dx);


      topbound = ballPositionInfo.currentyposition;

    });
    //Want to keep sliding direction that user was sliding if it is liked/disliked
   /* final dragVector = cardOffset / cardOffset.distance;
    //Dislike region
    final isInLeftRegion = (cardOffset.dx / context.size.width) < -0.45;
    final isInRightRegion = (cardOffset.dx / context.size.width) > 0.45;
    final isInTopRegion = (cardOffset.dy / context.size.height) < -0.40;

    setState(() {
      if (isInLeftRegion || isInRightRegion) {
        // using context.size to adapt the app to different screen sizes
        slideOutTween = new Tween(begin: cardOffset, end: dragVector * (2 * context.size.width));
        slideOutAnimation.forward(from: 0.0);

        slideOutDirection = isInLeftRegion ? SlideDirection.left : SlideDirection.right;
      } else if (isInTopRegion) {
        slideOutTween = new Tween(begin: cardOffset, end: dragVector * (2 * context.size.height));
        slideOutAnimation.forward(from: 0.0);

        slideOutDirection = SlideDirection.up;
      } else {
        // If not in any of the regions it will slide beack to the middle
        slideBackStart = cardOffset;
        slideBackAnimation.forward(from: 0.0);
      }
    });


*/
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
      //  Positioned(
        //  top: progress!=null ? progress+ initialtop: initialtop,
      //    left: xvalue ,
    Transform(
      alignment: Alignment.topLeft,
      transform: new Matrix4.translationValues(ballPositionInfo.currentxposition,ballPositionInfo.currentyposition /*progress+ initialtop*/, 0.0),
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
    height: 150.0,
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
  double _currentxposition;
  double _currentyposition;
  double _velocityx;
  double _velocityy;
  double _acceleration;

  double get currentxposition => _currentxposition;
  set currentxposition(double newValue){
    _currentxposition = newValue;
    notifyListeners();
  }

  double get currentyposition => _currentyposition;
  set currentyposition(double newValue){
    _currentyposition = newValue;
    notifyListeners();
  }


}