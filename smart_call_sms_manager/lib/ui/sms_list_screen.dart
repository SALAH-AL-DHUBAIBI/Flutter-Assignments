import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/sms_controller.dart';
import 'package:smart_call_sms_manager/ui/sms_compose_screen.dart';
import 'package:smart_call_sms_manager/ui/sms_thread_screen.dart';

class SmsListScreen extends StatefulWidget {
  const SmsListScreen({super.key});

  @override
  State<SmsListScreen> createState() => _SmsListScreenState();
}

class _SmsListScreenState extends State<SmsListScreen> {
  final ScrollController _scrollController = ScrollController();
  late final SmsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SmsController());

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildThreadItem(BuildContext context, int index) {
    if (index >= controller.messages.length) {
      return _buildLoadingIndicator();
    }

    final thread = controller.messages[index];
    final address = thread['address'] ?? 'Unknown';
    final displayName = thread['name'] ?? address;
    final unreadCount = int.tryParse(thread['unread_count'] ?? '0') ?? 0;
    final hasUnread = unreadCount > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: hasUnread
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
                color: isDark
                    ? Theme.of(context).colorScheme.onBackground
                    : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            controller.formatDate(thread['date']),
            style: TextStyle(
              fontSize: 12,
              color: hasUnread
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              thread['snippet'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                color: isDark
                    ? (hasUnread
                          ? Theme.of(context).colorScheme.onBackground
                          : Colors.white70)
                    : (hasUnread ? Colors.black87 : Colors.grey[600]),
              ),
            ),
          ),
          if (hasUnread)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () async {
        await Get.to(
          () => SmsThreadScreen(
            address: address,
            threadId: thread['thread_id'],
            name: thread['name'],
            onMessagesRead: () {
              controller.updateThread(thread['thread_id'], {
                'unread_count': '0',
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Obx(() {
          if (controller.isLoadingMore) {
            return const CircularProgressIndicator();
          } else if (controller.hasMore && !controller.isLoading) {
            return TextButton(
              onPressed: controller.loadMore,
              child: const Text('Load More Messages'),
            );
          } else if (!controller.hasMore && controller.messages.isNotEmpty) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No more messages',
                style: TextStyle(color: Colors.grey),
              ),
            );
          } else if (!controller.hasMore && controller.messages.isEmpty) {
            return const SizedBox();
          }
          return const SizedBox();
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messages"), actions: []),
      body: Obx(() {
        if (controller.isLoading && controller.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.messages.isEmpty && !controller.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.message, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No messages found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => controller.fetchSms(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchSms();
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
                controller.messages.length +
                (controller.hasMore || controller.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.messages.length) {
                return _buildLoadingIndicator();
              }
              return _buildThreadItem(context, index);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () => Get.to(() => const SmsComposeScreen()),
      ),
    );
  }
}
