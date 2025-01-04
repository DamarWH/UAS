import 'package:vania/vania.dart';

class CreateSepatuTable extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('shoes', () {
      primary('shoes_id');
      bigIncrements('shoes_id');
      bigInt('brand_id', unsigned: true);
      string('sepatu_type');
      string('model_name');
      integer('size');
      integer('harga');
      string('warna');
      string('image_url', nullable: true);
      string('manual_url', nullable: true);
      text('description', nullable: true);
      timeStamps();

      foreign('brand_id', 'brands', 'brand_id',
          constrained: true); // Pastikan merujuk ke brand_id
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('shoes');
  }
}
