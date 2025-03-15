import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/modules/reels/reels.dart';
import 'package:mehra_app/shared/components/constants.dart';

class HomePage extends StatelessWidget {
  final List<String> videos = [
    'https://assets.mixkit.co/videos/preview/mixkit-happy-family-walking-in-the-park-39882-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-young-woman-enjoying-nature-39883-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-kids-playing-in-the-snow-39884-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-couple-walking-on-the-beach-39885-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-girl-using-a-smartphone-in-the-park-39886-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-woman-doing-yoga-in-nature-39887-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-people-having-fun-at-a-party-39888-large.mp4'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.blueColor,
                MyColor.purpleColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      backgroundColor: MyColor.LightSearchColor,
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              //We need swiper for every content
              Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return ContentScreen(
                    src: videos[index],
                  );
                },
                itemCount: videos.length,
                scrollDirection: Axis.vertical,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,
                vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ريلز ',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: MyColor.blueColor
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Color(0xFF4423B1),
                            Color(0xFFA02D87),
                          ],
                        ).createShader(bounds);
                      },
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
