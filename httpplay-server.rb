#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'erb'
require 'digest'
require 'yaml'

hashmap = {}

config = nil
begin
  config = YAML.load File.read(sprintf('%s/reasonset/httpplay.yaml', (ENV["XDG_CONFIG_HOME"] || "#{ENV["HOME"]}/.config")))
rescue
  $stderr.puts "Failed to load config. Use default."
  config = {}
end

config["port"] ||= 4567
config["iface"] ||= "0.0.0.0"
config["filter"] ||= ["127.*.*.*", "192.168.*.*", "172.{1[6-9],2[0-9],30,31}.*.*", "10.*.*.*"]

set :bind, config["iface"]
set :port, config["port"]

INDEX_TEMPLATE = <<'EOF'
<html>
<head><title>Playlists</title></head>
<body>
  <ul>
% db.each do |k, v|
    <li><a href="/playlist/<%= Digest::MD5.hexdigest k %>"><%= k %></a></li>
% end
  </ul>
</body>
</html>
EOF

M3U_TEMPLATE = <<'EOF'
#EXTM3U
# Playlist created by Httpplay
% db[key].each_with_index do |i, index|
#EXTINF:-1, <%= i %>
http://<%= request.host %>:<%= config["port"] %>/play/<%= hk %>/<%= index %>
% end
EOF

get '/' do
  unless config["filter"].any? {|i| File.fnmatch i, request.ip, File::FNM_EXTGLOB }
    status 403
    next
  end
  db = Marshal.load(File.read(sprintf('%s/reasonset/httpplay.rbm', (ENV["XDG_DATA_HOME"] || "#{ENV["HOME"]}/.local/share"))))
  ERB.new(INDEX_TEMPLATE, trim_mode: "%").result(binding)
end

get '/playlist/:hex', provides: "audio/x-mpegurl" do
  unless config["filter"].any? {|i| File.fnmatch i, request.ip, File::FNM_EXTGLOB }
    status 403
    next
  end
  hk = params["hex"]
  db = Marshal.load(File.read(sprintf('%s/reasonset/httpplay.rbm', (ENV["XDG_DATA_HOME"] || "#{ENV["HOME"]}/.local/share"))))
  key = db.keys.find {|i| Digest::MD5.hexdigest(i) == hk }
  pp key
  hashmap[hk] = key
  ERB.new(M3U_TEMPLATE, trim_mode: "%").result(binding)
end

get '/play/:hex/:index' do
  unless config["filter"].any? {|i| File.fnmatch i, request.ip, File::FNM_EXTGLOB }
    status 403
    next
  end
  db = Marshal.load(File.read(sprintf('%s/reasonset/httpplay.rbm', (ENV["XDG_DATA_HOME"] || "#{ENV["HOME"]}/.local/share"))))
  key = hashmap[params["hex"]]
  filename = db[key][params["index"].to_i]
  filepath = [key, filename].join("/")
  mtype = case File.extname(filename)
  when ".wav"
    "audio/wav"
  when ".mp3"
    "audio/mpeg"
  when ".aac"
    "audio/aac"
  when ".m4a"
    "audio/aac"
  when ".flac"
    "audio/x-flac"
  when ".ogg"
    "audio/ogg"
  when ".oga"
    "audio/ogg"
  when ".opus"
    "audio/opus"
  when ".ogv"
    "video/ogg"
  when ".mp4"
    "video/mp4"
  when ".mov"
    "video/quicktime"
  when ".mkv"
    "video/x-matroska"
  when ".webm"
    "video/webm"
  when ".flv"
    "video/x-flv"
  end

  content_type mtype
  File.read(filepath)
end