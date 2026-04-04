import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:prontosindico/constants.dart';

import 'package:prontosindico/components/app_drawer.dart';

class MuralScreen extends StatelessWidget {
  const MuralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Cabeçalho fixo (congelado)
          Container(
            color: const Color(0xFFF8FAFC),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (ctx) => IconButton(
                          icon: const Icon(Icons.menu, color: primaryColor),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          "Mural de Avisos",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none,
                            color: Color(0xFF0F172A)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mantenha-se informado sobre as últimas atualizações do seu condomínio.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: blackColor10),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Filtrar avisos...',
                        hintStyle: TextStyle(fontSize: 14, color: blackColor20),
                        icon: Icon(Icons.search, color: blackColor20, size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Conteúdo rolável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notices
                  _buildNoticeCard(
                    context,
                    tag: 'IMPORTANTE',
                    tagColor: secondaryColor,
                    time: 'Postado ha 2 horas',
                    title: 'Manutencao Preventiva dos Elevadores: Torre A e B',
                    content:
                        'Informamos que na proxima terca-feira (24/10), os elevadores das Torres A e B passarao por uma manutencao tecnica obrigatoria entre 09:00 e 16:00. Solicitamos a compreensao de todos.',
                    hasAttachment: true,
                    attachmentName: 'Cronograma.pdf',
                  ),
                  const SizedBox(height: defaultPadding),
                  _buildNoticeCard(
                    context,
                    tag: 'SOCIAL',
                    tagColor: const Color(0xFF00D1FF),
                    time: 'Postado ontem',
                    title: 'Festa da Primavera: Convite Especial',
                    content:
                        'Venha celebrar a chegada da primavera conosco no salao de festas principal. Teremos musica ao vivo, buffet completo e atividades para as criancas.',
                    hasAttachment: false,
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(
    BuildContext context, {
    required String tag,
    required Color tagColor,
    required String time,
    required String title,
    required String content,
    required bool hasAttachment,
    String? attachmentName,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: blackColor10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: tagColor),
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(fontSize: 10, color: blackColor20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: blackColor80),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                  fontSize: 13, color: blackColor60, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      Text('Ler Mais',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryColor)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: primaryColor),
                    ],
                  ),
                ),
                if (hasAttachment) ...[
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: blackColor5,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(attachmentName ?? 'Arquivo',
                            style: const TextStyle(
                                fontSize: 11, color: blackColor60)),
                        const SizedBox(width: 6),
                        const Icon(Icons.picture_as_pdf,
                            color: errorColor, size: 16),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
