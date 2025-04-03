using MongoDB.Bson;
using MongoDB.Driver;
using System.Diagnostics;


namespace AdmonBD.Contexto
{

    public class MongoDBService
    {
        private readonly MongoClient _client;
        private const string DockerContainerName = "mongodb";


        public MongoDBService(IConfiguration config)
        {
            var connectionString = config.GetConnectionString("MongoDB");
            _client = new MongoClient(connectionString);
        }

        // Obtener todas las bases de datos existentes
        public List<string> ObtenerBasesDeDatos()
        {
            return _client.ListDatabaseNames().ToList();
        }

        // Obtener todas las colecciones de una base de datos
        public List<string> ObtenerColecciones(string baseDeDatos)
        {
            var db = _client.GetDatabase(baseDeDatos);
            return db.ListCollectionNames().ToList();
        }

        // Crear una nueva base de datos (MongoDB la crea automáticamente al insertar datos)
        public void CrearBaseDeDatos(string nombreBase)
        {
            var db = _client.GetDatabase(nombreBase);
            db.CreateCollection("default_collection");
        }

        // Crear una nueva colección en una base de datos específica
        public void CrearColeccion(string nombreBase, string nombreColeccion)
        {
            var db = _client.GetDatabase(nombreBase);
            db.CreateCollection(nombreColeccion);
        }

        // Insertar un documento genérico en cualquier colección
        public void InsertarDocumento(string nombreBase, string nombreColeccion, Dictionary<string, object> datos)
        {
            var db = _client.GetDatabase(nombreBase);
            var collection = db.GetCollection<BsonDocument>(nombreColeccion);

            // Convertir el diccionario en un BsonDocument válido
            var documento = new BsonDocument();
            foreach (var kvp in datos)
            {
                documento[kvp.Key] = BsonValue.Create(kvp.Value);
            }

            collection.InsertOne(documento);
        }
        // Método para eliminar una base de datos
        public void EliminarBaseDeDatos(string nombreBase)
        {
            _client.DropDatabase(nombreBase);
        }

        // Método para eliminar una colección de una base de datos específica
        public void EliminarColeccion(string nombreBase, string nombreColeccion)
        {
            try
            {
                var db = _client.GetDatabase(nombreBase);
                db.DropCollection(nombreColeccion);
            }
            catch (Exception ex)
            {
                // Loguear el error si es necesario
                throw new Exception($"Error al eliminar la colección: {ex.Message}");
            }
        }

        public List<BsonDocument> ObtenerDocumentos(string nombreBase, string nombreColeccion)
        {
            var db = _client.GetDatabase(nombreBase);
            var collection = db.GetCollection<BsonDocument>(nombreColeccion);
            return collection.Find(new BsonDocument()).ToList();
        }
        public void RealizarBackup(string nombreBase, string backupFolder)
        {
            try
            {
                string backupPath = Path.Combine(backupFolder, nombreBase);
                if (Directory.Exists(backupPath))
                {
                    Directory.Delete(backupPath, true); // Elimina el directorio y su contenido
                }

                // Asegúrate de que el directorio de backup esté creado después de eliminarlo
                Directory.CreateDirectory(backupPath);

                // Asegúrate de que el directorio dentro del contenedor sea accesible
                string contenedorBackupPath = $"/backup/{nombreBase}";

                // Ahora ejecutamos el comando para hacer el backup
                string command = $"docker exec mongodb mongodump --db {nombreBase} --out={contenedorBackupPath} --username donaji --password 123456 --authenticationDatabase admin";
                EjecutarComando(command);

                Console.WriteLine("Backup realizado con éxito.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error al realizar el backup: {ex.Message}");
            }
        }

        public void RestaurarBackup(string nombreBase, string backupFolder)
        {
            var command = $"docker exec {DockerContainerName} mongorestore --username donaji --password 123456 --authenticationDatabase admin --drop --db {nombreBase} {backupFolder}";
            EjecutarComando(command);
        }
        private void EjecutarComando(string command)
        {
            var processStartInfo = new ProcessStartInfo
            {
                FileName = "powershell.exe",
                Arguments = $"-c \"{command}\"",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            using (var process = Process.Start(processStartInfo))
            {
                string output = process.StandardOutput.ReadToEnd();
                string error = process.StandardError.ReadToEnd();
                process.WaitForExit();

                if (process.ExitCode != 0)
                {
                    throw new Exception($"Error ejecutando comando: {error}");
                }
            }
        }
        public void CopiarBackupDesdeContenedor(string backupFolder, string nombreBase)
        {
            // Define la ruta del backup dentro del contenedor y la ruta donde deseas guardarlo en el sistema local
            var contenedorBackupPath = $"/backup/{nombreBase}";
            var localBackupPath = Path.Combine(backupFolder, nombreBase);

            var comandoCopiar = $"docker cp mongodb:{contenedorBackupPath} {localBackupPath}";

            EjecutarComando(comandoCopiar);
        }
        public void CrearUsuario(string usuario, string contraseña, string[] roles)
        {
            var db = _client.GetDatabase("admin");
            var command = new BsonDocument
            {
                { "createUser", usuario },
                { "pwd", contraseña },
                { "roles", new BsonArray(roles.Select(role => new BsonDocument { { "role", role }, { "db", "miBaseDeDatos" } })) }
            };

            db.RunCommand<BsonDocument>(command);
        }
        public void EliminarUsuario(string usuario)
        {
            var db = _client.GetDatabase("admin");
            var command = new BsonDocument
            {
                { "dropUser", usuario }
            };

            db.RunCommand<BsonDocument>(command);
        }
        public List<BsonDocument> ObtenerUsuarios()
        {
            var db = _client.GetDatabase("admin");
            var command = new BsonDocument { { "usersInfo", 1 } };
            var result = db.RunCommand<BsonDocument>(command);
            return result["users"].AsBsonArray.Select(user => user.AsBsonDocument).ToList();
        }
    }
}
