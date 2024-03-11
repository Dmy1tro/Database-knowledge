using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace MongoTestApp.Models
{
    internal class Entity<T>
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime ModifiedAt { get; set; } = DateTime.UtcNow;

        public T Payload { get; set; }
    }
}
