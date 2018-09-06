import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';


class LogoApp extends StatefulWidget {
  _LogoAppState createState() => _LogoAppState();
}

class _LogoAppState extends State<LogoApp> {


  Widget build(BuildContext context) {
    final double screenheight = MediaQuery.of(context).size.height;
    final double screenwidth = MediaQuery.of(context).size.width;
    print(screenheight);
    return  Scaffold(
        body: InnerApp(screenHeight: screenheight-200.0, screenwidth: screenwidth-50.0, initPosition: 50.0,)
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

class _InnerAppState extends State<InnerApp> with SingleTickerProviderStateMixin {

  Animation<double> animation;
  AnimationController controller;
  GravitySimulation simulation;

  double initialtop;
  double initialbottom;
  double initdistance;
  double initxvalue;

  double newdistance;

  double fallingfrom;
  double fallingto;
  double fallingdistance;

  double risingto;
  double risingfrom;

  BallState ballstate;
  double animval;
  double xvalue;
  double animvalathit;
  double progress;
  double velocity;
  double bounceupvelocity;
  bool goingleft;
  bool hit;

  double xbound;


  double frictionloss;

  Duration duration;
  double acceleration;


  initState() {
    super.initState();
    ballstate = BallState.idle;
    goingleft = false;
    hit = false;

    initxvalue = 0.0;
    xbound = widget.screenwidth;
    initialtop= widget.initPosition;
    initialbottom =widget.screenHeight;// - widget.initPosition;
    initdistance = initialbottom-initialtop;
    newdistance = initdistance;


    fallingfrom = initialtop;
    fallingto = initialbottom; //Distance final
    fallingdistance = initdistance;

    acceleration = 1540.0;

    duration = Duration(milliseconds: (pow(2*initdistance/acceleration, 0.5)*1000).toInt());

    simulation = GravitySimulation(
        acceleration,
        0.0,
        fallingdistance,
        0.0
    );
    controller = AnimationController(
        duration: duration, vsync: this);
    _dropBall();
  }

  _dropBall() {
     ballstate = BallState.falling;
     animvalathit= 0.0;
     xvalue = initxvalue;


      animation = Tween(begin: 0.0, end: initdistance ).animate(controller)
        ..addListener(() {
        setState(() {
          animval = animation.value;
          if(goingleft){
            if((initxvalue-animval/4)<0){
              hit = true;
              goingleft = false;
              animvalathit = animval;
              xvalue = 0.0;
            } else if (hit){
              xvalue = xbound-((animval-animvalathit)/4);
            } else{
              xvalue = initxvalue-animval/4;
            }
          } else {
            if((initxvalue+animval/4)>xbound){
              hit = true;
              goingleft = true;
              animvalathit = animval;
              xvalue = xbound;
            } else if (hit){
              xvalue = (animval-animvalathit)/4;
            } else{
              xvalue = initxvalue+animval/4;
            }

          }

         /*if (xvalue>=xbound){
            animvalathit = animval;
            goingleft = false;
          } else if (xvalue<0){
            animvalathit = animval;
            goingleft = true;
          }
          xvalue = !goingleft ? initxvalue+ animvalathit/4-((animval - animvalathit)/4) : initxvalue-animvalathit/4 +(animval+animvalathit)/4;

*/
          velocity = simulation.dx((duration.inMilliseconds/initdistance) * (animation.value / 1000));
          progress = simulation.x((duration.inMilliseconds/initdistance) * ((animation.value) / 1000));
          //double fractionaldistance = newdistance/initdistance;

        //  velocity = simulation.dx((duration.inMilliseconds/newdistance/*initdistance*/) * (fractionaldistance*animation.value / 1000));
         // progress = simulation.x((duration.inMilliseconds/newdistance/*initdistance*/) * ((fractionaldistance*animation.value) / 1000));
        });
      })
      ..addStatusListener((status) {
        if (animation.isCompleted ) {
          hit=false;
          if (newdistance > 10.0) {
            setState(() {
              switch (ballstate) {
                case BallState.falling:
                  ballstate = BallState.rising;
                  initxvalue = xvalue;
                  frictionloss = 50.0;
                  bounceupvelocity = -velocity + frictionloss;

                  duration = Duration(
                      milliseconds: (-bounceupvelocity * 1000 / acceleration)
                          .round()
                  );
                  newdistance = .5 * acceleration *
                      pow(duration.inMilliseconds / 1000, 2);

                  risingfrom = fallingto;
                  risingto = fallingfrom;

                  simulation = GravitySimulation(
                      acceleration,
                      risingfrom, //peak,
                      risingto, //relativeground,
                      bounceupvelocity
                  );
                  break;

                case BallState.rising:
                  ballstate = BallState.falling;
                  initxvalue = xvalue;

                  fallingfrom = progress;

                  simulation = GravitySimulation(
                      acceleration,
                      fallingfrom,
                      fallingto,
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
          }
        }
      });

  }


  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        Positioned(
          top: progress!=null ? progress+ initialtop: initialtop,
          left: xvalue ,
          child:
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            height: 50.0, //animation.value,
            width: 50.0, //animation.value,
            child: FlutterLogo(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: RaisedButton(
                onPressed: () {setState(() {
                  if(controller.isAnimating){
                    controller.stop();
                    controller.reset();
                  }
                  controller.forward();

                });
                }
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: 100.0,
            color: Colors.blue,
          ),
        )

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