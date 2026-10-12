import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/ai_assistant_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'itinerary_detail_screen.dart';
import 'trip_wizard_screen.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<ChatMessage> _messages = [];
  final _inputController = TextEditingController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: 'أهلاً بك! أنا مساعد "هنهندلك" الذكي لتخطيط رحلات مصر. اكتب لي رغباتك أو اختر من الاقتراحات بالأسفل وسأصمم لك جدولاً متكاملاً مع الأسعار والمواعيد الموثقة.\n\nHello! I am HNHNDLK AI Assistant. Tell me your travel goals and I will craft an official, verified schedule for you!',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _handleSend([String? preset]) async {
    final query = preset ?? _inputController.text.trim();
    if (query.isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add(ChatMessage(text: query, isUser: true, timestamp: DateTime.now()));
      _isGenerating = true;
    });

    final response = await AiAssistantService.processUserPrompt(
      prompt: query,
      destinationId: 'cairo',
      daysCount: 3,
      travelerCount: 2,
    );

    if (!mounted) return;

    final provider = Provider.of<AppProvider>(context, listen: false);
    final isAr = provider.isArabic;

    setState(() {
      _isGenerating = false;
      _messages.add(
        ChatMessage(
          text: isAr ? response.textResponseAr : response.textResponseEn,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });

    if (response.generatedTrip != null) {
      provider.addTrip(response.generatedTrip!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'تم إنشاء الرحلة وحفظها في "رحلاتي"!' : 'Trip created and saved to My Trips!'),
          action: SnackBarAction(
            label: isAr ? 'عرض' : 'View',
            textColor: AppColors.papyrusGold,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItineraryDetailScreen(trip: response.generatedTrip!),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;
    final userName = provider.userProfile.name;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.terracotta),
            const SizedBox(width: 8),
            Text(loc.translate('aiPlannerTitle')),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TripWizardScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: msg.isUser ? AppColors.nileTeal : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: msg.isUser ? Radius.zero : null,
                        bottomLeft: !msg.isUser ? Radius.zero : null,
                      ),
                      border: msg.isUser ? null : Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sender Name Header Badge
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              msg.isUser ? Icons.person_pin_rounded : Icons.auto_awesome_rounded,
                              size: 14,
                              color: msg.isUser ? AppColors.papyrusGold : AppColors.terracotta,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              msg.isUser
                                  ? (userName.isNotEmpty ? userName : (isAr ? 'أنت' : 'You'))
                                  : 'HNHNDLK AI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: msg.isUser ? AppColors.papyrusGold : AppColors.terracotta,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Message Text Body
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser ? Colors.white : AppColors.charcoal,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isGenerating)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.terracotta)),
                  SizedBox(width: 8),
                  Text('HNHNDLK AI is thinking...', style: TextStyle(color: AppColors.terracotta, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          // Presets Pills
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildPresetChip('3 days in Cairo for 2 travelers'),
                _buildPresetChip('5 days in Red Sea & Hurghada for family'),
                _buildPresetChip('7 days tour of Luxor & Aswan'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Input Bar with bottom padding to avoid floating nav bar occlusion
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 95),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: loc.translate('aiPlannerHint'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.terracotta,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _handleSend(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.desertSand,
        onPressed: () => _handleSend(text),
      ),
    );
  }
}
