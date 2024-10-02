import 'dart:convert';

import 'package:photo_lab/src/models/card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardsManager {
  static Future<void> addCard(CardModel card) async {
    List<CardModel> allCards = await getCardsList();
    List<CardModel> previousCards = await getCardsList(card.userId);

    if (previousCards.length == 0) {
      card.isDefault = true;
    }
    allCards.add(card);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('payment_cards', jsonEncode(allCards));
  }

  static Future<List<CardModel>> getCardsList([int userId = 0]) async {
    List<CardModel> cards = [];

    final prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString('payment_cards');
    if (json != null) {
      List<dynamic> list = jsonDecode(json);
      for (var element in list) {
        CardModel card = CardModel.fromJson(element);
        if (card.userId == userId || userId == 0) {
          cards.add(card);
        }
      }
    }

    return cards;
  }

  static Future<CardModel?> getDefaultCard(int userId) async {
    List<CardModel> cards = await getCardsList(userId);
    CardModel? defaultCard;
    for (int i = 0; i < cards.length; i++) {
      if (cards[i].isDefault) {
        defaultCard = cards[i];
        break;
      }
    }
    return defaultCard;
  }

  static Future<void> setDefaultCard(int position, int userId) async {

    List<CardModel> cards = await getCardsList(userId);

    for (int i = 0; i < cards.length; i++) {
      if (cards[i].userId == userId) {
        cards[i].isDefault = (i == position);
      }
    }

    List<CardModel> allCards = await getCardsList();
    List<CardModel> filteredCards =
    allCards.where((element) => element.userId != userId).toList();
    filteredCards.addAll(cards);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('payment_cards', jsonEncode(filteredCards));
  }

  static Future<void> deleteCard(int position, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    List<CardModel> cards = await getCardsList(userId);
    cards.removeAt(position);

    List<CardModel> allCards = await getCardsList();
    List<CardModel> filteredCards =
        allCards.where((element) => element.userId != userId).toList();
    filteredCards.addAll(cards);

    prefs.setString('payment_cards', jsonEncode(filteredCards));
  }
}