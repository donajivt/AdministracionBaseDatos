namespace AdmonBD.Models
{
    public class LoginUsuarioModel
    {
        public string LoginName { get; set; }
        public string UserName { get; set; }
        public string Password { get; set; }
        public string ServerPermission { get; set; }
        public string DatabaseName { get; set; }
        public string TableName { get; set; }
        public List<string> AssignedDatabases { get; set; }
        public List<string> AssignedTables { get; set; }
    }
}
