using AdmonBD.Contexto;
using AdmonBD.Models;
using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using System.Diagnostics;

namespace AdmonBD.Controllers
{
    public class AdministracionMongoController : Controller
    {
        private readonly MongoDBService _mongoService;
        private const string BackupFolder = "/backup";
        private const string DockerContainerName = "mongodb";
        public AdministracionMongoController(MongoDBService mongoService)
        {
            _mongoService = mongoService;
        }
        [HttpGet]
        public IActionResult Index()
        {
            var basesDeDatos = _mongoService.ObtenerBasesDeDatos();
            var basesConColecciones = new List<BaseConColecciones>();

            foreach (var baseDeDatos in basesDeDatos)
            {
                var colecciones = _mongoService.ObtenerColecciones(baseDeDatos);
                basesConColecciones.Add(new BaseConColecciones
                {
                    NombreBase = baseDeDatos,
                    Colecciones = colecciones
                });
            }
            var backupFolder = @"\backup";
            var backupsDisponibles = Directory.GetDirectories(backupFolder).Select(Path.GetFileName).ToList();

            // Pasar la lista de backups al ViewData
            ViewBag.backupsDisponibles = backupsDisponibles;

            return View(basesConColecciones);
        }

        [HttpPost]
        public IActionResult CrearBaseDeDatos(string nombreBase)
        {
            _mongoService.CrearBaseDeDatos(nombreBase);
            return RedirectToAction("Index");
        }
        [HttpGet]
        public IActionResult Gestionar(string nombreBase)
        {
            var colecciones = _mongoService.ObtenerColecciones(nombreBase);
            ViewBag.NombreBase = nombreBase;
            ViewBag.Colecciones = colecciones;
            return View(colecciones);
        }

        [HttpPost]
        public IActionResult CrearColeccion(string nombreBase, string nombreColeccion)
        {
            _mongoService.CrearColeccion(nombreBase, nombreColeccion);
            return RedirectToAction("Gestionar", new { nombreBase });
        }
        [HttpPost]
        public IActionResult EliminarBaseDeDatos(string nombreBase)
        {
            if (string.IsNullOrEmpty(nombreBase))
                return RedirectToAction("Index");

            _mongoService.EliminarBaseDeDatos(nombreBase);

            TempData["Mensaje"] = $"Base de datos '{nombreBase}' eliminada.";
            return RedirectToAction("Index");
        }

        [HttpPost]
        public IActionResult EliminarColeccion(string nombreBase, string nombreColeccion)
        {
            if (string.IsNullOrEmpty(nombreBase) || string.IsNullOrEmpty(nombreColeccion))
            {
                TempData["Mensaje"] = "Base de datos o colección no proporcionados.";
                return RedirectToAction("Gestionar", new { nombreBase });
            }

            try
            {
                _mongoService.EliminarColeccion(nombreBase, nombreColeccion);
                TempData["Mensaje"] = $"Colección '{nombreColeccion}' eliminada correctamente.";
            }
            catch (Exception ex)
            {
                TempData["Mensaje"] = $"Error al eliminar la colección: {ex.Message}";
            }

            return RedirectToAction("Gestionar", new { nombreBase });
        }

        [HttpGet]
        public IActionResult VerDocumentos(string nombreBase, string nombreColeccion)
        {
            var documentos = _mongoService.ObtenerDocumentos(nombreBase, nombreColeccion);
            ViewBag.NombreBase = nombreBase;
            ViewBag.NombreColeccion = nombreColeccion;
            return View(documentos);
        }
        [HttpPost]
        public IActionResult InsertarDocumento(string nombreBase, string nombreColeccion, string[] clave, string[] valor)
        {
            // Verifica que las longitudes de las claves y valores coincidan
            if (clave.Length != valor.Length)
            {
                TempData["Mensaje"] = "Las claves y valores no coinciden.";
                return RedirectToAction("Gestionar", new { nombreBase });
            }

            // Crear un diccionario para almacenar los pares clave-valor
            var documento = new Dictionary<string, object>();
            for (int i = 0; i < clave.Length; i++)
            {
                documento[clave[i]] = valor[i];
            }

            // Inserta el documento en la colección
            try
            {
                _mongoService.InsertarDocumento(nombreBase, nombreColeccion, documento);
                TempData["Mensaje"] = "Documento insertado correctamente.";
            }
            catch (Exception ex)
            {
                TempData["Mensaje"] = "Error al insertar documento: " + ex.Message;
            }

            // Redirige a la vista de documentos en la colección
            return RedirectToAction("Gestionar", new { nombreBase });
        }
        public IActionResult Backup(string nombreBase)
        {
            try
            {
                _mongoService.RealizarBackup(nombreBase, BackupFolder);
                _mongoService.CopiarBackupDesdeContenedor(BackupFolder, nombreBase);
                TempData["Mensaje"] = "Backup realizado correctamente.";
            }
            catch (Exception ex)
            {
                TempData["Mensaje"] = "Error al realizar el backup: " + ex.Message;
            }
            return RedirectToAction("Index");
        }

        [HttpPost]
        public IActionResult Restaurar(string nombreBase)
        {
            var backupPath = $"/backup/{nombreBase}/{nombreBase}";

            if (!Directory.Exists(backupPath))
            {
                TempData["Mensaje"] = "No se encontró la base de datos en el respaldo.";
                return RedirectToAction("Index");
            }

            try
            {
                _mongoService.RestaurarBackup(nombreBase, backupPath);
                TempData["Mensaje"] = "Restauración realizada correctamente.";
            }
            catch (Exception ex)
            {
                TempData["Mensaje"] = "Error al restaurar la base de datos: " + ex.Message;
            }

            return RedirectToAction("Index");
        }
        // Acción para crear un usuario
        [HttpPost]
        public IActionResult CrearUsuario(string usuario, string contraseña, string[] roles)
        {
            try
            {
                _mongoService.CrearUsuario(usuario, contraseña, roles); // roles ya es un array de strings
                TempData["Mensaje"] = "Usuario creado correctamente.";
            }
            catch (Exception ex)
            {
                TempData["Mensaje"] = "Error al crear el usuario: " + ex.Message;
            }
            return RedirectToAction("VerUsuarios");
        }
        [HttpGet]
        public IActionResult CrearUsuario()
        {
            var rolesDisponibles = new List<string>
            {
                "readWrite", "dbAdmin", "read", "userAdmin", "clusterAdmin", "backup"
            };

            // Pasar los roles disponibles a la vista
            ViewBag.RolesDisponibles = rolesDisponibles;

            return View();
        }


        // Acción para eliminar un usuario
        [HttpPost]
        public IActionResult EliminarUsuario(string usuario)
        {
            try
            {
                _mongoService.EliminarUsuario(usuario);
                TempData["Mensaje"] = "Usuario eliminado correctamente.";
            }
            catch (Exception ex)
            {
                TempData["Mensaje"] = "Error al eliminar el usuario: " + ex.Message;
            }
            return RedirectToAction("VerUsuarios");
        }
        // Acción para ver y gestionar los usuarios
        public IActionResult VerUsuarios()
        {
            var usuarios = _mongoService.ObtenerUsuarios();
            return View(usuarios);
        }
    }
}
