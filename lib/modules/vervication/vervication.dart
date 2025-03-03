     import 'package:flutter/material.dart';
import 'package:mehra_app/modules/vervication/InputScreen.dart';
import 'package:mehra_app/shared/components/constants.dart';


class VervicationScreen extends StatefulWidget {
  const VervicationScreen({super.key});

  @override
  State<VervicationScreen> createState() => _VervicationScreenState();
}

class _VervicationScreenState extends State<VervicationScreen> {
  final TextEditingController _controller = TextEditingController();
  List<bool> _selectedCircles = List.filled(6, false);
  List<String> _enteredNumbers = List.filled(6, '');

  void _onClear() {
    setState(() {
      _controller.clear();
      _selectedCircles = List.filled(6, false);
      _enteredNumbers = List.filled(6, '');
    });
  }

  void _onCirclePressed(int index) {
    setState(() {
      _selectedCircles[index] = !_selectedCircles[index];
    });
  }

  void _onNumberPressed(String number) {
    setState(() {
      _controller.text += number;
      for (int i = 0; i < _enteredNumbers.length; i++) {
        if (_enteredNumbers[i].isEmpty) {
          _enteredNumbers[i] = number;
          break;
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      for (int i = _enteredNumbers.length - 1; i >= 0; i--) {
        if (_enteredNumbers[i].isNotEmpty) {
          _enteredNumbers[i] = '';
          break;
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.blueColor,MyColor.purpleColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Container(
              color: MyColor.lightprimaryColor,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/bottom.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: 430,
                height: 268,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/1.png'),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'أدخل رمز التحقق',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MyColor.purpleColor,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return GestureDetector(
                            onTap: () => _onCirclePressed(index),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                gradient: _selectedCircles[index]
                                    ? LinearGradient(
                                        colors: [
                                          Color(0xFF4423B1),
                                          Color(0xFFA02D87),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: _selectedCircles[index]
                                    ? null
                                    : Color(0xFFE4E4E4),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _enteredNumbers[index],
                                  style: TextStyle(
                                    color: MyColor.purpleColor,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ), ), ),),
            NumberInputScreen(
              onNumberPressed: _onNumberPressed,
              onDeletePressed: _onDeletePressed,
              enteredNumbers: _enteredNumbers,
            ),
          ],
        ),
      ),
    );
  }
}