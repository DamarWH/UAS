import 'dart:io';
import 'package:backend/app/models/shoes.dart';
import 'package:vania/vania.dart';
import 'package:vania/src/exception/validation_exception.dart';

class ShoesController extends Controller {
  // Menampilkan semua data sepatu
  Future<Response> index() async {
    try {
      var shoes = await Shoes().query().get();
      return Response.json({'data': shoes}, HttpStatus.ok);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, HttpStatus.internalServerError);
    }
  }

  // Menampilkan sepatu berdasarkan ID
  Future<Response> show(int id) async {
    try {
      var shoe = await Shoes().query().where('shoes_id', '=', id).first();

      if (shoe == null) {
        return Response.json({
          'message': 'Sepatu dengan ID $id tidak ditemukan.',
        }, HttpStatus.notFound);
      }

      return Response.json({'data': shoe}, HttpStatus.ok);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, HttpStatus.internalServerError);
    }
  }

  // Menambahkan sepatu baru
  Future<Response> create(Request request) async {
    try {
      // Validasi input
      request.validate({
        'sepatu_type': 'required|string',
        'model_name': 'required|string',
        'size': 'required|integer',
        'harga': 'required|double',
        'warna': 'required|string',
        'image_url': 'nullable|string',
        'manual_url': 'nullable|string',
        'brand_id': 'required|integer',
      }, {
        'sepatu_type.required': 'Tipe sepatu harus diisi.',
        'model_name.required': 'Nama model harus diisi.',
        'size.required': 'Ukuran harus diisi.',
        'size.integer': 'Ukuran harus berupa angka.',
        'harga.required': 'Harga harus diisi.',
        'harga.double': 'Harga harus berupa angka desimal.',
        'warna.required': 'Warna harus diisi.',
        'brand_id.required': 'ID brand harus diisi.',
      });

      var input = request.input();

      // Menambahkan sepatu baru
      await Shoes().query().insert(input);

      return Response.json({
        'message': 'Sepatu berhasil ditambahkan.',
        'data': input,
      }, HttpStatus.created);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, HttpStatus.badRequest);
      }
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, HttpStatus.internalServerError);
    }
  }

  // Memperbarui data sepatu berdasarkan ID
  Future<Response> update(Request request, int id) async {
    try {
      // Validasi input
      request.validate({
        'sepatu_type': 'required|string',
        'model_name': 'required|string',
        'size': 'required|integer',
        'harga': 'required|double|min:0',
        'warna': 'required|string',
        'image_url': 'nullable|string',
        'manual_url': 'nullable|string',
        'brand_id': 'required|integer',
      }, {
        'sepatu_type.required': 'Tipe sepatu harus diisi.',
        'model_name.required': 'Nama model harus diisi.',
        'size.required': 'Ukuran harus diisi.',
        'size.integer': 'Ukuran harus berupa angka.',
        'harga.required': 'Harga harus diisi.',
        'harga.double': 'Harga harus berupa angka desimal.',
        'harga.min': 'Harga tidak boleh negatif.',
        'warna.required': 'Warna harus diisi.',
        'brand_id.required': 'ID brand harus diisi.',
      });

      var shoe = await Shoes().query().where('shoes_id', '=', id).first();
      if (shoe == null) {
        return Response.json({
          'message': 'Sepatu dengan ID $id tidak ditemukan.',
        }, HttpStatus.notFound);
      }

      var input = request.input();
      input.remove('shoes_id'); // Hindari pengubahan ID

      // Memperbarui sepatu
      var updated =
          await Shoes().query().where('shoes_id', '=', id).update(input);

      if (updated == 0) {
        return Response.json({
          'message': 'Tidak ada perubahan pada data sepatu.',
        }, HttpStatus.noContent); // Return No Content when no update occurred
      }

      var updatedShoe =
          await Shoes().query().where('shoes_id', '=', id).first();
      return Response.json({
        'message': 'Sepatu berhasil diperbarui.',
        'data': updatedShoe,
      }, HttpStatus.ok);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, HttpStatus.badRequest);
      }
      print('Error: $e');
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, HttpStatus.internalServerError);
    }
  }

  // Menghapus sepatu berdasarkan ID
  Future<Response> destroy(int id) async {
    try {
      var shoe = await Shoes().query().where('shoes_id', '=', id).first();

      if (shoe == null) {
        return Response.json({
          'message': 'Sepatu dengan ID $id tidak ditemukan.',
        }, HttpStatus.notFound);
      }

      await Shoes().query().where('shoes_id', '=', id).delete();

      return Response.json({
        'message': 'Sepatu berhasil dihapus.',
      }, HttpStatus.ok);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString(),
      }, HttpStatus.internalServerError);
    }
  }
}

final ShoesController shoesController = ShoesController();
