### Examples

- [MongoDB](https://github.com/hi-ogawa/database_cluster/tree/master/mongodb)
- [PostgresSQL](https://github.com/hi-ogawa/database_cluster/tree/master/postgresql)

### Notes

- Single Machine
  - simulate network partition by docker-compose

- Multi Machine
  - simulate multiple machines on Vagrant
  - setup with docker clustering (Swarm or Kubernates)
  - share configuration with etcd
  - private IP communication

- General
  - compromize C (Consistency) or A (Availability) in CAP
  - simulate primary/secondary server failure

- Client
  - ruby
