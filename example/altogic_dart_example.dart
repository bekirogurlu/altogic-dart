import 'package:altogic_dart/altogic_dart.dart';

Future<void> main() async {
  var client = AltogicClient(
      envUrl: 'https://c1-na.altogic.com/e:62863f06bb75ed002ed0f207',
      clientKey: '5ad8526dbd014613a8dbeff60daa7c26');

  var signIn =
      await client.auth.signInWithEmail('mehmedyaz@gmail.com', 'mehmetyaz');

  print(signIn.errors);

  print(signIn.session?.toJson());
  print(signIn.user?.toJson());

  await client.endpoint.get('path').asList();

  ///
  ///
}
