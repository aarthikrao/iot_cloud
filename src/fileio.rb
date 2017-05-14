File.open("GPSlog.text").each do |line|
        gflat,gflong=line.split(",")
      sp.write(gflat)
      sleep 1
      sp.write(gflong)