using MongoTestApp;
using MongoTestApp.Models;

var storage = new StorageService();

storage.CleanUp();

storage.AddTemplate(new EmailTemplate
{
    EmailType = "invite",
    RawHtml = "<div>Hello</div>"
});
var template = storage.GetTemplate("invite");

var user = storage.AddUser(new User
{
    FirstName = "John",
    LastName = "Doe",
    Addresses = new List<Address> { 
        new Address { Country = "UK", City = "Zhytomir", Street = "Central 123" }
    }
});

var johnDoe = storage.GetUser("John", "Doe");
storage.UpdateUser(user.Id, new User
{
    FirstName = "r2",
    LastName = "d2",
    Addresses = new List<Address> {
        new Address { Country = "UK", City = "Kh", Street = "Naukova 2" }
    }
});

storage.AddUser(new User
{
    FirstName = "r3",
    LastName = "d3",
    Addresses = new List<Address> {
        new Address { Country = "UK", City = "Kh", Street = "Naukova 3" }
    }
});

storage.AddUser(new User
{
    FirstName = "r4",
    LastName = "d4",
    Addresses = new List<Address> {
        new Address { Country = "UK", City = "Kh", Street = "Naukova 4" }
    }
});

storage.AddUserExtended(new UserExtended
{
    FirstName = "r3",
    LastName = "d3",
    Addresses = new List<Address> {
        new Address { Country = "UK", City = "Kh", Street = "Naukova 3" }
    },
    Age = 123,
    Email = "qq@qq.com"
});

var complexModel = storage.AddComplexModel(new ComplexModel
{
    Value = "first",
    Models = new List<ComplexModel>
    {
        new ComplexModel
        {
            Value = "second_1",

        },
        new ComplexModel
        {
            Value = "second_3",
            Models = new List<ComplexModel>
            {
                new ComplexModel
                {
                    Value = "third_1",
                },
                new ComplexModel
                {
                    Value = "third_2"
                }
            }
        }
    }
});

var modelFromStorage = storage.GetComplexModel(complexModel.Id);
