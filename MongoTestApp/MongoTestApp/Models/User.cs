namespace MongoTestApp.Models
{
    internal class User
    {
        public string FirstName { get; set; }

        public string LastName { get; set; }

        public List<Address> Addresses { get; set; } = new List<Address>();
    }

    internal class UserExtended : User
    {
        public int Age { get; set; }

        public string Email { get; set; }
    }

    internal class Address
    {
        public string Country { get; set; }

        public string City { get; set; }

        public string Street { get; set; }
    }
}
