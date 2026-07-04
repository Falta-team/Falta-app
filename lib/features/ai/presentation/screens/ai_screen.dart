import 'package:flutter/material.dart';

class FaltaChatAIScreen extends StatefulWidget {
  const FaltaChatAIScreen({super.key});

  @override
  State<FaltaChatAIScreen> createState() => _FaltaChatScreenState();
}

class _FaltaChatScreenState extends State<FaltaChatAIScreen> {
  // ── Design Tokens ─────────────────────────────────────────────────────────
  static const Color kBg       = Color(0xFFFFFFFF);
  static const Color kGreen    = Color(0xFF44AE02);
  static const Color kTextDark = Color(0xFF1A202C);
  static const Color kTextGray = Color(0xFF64748B);
  static const Color kBorder   = Color(0xFFE2E8F0);
  static const Color kInputBg  = Color(0xFFF3F9FF);

  final _msgController = TextEditingController();
  final _scrollCtrl    = ScrollController();
  bool _isTyping       = false;

  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'Hello FaltaChat how are you today?', isUser: true),
    _ChatMessage(text: "Hello,i'm fine,how can i help you?", isUser: false),
    _ChatMessage(text: 'What is the best programming language?', isUser: true),
    _ChatMessage(
      text:
      'There are many programming languages in the market that are used in designing and building websites, various applications and other tasks. All these languages are popular in their place and in the way they are used, and how many programmers learn and use them.',
      isUser: false,
    ),
    _ChatMessage(text: 'So explain to me more', isUser: true),
    _ChatMessage(text: '...', isUser: false, isTyping: true),
  ];

  @override
  void dispose() {
    _msgController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.removeWhere((m) => m.isTyping);
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(_ChatMessage(text: '...', isUser: false, isTyping: true));
      _isTyping = true;
    });
    _msgController.clear();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.isTyping);
        _messages.add(_ChatMessage(
          text: 'شكراً على سؤالك! سأجيب عليه بأفضل ما يمكنني.',
          isUser: false,
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    });
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
      backgroundColor: kBg,
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
                  const Text(
                    'FaltaChat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: kGreen,
                      fontFamily: 'Cairo',
                      letterSpacing: 0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_forward,
                        color: kTextDark, size: 26),
                  ),
                ],
              ),
            ),

            const Divider(color: kBorder, height: 1),

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
                color: kBg,
                border: Border(top: BorderSide(color: kBorder)),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Text Input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: kInputBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: kBorder),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgController,
                              style: const TextStyle(
                                fontSize: 14,
                                color: kTextDark,
                                fontFamily: 'Cairo',
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Write your message',
                                hintStyle: TextStyle(
                                  color: kTextGray,
                                  fontSize: 14,
                                  fontFamily: 'Cairo',
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          // Mic icon
                          const Icon(Icons.mic_none,
                              color: kTextGray, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Send Button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: kGreen,
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
            color: kGreen,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Cairo',
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
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(bottom: 12, left: 6),
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '🤖',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),

        Flexible(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12, right: 48),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F9FF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: kBorder),
            ),
            child: msg.isTyping
                ? _TypingIndicator()
                : Text(
              msg.text,
              style: const TextStyle(
                color: kTextDark,
                fontSize: 14,
                fontFamily: 'Cairo',
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

// ── Animated typing dots ──────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final opacity = (((_ctrl.value * 3) - i) % 3 < 1)
                ? 1.0
                : 0.3;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFF44AE02).withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}