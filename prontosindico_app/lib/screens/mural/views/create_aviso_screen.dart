import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/domain/entities/mural_aviso.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/providers/communication_providers.dart';

class CreateAvisoScreen extends ConsumerStatefulWidget {
  const CreateAvisoScreen({super.key});

  @override
  ConsumerState<CreateAvisoScreen> createState() => _CreateAvisoScreenState();
}

class _CreateAvisoScreenState extends ConsumerState<CreateAvisoScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  MuralTag _selectedTag = MuralTag.informativo; // Mapeia 'Geral' para informativo
  bool _sendPush = true;

  final Map<String, MuralTag> _categoryMap = {
    'Geral': MuralTag.informativo,
    'Urgente': MuralTag.importante,
    'Social': MuralTag.social,
    'Outros': MuralTag.manutencao,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Novo Aviso",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: TextButton(
              onPressed: _publishAviso,
              child: const Text(
                "Publicar",
                style: TextStyle(
                  color: Color(0xFF1E40AF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("TÍTULO DO AVISO"),
            const SizedBox(height: 12),
            _buildTextField(_titleController, "Ex: Assembleia Geral"),
            
            const SizedBox(height: 32),
            _buildLabel("CATEGORIA"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categoryMap.keys.map((cat) => _buildCategoryChip(cat)).toList(),
            ),

            const SizedBox(height: 32),
            _buildLabel("CONTEÚDO"),
            const SizedBox(height: 12),
            _buildTextField(_contentController, "Escreva os detalhes do aviso aqui...", maxLines: 6),

            const SizedBox(height: 32),
            _buildLabel("ANEXOS"),
            const SizedBox(height: 12),
            _buildAttachmentBox(),

            const SizedBox(height: 32),
            const Text(
              "OPÇÕES DE ENVIO",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            
            // Push Notification Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_active, color: Color(0xFF0D9488), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Notificação Push",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 15),
                        ),
                        Text(
                          "Alertar moradores via aplicativo",
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

            const SizedBox(height: 24),
            // Specialist Tip Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF075985),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
                  const SizedBox(height: 16),
                  const Text(
                    "Dica de Especialista",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Avisos com imagens e títulos claros têm 40% mais visualizações. Use uma linguagem acolhedora para aumentar o engajamento da comunidade.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            // Final Action Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _publishAviso,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Publicar Aviso",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
        letterSpacing: 1.2,
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
        fillColor: const Color(0xFFF1F5F9).withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final bool currentMatch = _categoryMap[label] == _selectedTag;

    return GestureDetector(
      onTap: () => setState(() => _selectedTag = _categoryMap[label]!),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: currentMatch ? const Color(0xFF0369A1) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: currentMatch ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          style: BorderStyle.solid, // Custom dashed Painter could be used for 100% fidelity
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
            child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF1E40AF)),
          ),
          const SizedBox(height: 16),
          const Text(
            "Adicionar Imagem ou Documento",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            "PDF, JPG, PNG até 10MB",
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Future<void> _publishAviso() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha o título e o conteúdo.")),
      );
      return;
    }

    final userUid = ref.read(userProfileProvider).valueOrNull?.uid;
    if (userUid == null) return;

    final aviso = MuralAviso(
      title: _titleController.text,
      description: _contentController.text,
      tag: _selectedTag,
      time: "Recém publicado",
      createdAt: DateTime.now(),
    );

    await ref.read(communicationRepositoryProvider).saveMuralAviso(userUid, aviso);
    if (mounted) Navigator.pop(context);
  }
}
