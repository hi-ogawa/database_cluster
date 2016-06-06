### Demonstration

```
-- start primary postgres server --
$ docker-compose up -d primary

-- create special user --
$ docker-compose run primary createuser -h primary -U postgres repuser -P -c 5 --replication
Enter password for new role: asdfjkl

-- replicate initial data for standby by copying from primary --
$ docker-compose up copyman

-- start standby postgres server --
$ docker-compose up -d standby

-- create data from primary --
$ docker-compose run primary psql -h primary -U postgres
postgres=# CREATE TABLE todo (note text);
postgres=# INSERT INTO todo (note) VALUES ('xxxx');
postgres=# select * from todo;
 note
------
 xxxx
(1 row)

-- read data from standby --
$ docker-compose run standby psql -h primary -U postgres
postgres=# select * from todo;
 note
------
 xxxx
(1 row)
```


### References

- [DockerHub: postgres](https://hub.docker.com/_/postgres/)
- [gcloud: How to Set Up PostgreSQL for High Availability and Replication with Hot Standby](https://cloud.google.com/solutions/setup-postgres-hot-standby)
- [digitalocean: How To Set Up Master Slave Replication on PostgreSQL on an Ubuntu 12.04 VPS](https://www.digitalocean.com/community/tutorials/how-to-set-up-master-slave-replication-on-postgresql-on-an-ubuntu-12-04-vps)
- [postgresql: Streaming Replication](https://www.postgresql.org/docs/9.3/static/warm-standby.html#STREAMING-REPLICATION)
