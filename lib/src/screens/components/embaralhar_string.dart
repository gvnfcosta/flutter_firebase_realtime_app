import 'dart:math';

String embaralharString(String texto) {
  if (texto.isEmpty) return texto;

  // Converte a string em uma lista de caracteres
  List<String> caracteres = texto.split('');

  // Cria uma instância do Random (melhor usar uma seed fixa se quiser resultado reproduzível)
  final random = Random();

  // Algoritmo Fisher-Yates (moderno e imparcial)
  for (int i = caracteres.length - 1; i > 0; i--) {
    int j = random.nextInt(i + 1);
    // Troca os elementos
    var temp = caracteres[i];
    caracteres[i] = caracteres[j];
    caracteres[j] = temp;
  }

  // Junta tudo de volta em uma string
  return caracteres.join('');
}
