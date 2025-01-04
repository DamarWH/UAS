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

  Future<Response> updateProfile(Request request) async {
    try {
      // Log the request body to debug
      print('Request Body: ${request.body}'); // Debugging line

      // Validate the incoming fields
      request.validate({
        'username': 'required|string|min:3|max:30',
        'email': 'required|email', // You may omit email if not needed
      });

      String username = request.input('username');
      String email = request.input('email');

      // Log the values for debugging
      print('Received Username: $username'); // Debugging line
      print('Received Email: $email'); // Debugging line

      Map? user = Auth().user();
      if (user == null) {
        return Response.json({'message': 'User not authenticated'}, 401);
      }

      // Check if the email is unique (if necessary)
      var existingUser =
          await User().query().where('email', '=', email).first();
      if (existingUser != null && existingUser['id'] != user['id']) {
        return Response.json({'message': 'Email is already taken'}, 400);
      }

      // Update user profile (username, email, etc.)
      await User().query().where('id', '=', user['id']).update({
        'username': username,
        'email': email, // Update email if necessary, or omit
      });

      return Response.json({
        'message': 'Profile successfully updated',
      }, 200);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      }
      return Response.json(
          {'message': 'Error updating profile', 'error': e.toString()}, 500);
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
      return Response.json({
        'message': 'Password reset link has been sent to your email.',
      }, 200);
    } catch (e) {
      return Response.json(
          {'message': 'Error processing request', 'error': e.toString()}, 500);
    }
  }

  Future<Response> delete() async {
    try {
      // Get the authenticated user
      Map? user = Auth().user();

      if (user == null) {
        return Response.json({'message': 'User not authenticated'}, 401);
      }

      // Check if the user exists
      var existingUser =
          await User().query().where('id', '=', user['id']).first();
      if (existingUser == null) {
        return Response.json({'message': 'User not found'}, 404);
      }

      // Delete the user
      await User().query().where('id', '=', user['id']).delete();

      return Response.json({'message': 'Account successfully deleted'}, 200);
    } catch (e) {
      return Response.json(
          {'message': 'Error deleting account', 'error': e.toString()}, 500);
    }
  }
}

final UserController userController = UserController();
