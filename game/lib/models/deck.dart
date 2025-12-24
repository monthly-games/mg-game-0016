import 'package:equatable/equatable.dart';
import 'card.dart';

class Deck extends Equatable {
  final List<Card> cards;

  const Deck({required this.cards});

  bool get isValid => cards.length == 30;

  @override
  List<Object?> get props => [cards];
}
