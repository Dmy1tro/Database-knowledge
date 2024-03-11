using MongoDB.Driver;
using MongoTestApp.Models;

namespace MongoTestApp
{
    internal class StorageService
    {
        const string ConnectionString = "mongodb://root:rootpassword123@localhost:27017";
        const string DatabaseName = "TestDb";
        const string EmailTemplatesCollectionName = "EmailTemplates";
        const string UsersCollectionName = "Users";
        const string ComplexModelsCollectionName = "Complex";

        private readonly IMongoDatabase _database;
        private readonly IMongoCollection<Entity<EmailTemplate>> _emailTemplates;
        private readonly IMongoCollection<Entity<User>> _users;
        private readonly IMongoCollection<Entity<ComplexModel>> _complexModels;

        public StorageService()
        {
            // var mongoUri = new MongoUrl(ConnectionString);
            var client = new MongoClient(ConnectionString);

            var database = client.GetDatabase(DatabaseName);
            var existingCollections = database.ListCollectionNames().ToList();

            if (!existingCollections.Contains(EmailTemplatesCollectionName))
            {
                database.CreateCollection(EmailTemplatesCollectionName);
            }

            if (!existingCollections.Contains(UsersCollectionName))
            {
                database.CreateCollection(UsersCollectionName);
            }

            if (!existingCollections.Contains(ComplexModelsCollectionName))
            {
                database.CreateCollection(ComplexModelsCollectionName);
            }

            _database = database;
            _emailTemplates = database.GetCollection<Entity<EmailTemplate>>(EmailTemplatesCollectionName);
            _users = database.GetCollection<Entity<User>>(UsersCollectionName);
            _complexModels = database.GetCollection<Entity<ComplexModel>>(ComplexModelsCollectionName);
        }

        public void AddTemplate(EmailTemplate emailTemplate)
        {
            var entity = new Entity<EmailTemplate>
            {
                Payload = emailTemplate
            };

            _emailTemplates.InsertOne(entity);
        }

        public Entity<EmailTemplate> GetTemplate(string emailType)
        {
            var template = _emailTemplates.Find(document => document.Payload.EmailType == emailType).FirstOrDefault();

            return template;
        }

        public Entity<User> AddUser(User user)
        {
            var entity = new Entity<User>
            {
                Payload = user
            };

            _users.InsertOne(entity);

            return entity;
        }

        public Entity<UserExtended> AddUserExtended(UserExtended userExtended)
        {
            var entity = new Entity<UserExtended>
            {
                Payload = userExtended
            };

            _database.GetCollection<Entity<UserExtended>>(UsersCollectionName).InsertOne(entity);

            return entity;
        }

        public Entity<User> GetUser(string firstName, string lastName)
        {
            var user = _users
                .Find(document => document.Payload.FirstName == firstName && document.Payload.LastName == lastName)
                .Sort(Builders<Entity<User>>.Sort.Ascending(x => x.Payload.FirstName))
                .SortBy(x => x.Payload.FirstName)
                .FirstOrDefault();

            return user;
        }

        public void UpdateUser(string id, User user)
        {
            var filter = Builders<Entity<User>>.Filter.Eq(document => document.Id, id);

            var update = Builders<Entity<User>>.Update
                .Set(document => document.Payload.FirstName, user.FirstName)
                .Set(document => document.Payload.LastName, user.LastName)
                .Set(document => document.Payload.Addresses, user.Addresses)
                .Set(document => document.ModifiedAt, DateTime.UtcNow);

            _users.FindOneAndUpdate(filter, update);

            // Full replacement.
            // _users.ReplaceOne(filter, new Entity<User>());
        }

        public Entity<ComplexModel> AddComplexModel(ComplexModel model)
        {
            var entity = new Entity<ComplexModel>
            {
                Payload = model
            };

            _complexModels.InsertOne(entity);

            return entity;
        }

        public Entity<ComplexModel> GetComplexModel(string id)
        {
            var model = _complexModels.Find(m => m.Id == id).FirstOrDefault();

            return model;
        }

        public void CleanUp()
        {
            _users.DeleteMany(document => true);
            _emailTemplates.DeleteMany(document => true);
            _complexModels.DeleteMany(document => true);
        }
    }
}
