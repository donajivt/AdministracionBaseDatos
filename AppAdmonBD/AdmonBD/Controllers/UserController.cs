using AdmonBD.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace AdmonBD.Controllers
{
    public class UserController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly string _connectionString;

        public UserController(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        // Mostrar todos los usuarios
        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var users = await GetUsersAndLogins();
            return View(users);
        }

        // Mostrar formulario para crear un nuevo usuario
        [HttpGet]
        public IActionResult Create()
        {
            var model = new UserModel();
            ViewBag.Databases = GetDatabases().Result;
            ViewBag.ServerPermissions = GetServerPermissions().Result;
            ViewBag.DatabasePermissions = GetDatabasePermissions().Result;
            return View(model);
        }

        // Crear un nuevo usuario
        [HttpPost]
        public async Task<IActionResult> Create(UserModel model)
        {
            if (ModelState.IsValid)
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    // Crear Login y Usuario
                    var command = new SqlCommand("sp_CreateLoginAndUser", connection)
                    {
                        CommandType = CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@LoginName", model.LoginName);
                    command.Parameters.AddWithValue("@Password", model.Password);
                    command.Parameters.AddWithValue("@UserName", model.UserName);
                    command.Parameters.AddWithValue("@Databases", string.Join(",", model.AssignedDatabases));

                    await command.ExecuteNonQueryAsync();

                    // Asignar permisos a nivel de servidor
                    foreach (var permission in model.ServerPermissions)
                    {
                        var serverPermissionCmd = new SqlCommand("sp_AssignServerPermissions", connection)
                        {
                            CommandType = CommandType.StoredProcedure
                        };
                        serverPermissionCmd.Parameters.AddWithValue("@LoginName", model.LoginName);
                        serverPermissionCmd.Parameters.AddWithValue("@Permission", permission);
                        await serverPermissionCmd.ExecuteNonQueryAsync();
                    }

                    // Asignar permisos a nivel de base de datos
                    foreach (var dbPermission in model.DatabasePermissions)
                    {
                        foreach (var db in model.AssignedDatabases)
                        {
                            var dbPermissionCmd = new SqlCommand("sp_AssignDatabasePermissions", connection)
                            {
                                CommandType = CommandType.StoredProcedure
                            };
                            dbPermissionCmd.Parameters.AddWithValue("@UserName", model.UserName);
                            dbPermissionCmd.Parameters.AddWithValue("@DatabaseName", db);
                            dbPermissionCmd.Parameters.AddWithValue("@Permission", dbPermission);
                            await dbPermissionCmd.ExecuteNonQueryAsync();
                        }
                    }
                }

                ViewBag.Message = "Usuario creado y permisos asignados correctamente.";
                return RedirectToAction("Index");
            }

            ViewBag.Databases = GetDatabases().Result;
            ViewBag.ServerPermissions = GetServerPermissions().Result;
            ViewBag.DatabasePermissions = GetDatabasePermissions().Result;
            return View(model);
        }

        // Obtener las bases de datos disponibles
        private async Task<List<string>> GetDatabases()
        {
            var databases = new List<string>();
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                var command = new SqlCommand("sp_GetDatabases", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        databases.Add(reader.GetString(0));
                    }
                }
            }
            return databases;
        }

        // Obtener los permisos a nivel de servidor
        private async Task<List<string>> GetServerPermissions()
        {
            var permissions = new List<string>
            {
                "bulkadmin",
                "dbcreator",
                "diskadmin",
                "processadmin",
                "securityadmin",
                "serveradmin",
                "setupadmin",
                "sysadmin"
            };
            return permissions;
        }

        // Obtener los permisos a nivel de base de datos
        private async Task<List<string>> GetDatabasePermissions()
        {
            var permissions = new List<string>
            {
                "db_accessadmin",
                "db_backupoperator",
                "db_datareader",
                "db_datawriter",
                "db_ddladmin",
                "db_denydatareader",
                "db_denydatawriter",
                "db_owner",
                "db_securityadmin"
            };
            return permissions;
        }

        // Obtener los usuarios y logins existentes
        private async Task<List<UserModel>> GetUsersAndLogins()
        {
            var users = new List<UserModel>();
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                var command = new SqlCommand("sp_GetUserLoginDetails", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var user = new UserModel
                        {
                            LoginName = reader["LoginName"].ToString(),
                            UserName = reader["UserName"].ToString(),
                            AssignedDatabases = reader["AssignedDatabases"].ToString().Split(',').ToList()
                        };
                        users.Add(user);
                    }
                }
            }
            return users;
        }
        [HttpGet]
        public IActionResult GetTablesForDatabase(string databaseName)
        {
            if (string.IsNullOrEmpty(databaseName))
            {
                return BadRequest("El nombre de la base de datos es requerido.");
            }

            var tables = new List<string>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var command = new SqlCommand("sp_GetTablesForDatabase", connection)
                    {
                        CommandType = CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@DatabaseName", databaseName);

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            tables.Add(reader.GetString(0));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return BadRequest($"Error al obtener las tablas: {ex.Message}");
            }

            return Json(tables);
        }
    }
}