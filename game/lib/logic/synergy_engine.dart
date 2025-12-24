import '../models/card.dart';

class SynergyEngine {
  // Simple synergy: If deck has X cards of Type Y, grant +Z% effectiveness to that type
  // Or: All stats + N

  static double calculateEnhancement(List<Card> deck, CardType type) {
    int count = deck.where((c) => c.type == type).length;

    // Example Synergy:
    // 5+ Attack cards -> 10% bonus
    // 10+ Attack cards -> 25% bonus
    if (count >= 10) return 1.25;
    if (count >= 5) return 1.10;

    return 1.0;
  }
}
