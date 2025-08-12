import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(QuizApp());
}

class QuestionItem {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuestionItem({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختبار 10 أسئلة',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuizHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class QuizHomePage extends StatefulWidget {
  @override
  _QuizHomePageState createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  final List<QuestionItem> _questions = [
    QuestionItem(question: 'ما عاصمة فرنسا؟', options: ['باريس', 'لندن', 'مدريد', 'روما'], correctIndex: 0),
    QuestionItem(question: '2 + 3 = ؟', options: ['4', '5', '6', '3'], correctIndex: 1),
    QuestionItem(question: 'أكبر كوكب في المجموعة الشمسية؟', options: ['الأرض', 'المشتري', 'زحل', 'المريخ'], correctIndex: 1),
    QuestionItem(question: 'لون السماء في يوم صافٍ؟', options: ['أخضر', 'أزرق', 'أحمر', 'أسود'], correctIndex: 1),
    QuestionItem(question: 'من اخترع المصباح الكهربائي؟', options: ['توماس إديسون', 'ألكسندر جراهام بيل', 'نيوتن', 'جاليليو'], correctIndex: 0),
    QuestionItem(question: 'أي دولة مشهورة بالبيتزا؟', options: ['اليابان', 'إيطاليا', 'البرازيل', 'مصر'], correctIndex: 1),
    QuestionItem(question: 'ما هو الحيوان المعروف بـ \"ملك الغابة\"؟', options: ['النمر', 'الأسد', 'الفيل', 'الزرافة'], correctIndex: 1),
    QuestionItem(question: 'ما هو البحر الذي يقع بين السعودية ومصر؟', options: ['البحر الأحمر', 'البحر المتوسط', 'خليج عمان', 'خليج عدن'], correctIndex: 0),
    QuestionItem(question: '5 × 4 = ؟', options: ['20', '15', '25', '10'], correctIndex: 0),
    QuestionItem(question: 'ما هو الغاز الذي نتنفسه؟', options: ['الأكسجين', 'الهيدروجين', 'ثاني أكسيد الكربون', 'النتروجين'], correctIndex: 0),
  ];

  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _chosenIndex;
  int _timeLeft = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = 15;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _nextQuestion();
      }
    });
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _chosenIndex = index;
      if (index == _questions[_currentIndex].correctIndex) {
        _score += 1;
      }
    });
    _timer?.cancel();
    Future.delayed(Duration(milliseconds: 800), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _chosenIndex = null;
      });
      _startTimer();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultPage(score: _score, total: _questions.length),
        ),
      ).then((_) {
        setState(() {
          _currentIndex = 0;
          _score = 0;
          _answered = false;
          _chosenIndex = null;
        });
        _startTimer();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('سؤال ${_currentIndex + 1} من ${_questions.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                '$_timeLeft ث',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              q.question,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ...List.generate(q.options.length, (i) {
              Color? bg;
              if (_answered && _chosenIndex != null) {
                if (i == q.correctIndex) {
                  bg = Colors.green;
                } else if (i == _chosenIndex && _chosenIndex != q.correctIndex) {
                  bg = Colors.red;
                }
              }
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => _selectOption(i),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bg ?? Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    q.options[i],
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              );
            }),
            Spacer(),
            Text(
              'النقاط: $_score',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final int total;

  const ResultPage({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('النتيجة النهائية')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('نتيجتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 18),
            Text('$score / $total', style: TextStyle(fontSize: 48, color: Colors.blue)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إعادة الاختبار'),
            ),
          ],
        ),
      ),
    );
  }
}
