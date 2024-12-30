import 'package:backend/app/models/brand.dart';
import 'package:backend/app/models/shoes.dart';
import 'package:vania/vania.dart';
import 'package:vania/src/exception/validation_exception.dart';

class ShoesController extends Controller {
  Future<Response> index() async {
    try {
      var shoes = await Shoes().query().get();
      return Response.json({'data': shoes});
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, 500);
    }
  }

  // Menampilkan sepatu berdasarkan ID
  Future<Response> show(int id) async {
    try {
      var shoe = await Shoes().query().where('shoes_id', '=', id).first();

      if (shoe == null) {
        return Response.json({
          'message': 'Sepatu dengan ID $id tidak ditemukan.',
        }, 404);
      }

      var brand = await Brand()
          .query()
          .where('brand_id', '=', shoe['brand_id'])
          .first();

      return Response.json({
        'data': {'shoe': shoe, 'brand': brand},
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, 500);
    }
  }

  // Menambahkan sepatu baru
  Future<Response> create(Request request) async {
    try {
      // Validasi input
      request.validate({
        'brand_id': 'required|integer',
        'sepatu_type': 'required|string',
        'model_name': 'required|string',
        'size': 'required|integer',
        'harga': 'required|double',
        'warna': 'required|string',
      }, {
        'brand_id': 'Brand ID harus diisi dan berupa angka.',
        'sepatu_type': 'Tipe sepatu harus diisi.',
        'model_name': 'Nama model sepatu harus diisi.',
        'size': 'Ukuran sepatu harus berupa angka.',
        'harga': 'Harga sepatu harus berupa angka desimal.',
        'warna': 'Warna sepatu harus diisi.',
      });

      var input = request.input();

      // Memastikan brand_id valid
      var brand = await Brand()
          .query()
          .where('brand_id', '=', input['brand_id'])
          .first();
      if (brand == null) {
        return Response.json({
          'message': 'Brand dengan ID ${input['brand_id']} tidak ditemukan.',
        }, 400);
      }

      // Menambahkan sepatu baru
      await Shoes().query().insert(input);

      return Response.json({
        'message': 'Sepatu berhasil ditambahkan.',
        'data': input,
      }, 201);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      }
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, 500);
    }
  }

  // Mengupdate sepatu berdasarkan ID
  Future<Response> update(Request request, int id) async {
    try {
      var shoe = await Shoes().query().where('shoes_id', '=', id).first();

      if (shoe == null) {
        return Response.json({
          'message': 'Sepatu dengan ID $id tidak ditemukan.',
        }, 404);
      }

      request.validate({
        'brand_id': 'required|integer',
        'sepatu_type': 'required|string',
        'model_name': 'required|string',
        'size': 'required|integer',
        'harga': 'required|double',
        'warna': 'required|string',
      }, {
        'brand_id': 'Brand ID harus diisi dan berupa angka.',
        'sepatu_type': 'Tipe sepatu harus diisi.',
        'model_name': 'Nama model sepatu harus diisi.',
        'size': 'Ukuran sepatu harus berupa angka.',
        'harga': 'Harga sepatu harus berupa angka desimal.',
        'warna': 'Warna sepatu harus diisi.',
      });

      var input = request.input();

      // Memperbarui data sepatu
      await Shoes().query().where('shoes_id', '=', id).update(input);

      return Response.json({
        'message': 'Sepatu berhasil diperbarui.',
        'data': input,
      }, 200);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      }
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, 500);
    }
  }

  // Menghapus sepatu berdasarkan ID
  Future<Response> destroy(int id) async {
    try {
      var shoe = await Shoes().query().where('shoes_id', '=', id).first();

      if (shoe == null) {
        return Response.json({
          'message': 'Sepatu dengan ID $id tidak ditemukan.',
        }, 404);
      }

      // Menghapus sepatu
      await Shoes().query().where('shoes_id', '=', id).delete();

      return Response.json({
        'message': 'Sepatu berhasil dihapus.',
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, 500);
    }
  }
}

final ShoesController shoesController = ShoesController();
