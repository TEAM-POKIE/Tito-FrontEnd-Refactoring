import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:tito_app/core/provider/chat_view_provider.dart';
import 'package:tito_app/core/provider/login_provider.dart';
import 'package:tito_app/core/provider/popup_provider.dart';
import 'package:tito_app/core/provider/timer_provider.dart';
import 'package:tito_app/core/provider/websocket_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tito_app/src/data/models/debate_info.dart';
import 'package:tito_app/src/data/models/login_info.dart';
import 'package:tito_app/src/viewModel/chat_viewModel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatListView extends ConsumerStatefulWidget {
  final int id;

  const ChatListView({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends ConsumerState<ChatListView> {
  List<Map<String, dynamic>> _messages = [];
  late StreamSubscription<Map<String, dynamic>> _subscription;
  bool _isTyping = false;
  Timer? _typingTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        _fetchDebateInfo();
        _subscribeToMessages();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDebateInfo() async {
    try {
      final chatViewModel = ref.read(chatInfoProvider.notifier);
      await chatViewModel.fetchDebateInfo(widget.id);
    } catch (e) {
      if (mounted) {
        print("Error fetching debate info: $e");
      }
    }
  }

  void _handlePopupIfNeeded(Map<String, dynamic> message, LoginInfo loginInfo) {
    if (!mounted) return;
    final chatState = ref.read(chatInfoProvider);
    final popupViewModel = ref.read(popupProvider.notifier);
    final timerViewModel = ref.read(timerProvider.notifier);

    switch (message['command']) {
      case 'CHAT':
        final createdAt = DateTime.parse(message['createdAt']);
        timerViewModel.resetTimer(startTime: createdAt);
        break;

      case 'TIMING_BELL_REQ':
        if (loginInfo.id != message['userId'] &&
            message['content'] == 'timing bell request') {
          print("Timing Bell Request Received: ${message['content']}");
          if (mounted &&
              chatState!.canTiming &&
              chatState.debateStatus == "IN_PROGRESS") {
            popupViewModel.showTimingReceive(context);
            chatState.canTiming = false;
          }
        }
        chatState?.canTiming = false;
        break;

      case 'TIMING_BELL_RES':
        chatState?.canTiming = false;
        break;

      case 'NOTIFY':
        if (message['content'] == "토론이 종료 되었습니다.") {
          if (mounted && chatState != null) {
            popupViewModel.showEndPopup(context);
            chatState.debateStatus = 'VOTING';
          }
        }
        break;

      default:
        break;
    }
  }

  void _subscribeToMessages() {
    final webSocketService = ref.read(webSocketProvider);
    final loginInfo = ref.watch(loginInfoProvider);

    _subscription = webSocketService.stream.listen((message) {
      if (message.containsKey('content') && mounted) {
        setState(() {
          _messages.add(message);
          if (loginInfo != null) {
            _handlePopupIfNeeded(message, loginInfo);
          }
        });
        _scrollToBottom();
      }
      if (message['command'] == 'TYPING') {
        if (mounted) {
          setState(() {
            _isTyping = true;
          });
        }
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isTyping = false;
            });
          }
        });
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginInfo = ref.watch(loginInfoProvider);
    final chatState = ref.watch(chatInfoProvider);
    final chatViewModel = ref.read(chatInfoProvider.notifier);

    if (chatState == null || loginInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: chatState.debateJoinerId == loginInfo.id ||
                  chatState.debateOwnerId == loginInfo.id
              ? JoinerChatList(
                  messages: _messages,
                  loginInfo: loginInfo,
                  isTyping: _isTyping,
                  chatViewModel: chatViewModel,
                  chatState: chatState,
                  scrollController: _scrollController,
                )
              : ParticipantsList(
                  messages: _messages,
                  loginInfo: loginInfo,
                  isTyping: _isTyping,
                  chatViewModel: chatViewModel,
                  scrollController: _scrollController,
                ),
        ),
      ],
    );
  }
}

