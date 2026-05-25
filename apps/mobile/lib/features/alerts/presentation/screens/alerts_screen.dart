import 'package:agrishield/app/theme/agri_tokens.dart';
import 'package:agrishield/features/alerts/application/alerts_cubit.dart';
import 'package:agrishield/features/alerts/application/alerts_state.dart';
import 'package:agrishield/features/alerts/presentation/widgets/alert_card.dart';
import 'package:agrishield/features/alerts/presentation/widgets/alert_filter_pills.dart';
import 'package:agrishield/features/dashboard/view/prototype_screens.dart'
    as prototype;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:agrishield/core/repositories/alert_repository.dart';
import 'package:agrishield/features/dashboard/cubit/dashboard_cubit.dart';

class AlertsScreenWrapper extends StatelessWidget {
  const AlertsScreenWrapper({required this.alertRepository, super.key});

  final AlertRepository alertRepository;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (previous, current) =>
          previous.deviceCode != current.deviceCode,
      builder: (context, state) {
        final deviceCode = state.deviceCode;
        if (deviceCode == null) {
          return const prototype.PageFrame(
            title: 'Alerts',
            subtitle: 'Waiting for device connection...',
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        }

        return BlocProvider(
          key: ValueKey(deviceCode),
          create: (context) => AlertsCubit(
            alertRepository: alertRepository,
            deviceCode: deviceCode,
          )..startListening(),
          child: const AlertsScreen(),
        );
      },
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AgriFieldTokens>() ?? AgriFieldTokens.light;

    return prototype.PageFrame(
      title: 'Alerts',
      subtitle: 'Recent warnings and field conditions',
      children: [
        BlocBuilder<AlertsCubit, AlertsState>(
          builder: (context, state) {
            return AlertFilterPills(
              selectedFilter: state.filter,
              onFilterSelected: (filter) {
                context.read<AlertsCubit>().setFilter(filter);
              },
            );
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<AlertsCubit, AlertsState>(
          builder: (context, state) {
            if (state is AlertsLoading || state is AlertsInitial) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is AlertsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    state.message,
                    style: TextStyle(color: tokens.statusCritical),
                  ),
                ),
              );
            }

            if (state is AlertsLoaded) {
              if (state.alerts.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(64.0),
                    child: Text(
                      'No alerts to show',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: state.alerts.map((alert) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AlertCard(
                      alert: alert,
                      onTap: () => context.go('/field/alerts/${alert.id}'),
                    ),
                  );
                }).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
