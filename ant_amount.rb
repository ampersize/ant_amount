DEBUG = false

require 'net/http'
require 'json'
require 'rubygems'
require 'ant'
require 'yaml'

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
pp rate["data"]
