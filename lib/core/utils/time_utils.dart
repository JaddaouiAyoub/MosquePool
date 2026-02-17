String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays >= 30) {
    return 'il y a ${(difference.inDays / 30).floor()} mois';
  } else if (difference.inDays >= 7) {
    return 'il y a ${(difference.inDays / 7).floor()} sem';
  } else if (difference.inDays >= 1) {
    return 'il y a ${difference.inDays} j';
  } else if (difference.inHours >= 1) {
    return 'il y a ${difference.inHours} h';
  } else if (difference.inMinutes >= 1) {
    return 'il y a ${difference.inMinutes} min';
  } else {
    return "À l'instant";
  }
}
