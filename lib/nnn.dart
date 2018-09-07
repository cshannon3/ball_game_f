import 'dart:math';

import 'package:ball_game_f/new.dart';
import 'package:flutter/material.dart';

import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';


class LogoApp extends StatefulWidget {
  _LogoAppState createState() => _LogoAppState();
}

class _LogoAppState extends State<LogoApp> {


  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double paddingTop = 50.0;
    final double paddingBottom= 50.0;

    return  Scaffold(
        body: InnerApp3(screenSize: screenSize, paddingTop: 50.0, paddingBottom: 150.0,)
    );
  }


}

void main() {
  runApp(MaterialApp(
      home:LogoApp()));
}

class InnerApp3 extends StatefulWidget {
  final Size screenSize;
  final double paddingTop;
  final double paddingBottom;


  const InnerApp3({Key key, this.screenSize, this.paddingBottom, this.paddingTop}) : super(key: key);

  @override
  _InnerAppState createState() => new _InnerAppState();
}

class _InnerAppState extends State<InnerApp3> with TickerProviderStateMixin {

  Animation<double> animation;
  AnimationController controller;
  GravitySimulation simulation;
  BallPositionInfo ballPositionInfo;

  double minypercent;
  double maxypercent;
  //double maxydistance;
  double initxvalue;

  double currentpeakminypercent;
  double currentypercent;
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
  EdgeInsets e  = EdgeInsets.only(left: 50.0, right: 50.0);



  initState() {
    super.initState();
    print(e.right);
    ballstate = BallState.idle;
    goingleft = false;
    hit = false;
    ballPositionInfo = new BallPositionInfo();
    //  initxvalue = 0.0;
    xbound = widget.screenSize.width;
    minypercent= widget.paddingTop/widget.screenSize.height;
    currentpeakminypercent = minypercent;
    //print(minypercent);
    maxypercent =(widget.screenSize.height-widget.paddingBottom)/widget.screenSize.height;// - widget.initPosition;
    print(maxypercent);
    xvalue = 0.0;



  // Make duration not dependent on maxdistance;
    //fallingdistance = initdistance;


    acceleration = 2.0;
    currentpositiony = minypercent;
    //currentposition = Offset(0.0, minypercent);
    ballPositionInfo.currentxposition = 0.0;
    ballPositionInfo.currentyposition = minypercent;
    /* duration = Duration(milliseconds: (pow(2*initdistance/acceleration, 0.5)*1000).toInt());


    controller = AnimationController(
      duration: duration,
        vsync: this);
   // _dropBall();*/
  }

  _dropBall() {

    setState(() {
      //maxydistance = maxypercent-minypercent;
      //currentypercentmin = maxydistance;
      distancefromtopbound = 1.0-currentpeakminypercent;

      initxvalue = ballPositionInfo.currentxposition;//currentposition.dx;
      ballPositionInfo.currentxposition = 0.0;
      duration = Duration(milliseconds: (pow(2*(maxypercent-minypercent)/acceleration, 0.5)*1000).toInt());
      print(duration);
      controller = AnimationController(
          duration: duration,
          vsync: this);


    });


    simulation = GravitySimulation(
        acceleration,
        minypercent, //distancefromtopbound, // falling from
        maxypercent, // falling to
        0.0
    );
    ballstate = BallState.falling;
    animvalathit= 0.0;
    //xvalue =// initxvalue;


    animation = Tween(begin: 0.0, end: 1.0 ).animate(controller)
      ..addListener(() {
        setState(() {

          animval = animation.value;
          if(goingleft){
            if((initxvalue-animval/4)<0){
              hit = true;
              goingleft = false;
              animvalathit = animval;
              ballPositionInfo.currentxposition = 0.0;
            } else if (hit){
              ballPositionInfo.currentxposition = 1.0/*xbound*/-((animval-animvalathit)/4);
            } else{
              ballPositionInfo.currentxposition = initxvalue-animval/4;
            }
          } else {
            if((initxvalue+animval/4)>1.0/*xbound*/){
              hit = true;
              goingleft = true;
              animvalathit = animval;
              ballPositionInfo.currentxposition = 1.0; //xbound;
            } else if (hit){
              ballPositionInfo.currentxposition = (animval-animvalathit)/4;
            } else{
              ballPositionInfo.currentxposition = initxvalue+animval/4;
            }

          }


          //These values should fit duration
          velocity = simulation.dx((duration.inMilliseconds) * (animation.value / 1000));
          distancefromtopbound  = simulation.x((duration.inMilliseconds)* ((animation.value) / 1000));

          ballPositionInfo.currentyposition = distancefromtopbound;
        });
      })
      ..addStatusListener((status) {
        if (animation.isCompleted ) {
          hit=false;
       //   if (currentypercentmin > 0.01) {
            setState(() {
              switch (ballstate) {
                case BallState.falling:
                  ballstate = BallState.rising;
                  initxvalue = ballPositionInfo.currentxposition;
                 // frictionloss = 0.1;
                  bounceupvelocity = -velocity /*+ frictionloss*/;

                  duration = Duration(
                      milliseconds: (-bounceupvelocity * 1000 / acceleration)
                          .round()
                  );
                  currentpeakminypercent = maxypercent - (.5 * acceleration *
                      pow(duration.inMilliseconds / 1000, 2));
                  distancefromtopbound = currentpeakminypercent;

                  simulation = GravitySimulation(
                      acceleration,
                      maxypercent, //starting from,
                      minypercent,//distancefromtopbound, //going to,
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
                      maxypercent,
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
          } /*else {
            //progress = null;
            controller.stop();
            controller.dispose();
          }*/
      //  }
      });
    controller.forward();

  }


  dispose() {
    controller.dispose();
    super.dispose();
  }
  void _onPanStart(DragStartDetails details){
   // Offset off = Offset(ballPositionInfo.currentxposition, ballPositionInfo.currentyposition);
    dragStart = details.globalPosition;//- off;
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


      minypercent = ballPositionInfo.currentyposition;

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
    double xposition = ballPositionInfo.currentxposition * xbound;
    double yposition = ballPositionInfo.currentyposition * widget.screenSize.height;
    print("ypos $yposition");
    return new Stack(
      children: <Widget>[
        //  Positioned(
        //  top: progress!=null ? progress+ initialtop: initialtop,
        //    left: xvalue ,
        Transform(
          alignment: Alignment.topLeft,
          transform: new Matrix4.translationValues(xposition,yposition/*progress+ initialtop*/, 0.0),
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
      /*  Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: widget.paddingBottom,
            color: Colors.red,
          ),
        ),*/
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