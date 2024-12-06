import 'package:flutter/material.dart';

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String displayText = '0';

  void onButtonPressed(String value) {
    setState(() {
      if (value == '=') {
        // Hisoblash
        try {
          displayText = _calculateResult(displayText);
        } catch (e) {
          displayText = "Error";
        }
      } else {
        // Matnni yangilash
        if (displayText == '0' && value != '.') {
          displayText = value;
        } else {
          displayText += value;
        }
      }
    });
  }

  String _calculateResult(String expression) {
    // Hisoblashni amalga oshiruvchi funksiya
    List<String> tokens = _tokenize(expression);
    List<String> postfix = _toPostfix(tokens);
    return _evaluatePostfix(postfix).toString();
  }

  List<String> _tokenize(String expression) {
    // Ifodani bo‘laklarga ajratish
    List<String> tokens = [];
    String currentNumber = '';
    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      if ('0123456789.'.contains(char)) {
        currentNumber += char; // Sonlarni yig‘ish
      } else {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = '';
        }
        tokens.add(char); // Operatorlarni qo‘shish
      }
    }
    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }
    return tokens;
  }

  List<String> _toPostfix(List<String> tokens) {
    // Infix dan Postfix (Reverse Polish Notation) ga o‘tkazish
    List<String> postfix = [];
    List<String> stack = [];
    Map<String, int> precedence = {'+': 1, '-': 1, '×': 2, '÷': 2};

    for (String token in tokens) {
      if ('0123456789.'.contains(token[0])) {
        postfix.add(token); // Sonlarni qo‘shish
      } else if (token == '(') {
        stack.add(token);
      } else if (token == ')') {
        while (stack.isNotEmpty && stack.last != '(') {
          postfix.add(stack.removeLast());
        }
        stack.removeLast();
      } else {
        while (stack.isNotEmpty &&
            precedence[stack.last] != null &&
            precedence[stack.last]! >= precedence[token]!) {
          postfix.add(stack.removeLast());
        }
        stack.add(token);
      }
    }
    while (stack.isNotEmpty) {
      postfix.add(stack.removeLast());
    }
    return postfix;
  }

  double _evaluatePostfix(List<String> postfix) {
    // Postfix ifodani hisoblash
    List<double> stack = [];
    for (String token in postfix) {
      if ('0123456789.'.contains(token[0])) {
        stack.add(double.parse(token));
      } else {
        double b = stack.removeLast();
        double a = stack.removeLast();
        switch (token) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '×':
            stack.add(a * b);
            break;
          case '÷':
            stack.add(a / b);
            break;
        }
      }
    }
    return stack.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          // Displey qismi
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.all(20),
              child: Text(
                displayText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Tugmalar qismi
          Expanded(
            flex: 8,
            child: GridView.count(
              crossAxisCount: 4,
              padding: EdgeInsets.all(10),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                for (String label in [
                  '7',
                  '8',
                  '9',
                  '÷',
                  '4',
                  '5',
                  '6',
                  '×',
                  '1',
                  '2',
                  '3',
                  '-',
                  '0',
                  '.',
                  '=',
                  '+'
                ])
                  GestureDetector(
                    onTap: () => onButtonPressed(label),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _isOperator(label)
                            ? (label == '=' ? Colors.white : Colors.blue)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 24,
                          color: _isOperator(label)
                              ? (label == '=' ? Colors.black : Colors.white)
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Operatorlarni aniqlash
  bool _isOperator(String label) {
    return ['÷', '×', '-', '+', '='].contains(label);
  }
}
