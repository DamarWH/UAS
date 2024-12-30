// Importing necessary packages
import 'package:vania/vania.dart';
import '../../models/favorite.dart';
import 'package:vania/src/exception/validation_exception.dart';

class FavoriteController extends Controller {
  // Get all favorite items for a user
  Future<Response> index() async {
    try {
      final favoriteItems = await Favorite().query().get();
      return Response.json({'data': favoriteItems}, 200);
    } catch (e) {
      return Response.json(
          {'message': 'Gagal mengambil data favorite', 'error': e.toString()},
          500);
    }
  }

  // Add an item to the user's favorites
  Future<Response> create(Request request) async {
    try {
      request.validate({
        'user_id': 'required|integer',
        'shoes_id': 'required|integer',
      });

      final favoriteData = request.input();
      await Favorite().query().insert(favoriteData);

      return Response.json({
        'message': 'Item berhasil ditambahkan ke favorite',
        'data': favoriteData
      }, 201);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      }
      return Response.json(
          {'message': 'Terjadi kesalahan', 'error': e.toString()}, 500);
    }
  }

  // Show favorite items by user_id
  Future<Response> showByUserId(int userId) async {
    try {
      var favorites =
          await Favorite().query().where('user_id', '=', userId).get();

      if (favorites.isEmpty) {
        return Response.json({
          'message': 'Tidak ada data favorit untuk user dengan ID $userId.',
        }, 404);
      }

      return Response.json({
        'data': favorites,
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, 500);
    }
  }

  // Delete favorite item by user_id
  Future<Response> destroy(String id) async {
    try {
      final favoriteItem =
          await Favorite().query().where('user_id', '=', id).first();
      if (favoriteItem == null) {
        return Response.json({'message': 'Item favorite tidak ditemukan'}, 404);
      }

      await Favorite().query().where('user_id', '=', id).delete();
      return Response.json({'message': 'Item favorite berhasil dihapus'}, 200);
    } catch (e) {
      return Response.json(
          {'message': 'Terjadi kesalahan', 'error': e.toString()}, 500);
    }
  }
}

final FavoriteController favoriteController = FavoriteController();
