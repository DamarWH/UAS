import 'package:vania/vania.dart';

class CreateBrandsTable extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('brands', () {
      primary('brand_id');
      bigIncrements('brand_id');
      string('name');
      text('description', nullable: true);
      timeStamps();
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('brands');
  }
}
