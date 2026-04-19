import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class FavoritesService {
  static const String _favoritesKey = 'favorite_symbols';

  final SharedPreferences _prefs;

  FavoritesService(this._prefs);

  /// Get list of favorite symbols
  Future<List<String>> getFavoriteSymbols() async {
    final favorites = _prefs.getStringList(_favoritesKey) ?? [];
    return favorites;
  }

  /// Check if symbol is favorited
  Future<bool> isFavorite(String symbol) async {
    final favorites = await getFavoriteSymbols();
    return favorites.contains(symbol);
  }

  /// Add symbol to favorites
  Future<bool> addFavorite(String symbol) async {
    final favorites = await getFavoriteSymbols();
    if (!favorites.contains(symbol)) {
      favorites.add(symbol);
      return await _prefs.setStringList(_favoritesKey, favorites);
    }
    return true;
  }

  /// Remove symbol from favorites
  Future<bool> removeFavorite(String symbol) async {
    final favorites = await getFavoriteSymbols();
    if (favorites.contains(symbol)) {
      favorites.remove(symbol);
      return await _prefs.setStringList(_favoritesKey, favorites);
    }
    return true;
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String symbol) async {
    final isFav = await isFavorite(symbol);
    if (isFav) {
      return await removeFavorite(symbol);
    } else {
      return await addFavorite(symbol);
    }
  }
}
