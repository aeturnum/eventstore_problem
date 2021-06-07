import Config

config :commanded_test, event_stores: [CommandedTest.EventStore]

config :commanded_test, CommandedTest.EventStore,
   serializer: Commanded.Serialization.JsonSerializer,
   username: "postgres",
   password: "postgres",
   database: "eventstore_test_2",
   hostname: "localhost",
   pool_size: 10
