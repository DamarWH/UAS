import 'package:vania/vania.dart';
import '../../models/brand.dart'; // Import Brand model
import 'package:vania/src/exception/validation_exception.dart';

class BrandController extends Controller {
  // Menampilkan daftar semua brand
  Future<Response> index() async {
    try {
      var brands = await Brand().query().get();
      return Response.json({'data': brands});
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, 500);
    }
  }

  // Menampilkan brand berdasarkan ID
  Future<Response> show(int id) async {
    try {
      var brand = await Brand().query().where('id', '=', id).first();

      if (brand == null) {
        return Response.json({
          'message': 'Brand tidak ditemukan.',
        }, 404);
      }

      return Response.json({'data': brand});
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, 500);
    }
  }

  // Menambahkan data brand baru
  Future<Response> create(Request request) async {
    try {
      request.validate({
        'name': 'required|string',
        'description': 'required|string',
      }, {
        'name.required': 'Nama brand harus diisi.',
        'description.required': 'Deskripsi brand harus diisi.',
      });

      var input = request.input();
      await Brand().query().insert(input);

      return Response.json({
        'message': 'Brand berhasil ditambahkan.',
        'data': input,
      }, 201);
    } catch (e) {
      if (e is ValidationException) {
        final errorMessage = e.message;
        return Response.json({'errors': errorMessage}, 400);
      } else {
        return Response.json({
          'message': 'Terjadi kesalahan di sisi server.',
        }, 500);
      }
    }
  }

  // Mengupdate data brand berdasarkan ID
  Future<Response> update(Request request, int id) async {
    try {
      var brand = await Brand().query().where('id', '=', id).first();

      if (brand == null) {
        return Response.json({
          'message': 'Brand tidak ditemukan.',
        }, 404);
      }

      request.validate({
        'name': 'required|string',
        'description': 'required|string',
      }, {
        'name.required': 'Nama brand harus diisi.',
        'description.required': 'Deskripsi brand harus diisi.',
      });

      var input = request.input();
      await Brand().query().where('id', '=', id).update(input);

      return Response.json({
        'message': 'Brand berhasil diperbarui.',
        'data': input,
      }, 200);
    } catch (e) {
      if (e is ValidationException) {
        final errorMessage = e.message;
        return Response.json({'errors': errorMessage}, 400);
      } else {
        return Response.json({
          'message': 'Terjadi kesalahan di sisi server.',
          'error': e.toString(),
        }, 500);
      }
    }
  }

  // Menghapus brand berdasarkan ID
  Future<Response> destroy(int id) async {
    try {
      var brand = await Brand().query().where('id', '=', id).first();

      if (brand == null) {
        return Response.json({
          'message': 'Brand tidak ditemukan.',
        }, 404);
      }

      await Brand().query().where('id', '=', id).delete();

      return Response.json({
        'message': 'Brand berhasil dihapus.',
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, 500);
    }
  }
}

final BrandController brandController = BrandController();
