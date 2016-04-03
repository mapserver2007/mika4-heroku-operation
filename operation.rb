# -*- coding: utf-8 -*-
require 'optparse'
require 'open3'
require 'net/https'
require 'json'
require 'yaml'

config = {}
OptionParser.new do |opt|
  opt.on('-w', '--worker WORKER') {|v| config[:worker] = v}
  opt.on('-a', '--application APPLICATION') {|v| config[:application] = v}
  opt.on('-c', '--command COMMAND') {|v| config[:command] = v}
  opt.parse!
end

result = {}
if config[:application].nil? || config[:command].nil?
  result = {
    :message => "Invalid arguments error.",
    :status => 1,
    :success => false
  }
else
  commands = {
    'restart' => "/usr/local/bin/heroku restart --app #{config[:application]}",
    'start' => "/usr/local/bin/heroku scale #{config[:worker]}=1 --app #{config[:application]}",
    'stop' => "/usr/local/bin/heroku scale #{config[:worker]}=0 --app #{config[:application]}"
  }

  command = commands[config[:command]]
  stdout = Open3.capture3(command)
  result = {
    :message => stdout,
    :status => 0,
    :success => true
  }
end

config = YAML.load_file(File.dirname(__FILE__) + "/config/mlab.heroku_operation.yml")
database = config['database']
collection = config['collection']
apiKey = config['apikey']
path = '/api/1/databases/%s/collections/%s' % [database, collection]
header = {'Content-Type' => "application/json"}

Net::HTTP.version_1_2
https = Net::HTTP.new('api.mlab.com', 443)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_NONE
https.start do |request|
  raise unless request.put(path + "?apiKey=#{apiKey}", [].to_json, header).code == "200"
  raise unless request.post(path + "?apiKey=#{apiKey}", result.to_json, header).code == "200"
end
