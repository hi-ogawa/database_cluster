### Demonstration

Prepare MongoDB replica set:

```
$ docker-compose up -d mongo0 mongo1 mongo2
$ docker-compose ps
    Name                  Command               State     Ports
-----------------------------------------------------------------
app_mongo0_1   /entrypoint.sh --replSet r ...   Up      27017/tcp
app_mongo1_1   /entrypoint.sh --replSet r ...   Up      27017/tcp
app_mongo2_1   /entrypoint.sh --replSet r ...   Up      27017/tcp
$ docker-compose exec mongo0 mongo
> rs.initiate({
    _id: "rs0",
    version: 1,
    members: [
      { _id: 0, host: "mongo0:27017", priority: 1  , tags: { dc: "asia" } },
      { _id: 1, host: "mongo1:27017", priority: 0.5, tags: { dc: "us"   } },
      { _id: 2, host: "mongo2:27017", priority: 0.5, tags: { dc: "eu"   } }
    ]
  })
> rs.status()
{
  "set" : "rs0",
  ...
  "members" : [
    {
      "_id" : 0,
      "name" : "mongo0:27017",
      "health" : 1,
      "state" : 1,
      "stateStr" : "PRIMARY",
      ...
    },
    {
      "_id" : 1,
      "name" : "mongo1:27017",
      "health" : 1,
      "state" : 2,
      "stateStr" : "SECONDARY",
      ...
    },
    {
      "_id" : 2,
      "name" : "mongo2:27017",
      "health" : 1,
      "state" : 2,
      "stateStr" : "SECONDARY",
      ...
    }
  ],
  "ok" : 1
}
> use rep_test_db
> db.createUser({ user: 'mongoman', pwd: 'asdfjkl', roles: ['dbOwner'] })
> exit
bye
```

Show how write/read operation is distributed to MongoDB cluster:

```
$ docker-compose run --rm client
... initialize client: `client = Mongo::Client.new` ...
D, [2016-06-06T02:42:59.137719 #1] DEBUG -- : MONGODB | Adding mongo0:27017 to the cluster.
D, [2016-06-06T02:42:59.141778 #1] DEBUG -- : MONGODB | Adding mongo1:27017 to the cluster.
D, [2016-06-06T02:42:59.145304 #1] DEBUG -- : MONGODB | Adding mongo2:27017 to the cluster.
D, [2016-06-06T02:42:59.148446 #1] DEBUG -- : MONGODB | Server mongo0:27017 elected as primary in rs0.
... write data: `client[:todo].insert_one({ content: "xxxx" })` ...
D, [2016-06-06T02:42:59.150470 #1] DEBUG -- : MONGODB | mongo0:27017 | rep_test_db.saslStart | STARTED | {}
D, [2016-06-06T02:42:59.152840 #1] DEBUG -- : MONGODB | mongo0:27017 | rep_test_db.saslStart | SUCCEEDED | 0.0017331039999999999s
D, [2016-06-06T02:42:59.160213 #1] DEBUG -- : MONGODB | mongo0:27017 | rep_test_db.saslContinue | STARTED | {}
D, [2016-06-06T02:42:59.161198 #1] DEBUG -- : MONGODB | mongo0:27017 | rep_test_db.saslContinue | SUCCEEDED | 0.000405724s
D, [2016-06-06T02:42:59.162016 #1] DEBUG -- : MONGODB | mongo0:27017 | rep_test_db.saslContinue | STARTED | {}
D, [2016-06-06T02:42:59.163247 #1] DEBUG -- : MONGODB | mongo0:27017 | rep_test_db.saslContinue | SUCCEEDED | 0.000780344s
D, [2016-06-06T02:42:59.164054 #1] DEBUG -- : MONGODB | mongo0:27017 | rep_test_db.insert | STARTED | {"insert"=>"todo", "documents"=>[{:content=>"xxxx", :_id=>BSON::ObjectId('5754e3333b757a00019593e0')}], "ordered"=>true}
D, [2016-06-06T02:42:59.166068 #1] DEBUG -- : MONGODB | mongo0:27017 | rep_test_db.insert | SUCCEEDED | 0.0014141580000000002s
... read data: `client[:todo].find.to_a` ...
D, [2016-06-06T02:42:59.168883 #1] DEBUG -- : MONGODB | mongo2:27017 | rep_test_db.find | STARTED | {"find"=>"todo", "filter"=>{}}
D, [2016-06-06T02:42:59.170197 #1] DEBUG -- : MONGODB | mongo2:27017 | rep_test_db.saslStart | STARTED | {}
D, [2016-06-06T02:42:59.172092 #1] DEBUG -- : MONGODB | mongo2:27017 | rep_test_db.saslStart | SUCCEEDED | 0.001580948s
D, [2016-06-06T02:42:59.179198 #1] DEBUG -- : MONGODB | mongo2:27017 | rep_test_db.saslContinue | STARTED | {}
D, [2016-06-06T02:42:59.180128 #1] DEBUG -- : MONGODB | mongo2:27017 | rep_test_db.saslContinue | SUCCEEDED | 0.000565824s
D, [2016-06-06T02:42:59.180513 #1] DEBUG -- : MONGODB | mongo2:27017 | rep_test_db.saslContinue | STARTED | {}
D, [2016-06-06T02:42:59.181471 #1] DEBUG -- : MONGODB | mongo2:27017 | rep_test_db.saslContinue | SUCCEEDED | 0.000678566s
D, [2016-06-06T02:42:59.182254 #1] DEBUG -- : MONGODB | mongo2:27017 | rep_test_db.find | SUCCEEDED | 0.01289717s

```

Show how "C" (Consistency) is failing for this replica set configuration:

```
$ docker-compose run compromize_consitency
... out of 10, below number of documents was not be able to be read immidiately after creation ...
5
```


### References

- [Dockerhub: MongoDB](https://hub.docker.com/_/mongo/)
- [MongoDB: Deploy a Replica Set](https://docs.mongodb.com/manual/tutorial/deploy-replica-set/)
- [MongoDB: Read Operation Control](https://docs.mongodb.com/manual/reference/read-preference/#query-from-geographically-distributed-members)
- [Network in Docker Compose](https://docs.docker.com/compose/networking/)
- [Ruby Client](https://docs.mongodb.com/ecosystem/tutorial/ruby-driver-tutorial/)
