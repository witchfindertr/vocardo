import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocardo/core/service/card/card_list_provider.dart';

part 'current_card_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentCard extends _$CurrentCard {
  @override
  Future<CardItem?> build() async {
    final cards = ref.watch(cardListProvider);

    if (cards.valueOrNull == null) {
      return null;
    }
    return Future.value(cards.valueOrNull!.elementAt(0));
  }

  next() async {
    final cardsRef = ref.read(cardListProvider);
    if (state.valueOrNull == null || cardsRef.valueOrNull == null) {
      return;
    }
    final cards = cardsRef.valueOrNull!;
    final card = state.valueOrNull!;
    if (cards.last == card) {
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return cards.elementAt(cards.indexOf(card) + 1);
    });
  }
}
