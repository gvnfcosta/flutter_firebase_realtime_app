import 'dart:math';

String getLastChars(String value) {
  if (value.length <= 6) return value;
  return value.substring(value.length - 6);
}

String generateRandomId([int length = 10]) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random();
  return List.generate(
    length,
    (index) => chars[rand.nextInt(chars.length)],
  ).join();
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  // Lista de preposições e artigos comuns em português
  List<String> excecoes = ['de', 'da', 'do']; //, 'a', 'e', 'o'];

  return text
      .toLowerCase()
      .split(RegExp(' ')) // Divide por espaços, "(" ou ")"
      .map((word) {
    if (word.isEmpty) return ''; // Evita processar strings vazias

    // Remove a single trailing space if it is the last character
    if (word.endsWith('  ')) {
      word = word.substring(0, word.length - 2);
    }

    // Se a palavra está na lista de exceções, mantém minúscula
    if (excecoes.contains(word)) return word;

    // Se começa com "(", capitaliza a primeira letra depois do "("
    if (word.startsWith('(') && word.length > 1) {
      return '(${word[1].toUpperCase()}${word.substring(2)}';
    }

    // Capitaliza normalmente
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}
