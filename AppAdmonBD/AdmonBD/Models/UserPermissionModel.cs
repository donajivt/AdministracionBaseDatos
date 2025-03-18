namespace AdmonBD.Models
{
    public class UserPermissionModel
    {
        public string DatabaseName { get; set; }
        public string LoginName { get; set; }
        public string UserName { get; set; }
        public string DatabaseRoles { get; set; }
        public string ServerRoles { get; set; }
    }
}
