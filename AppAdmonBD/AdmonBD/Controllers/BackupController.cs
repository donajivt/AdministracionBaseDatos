using AdmonBD.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Reflection;

namespace AdmonBD.Controllers
{
    public class BackupController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly string _connectionString;
        public BackupController(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }
        public async Task<IActionResult> Index()
        {
            var databases = await GetDatabasesWithBackups();
            return View(databases);
        }
        private async Task<List<BackupModel>> GetDatabasesWithBackups()
        {
            var databases = new List<BackupModel>();
            var connectionString = _configuration.GetConnectionString("DefaultConnection");

            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();

                var command = new SqlCommand("sp_GetDatabasesWithBackups", connection);
                command.CommandType = CommandType.StoredProcedure;

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var dbModel = new BackupModel
                        {
                            DatabaseName = reader["DatabaseName"].ToString(),
                            BackupType = reader["BackupType"].ToString(),
                            BackupStartDate = reader["BackupStartDate"].ToString(),
                            BackupFinishDate = reader["BackupFinishDate"].ToString()
                        };

                        databases.Add(dbModel);
                    }
                }
            }

            return databases;
        }

        [HttpGet]
        public async Task<IActionResult> Create()
        {
            var databases = await GetDatabases();

            // Validar que la lista no sea nula
            ViewBag.Databases = databases.Select(db => db.DatabaseName).ToList();

            return View();
        }


        [HttpPost]
        public async Task<IActionResult> Create(string DatabaseName, string BackupType)
        {
            var databases = await GetDatabases();
            if (string.IsNullOrEmpty(DatabaseName))
            {
                ViewBag.Message = "Debes elegir una Base de Datos.";
                ViewBag.IsSuccess = false;
                ViewBag.Databases = databases.Select(db => db.DatabaseName).ToList();
                return View();
            }
            if (string.IsNullOrEmpty(BackupType))
            {
                ViewBag.Message = "Debes elegir un Tipo de Backup.";
                ViewBag.IsSuccess = false;
                ViewBag.Databases = databases.Select(db => db.DatabaseName).ToList();
                return View();
            }

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("sp_BackupDatabase", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@DatabaseName", DatabaseName);
                        command.Parameters.AddWithValue("@BackupType", BackupType);

                        await command.ExecuteNonQueryAsync();
                        ViewBag.Message = "Backup realizado con éxito.";
                        ViewBag.IsSuccess = true;
                    }
                }
                return RedirectToAction("Index");
            }
            catch (SqlException ex)
            {
                ViewBag.Message = $"Error al realizar el backup: {ex.Message}";
                ViewBag.IsSuccess = false;
            }
            ViewBag.Databases = databases.Select(db => db.DatabaseName).ToList();
            return View();
        }

        private async Task<List<BackupModel>> GetDatabases()
        {
            var databases = new List<BackupModel>();
            var connectionString = _configuration.GetConnectionString("DefaultConnection");

            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();

                var command = new SqlCommand("sp_GetDatabases", connection);
                command.CommandType = CommandType.StoredProcedure;

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var dbModel = new BackupModel
                        {
                            DatabaseName = reader["Nombre"].ToString()
                        };

                        databases.Add(dbModel);
                    }
                }
            }

            return databases;
        }
    }
}
