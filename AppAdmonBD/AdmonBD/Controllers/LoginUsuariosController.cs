//using AdmonBD.Models;
//using Microsoft.AspNetCore.Mvc;
//using Microsoft.Data.SqlClient;
//using System.Data;

//namespace AdmonBD.Controllers
//{
//    public class LoginUsuariosController : Controller
//    {
//        private readonly string _connectionString;
//        private readonly IConfiguration _configuration;
//        public LoginUsuariosController(IConfiguration configuration)
//        {
//            _configuration = configuration;
//            _connectionString = configuration.GetConnectionString("DefaultConnection");
//        }
//        [HttpGet]
//        public IActionResult Index()
//        {
//            var users = GetUsers();
//            return View(users);
//        }
//        public IActionResult AssignPermissions(string userName)
//        {
//            var userPermissions = new UserModel();
//            // Lógica para obtener las bases de datos y tablas disponibles para asignar permisos
//            userPermissions.AssignedDatabases = GetDatabases();
//            userPermissions.AssignedTables = GetTables(userPermissions.DatabaseName);

//            return View(userPermissions);
//        }

//        [HttpPost]
//        public IActionResult Create(LoginUsuarioModel model)
//        {
//            if (ModelState.IsValid)
//            {
//                try
//                {
//                    using (var connection = new SqlConnection(_connectionString))
//                    {
//                        connection.Open();
//                        using (var command = new SqlCommand("sp_CreateLoginAndUser", connection))
//                        {
//                            command.CommandType = CommandType.StoredProcedure;
//                            command.Parameters.AddWithValue("@LoginName", model.LoginName);
//                            command.Parameters.AddWithValue("@UserName", model.UserName);
//                            command.Parameters.AddWithValue("@Password", model.Password);
//                            command.Parameters.AddWithValue("@DatabaseName", model.DatabaseName);
//                            command.Parameters.AddWithValue("@TablePermissions", model.TablePermissions ?? string.Empty);
//                            command.Parameters.AddWithValue("@SchemaPermissions", model.SchemaPermissions ?? string.Empty);
//                            command.Parameters.AddWithValue("@RoleName", model.RoleName ?? string.Empty);

//                            command.ExecuteNonQuery();
//                        }
//                    }
//                    ViewBag.Message = "Login y usuario creados correctamente.";
//                }
//                catch (Exception ex)
//                {
//                    ViewBag.Message = $"Error: {ex.Message}";
//                }
//            }
//            return View();
//        }
//    }
//}