class JoinerChatList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final LoginInfo loginInfo;
  final ChatViewModel chatViewModel;
  final DebateInfo chatState;
  final bool isTyping;
  final ScrollController scrollController;

  const JoinerChatList({
    required this.messages,
    required this.loginInfo,
    required this.chatViewModel,
    required this.isTyping,
    required this.chatState,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMyMessage = message['userId'] == loginInfo.id;
        final chatMessage = message['command'] == 'CHAT';
        final notifyMessage = message['command'] == 'NOTIFY';

        if (loginInfo.id == chatState.debateOwnerId) {
          if (index == 3) {
            chatState.lastUrl = message['userImageUrl'] ?? '';
          }
        } else {
          if (index == 2) {
            chatState.lastUrl = message['userImageUrl'] ?? '';
          }
        }

        final DateTime parsedDate = DateTime.parse(message['createdAt']);
        final String formattedTime = DateFormat('a h:mm').format(parsedDate);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            chatMessage
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isMyMessage
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isMyMessage)
                          IconButton(
                            onPressed: () {
                              chatViewModel.getProfile(
                                  message['userId'], context);
                            },
                            icon: CircleAvatar(
                              backgroundImage:
                                  message['userImageUrl'] != null &&
                                          message['userImageUrl']!.isNotEmpty
                                      ? NetworkImage(message['userImageUrl']!)
                                      : null,
                              radius: 20.r,
                              child: message['userImageUrl'] == null ||
                                      message['userImageUrl']!.isEmpty
                                  ? SvgPicture.asset(
                                      'assets/icons/basicProfile.svg')
                                  : null,
                            ),
                          ),
                        SizedBox(width: 5.w),
                        Column(
                          crossAxisAlignment: isMyMessage
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isMyMessage)
                              Container(
                                constraints: BoxConstraints(maxWidth: 250.w),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.h, horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: ColorSystem.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.r),
                                    topRight: Radius.circular(16.r),
                                    bottomRight: Radius.circular(16.r),
                                    bottomLeft: Radius.circular(4.r),
                                  ),
                                ),
                                child: Text(
                                  message['content'] ?? '',
                                  style: FontSystem.KR16R,
                                ),
                              ),
                            if (isMyMessage)
                              Container(
                                constraints: BoxConstraints(maxWidth: 250.w),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.h, horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: ColorSystem.purple,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.r),
                                    topRight: Radius.circular(16.r),
                                    bottomRight: Radius.circular(4.r),
                                    bottomLeft: Radius.circular(16.r),
                                  ),
                                ),
                                child: Text(
                                  message['content'] ?? '',
                                  style: FontSystem.KR16R
                                      .copyWith(color: ColorSystem.white),
                                ),
                              ),
                            SizedBox(height: 8.h),
                            Text(
                              formattedTime,
                              style: FontSystem.KR12R
                                  .copyWith(color: ColorSystem.grey1),
                            ),
                          ],
                        ),
                        if (isMyMessage) SizedBox(width: 5.w),
                        if (isMyMessage)
                          IconButton(
                            onPressed: () {
                              chatViewModel.getProfile(
                                  message['userId'], context);
                            },
                            icon: CircleAvatar(
                              backgroundImage:
                                  message['userImageUrl'] != null &&
                                          message['userImageUrl']!.isNotEmpty
                                      ? NetworkImage(message['userImageUrl']!)
                                      : null,
                              radius: 20.r,
                              child: message['userImageUrl'] == null ||
                                      message['userImageUrl']!.isEmpty
                                  ? SvgPicture.asset(
                                      'assets/icons/basicProfile.svg')
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  )
                : notifyMessage
                    ? Container(
                        padding: EdgeInsets.only(
                            top: index == 0 ? 5.h : 0.h, bottom: 0.h),
                        child: Center(child: Text(message['content'] ?? '')),
                      )
                    : const SizedBox(width: 0),
            if (messages.length == 3 && index == messages.length - 1)
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: CircleAvatar(
                        radius: 20.r,
                        child:
                            SvgPicture.asset('assets/icons/basicProfile.svg')),
                  ),
                  SizedBox(width: 20.w),
                  Text(
                    '상대 찾는중',
                    style: FontSystem.KR16B.copyWith(color: ColorSystem.purple),
                  ),
                  SizedBox(width: 6.w),
                  LoadingAnimationWidget.waveDots(
                    color: ColorSystem.purple,
                    size: 15.sp,
                  ),
                ],
              )
            else if (index == messages.length - 1 &&
                message['userId'] == loginInfo.id &&
                message['command'] != 'TIMING_BELL_REQ')
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: IconButton(
                      onPressed: () {
                        if (loginInfo.id == chatState.debateJoinerId) {
                          chatViewModel.getProfile(
                              chatState.debateOwnerId, context);
                        } else {
                          chatViewModel.getProfile(
                              chatState.debateJoinerId, context);
                        }
                      },
                      icon: CircleAvatar(
                        backgroundImage: chatState.lastUrl != null &&
                                chatState.lastUrl.isNotEmpty
                            ? NetworkImage(chatState.lastUrl)
                            : null,
                        radius: 20.r,
                        child: chatState.lastUrl == null ||
                                chatState.lastUrl.isEmpty
                            ? SvgPicture.asset('assets/icons/basicProfile.svg')
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Text(
                    '답변 작성중',
                    style: FontSystem.KR16B.copyWith(color: ColorSystem.purple),
                  ),
                  SizedBox(width: 6.w),
                  LoadingAnimationWidget.waveDots(
                    color: ColorSystem.purple,
                    size: 15.sp,
                  ),
                ],
              )
            else if (index == messages.length - 1 &&
                message['content'] == '토론이 시작되었습니다.' &&
                loginInfo.id == chatState.debateJoinerId)
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: IconButton(
                      onPressed: () {
                        if (loginInfo.id == chatState.debateJoinerId) {
                          chatViewModel.getProfile(
                              chatState.debateOwnerId, context);
                        } else {
                          chatViewModel.getProfile(
                              chatState.debateJoinerId, context);
                        }
                      },
                      icon: CircleAvatar(
                        backgroundImage: chatState.lastUrl != null &&
                                chatState.lastUrl.isNotEmpty
                            ? NetworkImage(chatState.lastUrl)
                            : null,
                        radius: 20.r,
                        child: chatState.lastUrl == null ||
                                chatState.lastUrl.isEmpty
                            ? SvgPicture.asset('assets/icons/basicProfile.svg')
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Text(
                    '답변 작성중',
                    style: FontSystem.KR16B.copyWith(color: ColorSystem.purple),
                  ),
                  SizedBox(width: 6.w),
                  LoadingAnimationWidget.waveDots(
                    color: ColorSystem.purple,
                    size: 15.sp,
                  ),
                ],
              )
            else
              SizedBox(
                width: 0.w,
              ),
            SizedBox(height: 20.h),
          ],
        );
      },
    );
  }
}

