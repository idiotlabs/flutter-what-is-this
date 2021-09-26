import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://4e2d27a2c9684614ad068c05a8eb96b0@o275739.ingest.sentry.io/5920420';
    },
    appRunner: () => runApp(MyApp()),
  );

  // or define SENTRY_DSN via Dart environment variable (--dart-define)
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        analytics: analytics,
        observer: observer,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
    required this.analytics,
    required this.observer,
  }) : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var questionList = [
    '이게 뭘까?',
    '이게 뭐개?',
    '이게 뭐야?',
    '이게 뭐지?',
  ];
  var answerList = ['까마귀', '개', '야옹이', '지렁이'];
  var thisQuestion;
  var thisQuestionImage;
  var thisAnswer;

  void _startQuestion() {
    setState(() {
      thisQuestion = Random().nextInt(4);
      thisQuestionImage = (Random().nextInt(9)).toString();
      thisAnswer = null;
    });
  }

  bool _checkAnswer(answer) {
    this._sendAnalyticsEvent(answer);

    if (thisQuestion == answer)
      return true;

    return false;
  }

  void _clickButton(answer) {
    if (_checkAnswer(answer)) {
      answer = 'o';
    }
    else {
      answer = 'x';
    }

    showDialog(
        context: context,
        builder: (_) => ImageDialog(answer: answer,),
        barrierDismissible: false,
        barrierColor: Colors.transparent,
    );

    _startQuestion();
  }

  // firebase log event
  Future<void> _sendAnalyticsEvent(answer) async {
    await widget.analytics.logEvent(name: 'check answer', parameters: {'answer': thisQuestion == answer});
  }

  @override
  void initState() {
    super.initState();

    this._startQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      // title: Text(widget.title),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                // color: Colors.green,
                child: Image.asset('images/q/'+thisQuestionImage+'.png', fit: BoxFit.fill),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  questionList[thisQuestion],
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: GridView.count(
                    primary: true,
                    padding: const EdgeInsets.all(10),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    physics: new NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      OutlinedButton(
                          onPressed: () => _clickButton(0),
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black87,
                            side: BorderSide(color: Colors.black87, width: 1),
                          ),
                          child: Text(
                            answerList[0],
                            style: TextStyle(fontSize: 30),
                          )),
                      OutlinedButton(
                          onPressed: () => _clickButton(1),
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black87,
                            side: BorderSide(color: Colors.black87, width: 1),
                          ),
                          child: Text(
                            answerList[1],
                            style: TextStyle(fontSize: 30),
                          )),
                      OutlinedButton(
                          onPressed: () => _clickButton(2),
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black87,
                            side: BorderSide(color: Colors.black87, width: 1),
                          ),
                          child: Text(
                            answerList[2],
                            style: TextStyle(fontSize: 30),
                          )),
                      OutlinedButton(
                          onPressed: () => _clickButton(3),
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black87,
                            side: BorderSide(color: Colors.black87, width: 1),
                          ),
                          child: Text(
                            answerList[3],
                            style: TextStyle(fontSize: 30),
                          )),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  var answer;

  ImageDialog({Key? key, required this.answer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 400), () {
      Navigator.of(context).pop(true);
    });
    return Dialog(
      backgroundColor: Colors.transparent.withOpacity(0),
      elevation: 0,
      child: Container(
        // width: 200,
        // height: 200,
        child: Image.asset('images/' + answer + '.png', fit: BoxFit.cover),
        // child: Image.asset('images/q/0.png'),
        // decoration: BoxDecoration(
        //     image: DecorationImage(
        //         image: ExactAssetImage('images/cat.jpeg'), fit: BoxFit.cover)),
      ),
    );
  }
}