import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/domain/entities/resident.dart';
import 'package:prontosindico/ui/features/residents/controllers/residents_controller.dart';

import 'package:prontosindico/components/app_drawer.dart';

class ResidentsScreen extends ConsumerWidget {
  const ResidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(residentsControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: backgroundLightColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: primaryColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/logo/logo.png',
          height: 32,
          errorBuilder: (_, __, ___) => const Text("ProntoSindico",
              style:
                  TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
      ),
      body: _buildBody(context, ref, state, colorScheme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    state,
    ColorScheme colorScheme,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: errorColor),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(residentsControllerProvider),
              child: const Text("Tentar Novamente"),
            ),
          ],
        ),
      );
    }

    final residents = state.residents;

    if (residents.isEmpty) {
      return const Center(child: Text("Nenhum morador encontrado."));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(defaultPadding),
      itemCount: residents.length,
      separatorBuilder: (_, __) => const SizedBox(height: defaultPadding),
      itemBuilder: (context, index) {
        final resident = residents[index];
        return _ResidentCard(resident: resident);
      },
    );
  }
}

class _ResidentCard extends ConsumerWidget {
  const _ResidentCard({required this.resident});

  final Resident resident;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = resident.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: user.isActive ? Colors.transparent : errorColor.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                      ? Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  "assets/icons/miniRight.svg",
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color!.withOpacity(0.4),
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _RoleChip(role: user.role.name),
                const SizedBox(width: 8),
                if (resident.apartment != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Apto: ${resident.apartment}",
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      resident.hasPaid ? 'Pago' : 'Pendente',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: resident.hasPaid ? Colors.green : errorColor,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch.adaptive(
                        value: resident.hasPaid,
                        activeTrackColor: Colors.green,
                        inactiveThumbColor: errorColor,
                        onChanged: (value) {
                          if (resident.id != null) {
                            ref
                                .read(residentsControllerProvider.notifier)
                                .togglePaymentStatus(resident.id!, value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final String role;

  Color _cor() {
    switch (role.toLowerCase()) {
      case 'administrador':
        return Colors.deepPurple;
      case 'sindico':
        return primaryColor;
      case 'funcionario':
        return Colors.orange.shade700;
      case 'portaria':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _cor().withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cor().withOpacity(0.4)),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 11,
          color: _cor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
