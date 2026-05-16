import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils.dart';
import '../../blocs/center/center_bloc.dart';
import '../../resources/color_manageer.dart';
import '../../widgets/common/loading_widget.dart';

class CenterStockHistoryPage extends StatefulWidget {
  const CenterStockHistoryPage({super.key});

  static const String routeName = 'center_stock_history';

  @override
  State<CenterStockHistoryPage> createState() => _CenterStockHistoryPageState();
}

class _CenterStockHistoryPageState extends State<CenterStockHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CenterBloc>().add(CenterStockHistoryLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل المخزون')),
      body: BlocConsumer<CenterBloc, CenterState>(
        listener: (context, state) {
          if (state is CenterFailure) {
            Utils.showSnackBar(
              context: context,
              msg: state.message,
              color: ColorManager.error,
            );
          }
        },
        builder: (context, state) {
          if (state is CenterLoading) {
            return const Center(child: LoadingWidget());
          }
          if (state is CenterStockHistoryLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('لا يوجد سجل حتى الآن'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.items.length + (state.hasNextPage ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return TextButton(
                    onPressed: () {
                      context.read<CenterBloc>().add(
                            CenterStockHistoryLoadRequested(
                              cursor: state.nextCursor,
                              append: true,
                            ),
                          );
                    },
                    child: const Text('تحميل المزيد'),
                  );
                }
                final entry = state.items[index];
                final sign = entry.change >= 0 ? '+' : '';
                return ListTile(
                  title: Text('${entry.bloodType}  $sign${entry.change}'),
                  subtitle: Text(
                    entry.reason.isNotEmpty
                        ? entry.reason
                        : entry.createdAt,
                  ),
                  trailing: entry.reason.isNotEmpty
                      ? Text(
                          entry.createdAt,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : null,
                );
              },
            );
          }
          return const Center(child: Text('لا توجد بيانات'));
        },
      ),
    );
  }
}
