# coding: utf-8
require 'sinatra'
require "sinatra/json"
require 'rack'
require 'json'
require 'haml'

JSON_TYPE = 'application/json; charset=utf-8'
set :json_content_type, JSON_TYPE

get '/' do
	haml :index
end

get '/app.js' do
	coffee :app
end

get '/reserves.json' do
	json(JSON.parse(File.open('../reserves.json').read).map{|reserve|
    time = Time.at(reserve["start"] / 1000)
    title = reserve["title"]
    episode = reserve["episode"]
    if nil != episode
      title += " ##{episode}"
    end
    {
      startTime: time.strftime("%Y-%m-%d %H:%M:%S"),
      channel: reserve["channel"]["name"],
      title: title
    }
	})
end

get '/storage.json' do
  df = `df --block-size=1G /record`
  if %r{/dev/sda1\s+\d+\s+(\d+)\s+(\d+)}.match(df)
    used = $1.to_i
    free = $2.to_i
    total = used + free
    json({
      used: used,
      free: free,
      total: total,
      percentage: (100.0 * used / total).round(1),
      unit: "GB"
    })
  else
    status 500
  end
end

get '/machine-status.json' do
  temperature = `tail -n 300 ../machine-check.csv`
  json(temperature.split("\n").map{|line|
    cols = line.split(",")
    {
      time: cols[0],
      status: cols[1],
      cpu: cols[2].to_f,
      ssd: cols[3].to_f,
      room: cols[4].to_f,
      humi: cols[5].to_f
    }
  })
end