class ParticipantsList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final LoginInfo loginInfo;
  final ChatViewModel chatViewModel;
  final bool isTyping;
  final ScrollController scrollController;

  const ParticipantsList({
    required this.messages,
    required this.loginInfo,
    required this.isTyping,
    required this.chatViewModel,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMyMessage =
            messages.length > 2 && message['userId'] == messages[2]['userId'];
        final chatMessage = message['command'] == 'CHAT';
        final DateTime parsedDate = DateTime.parse(message['createdAt']);
        final String formattedTime = DateFormat('a h:mm').format(parsedDate);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: chatMessage
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 20.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isMyMessage && messages.length != 3
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMyMessage ||
                              index == 2 && messages.length == 3)
                            IconButton(
                              onPressed: () {
                                chatViewModel.getProfile(
                                    message['userId'], context);
                              },
                              icon: CircleAvatar(
                                backgroundImage:
                                    message['userImageUrl'] != null &&
                                            message['userImageUrl']!.isNotEmpty
                                        ? NetworkImage(message['userImageUrl']!)
                                        : null,
                                radius: 20.r,
                                child: message['userImageUrl'] == null ||
                                        message['userImageUrl']!.isEmpty
                                    ? SvgPicture.asset(
                                        'assets/icons/basicProfile.svg')
                                    : null,
                              ),
                            ),
                          SizedBox(width: 5.w),
                          Column(
                            crossAxisAlignment: isMyMessage
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (!isMyMessage)
                                Container(
                                  constraints: BoxConstraints(maxWidth: 250.w),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.h, horizontal: 12.w),
                                  decoration: BoxDecoration(
                                    color: ColorSystem.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16.r),
                                      topRight: Radius.circular(16.r),
                                      bottomRight: Radius.circular(16.r),
                                      bottomLeft: Radius.circular(4.r),
                                    ),
                                  ),
                                  child: Text(
                                    message['content'] ?? '',
                                    style: FontSystem.KR16R,
                                  ),
                                ),
                              if (isMyMessage)
                                Container(
                                  constraints: BoxConstraints(maxWidth: 250.w),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.h, horizontal: 12.w),
                                  decoration: BoxDecoration(
                                    color: ColorSystem.purple,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16.r),
                                      topRight: Radius.circular(16.r),
                                      bottomRight: Radius.circular(4.r),
                                      bottomLeft: Radius.circular(16.r),
                                    ),
                                  ),
                                  child: Text(
                                    message['content'] ?? '',
                                    style: FontSystem.KR16R
                                        .copyWith(color: ColorSystem.white),
                                  ),
                                ),
                              SizedBox(height: 8.h),
                              Text(
                                formattedTime,
                                style: FontSystem.KR12R
                                    .copyWith(color: ColorSystem.grey1),
                              ),
                            ],
                          ),
                          if (isMyMessage) SizedBox(width: 5.w),
                          if (isMyMessage && messages.length != 3)
                            IconButton(
                              onPressed: () {
                                chatViewModel.getProfile(
                                    message['userId'], context);
                              },
                              icon: CircleAvatar(
                                backgroundImage:
                                    message['userImageUrl'] != null &&
                                            message['userImageUrl']!.isNotEmpty
                                        ? NetworkImage(message['userImageUrl']!)
                                        : null,
                                radius: 20.r,
                                child: message['userImageUrl'] == null ||
                                        message['userImageUrl']!.isEmpty
                                    ? SvgPicture.asset(
                                        'assets/icons/basicProfile.svg')
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Center(child: Text(message['content'] ?? '')),
                    ),
            ),
          ],
        );
      },
    );
  }
}
