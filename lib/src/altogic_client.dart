part of altogic_dart;

ClientOptions _defaultOptions = ClientOptions();



AltogicClient createClient(){
  throw UnimplementedError();
}


/// Dart client for interacting with your backend applications
/// developed in Altogic.
///
/// AltogicClient is the main object that you will be using to issue commands
/// to your backend apps. The commands that you can run are grouped below:
///
/// * [auth] : [AuthManager] - Manage users and user sessions
/// * [endpoint] : [EndpointManager] - Make http requests to your app
/// endpoints and execute associated services
/// * [db] : [DatabaseManager] - Perform CRUD (including lookups,
/// filtering, sorting, pagination) operations in your app database
/// * [queue] : [QueueManager] - Enables you to run long-running jobs
/// asynchronously by submitting messages to queues
/// * [cache] : [CacheManager] - Store and manage your data objects in
/// high-speed data storage layer (Redis)
/// * [task] : [TaskManager] - Manually trigger execution of
/// scheduled tasks (e.g., cron jobs)
///
/// Each AltogicClient can interact with one of your app environments
/// (e.g., development, test, production). You cannot create a single
/// client to interact with multiple development, test or production
/// environments at the same time. If you would like to issue commands
/// to other environments, you need to create additional AltogicClient
/// objects using the target environment's `envUrl`.
class AltogicClient {
  /// Create a new client for web applications.
  /// [envUrl] The unique app environment base URL which is generated when
  /// you create an environment (e.g., development, test, production) for
  /// your backend app. You can access [envUrl] of your app environment from
  /// the Environments panel in Altogic designer. Note that, an AltogicClient
  /// object can only access a single app environment, you cannot use a
  /// development environment [envUrl] to access a test or production
  /// environment. To access other environments you need to create additional
  /// Altogic client objects with their respective [envUrl] values.
  /// [clientKey] The client library key of the app. You can create client
  /// keys from the **App Settings/Client Library** panel in Altogic designer.
  /// Besides authenticating your client, client keys are also used to define
  /// the authorization rights of each client, e.g., what operations they are
  /// allowed to perform on your backend app and define the authorized domains
  /// where the client key can be used (e.g., if you list your app domains in
  /// your client key configuration, that client key can only be used to make
  /// calls to your backend from a front-end app that runs on those specific
  /// domains)
  /// [settings] Configuration options for the api client
  /// Throws an exception if [envUrl] is not specified or not a valid URL path
  /// or [clientKey] is not specified
  AltogicClient(
      {required String envUrl,
      required String clientKey,
      ClientOptions? settings}) {
    if (!(envUrl.trim().startsWith('http://') ||
        envUrl.trim().startsWith('https://'))) {
      throw ClientError('missing_required_value',
          'envUrl is a required parameter and needs to start with https://');
    }
    this.settings = _defaultOptions._merge(settings);

    // Set the default headers
    var headers = <String, String>{
      'X-Client': 'altogic-js',
      'X-Client-Key': clientKey,
    };

    // If apiKey is provided, add it to the default headers
    if (this.settings.apiKey != null) {
      headers['Authorization'] = this.settings.apiKey!;
    }
    // Create the http client to manage RESTful API calls
    _fetcher = Fetcher(this, normalizeUrl(envUrl), headers);
  }

  /// Restore auth session that saved from local storage.
  ///
  /// Will use [ClientOptions.localStorage] for local storage operations.
  Future<void> restoreLocalAuthSession() async {
    var session = await auth.getSession();
    if (session != null) {
      _fetcher.setSession(session);
    }
  }

  /// HTTP client for the dart native,js and Flutter.
  /// Primarily used to make RESTful API calls you your backend app.
  /// Each command that issue through the client library uses the fetcher
  /// to relay it to your backend app.
  late Fetcher _fetcher;

  /// Altogic client options
  late final ClientOptions settings;

  /// [AuthManager] object is used to manage user authentication and sessions
  AuthManager? _authManager;

  /// [EndpointManager] object is used to make http requests to your app
  /// endpoints.
  EndpointManager? _endpointManager;

  /// CacheManager object is used to store and manage objects in Redis cache
  CacheManager? _cacheManager;

  /// [QueueManager] object is used to submit messages to a message queue for
  /// asynchronous processing
  QueueManager? _queueManager;

  /// [TaskManager] object is used to trigger execution of scheduled tasks
  /// (e.g., cron jobs) manually
  TaskManager? _taskManager;

  /// [DatabaseManager] object is used to perform CRUD (create, read, update
  /// and delete) and run queries in your app's database
  DatabaseManager? _databaseManager;

  /// [StorageManager] object is used to manage the buckets and files of your
  /// app's cloud storage.
  StorageManager? _storageManager;

  /// Returns the authentication manager that can be used to perform user
  /// and session management activities.
  AuthManager get auth => _authManager ??= AuthManager(_fetcher, settings);

  /// Returns the endpoint manager which is used to make http requests to
  /// your app endpoints and execute associated services.
  EndpointManager get endpoint =>
      _endpointManager ??= EndpointManager(_fetcher);

  /// Returns the cache manager which is used to store and manage objects
  /// in Redis cache.
  CacheManager get cache => _cacheManager ??= CacheManager(_fetcher);

  /// Returns the queue manager which is used to submit messages to a
  /// message queue for processing.
  QueueManager get queue => _queueManager ??= QueueManager(_fetcher);

  /// Returns the task manager which is used to trigger scheduled tasks
  /// (e.g., cron jobs) for execution.
  TaskManager get task => _taskManager ??= TaskManager(_fetcher);

  /// Returns the database manager, which is used to perform CRUD (create, read,
  /// update and delete) and run queries in your app's database.
  DatabaseManager get db => _databaseManager ??= DatabaseManager(_fetcher);

  /// Returns the storage manager, which is used to manage buckets and files
  /// of your app.
  StorageManager get storage => _storageManager ??= StorageManager(_fetcher);
}
