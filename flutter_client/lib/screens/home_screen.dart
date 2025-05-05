import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/questionnaire_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkQuestionnaireStatus();
  }

  Future<void> _checkQuestionnaireStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<QuestionnaireProvider>(context, listen: false).checkStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kariyer Planlama'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<QuestionnaireProvider>(
              builder: (context, provider, child) {
                final isComplete = provider.isComplete;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'AI Destekli Kariyer Planlama',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Yapay zeka destekli kariyer planlama uygulamasına hoş geldiniz. '
                        'Bu uygulama, ilgi alanlarınız ve yeteneklerinize göre kişiselleştirilmiş '
                        'bir kariyer planı oluşturmanıza yardımcı olacaktır.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/questionnaire');
                        },
                        child: Text(
                          isComplete
                              ? 'Anketi Görüntüle'
                              : 'Anketi Başlat/Devam Et',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isComplete
                            ? () {
                                Navigator.pushNamed(context, '/career-plan');
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          disabledForegroundColor: Colors.white.withOpacity(0.38),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text('Kariyer Planını Görüntüle'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
} 