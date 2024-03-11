namespace MongoTestApp.Models
{
    internal class ComplexModel
    {
        public string Value { get; set; }

        public List<ComplexModel> Models { get; set; } = new List<ComplexModel>();
    }
}
