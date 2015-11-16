DEBUG = false

require 'rubygems'
require 'bundler/setup'
require 'net/http'
require 'json'
require 'ant'
require 'yaml'

def toHashSize(a)
	{
		" MH/s"  => 1024,
		" GH/s" => 1024 * 1024,
		" TH/s" => 1024 * 1024 * 1024,
		" PH/s" => 1024 * 1024 * 1024 * 1024
	}.each_pair { |e, s| return "#{(a.to_f / (s / 1024)).round(1)}#{e}" if a < s }
end

cfg = YAML::load_file("conf.yml") 
puts cfg.inspect if DEBUG
api = Ant::API.new(cfg["apuser"], cfg["api_key"], cfg["api_secret"])
puts api.inspect if DEBUG
account = api.account
abort "API error - please check config" if account["code"] != 0
puts account.inspect if DEBUG
rate = api.hashrate
source = 'http://api.coindesk.com/v1/bpi/currentprice.json'
resp = Net::HTTP.get_response(URI.parse(source))
data = resp.body
result = JSON.parse(data)
puts "BT value:   " + result["bpi"]["EUR"]["rate"].to_f.round(2).to_s + " €"
puts "earned 24h: #{account["data"]["earn24Hours"]} BTC / #{(result["bpi"]["EUR"]["rate"].to_f * account["data"]["earn24Hours"].to_f).round(2)} €"
puts "Total:      #{account["data"]["earnTotal"]} BTC / #{(result["bpi"]["EUR"]["rate"].to_f * account["data"]["earnTotal"].to_f).round(2)} €"
puts "Paid out:   #{account["data"]["paidOut"]} BTC / #{(result["bpi"]["EUR"]["rate"].to_f * account["data"]["paidOut"].to_f).round(2)} €"
puts "Balance:    #{account["data"]["balance"]} BTC / #{(result["bpi"]["EUR"]["rate"].to_f * account["data"]["balance"].to_f).round(2)} €"
rate["data"].each do |key, value|
	if key =~ /last/ || key =~ /prev/
		puts key + " : " + toHashSize(value.to_i)
	else
	puts key + " : " + value
	end
end
