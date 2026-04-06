import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/domain/entities/reserva.dart';
import 'package:prontosindico/providers/reserva_providers.dart';

class CreateAreaComumScreen extends ConsumerStatefulWidget {
  const CreateAreaComumScreen({super.key});

  @override
  ConsumerState<CreateAreaComumScreen> createState() =>
      _CreateAreaComumScreenState();
}

class _CreateAreaComumScreenState extends ConsumerState<CreateAreaComumScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  final _imageController = TextEditingController();

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
          "Novo Espaço Comum",
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
              onPressed: _saveArea,
              child: const Text(
                "Salvar",
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
            _buildLabel("NOME DO ESPAÇO"),
            const SizedBox(height: 12),
            _buildTextField(
                _nameController, "Ex: Salão de Festas, Churrasqueira..."),

            const SizedBox(height: 32),
            _buildLabel("CAPACIDADE MÁXIMA"),
            const SizedBox(height: 12),
            _buildTextField(_capacityController, "Ex: 50",
                keyboardType: TextInputType.number),

            const SizedBox(height: 32),
            _buildLabel("DESCRIÇÃO DOS RECURSOS"),
            const SizedBox(height: 12),
            _buildTextField(_descriptionController,
                "Ex: Cozinha completa, Ar-condicionado, Mesas...",
                maxLines: 4),

            const SizedBox(height: 32),
            _buildLabel("URL DA IMAGEM"),
            const SizedBox(height: 12),
            _buildTextField(
                _imageController, "Insira o link de uma foto do local"),

            const SizedBox(height: 32),
            _buildLabel("ANEXOS ADICIONAIS"),
            const SizedBox(height: 12),
            _buildAttachmentBox(),

            const SizedBox(height: 32),
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
                  const Icon(Icons.verified_user_outlined,
                      color: Colors.white, size: 24),
                  const SizedBox(height: 16),
                  const Text(
                    "Dica de Gestão",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Espaços com descrições detalhadas e fotos reais evitam dúvidas dos moradores e reduzem o trabalho da portaria na entrega das chaves.",
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
                onPressed: _saveArea,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Cadastrar Espaço",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.add_business_outlined,
                        color: Colors.white, size: 20),
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

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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

  Widget _buildAttachmentBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
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
            child: const Icon(Icons.image_outlined, color: Color(0xFF1E40AF)),
          ),
          const SizedBox(height: 16),
          const Text(
            "Carregar Foto da Área",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            "JPG, PNG até 5MB",
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveArea() async {
    if (_nameController.text.isEmpty || _capacityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha o nome e a capacidade.")),
      );
      return;
    }

    final area = AreaComum(
      id: '', // Will be generated by Firebase push().id
      nome: _nameController.text,
      descricao: _descriptionController.text,
      imagem: _imageController.text.isNotEmpty
          ? _imageController.text
          : 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&q=80&w=800',
      capacidade: int.tryParse(_capacityController.text) ?? 0,
    );

    await ref.read(reservaRepositoryProvider).saveAreaComum(area);
    if (mounted) Navigator.pop(context);
  }
}
