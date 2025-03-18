namespace AdmonBD.Models
{
    public class BackupModel
    {
        public string DatabaseName { set; get; }
        public string BackupType { set; get; }
        public string? BackupStartDate { set; get; }
        public string? BackupFinishDate { set; get; }
    }
}
