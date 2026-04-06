import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prontosindico/domain/entities/reserva.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/providers/reserva_providers.dart';

class MakeReservaScreen extends ConsumerStatefulWidget {
  final AreaComum area;

  const MakeReservaScreen({super.key, required this.area});

  @override
  ConsumerState<MakeReservaScreen> createState() => _MakeReservaScreenState();
}

class _MakeReservaScreenState extends ConsumerState<MakeReservaScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final _timeController = TextEditingController(text: "12:00 - 18:00");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Elegant Header with Image
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xFF1E40AF),
            leading: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.area.nome,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.area.imagem, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "DETALHES DO ESPAÇO",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.area.descricao,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF334155), height: 1.5)),

                  const SizedBox(height: 32),
                  const Text(
                    "SUA RESERVA",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 16),

                  // Date Picker Card
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              color: Color(0xFF1E40AF)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Data do Evento",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B))),
                                Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(_selectedDate),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A))),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_calendar_outlined,
                              size: 20, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Time Input
                  _buildTextField(
                      _timeController, "Horário (Ex: 10:00 - 14:00)",
                      icon: Icons.access_time),

                  const SizedBox(height: 40),

                  // Specialist Observation Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFF0284C7)),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            "Sua reserva passará por aprovação automática se estiver dentro das regras do condomínio.",
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF0369A1)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _confirmReserva,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E40AF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Confirmar Agendamento",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          icon: Icon(icon, color: const Color(0xFF1E40AF)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _confirmReserva() async {
    final userProfile = ref.read(userProfileProvider).valueOrNull;
    if (userProfile == null) {
      return;
    }

    final reserva = Reserva(
      areaId: widget.area.id,
      usuarioId: userProfile.uid,
      data: DateFormat('dd/MM/yyyy').format(_selectedDate),
      horario: _timeController.text,
      status: 'confirmada',
    );

    await ref.read(reservaRepositoryProvider).saveReserva(reserva);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reserva realizada com sucesso!")),
      );
    }
  }
}
