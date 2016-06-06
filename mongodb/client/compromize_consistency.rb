require 'mongo'

Mongo::Logger.logger.level = :error

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

client[:thing].delete_many

results = []

10.times.each do |i|
  client[:thing].insert_one({ number: i })
  # read document immidiately after creation
  results << client[:thing].find({ number: i }).first
end

puts '... out of 10, below number of documents was not be able to be read immidiately after creation ...'
puts results.select(&:nil?).length
