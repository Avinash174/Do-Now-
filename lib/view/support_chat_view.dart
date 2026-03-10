import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';

class SupportChatView extends StatefulWidget {
  const SupportChatView({super.key});

  @override
  State<SupportChatView> createState() => _SupportChatViewState();
}

class _SupportChatViewState extends State<SupportChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'type': 'bot',
      'message':
          'Hello! 👋 Welcome to Do Now Support. How can we help you today?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
    },
    {
      'type': 'bot',
      'message':
          'You can ask us about:\n• Getting started\n• Account issues\n• Feature questions\n• Billing & subscriptions\n• Technical problems',
      'timestamp': DateTime.now().subtract(
        const Duration(minutes: 1, seconds: 45),
      ),
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'type': 'user',
        'message': message.trim(),
        'timestamp': DateTime.now(),
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate bot response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'type': 'bot',
          'message': _getBotResponse(message),
          'timestamp': DateTime.now(),
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('hello') || message.contains('hi')) {
      return 'Hi there! 😊 How can I assist you today?';
    } else if (message.contains('getting') || message.contains('start')) {
      return 'To get started with Do Now:\n1. Create an account\n2. Set up your first task\n3. Add reminders\n4. Organize with categories\n\nWould you like help with any of these?';
    } else if (message.contains('account') || message.contains('login')) {
      return 'For account issues:\n• Can\'t log in? Use "Forgot Password"\n• Need 2FA help? Check Security Settings\n• Want to change email? Go to Profile Settings\n\nLet me know what you need!';
    } else if (message.contains('feature') || message.contains('how')) {
      return 'We have many features:\n✨ Task creation & organization\n🔔 Smart reminders\n📊 Analytics & insights\n👥 Collaboration\n🎨 Custom themes\n\nWhich would you like to know more about?';
    } else if (message.contains('billing') ||
        message.contains('subscription') ||
        message.contains('price')) {
      return 'Subscription info:\n🆓 Free: Basic features\n⭐ Premium: \$4.99/month or \$39.99/year\n👨‍👩‍👧‍👦 Family: \$9.99/month\n\nNeed help upgrading or managing your subscription?';
    } else if (message.contains('problem') ||
        message.contains('bug') ||
        message.contains('error')) {
      return 'I\'m sorry you\'re experiencing issues! 😟\n\nCan you tell me:\n1. What\'s the problem?\n2. When did it start?\n3. What device/OS?\n4. Error message (if any)?\n\nThis helps us fix it faster!';
    } else if (message.contains('thank')) {
      return 'You\'re welcome! 😊 Anything else I can help with?';
    }

    return 'Great question! 🤔 I\'m here to help. Could you provide more details? Our support team can also escalate this if needed.';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: PlatformBackButton(
          color: theme.textTheme.titleMedium?.color ?? AppColors.textDark,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Support',
              style: GoogleFonts.plusJakartaSans(
                color: theme.textTheme.titleMedium?.color ?? AppColors.textDark,
                fontWeight: FontWeight.w800,
                fontSize: isSmallScreen ? 18 : 20,
              ),
            ),
            Text(
              'Online now',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => HapticFeedback.lightImpact(),
            icon: Icon(
              Icons.more_vert_rounded,
              color: theme.textTheme.titleMedium?.color ?? AppColors.textDark,
            ),
          ),
          const SizedBox(width: 8),
        ],
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: 16,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['type'] == 'user';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isUser)
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primaryBlue,
                              child: Icon(
                                Icons.support_agent_rounded,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppColors.primaryBlue
                                    : theme.cardColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                                  bottomRight: Radius.circular(isUser ? 4 : 20),
                                ),
                                border: !isUser
                                    ? Border.all(
                                        color: theme.dividerColor.withValues(
                                          alpha: 0.1,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Text(
                                msg['message'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: isUser
                                      ? AppColors.white
                                      : (theme.textTheme.bodyLarge?.color ??
                                            AppColors.textDark),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          if (isUser) const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: EdgeInsets.only(
                          left: isUser ? 0 : 24,
                          right: isUser ? 24 : 0,
                        ),
                        child: Text(
                          _formatTime(msg['timestamp']),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color:
                                theme.textTheme.bodySmall?.color ??
                                AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0);
              },
            ),
          ),

          // Divider
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),

          // Quick Reply Suggestions (optional)
          if (_messages.length < 4)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickReply(context, 'Getting started', () {
                      _sendMessage('I need help getting started');
                    }),
                    _buildQuickReply(context, 'Account issues', () {
                      _sendMessage('I have account issues');
                    }),
                    _buildQuickReply(context, 'Premium', () {
                      _sendMessage('Tell me about premium');
                    }),
                  ],
                ),
              ),
            ),

          // Message Input
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => HapticFeedback.lightImpact(),
                    icon: const Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color:
                                theme.textTheme.bodySmall?.color ??
                                AppColors.textLight,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (value) => _sendMessage(value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _sendMessage(_messageController.text);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReply(
    BuildContext context,
    String text,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
