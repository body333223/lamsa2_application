// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glow_orb.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
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
        ? (context.read<AuthService>().currentUser?.uid ?? '')
        : userId;

    return ChangeNotifierProvider(
      create: (_) => ChatProvider(
        context.read<FirestoreService>(),
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
                    : StreamBuilder<QuerySnapshot>(
                        stream: provider.messagesStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2));
                          final messages = snapshot.data!.docs;

                          if (messages.isEmpty) {
                            return _EmptyChatView(s: s);
                          }

                          return ListView.builder(
                            controller: _scrollCtrl,
                            reverse: true,
                            padding: EdgeInsets.fromLTRB(
                                20,
                                MediaQuery.of(context).padding.top + 100,
                                20,
                                100),
                            itemCount: messages.length,
                            itemBuilder: (context, i) {
                              final data =
                                  messages[i].data() as Map<String, dynamic>?;
                              if (data == null) return const SizedBox();

                              final isAdmin = data['isAdmin'] == true;
                              final isRead = data['isRead'] == true;
                              final time =
                                  (data['createdAt'] as Timestamp?)?.toDate();

                              if (isAdmin && !isRead) {
                                provider.markRead();
                              }

                              return ChatMessageBubble(
                                text: data['text'] ?? '',
                                isAdmin: isAdmin,
                                time: time,
                              );
                            },
                          );
                        },
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
            theme.brightness == Brightness.dark
                ? 'كيف يمكننا مساعدتكِ؟'
                : 'How can we help you?',
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            theme.brightness == Brightness.dark
                ? 'فريق خدمة العملاء جاهز لخدمتكِ على مدار الساعة'
                : 'Our team is ready to serve you 24/7',
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
