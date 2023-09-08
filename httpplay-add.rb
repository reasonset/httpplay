#!/usr/bin/ruby

if ARGV[0]
  Dir.chdir ARGV[0]
end

dirname = Dir.pwd
files = Dir.children(".").select do |i|
  ext = File.extname(i).downcase
  %w:.wav .mp3 .m4a .aac .ogg .flac .opus .oga .ogv .mp3 .mkv .webm .mov .flv:.include?(ext)
end.sort

File.open((sprintf('%s/reasonset/httpplay.rbm', (ENV["XDG_DATA_HOME"] || "#{ENV["HOME"]}/.local/share"))), "r+") do |f|
  db = Marshal.load(f)
  db[dirname] = files
  f.seek 0
  Marshal.dump(db, f)
end