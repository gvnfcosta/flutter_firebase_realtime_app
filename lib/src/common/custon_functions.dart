String getLastChars(String value) {
  if (value.length <= 6) return value;
  return value.substring(value.length - 6);
}
