import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tito_app/core/provider/chat_view_provider.dart';
import 'package:tito_app/core/provider/login_provider.dart';
import 'package:tito_app/core/provider/popup_provider.dart';
import 'package:tito_app/core/provider/timer_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tito_app/core/constants/style.dart';

class ChatBottomDetail extends ConsumerStatefulWidget {
  final int id;
  const ChatBottomDetail({super.key, required this.id});

  @override
  ConsumerState<ChatBottomDetail> createState() => _ChatBottomDetailState();
}

class _ChatBottomDetailState extends ConsumerState<ChatBottomDetail> {
  late final chatViewModel = ref.read(chatInfoProvider.notifier);
  late final loginInfo = ref.read(loginInfoProvider);
  late final popupViewModel = ref.read(popupProvider.notifier);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleSendMessage(BuildContext context) async {
    final chatState = ref.read(chatInfoProvider);
    final popupState = ref.read(popupProvider);

    if (chatState!.debateJoinerId == 0 &&
        chatState.debateJoinerTurnCount == 0 &&
        chatState.debateOwnerId != loginInfo!.id) {
      popupState
        ..buttonStyle = 1
        ..title = '토론에 참여하시겠습니까?'
        ..imgSrc = 'assets/icons/popup_face.svg'
        ..buttonContentLeft = '토론 참여하기'
        ..content = '작성하신 의견을 전송하면\n토론 개설자에게 보여지고\n토론이 본격적으로 시작돼요!';

      await popupViewModel.showDebatePopup(context);
      chatViewModel.sendJoinMessage(context);
    } else if (chatState.debateJoinerId == loginInfo!.id ||
        chatState.debateOwnerId == loginInfo!.id) {
      if (chatState.debateJoinerId == loginInfo!.id) {
        if (chatState.debateJoinerTurnCount < chatState.debateOwnerTurnCount) {
          if (chatState.isFirstClick == true) {
            chatViewModel.createLLM();
          } else {
            chatViewModel.sendMessage();
          }
        }
      } else {
        if (chatState.debateJoinerTurnCount == chatState.debateOwnerTurnCount) {
          if (chatState.isFirstClick) {
            chatViewModel.createLLM();
          } else {
            chatViewModel.sendMessage();
          }
        }
      }
    } else {
      chatViewModel.sendChatMessage();
    }

    await Future.delayed(Duration(seconds: 2));

    // 여기서 mounted 체크 추가
    if (mounted && popupState.title == '토론이 시작 됐어요! 🎵') {
      ref.read(timerProvider.notifier).resetTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatInfoProvider);
    final loginInfo = ref.watch(loginInfoProvider);

    return Column(
      children: [
        Container(
          color: ColorSystem.white,
          padding:
              EdgeInsets.only(top: 10.h, bottom: 20.h, right: 10.w, left: 10.w),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset('assets/icons/plus.svg'),
                  ),
                  loginInfo!.nickname == chatState!.debateJoinerNick ||
                          loginInfo.nickname == chatState.debateOwnerNick
                      ? loginInfo.nickname == chatState.debateOwnerNick
                          ? chatState.debateOwnerTurnCount ==
                                  chatState.debateJoinerTurnCount
                              ? Container(
                                  width: 320.w,
                                  child: TextField(
                                    minLines: 1,
                                    maxLines: 3,
                                    controller: chatViewModel.controller,
                                    autocorrect: false,
                                    focusNode: chatViewModel.focusNode,
                                    decoration: InputDecoration(
                                      hintText: '당신의 의견 작성 타임이에요!',
                                      hintStyle: FontSystem.KR16M
                                          .copyWith(color: ColorSystem.grey),
                                      fillColor: ColorSystem.ligthGrey,
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.h, horizontal: 20.w),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      handleSendMessage(context);
                                    },
                                  ),
                                )
                              : Expanded(
                                  child: Container(
                                    width: 320.w,
                                    child: TextField(
                                      minLines: 1,
                                      maxLines: 3,
                                      controller: chatViewModel.controller,
                                      autocorrect: false,
                                      focusNode: chatViewModel.focusNode,
                                      decoration: InputDecoration(
                                        hintText: '상대 의견 작성 타임이에요!',
                                        hintStyle: FontSystem.KR16M
                                            .copyWith(color: ColorSystem.grey),
                                        fillColor: ColorSystem.ligthGrey,
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.h, horizontal: 20.w),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onSubmitted: (value) {
                                        handleSendMessage(context);
                                      },
                                    ),
                                  ),
                                )
                          : chatState.debateOwnerTurnCount >
                                  chatState.debateJoinerTurnCount
                              ? Expanded(
                                  child: Container(
                                    width: 320.w,
                                    child: TextField(
                                      minLines: 1,
                                      maxLines: 3,
                                      controller: chatViewModel.controller,
                                      autocorrect: false,
                                      focusNode: chatViewModel.focusNode,
                                      decoration: InputDecoration(
                                        hintText: '당신의 의견 작성 타임이에요!',
                                        hintStyle: FontSystem.KR16M
                                            .copyWith(color: ColorSystem.grey),
                                        fillColor: ColorSystem.ligthGrey,
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.h, horizontal: 20.w),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onSubmitted: (value) {
                                        handleSendMessage(context);
                                      },
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: Container(
                                    width: 320.w,
                                    child: TextField(
                                      minLines: 1,
                                      maxLines: 3,
                                      controller: chatViewModel.controller,
                                      autocorrect: false,
                                      focusNode: chatViewModel.focusNode,
                                      decoration: InputDecoration(
                                        hintText: '상대 의견 작성 타임이에요!',
                                        hintStyle: FontSystem.KR16M
                                            .copyWith(color: ColorSystem.grey),
                                        fillColor: ColorSystem.ligthGrey,
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.h, horizontal: 20.w),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onSubmitted: (value) {
                                        handleSendMessage(context);
                                      },
                                    ),
                                  ),
                                )
                      : Expanded(
                          child: Container(
                            width: 320.w,
                            child: TextField(
                              minLines: 1,
                              maxLines: 3,
                              controller: chatViewModel.controller,
                              autocorrect: false,
                              focusNode: chatViewModel.focusNode,
                              decoration: InputDecoration(
                                hintText: '댓글을 입력해주세요!',
                                hintStyle: FontSystem.KR16M
                                    .copyWith(color: ColorSystem.grey),
                                fillColor: ColorSystem.ligthGrey,
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.h, horizontal: 20.w),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (value) {
                                handleSendMessage(context);
                              },
                            ),
                          ),
                        ),
                  chatState.isLoading
                      ? SpinKitRing(
                          color: ColorSystem.purple,
                          size: 30.sp,
                          duration: Duration(seconds: 2),
                        )
                      : IconButton(
                          onPressed: () {
                            handleSendMessage(context);
                          },
                          icon: SvgPicture.asset(
                              'assets/icons/final_send_arrow.svg'),
                        ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
