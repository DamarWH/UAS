import 'package:vania/vania.dart';

class CreateFavoriteTable extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('favorite', () {
      primary('favorite_id');
      bigIncrements(
          'favorite_id'); // Create the favorite_id as auto-incremented primary key
      bigInt('user_id', unsigned: true); // Foreign key for users
      bigInt('shoes_id', unsigned: true); // Foreign key for shoes
      timeStamps();

      // Foreign key referencing 'users' table (id is the primary key)
      foreign('user_id', 'users', 'id', constrained: true, onDelete: 'CASCADE');

      // Foreign key referencing 'shoes' table (shoes_id is the primary key)
      foreign('shoes_id', 'shoes', 'shoes_id',
          constrained: true, onDelete: 'CASCADE');
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('favorite');
  }
}
