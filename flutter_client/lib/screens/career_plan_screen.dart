import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/career_plan_provider.dart';
import '../models/conversation_message.dart';

class CareerPlanScreen extends StatefulWidget {
  const CareerPlanScreen({super.key});

  @override
  State<CareerPlanScreen> createState() => _CareerPlanScreenState();
}

class _CareerPlanScreenState extends State<CareerPlanScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Provider.of<CareerPlanProvider>(context, listen: false).loadData();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    
    await Provider.of<CareerPlanProvider>(context, listen: false)
        .sendMessage(message);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildCareerPlanTab() {
    return Consumer<CareerPlanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: const Color(0xFF2A3990),
              size: 50,
            ),
          );
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        if (!provider.hasPlan) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.playlist_add,
                  size: 60,
                  color: Color(0xFF2A3990),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Henüz bir kariyer planınız bulunmuyor.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tüm anket sorularını cevapladıktan sonra burada planınızı oluşturabilirsiniz.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: provider.isGenerating 
                    ? null 
                    : () => provider.generateCareerPlan(),
                  child: provider.isGenerating
                      ? LoadingAnimationWidget.horizontalRotatingDots(
                          color: Colors.white,
                          size: 24,
                        )
                      : const Text('Kariyer Planı Oluştur'),
                ),
              ],
            ),
          );
        }

        final careerPlan = provider.careerPlan!;
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kişiselleştirilmiş Kariyer Planınız',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A3990),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Yeniden oluştur',
                    onPressed: provider.isGenerating 
                      ? null 
                      : () => provider.generateCareerPlan(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Oluşturulma Tarihi: ${_formatDate(careerPlan.createdAt)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: provider.isGenerating
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LoadingAnimationWidget.staggeredDotsWave(
                                  color: const Color(0xFF2A3990),
                                  size: 50,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Planınız oluşturuluyor...',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Bu işlem bir kaç dakika sürebilir.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : Markdown(
                            data: careerPlan.planContent,
                            physics: const BouncingScrollPhysics(),
                            styleSheet: MarkdownStyleSheet(
                              h1: const TextStyle(
                                color: Color(0xFF2A3990),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              h2: const TextStyle(
                                color: Color(0xFF2A3990),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              h3: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              p: const TextStyle(fontSize: 16),
                              listBullet: const TextStyle(fontSize: 16),
                            ),
                            onTapLink: (text, href, title) {
                              if (href != null) {
                                _launchUrl(href);
                              }
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatTab() {
    return Consumer<CareerPlanProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Expanded(
              child: provider.isLoading
                  ? Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: const Color(0xFF2A3990),
                        size: 50,
                      ),
                    )
                  : provider.chatHistory.isEmpty
                      ? const Center(
                          child: Text(
                            'Henüz hiç mesaj bulunmuyor.\nKariyer planınız hakkında bir soru sorun.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.chatHistory.length,
                          itemBuilder: (context, index) {
                            final message = provider.chatHistory[index];
                            return _buildChatMessage(message);
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Bir soru sorun...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 3,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: provider.isSendingMessage ? null : _sendMessage,
                    mini: true,
                    backgroundColor: const Color(0xFF2A3990),
                    child: provider.isSendingMessage
                        ? LoadingAnimationWidget.horizontalRotatingDots(
                            color: Colors.white,
                            size: 18,
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatMessage(ConversationMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            CircleAvatar(
              backgroundColor: const Color(0xFF2A3990),
              radius: 16,
              child: const Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF2A3990)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 16,
              child: Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'URL açılamadı: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kariyer Planı'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Kariyer Planı', icon: Icon(Icons.description)),
              Tab(text: 'AI Sohbet', icon: Icon(Icons.chat)),
            ],
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            _buildCareerPlanTab(),
            _buildChatTab(),
          ],
        ),
      ),
    );
  }
} 