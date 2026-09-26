import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme.dart';
import 'item_widgets.dart';
import 'swap_controller.dart';
import 'swap_models.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.offer});
  final SwapOffer offer;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _message = TextEditingController();
  final _swap = Get.find<SwapController>();
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_message.text.trim().isEmpty || _sending) return;
    final body = _message.text.trim();
    setState(() => _sending = true);
    final error = await _swap.run(
      () => _swap.repository.sendMessage(widget.offer.id, _swap.uid, body),
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (error == null) {
      _message.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.offer.ownerId == _swap.uid
                ? widget.offer.requesterName
                : widget.offer.ownerName,
          ),
          Text(
            '${widget.offer.offeredTitle} ⇄ ${widget.offer.targetTitle}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      backgroundColor: BadalColors.cream,
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _swap.repository.watchMessages(widget.offer.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const EmptyState(
                    icon: Icons.error_outline,
                    title: 'تعذر تحميل المحادثة',
                    subtitle: 'تحقق من اتصالك وقواعد Firestore.',
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                if (messages.isEmpty) {
                  return const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'ابدأ الحديث',
                    subtitle:
                        'اتفقا على تفاصيل المقايضة والمكان والوقت الآمنين.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final data = messages[index].data();
                    final mine = data['senderId'] == _swap.uid;
                    return Align(
                      alignment: mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * .78,
                        ),
                        margin: const EdgeInsets.only(bottom: 9),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: mine ? BadalColors.forest : BadalColors.mint,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Text(
                          data['body'] as String? ?? '',
                          style: TextStyle(
                            color: mine ? Colors.white : BadalColors.ink,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (widget.offer.status == 'pending' ||
              widget.offer.status == 'accepted')
            Container(
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _message,
                      maxLength: 1000,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة...',
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: BadalColors.forest,
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
