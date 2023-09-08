# httpplay

## Synopsis

Distribute audio/video playlist for playing on Android mpv.

## Overview

`httpplay-server.rb` is a HTTP application server for local network.
It distributes playlist index, m3u playlist and media files.

`httpplay-add.rb` adds new playlist to server.
Added playlist is shown on playlist index.

"Playlist" contains audio/video files on specified directory.
Media files in a playlist should be on one directory and they are ordered by lexical.

`httpplay-reset.rb` reset playlist index.

## Install

1. Put this repository to somewhere in PC.
2. `cd` to repository
3. (Optional) `bundle config set --local path vendor/bundle`
4. `bundle install`
5. `mkdir ${XDG_DATA_HOME:-$HOME/.local/share}/reasonset`
6. `./httpplay-reset.rb`

## Usage

1. Start `httpplay-server.rb` on a PC having media files you want to play.
2. `httpplay-add.rb <path_to_directory>` adds playlist contains media files on specified directory to server.
3. Access httpplay server root with web browser on your Android.
4. Copy playlist link.
5. Open link (Open URL) on Android mpv.
6. Enjoy.

## Dependency

* Ruby >=3.0
* RubyGems
* Bundler

## Configuration

Confguration file is `${XDG_CONFIG_HOME:-$HOME/.config}/reasonset/httpplay.yaml`.

|key|type|default|description|
|-----|-----|----------|---------------------------------|
|`port`|Integer|`4567`|Listen TCP port number of Thin HTTP Server|
|`iface`|String|`0.0.0.0`|Listen TCP network interface address of Thin HTTP Server|
|`filter`|String[]|`127.*.*.*`, `192.168.*.*`, `172.{1[6-9],2[0-9],30,31}.*.*`, `10.*.*.*`|Acceptable source IP address. Ruby's `fnmatch` pattern string array.|

## Supported media file types

### Audio

* `.wav`
* `.mp3`
* `.aac`
* `.m4a`
* `.flac`
* `.ogg`
* `.oga`
* `.opus`

### Video

* `.ogv`
* `.flv`
* `.mp4`
* `.mov`
* `.mkv`
* `.webm`

## Note

* You cannot access to media file before GET a playlist contains it.
* This software is for working on local network. *DO NOT PUT A SERVER ON PUBLIC.*
* It also works on mpv on PC.
* If there is a player that able to open m3u playlist contains HTTP source addresses via HTTP, you can play also on iOS.
* Media files can be symbolic links.
* If you want to run server on Windows, please use WSL.