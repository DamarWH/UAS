import 'package:backend/app/http/controllers/auth_controller.dart';
import 'package:backend/app/http/controllers/brand_controller.dart';
import 'package:backend/app/http/controllers/favorite_controller.dart';
import 'package:backend/app/http/controllers/shoes_contoller.dart';
import 'package:backend/app/http/controllers/user_controller.dart';
import 'package:vania/vania.dart';
import '../app/http/middleware/authenticate.dart';

class ApiRoute implements Route {
  @override
  void register() {
    /// Base RoutePrefix
    Router.basePrefix('api');

    Router.group(() {
      Router.post('register', authController.register);
      Router.post('login', authController.login);
    }, prefix: 'auth');

    /// Brands routes
    Router.group(() {
      Router.get('brands', brandController.index);
      Router.post('brands', brandController.create);
      Router.put('brands/{id}', brandController.update);
      Router.delete('brands/{id}', brandController.destroy);
    }, middleware: [AuthenticateMiddleware()]);

    /// Shoes routes
    Router.group(() {
      Router.get('shoes', shoesController.index); // List all shoes
      Router.get('shoes/{id}', shoesController.show); // Get shoe by ID
      Router.post('shoes', shoesController.create); // Create a new shoe
      Router.put(
          'shoes/update/{shoes_id}', shoesController.update); // Update a shoe
      Router.delete(
          'shoes/delete/{id}', shoesController.destroy); // Delete a shoe
    }, middleware: [AuthenticateMiddleware()]);

    /// Favorites routes
    Router.group(() {
      Router.post('favorites', favoriteController.create);
      Router.get('favorites', favoriteController.showByUserId);
      Router.delete('favorites', favoriteController.destroy);
    }, middleware: [AuthenticateMiddleware()]);

    /// User routes
    Router.group(() {
      Router.get('profile', userController.index);
      Router.put('update', userController.updateProfile);
      Router.post('forgotpass', userController.forgotPassword);
      Router.delete('/user/delete', userController.delete);
    }, prefix: 'user', middleware: [AuthenticateMiddleware()]);
  }
}
