import 'dart:io';
import 'package:backend/database/migrations/create_brand_table.dart';
import 'package:backend/database/migrations/create_favorite_table.dart';
import 'package:backend/database/migrations/create_shoes_table.dart';
import 'package:vania/vania.dart';
import 'create_users_table.dart';
import 'create_personal_access_tokens_table.dart';

void main(List<String> args) async {
  await MigrationConnection().setup();
  if (args.isNotEmpty && args.first.toLowerCase() == "migrate:fresh") {
    await Migrate().dropTables();
  } else {
    await Migrate().registry();
  }
  await MigrationConnection().closeConnection();
  exit(0);
}

class Migrate {
  registry() async {
    await CreateUsersTable().up();
    await CreateBrandsTable().up();
    await CreateSepatuTable().up();
    await CreateFavoriteTable().up();
    await CreatePersonalAccessTokensTable().up();
  }

  dropTables() async {
    await CreatePersonalAccessTokensTable().down();
    await CreateUsersTable().down();
    await CreateBrandsTable().down();
    await CreateSepatuTable().down();
    await CreateFavoriteTable().down();
  }
}
