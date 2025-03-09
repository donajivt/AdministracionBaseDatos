using AdmonBD.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Threading.Tasks;

namespace AdmonBD.Controllers
{
    public class DatabaseController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly string _connectionString;

        public DatabaseController(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        [HttpGet]
        public IActionResult Create()
        {
            return View("~/Views/DataBase/Create.cshtml");
        }

        [HttpPost]
        public async Task<IActionResult> Create(CreateDatabaseModel model)
        {
            try
            {
                // Validación de los parámetros necesarios
                if (string.IsNullOrEmpty(model.DatabaseName))
                {
                    ViewBag.Message = "El nombre de la base de datos es obligatorio.";
                    return View();
                }

                if (string.IsNullOrEmpty(model.DataFilePath))
                {
                    ViewBag.Message = "La ruta del archivo de datos es obligatoria.";
                    return View();
                }

                if (string.IsNullOrEmpty(model.LogFilePath))
                {
                    ViewBag.Message = "La ruta del archivo de log es obligatoria.";
                    return View();
                }

                // Ejecutar el procedimiento almacenado en la base de datos
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("SP_CreateDatabase", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@DatabaseName", model.DatabaseName);
                        command.Parameters.AddWithValue("@DataFilePath", model.DataFilePath);
                        command.Parameters.AddWithValue("@LogFilePath", model.LogFilePath);
                        command.Parameters.AddWithValue("@DataSize", model.DataSize);
                        command.Parameters.AddWithValue("@LogSize", model.LogSize);
                        command.Parameters.AddWithValue("@FileGrowthData", model.DataFileGrowth);
                        command.Parameters.AddWithValue("@FileGrowthLog", model.LogFileGrowth);

                        if (string.IsNullOrEmpty(model.FileGroupAdicional))
                        {
                            command.Parameters.AddWithValue("@FileGroupAdicional", DBNull.Value);
                        }
                        else
                        {
                            command.Parameters.AddWithValue("@FileGroupAdicional", model.FileGroupAdicional);
                        }

                        await command.ExecuteNonQueryAsync();
                    }
                }

                ViewBag.Message = "Base de datos creada correctamente.";
            }
            catch (Exception ex)
            {
                ViewBag.Message = $"Error al crear la base de datos: {ex.Message}";
                Console.WriteLine(ex);
            }

            return View();
        }

    }
}
