import 'package:backend/app/models/user.dart';
import 'package:vania/vania.dart';
import 'package:vania/src/exception/validation_exception.dart';

class UserController extends Controller {
  // Get the profile information of the logged-in user
  Future<Response> index() async {
    Map? user = Auth().user();
    user?.remove('password'); // Don't send password data
    return Response.json(user);
  }

  // Update the username of the logged-in user
  Future<Response> updateUsername(Request request) async {
    try {
      request.validate({
        'username': 'required|string|min:3|max:30',
      });

      String username = request.input('username');
      Map? user = Auth().user();
      if (user == null) {
        return Response.json({'message': 'User not authenticated'}, 401);
      }

      // Update username logic
      await User().query().where('id', '=', user['id']).update({
        'username': username,
      });

      return Response.json({
        'message': 'Username successfully updated',
      }, 200);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      }
      return Response.json(
          {'message': 'Error updating username', 'error': e.toString()}, 500);
    }
  }

  // Handle forgotten password (could involve sending a reset link or code)
  Future<Response> forgotPassword(Request request) async {
    try {
      request.validate({
        'email': 'required|email',
      });

      String email = request.input('email');

      // Find user by email
      var user = await User().query().where('email', '=', email).first();

      if (user == null) {
        return Response.json({'message': 'Email not found'}, 404);
      }

      // You could implement sending a reset link, email, or code here.
      // For now, just return a success response
      return Response.json({
        'message': 'Password reset link has been sent to your email.',
      }, 200);
    } catch (e) {
      return Response.json(
          {'message': 'Error processing request', 'error': e.toString()}, 500);
    }
  }
}

final UserController userController = UserController();
