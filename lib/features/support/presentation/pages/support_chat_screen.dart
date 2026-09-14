// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glow_orb.dart';
import '../../../../services/auth_service.dart';
import '../../logic/chat_provider.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';

class SupportChatScreen extends StatelessWidget {
  final String userId;
  final String? initialMessage;

  const SupportChatScreen(
      {super.key, required this.userId, this.initialMessage});

  @override
  Widget build(BuildContext context) {
    final actualUserId = userId.isEmpty
        ? (context.read<AuthService>().userId ?? '')
        : userId;

    return ChangeNotifierProvider(
      create: (_) => ChatProvider(
        null,
        context.read<AuthService>(),
        actualUserId,
      ),
      child: _SupportChatView(initialMessage: initialMessage),
    );
  }
}

class _SupportChatView extends StatefulWidget {
  final String? initialMessage;
  const _SupportChatView({this.initialMessage});

  @override
  State<_SupportChatView> createState() => _SupportChatViewState();
}

class _SupportChatViewState extends State<_SupportChatView> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().markRead();
      if (widget.initialMessage != null && !_initialized) {
        _ctrl.text = widget.initialMessage!;
        _initialized = true;
        _send();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    await context.read<ChatProvider>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final provider = context.watch<ChatProvider>();
    final messages = provider.messages;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: ChatHeader(userId: provider.userId),
      body: Stack(
        children: [
          Positioned(
            top: 200,
            right: -100,
            child:
                GlowOrb(size: 300, color: AppColors.primary.withOpacity(0.08)),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child:
                GlowOrb(size: 250, color: AppColors.accent.withOpacity(0.08)),
          ),
          Column(
            children: [
              Expanded(
                child: provider.userId.isEmpty
                    ? Center(
                        child: Text(s.loginFirst,
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5))))
                    : messages.isEmpty
                        ? _EmptyChatView(s: s)
                        : RefreshIndicator(
                            onRefresh: provider.refresh,
                            color: AppColors.primary,
                            child: ListView.builder(
                              controller: _scrollCtrl,
                              reverse: true,
                              padding: EdgeInsets.fromLTRB(
                                  20,
                                  MediaQuery.of(context).padding.top + 100,
                                  20,
                                  100),
                              itemCount: messages.length,
                              itemBuilder: (context, i) {
                                final data = messages[i];
                                final isAdmin = data['is_admin'] == true;
                                DateTime? time;
                                final raw = data['created_at'];
                                if (raw != null) {
                                  time = DateTime.tryParse(raw.toString());
                                }

                                return ChatMessageBubble(
                                  text: data['text'] ?? '',
                                  isAdmin: isAdmin,
                                  time: time,
                                );
                              },
                            ),
                          ),
              ),
              ChatInputBar(
                controller: _ctrl,
                sending: provider.sending,
                onSend: _send,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyChatView extends StatelessWidget {
  final AppStrings s;
  const _EmptyChatView({required this.s});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 60, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'كيف يمكننا مساعدتكِ؟',
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'فريق خدمة العملاء جاهز لخدمتكِ على مدار الساعة',
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.5)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
