import 'package:agrishield/app/theme/agri_theme.dart';
import 'package:agrishield/features/dashboard/view/prototype_screens.dart'
    as prototype;
import 'package:agrishield/features/device_pairing/cubit/device_pairing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DevicePairingScreen extends StatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await context.read<DevicePairingCubit>().submit(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DevicePairingCubit, DevicePairingState>(
      listenWhen: (previous, current) {
        return previous.status != current.status &&
            current.status == DevicePairingStatus.success;
      },
      listener: (context, state) => context.go('/field'),
      builder: (context, state) {
        final isSubmitting = state.status == DevicePairingStatus.submitting;
        final errorText = state.status == DevicePairingStatus.failure
            ? state.message
            : null;

        return Scaffold(
          backgroundColor: AgriTheme.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              children: [
                const Icon(
                  Icons.sensors_rounded,
                  color: AgriTheme.fieldGreen,
                  size: 54,
                ),
                const SizedBox(height: 18),
                Text(
                  'Connect Device',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the code shown on your field device to connect live readings.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                prototype.SoftCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _controller,
                          enabled: !isSubmitting,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: 'Device code',
                            hintText: 'AGRI01',
                            prefixIcon: const Icon(Icons.qr_code_2_rounded),
                            errorText: errorText,
                          ),
                          onFieldSubmitted: (_) => _submit(),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return DevicePairingFailure.empty.message;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: isSubmitting ? null : _submit,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Icon(Icons.sensors_rounded),
                          label: Text(
                            isSubmitting ? 'Connecting...' : 'Connect Device',
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                prototype.SoftCard(
                  child: Row(
                    children: [
                      const prototype.MetricIcon(
                        icon: Icons.verified_outlined,
                        color: AgriTheme.fieldGreen,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Live Device Connected appears after a valid code is saved on this phone.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: isSubmitting ? null : () => context.go('/demo'),
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('Try Demo Mode'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
