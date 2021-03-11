import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:text_recognition/adHelper/ad_helper.dart';
import 'package:text_recognition/api/firebase_ml_api.dart';
import 'package:text_recognition/widgets/text_area_widget.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({
    @required this.title,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  File image;
  String text = '';
  final FlutterTts flutterTts = FlutterTts();
  var translatedPhrase = '';

  Animation<double> _animation;
  AnimationController _animationController;

  @override
  void initState() {
    myBanner.load();
    debugPrint(
        'banner ----------------------------------------- ${myBanner.size}');
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  Future pickImage() async {
    final file = await ImagePicker().getImage(source: ImageSource.gallery);
    setImage(File(file.path));
  }

  void setImage(File newImage) {
    setState(() {
      image = newImage;
    });
  }

  Widget buildImage() => Container(
        child: image != null
            ? Image.file(image)
            : Icon(Icons.photo, size: 100, color: Colors.black),
      );

  Future scanText() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Center(
          child: CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 5.0,
            percent: 1.0,
            center: const Text('100%'),
            progressColor: Colors.indigo,
          ),
        ),
      ),
    );

    final text = await FirebaseMLApi.recogniseText(image);
    setText(text);

    Navigator.of(context).pop();
  }

  void setText(String newText) {
    setState(() {
      text = newText;
    });
  }

  void copyToClipboard() {
    if (text.trim() != '') {
      FlutterClipboard.copy(text);
    }
  }

  Future _speak({String text}) async {
    print(await flutterTts.getLanguages);
    await flutterTts.setLanguage('en-IN');
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  Future _speakBangla({String text}) async {
    print(await flutterTts.getLanguages);
    await flutterTts.setLanguage('bn-BD');
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  void clear() {
    setImage(null);
    setText('');
    translatedPhrase = '';
    _speak(text: '');
    _speakBangla(text: '');
  }

  @override
  void dispose() {
    myBanner?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  final myBanner = BannerAd(
    adUnitId: AdHelper.bannerAdUnitId,
    size: AdSize.banner,
    request: AdRequest(),
    listener: AdListener(
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        print('Ad failed to load: $error');
      },
      onAdOpened: (Ad ad) => print('Ad opened.'),
      onAdClosed: (Ad ad) => print('Ad closed.'),
      onApplicationExit: (Ad ad) => print('Left application.'),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final top = MediaQuery.of(context).padding.top;
    final appbarSize = AppBar().preferredSize.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Column(
          children: [
            Container(
              height: (height - appbarSize - top) * 0.15,

              // height: myBanner.size.height.toDouble(),
              // width: myBanner.size.width.toDouble(),
              child: AdWidget(
                ad: myBanner,
              ),
            ),
            Container(
              height: (height - appbarSize - top) * 0.3,
              child: buildImage(),
            ),
            TextAreaWidget(
              height: (height - appbarSize - top) * 0.5,
              text: text,
              onCopy: copyToClipboard,
              onSpeak: () => _speak(text: text),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionBubble(
        backGroundColor: Theme.of(context).primaryColor,
        items: <Bubble>[
          Bubble(
            title: 'Pick Image',
            iconColor: Colors.white,
            bubbleColor: Colors.indigo,
            icon: Icons.image,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              pickImage();
              _animationController.reverse();
            },
          ),
          Bubble(
            title: 'Scan For Text',
            iconColor: Colors.white,
            bubbleColor: Colors.indigo,
            icon: Icons.scanner,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              scanText();
              _animationController.reverse();
            },
          ),
          Bubble(
            title: 'Clear',
            iconColor: Colors.white,
            bubbleColor: Colors.indigo,
            icon: Icons.clear,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              clear();
              _animationController.reverse();
            },
          ),
        ],
        animation: _animation,
        onPress: _animationController.isCompleted
            ? _animationController.reverse
            : _animationController.forward,
        iconColor: Colors.indigo,
        animatedIconData: AnimatedIcons.add_event,
      ),
    );
  }
}
