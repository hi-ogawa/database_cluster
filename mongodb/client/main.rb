require 'mongo'

puts '... initialize client: `client = Mongo::Client.new` ...'
client = Mongo::Client.new(
  [
    'mongo0:27017',
    'mongo1:27017',
    'mongo2:27017'
  ],
  replica_set: 'rs0',
  database: 'rep_test_db',
  user: 'mongoman',
  password: 'asdfjkl',
  read: {
    mode: :nearest,
    tag_sets: [
      { dc: 'eu' }
    ]
  }
)

puts '... write data: `client[:todo].insert_one({ content: "xxxx" })` ...'
client[:todo].insert_one({ content: 'xxxx' })

puts '... read data: `client[:todo].find.to_a` ...'
client[:todo].find.to_a
