require "serialport"
require "json"
require "socket"

client = UDPSocket.new
client.connect("192.168.1.107", 1234)

port_str = "/dev/ttyACM0"
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

#just read forever
loop do
  begin
    while(k = sp.gets.chomp) do
      s1, s2, s3, s4, s5, s6, glat, glon = k.split(",")

      readings = {s1: s1, s2: s2, s3: s3,
                  s4: s4, s5: s5, s6: s6,
                  glat: glat, glon: glon}.to_json

      client.send(json,0)
      
    end

  rescue Exception => error
    puts error
  end
end

sp.close
