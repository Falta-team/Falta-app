import 'package:falta_app/core/subscription/subscription_gate.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/ai/data/sources/ai_remote_data_source.dart';
import 'package:falta_app/features/ai/presentation/widgets/typing_indecator_widget.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaltaChatAIScreen extends StatefulWidget {
  const FaltaChatAIScreen({super.key});

  @override
  State<FaltaChatAIScreen> createState() => _FaltaChatScreenState();
}

class _FaltaChatScreenState extends State<FaltaChatAIScreen> {
  final _msgController = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _ai = AiRemoteDataSource();
  bool _isTyping = false;
  String? _sessionId;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: 'مرحباً! أنا مساعد فلتا الدراسي. اسألني عن أي مادة توجيهي.',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _msgController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isTyping) return;
    if (!await SubscriptionGate.ensureActive(context)) return;
    if (!mounted) return;
    setState(() {
      _messages.removeWhere((m) => m.isTyping);
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(_ChatMessage(text: '...', isUser: false, isTyping: true));
      _isTyping = true;
    });
    _msgController.clear();
    _scrollToBottom();

    try {
      final result = await _ai.ask(
        question: text,
        sessionId: _sessionId,
      );
      if (!mounted) return;
      _sessionId = result.sessionId ?? _sessionId;
      setState(() {
        _messages.removeWhere((m) => m.isTyping);
        _messages.add(_ChatMessage(text: result.answer, isUser: false));
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.isTyping);
        _messages.add(_ChatMessage(
          text: e.toString().replaceFirst('Exception: ', ''),
          isUser: false,
        ));
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // FaltaChat title in green
                   Text(
                    'FaltaChat',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_forward,
                        color: AppColors.textDark, size: 26),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.kBorder, height: 1),

            // ── Messages ───────────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) =>
                    _buildMessage(_messages[i]),
              ),
            ),

            // ── Input Bar ──────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.kBorder)),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Text Input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.kBorder),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgController,
                              style:  GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                              decoration:  InputDecoration(
                                hintText: 'Write your message',
                                hintStyle: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          // Mic icon
                          const Icon(Icons.mic_none,
                              color: AppColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),

                  10.ws,

                  // Send Button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(_ChatMessage msg) {
    if (msg.isUser) {
      // ── User bubble (green, right aligned) ──
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Text(
            msg.text,
            style:  GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    // ── Bot bubble (white/gray, left aligned) ──
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // AI Avatar
        Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.only(bottom: 12, left: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Image.asset('icon_logo_chat.png'.icon_,fit: BoxFit.fill,),
        ),
        4.ws,

        Flexible(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12, right: 48),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F9FF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              border: Border.all(color: AppColors.kBorder),
            ),
            child: msg.isTyping
                ? TypingIndicator()
                : Text(
              msg.text,
              style: GoogleFonts.inter(
                color: AppColors.textDark,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isTyping;
  _ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });
}

