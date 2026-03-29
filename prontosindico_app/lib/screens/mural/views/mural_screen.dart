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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF0F172A)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Mural",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mural de Avisos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: grandisExtendedFont,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mantenha-se informado sobre as ultimas atualizacoes do seu condominio.',
                style: TextStyle(fontSize: 14, color: blackColor40),
              ),
              const SizedBox(height: defaultPadding * 1.5),

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
              const SizedBox(height: defaultPadding * 2),

              // Notices
              _buildNoticeCard(
                context,
                tag: 'IMPORTANTE',
                tagColor: secondaryColor,
                time: 'Postado ha 2 horas',
                title: 'Manutencao Preventiva dos Elevadores: Torre A e B',
                content: 'Informamos que na proxima terca-feira (24/10), os elevadores das Torres A e B passarao por uma manutencao tecnica obrigatoria entre 09:00 e 16:00. Solicitamos a compreensao de todos.',
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
                content: 'Venha celebrar a chegada da primavera conosco no salao de festas principal. Teremos musica ao vivo, buffet completo e atividades para as criancas.',
                hasAttachment: false,
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagColor),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: blackColor80),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 13, color: blackColor60, height: 1.5),
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
                      Text('Ler Mais', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: primaryColor),
                    ],
                  ),
                ),
                if (hasAttachment) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: blackColor5,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(attachmentName ?? 'Arquivo', style: const TextStyle(fontSize: 11, color: blackColor60)),
                        const SizedBox(width: 6),
                        const Icon(Icons.picture_as_pdf, color: errorColor, size: 16),
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
