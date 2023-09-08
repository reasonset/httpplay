File.open((sprintf('%s/reasonset/httpplay.rbm', (ENV["XDG_DATA_HOME"] || "#{ENV["HOME"]}/.local/share"))), "w") do |f|
  Marshal.dump({}, f)
end