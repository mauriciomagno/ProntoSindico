import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gerencia o índice da aba selecionada no EntryPoint.
/// Permite que qualquer tela troque de aba (ex: Home para Avisos).
final navigationProvider = StateProvider<int>((ref) => 0);
