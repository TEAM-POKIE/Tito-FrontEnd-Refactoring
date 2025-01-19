import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:tito_app/core/provider/chat_view_provider.dart';
import 'package:tito_app/src/view/chatView/chat_bottom_detail.dart';
import 'package:tito_app/src/view/chatView/chat_list_view.dart';
import 'package:tito_app/src/view/chatView/chat_speech_bubble.dart';
import 'package:tito_app/src/view/chatView/chat_view_details.dart';

class ChatBody extends ConsumerWidget {
  final int id;

  const ChatBody({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatInfoProvider);
    return Stack(
      children: [
        Column(
          children: [
            ChatViewDetails(id: id),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: ColorSystem.grey3),
                child: ChatListView(id: id),
                padding: EdgeInsets.symmetric(vertical: 20),
              ),
            ),
            ChatBottomDetail(id: id),
          ],
        ),
        if (chatState!.isFirstClick)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: ChatSpeechBubble(),
          ),
      ],
    );
  }
}
