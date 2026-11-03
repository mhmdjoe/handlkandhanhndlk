import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/ai_assistant_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../widgets/apple_touchable.dart';
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
                AppCupertinoPageRoute(
                  page: ItineraryDetailScreen(trip: response.generatedTrip!),
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
            const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryOrange),
            const SizedBox(width: 8),
            Text(loc.translate('aiPlannerTitle')),
          ],
        ),
        actions: [
          AppleTouchable(
            onTap: () {
              Navigator.push(
                context,
                AppCupertinoPageRoute(page: const TripWizardScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Icon(Icons.tune_rounded, color: AppColors.primaryPurple, size: 22),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List with Bouncing Physics & Spring Entrance
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return StaggeredEntranceItem(
                  index: index,
                  child: Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      decoration: BoxDecoration(
                        color: msg.isUser ? AppColors.primaryPurple : Colors.white,
                        borderRadius: BorderRadius.circular(18).copyWith(
                          bottomRight: msg.isUser ? Radius.zero : null,
                          bottomLeft: !msg.isUser ? Radius.zero : null,
                        ),
                        border: msg.isUser ? null : Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                msg.isUser ? Icons.person_pin_rounded : Icons.auto_awesome_rounded,
                                size: 14,
                                color: msg.isUser ? AppColors.papyrusGold : AppColors.primaryOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                msg.isUser
                                    ? (userName.isNotEmpty ? userName : (isAr ? 'أنت' : 'You'))
                                    : 'Handelak AI',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: msg.isUser ? AppColors.papyrusGold : AppColors.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            msg.text,
                            style: TextStyle(
                              color: msg.isUser ? Colors.white : AppColors.darkGray,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
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
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange)),
                  SizedBox(width: 8),
                  Text('HNHNDLK AI is thinking...', style: TextStyle(color: AppColors.primaryOrange, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          // Presets Pills
          SizedBox(
            height: 40,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildPresetChip(isAr ? 'رحلة ٧ أيام أهرامات وتاريخ مصر (القاهرة والأقصر وأسوان)' : '7 days Grand Egypt Highlights (Cairo, Luxor & Aswan)'),
                _buildPresetChip(isAr ? 'رحلة ٥ أيام البحر الأحمر وشاطئ جفتون بالغردقة' : '5 days Red Sea Resort & Diving (Hurghada & Giftun)'),
                _buildPresetChip(isAr ? 'رحلة ٣ أيام سفاري وبحيرات الملح في سيوة' : '3 days Desert & Salt Lakes Oasis Escape (Siwa)'),
                _buildPresetChip(isAr ? 'رحلة ٤ أيام عائلية في القاهرة والإسكندرية' : '4 days Family Tour of Cairo & Alexandria'),
                _buildPresetChip(isAr ? 'رحلة ٤ أيام دلافين وشعاب مرجانية بمرسى علم' : '4 days Dolphin Reef & Coral Sea (Marsa Alam)'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Input Bar
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 95),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: loc.translate('aiPlannerHint'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppleTouchable(
                  pressedScale: 0.85,
                  onTap: () => _handleSend(),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryOrange,
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
      child: AppleTouchable(
        pressedScale: 0.92,
        onTap: () => _handleSend(text),
        child: ActionChip(
          label: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.lightPurple,
          side: const BorderSide(color: AppColors.borderLight),
          onPressed: () => _handleSend(text),
        ),
      ),
    );
  }
}
