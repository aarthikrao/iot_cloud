require "kemal"
require "db"
require "sqlite3"
require "json"


# Open a connection to SQLite3
database_url = "sqlite3:./database.db"
db = DB.open database_url

# Check if table exists
table_sensor_data_exists = db.scalar "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='sensor_data'"

# Create the table if it does not exist
if table_sensor_data_exists == 0
  puts "Table 'Sensor Data' does not exist. Creating one"

  db.exec "CREATE TABLE sensor_data (boat_id float, \
methane_ppm float, co_ppm float, smoke_ppm float, temp float, \
humidity float, conductivity float, gps_lat float, gps_lng float)"
end

# Ensure to close the database connection
at_exit { db.close }

# Set up the UDP Server
server = UDPSocket.new
server.bind("0.0.0.0", 1234)


# Spawn a fiber (this is like a thread, but lighter)
spawn do

  # receive sensor data from boats
  loop do
    data, _client = server.receive(1024)

    parsed_data = JSON.parse(data)

    puts "Incoming Data. Inserting"

    args = [] of DB::Any

    args << parsed_data["boat_id"].as_f
    args << parsed_data["s1"].as_f
    args << parsed_data["s2"].as_f
    args << parsed_data["s3"].as_f
    args << parsed_data["s4"].as_f
    args << parsed_data["s5"].as_f
    args << parsed_data["s6"].as_f
    args << parsed_data["glat"].as_f
    args << parsed_data["glng"].as_f

    db.exec "INSERT INTO sensor_data values (?, ?, ?, ?, ?, ?, ?, ?, ?)", args
    puts "---"
  end
end


# Web Server routes
get "/" do
  sensor_count = 15
  render "src/views/index.ecr", "src/views/layout.ecr"
end

get "/table" do
  sensor_data = [] of Array(Float64)

  db.query "SELECT * FROM sensor_data" do |rs|

    rs.each do
      record = [] of (Float64)

      record << rs.read(Float64)
      record << rs.read(Float64)
      record << rs.read(Float64)
      record << rs.read(Float64)
      record << rs.read(Float64)
      record << rs.read(Float64)
      record << rs.read(Float64)
      record << rs.read(Float64)
      record << rs.read(Float64)

      sensor_data << record
    end
  end

  render "src/views/table.ecr", "src/views/layout.ecr"
end

get "/user" do
  render "src/views/user.ecr", "src/views/layout.ecr"
end

get "/maps" do
  render "src/views/maps.ecr", "src/views/layout.ecr"
end

get "/command" do
  render "src/views/command.ecr", "src/views/layout.ecr"
end

get "/setdata" do |env|
  # latitude = env.params.query["latitude"].as(String)
  # longitude = env.params.query["longitude"].as(String)

  # args = [] of DB::Any
  # args << latitude
  # args << longitude

  # db.exec "INSERT INTO gps_coordinates values (?, ?)", args

  # data = {
  #   latitude: latitude,
  #   longitude: longitude
  # }.to_json

  # client.send(data, 0)
end

Kemal.run
