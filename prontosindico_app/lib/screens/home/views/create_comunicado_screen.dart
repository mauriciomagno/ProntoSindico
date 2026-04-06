import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/domain/entities/comunicado.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/providers/communication_providers.dart';

class CreateComunicadoScreen extends ConsumerStatefulWidget {
  const CreateComunicadoScreen({super.key});

  @override
  ConsumerState<CreateComunicadoScreen> createState() => _CreateComunicadoScreenState();
}

class _CreateComunicadoScreenState extends ConsumerState<CreateComunicadoScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Manutenção';
  bool _sendPush = true;

  final List<String> _categories = [
    'Manutenção',
    'Aviso Geral',
    'Evento',
    'Segurança',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Novo Comunicado",
          style: TextStyle(
            color: Color(0xFF1E40AF),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _publishComunicado,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text("Publicar", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "GESTÃO CONDOMINIAL",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E40AF),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Crie uma nova mensagem para os moradores.",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Mantenha todos informados com clareza e transparência. Preencha os detalhes abaixo para disparar o comunicado.",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // Form Content
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSectionTitle("Título do Comunicado"),
                   const SizedBox(height: 12),
                   _buildTextField(_titleController, "Ex: Manutenção de Elevadores"),
                   
                   const SizedBox(height: 24),
                   _buildSectionTitle("Categoria"),
                   const SizedBox(height: 12),
                   Wrap(
                     spacing: 8,
                     runSpacing: 8,
                     children: _categories.map((cat) => _buildCategoryChip(cat)).toList(),
                   ),

                   const SizedBox(height: 24),
                   _buildSectionTitle("Conteúdo"),
                   const SizedBox(height: 12),
                   _buildTextField(_contentController, "Escreva aqui a mensagem completa para os moradores...", maxLines: 6),

                   const SizedBox(height: 24),
                   _buildSectionTitle("Anexos"),
                   const SizedBox(height: 12),
                   _buildAttachmentBox(),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              "Opções de Envio",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            
            // Push Notification Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Notificação Push",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          "Notificar todos os moradores",
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _sendPush,
                    onChanged: (val) => setState(() => _sendPush = val),
                    activeColor: const Color(0xFF1E40AF),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Specialist Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info, color: Color(0xFF0369A1), size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Dica de Especialista: ",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0369A1), fontSize: 13),
                          ),
                          TextSpan(
                            text: "Comunicados com imagens têm 40% mais visualizações. Use anexos para maior engajamento.",
                            style: TextStyle(color: Color(0xFF0369A1), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            // Promo Banner
            _buildPromoBanner(),

            const SizedBox(height: 32),
            // Final Action Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _publishComunicado,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                label: const Text(
                  "Publicar Comunicado",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005EB8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          style: BorderStyle.solid, // Note: standard border for now, custom painter needed for dashed
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.note_add_outlined, color: Color(0xFF1E40AF)),
          ),
          const SizedBox(height: 16),
          const Text(
            "Adicionar Imagem ou Documento",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            "PDF, JPG ou PNG (Máx. 10MB)",
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&q=80&w=800'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PRONTOSÍNDICO",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.5),
            ),
            SizedBox(height: 4),
            Text(
              "Sua gestão, em um novo\npatamar de excelência.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publishComunicado() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos obrigatórios.")),
      );
      return;
    }

    final userProfile = ref.read(userProfileProvider).valueOrNull;
    final userUid = userProfile?.uid;
    if (userUid == null) return;

    final comunicado = Comunicado(
      title: _titleController.text,
      description: _contentController.text,
      author: userProfile?.name.toUpperCase() ?? "SÍNDICO",
      date: DateTime.now(),
      category: _selectedCategory,
      canNotify: _sendPush,
    );

    await ref.read(communicationRepositoryProvider).saveComunicado(userUid, comunicado);
    if (mounted) Navigator.pop(context);
  }
}
