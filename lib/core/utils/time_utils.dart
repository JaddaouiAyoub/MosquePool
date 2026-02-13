String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays >= 30) {
    return '${(difference.inDays / 30).floor()}mo ago';
  } else if (difference.inDays >= 7) {
    return '${(difference.inDays / 7).floor()}w ago';
  } else if (difference.inDays >= 1) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}
