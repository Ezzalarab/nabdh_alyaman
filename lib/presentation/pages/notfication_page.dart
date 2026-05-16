import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_notification.dart';
import '../blocs/notifications/notifications_bloc.dart';
import '../resources/color_manageer.dart';
import '../widgets/common/loading_widget.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  static const String routeName = 'notification_page';

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(NotificationsLoadRequested());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = context.read<NotificationsBloc>().state;
    if (state is! NotificationsLoaded) return;
    if (state.loadingMore || state.nextCursor == null) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    context.read<NotificationsBloc>().add(
          NotificationsLoadRequested(
            append: true,
            cursor: state.nextCursor,
          ),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          TextButton(
            onPressed: () => context
                .read<NotificationsBloc>()
                .add(NotificationsMarkAllReadRequested()),
            child: const Text('قراءة الكل'),
          ),
        ],
      ),
      backgroundColor: ColorManager.white,
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: LoadingWidget());
          }
          if (state is NotificationsFailure) {
            return Center(child: Text(state.message));
          }
          if (state is NotificationsLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('لا توجد إشعارات'));
            }
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.items.length + (state.loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: LoadingWidget()),
                  );
                }
                return _NotificationTile(
                  item: state.items[index],
                  onTap: () {
                    final id = state.items[index].id;
                    if (id > 0) {
                      context
                          .read<NotificationsBloc>()
                          .add(NotificationMarkReadRequested(id));
                    }
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: item.isRead ? null : ColorManager.primary.withOpacity(0.05),
      title: Text(
        item.title.isNotEmpty ? item.title : 'إشعار',
        style: TextStyle(
          fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.body.isNotEmpty) Text(item.body),
          if (item.createdAt.isNotEmpty)
            Text(
              item.createdAt,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      leading: Icon(
        item.isRead ? Icons.notifications_none : Icons.notifications_active,
        color: ColorManager.primary,
      ),
    );
  }
}
