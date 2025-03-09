using System.ComponentModel.DataAnnotations;

namespace AdmonBD.Models
{
    public class CreateDatabaseModel
    {
        [Required(ErrorMessage = "El nombre de la base de datos es obligatorio.")]
        public string DatabaseName { get; set; }



        [Required(ErrorMessage = "La ruta del archivo de datos es obligatoria.")]
        public string DataFilePath { get; set; }



        [Required(ErrorMessage = "La ruta del archivo de log es obligatoria.")]
        public string LogFilePath { get; set; }



        [Range(10, int.MaxValue, ErrorMessage = "El tamaño de los archivos debe ser al menos 10 MB.")]
        public int DataSize { get; set; }



        [Range(5, int.MaxValue, ErrorMessage = "El crecimiento de los archivos de data debe ser al menos 5%.")]
        public int DataFileGrowth { get; set; }



        [Range(10, int.MaxValue, ErrorMessage = "El tamaño del archivo de log debe ser al menos 10 MB.")]
        public int LogSize { get; set; }



        [Range(5, int.MaxValue, ErrorMessage = "El crecimiento de los archivos de log debe ser al menos 5%.")]
        public int LogFileGrowth { get; set; }



        public string? FileGroupAdicional { get; set; }


        public bool Created { get; set; }
    }
}
