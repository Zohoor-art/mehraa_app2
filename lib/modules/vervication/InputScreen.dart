import 'package:flutter/material.dart';
class NumberInputScreen extends StatelessWidget {
  final Function(String) onNumberPressed;
  final Function onDeletePressed;
  final List<String> enteredNumbers;

  const NumberInputScreen({
    Key? key,
    required this.onNumberPressed,
    required this.onDeletePressed,
    required this.enteredNumbers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50, // تعديل الموضع حسب الحاجة
      left: 40,
      right: 40,
      child: Container(
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
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(9, (index) {
                  String buttonText = (index + 1).toString();
                  return GestureDetector(
                    onTap: () {
                      onNumberPressed(buttonText);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        buttonText,
                        style: TextStyle(fontSize: 35),
                      ),
                    ),
                  );
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      onNumberPressed("0");
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("0", style: TextStyle(fontSize: 35)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}