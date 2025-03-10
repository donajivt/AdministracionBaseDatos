namespace AdmonBD.Models
{
    public class UserModel
    {
        public string LoginName { get; set; }
        public string Password { get; set; }
        public string UserName { get; set; }
        public List<string> AssignedDatabases { get; set; } = new List<string>();
        public List<string> AssignedTables { get; set; } = new List<string>();
        public List<string> ServerPermissions { get; set; } = new List<string>();
        public List<string> DatabasePermissions { get; set; } = new List<string>();
        public List<string> TablePermissions { get; set; } = new List<string>();
    }

}
