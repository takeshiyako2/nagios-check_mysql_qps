#!/bin/env ruby
# -*- coding: utf-8 -*-
#
# Monitoring Script for MYSQL QPS
#
# example)
# $ ruby check_mysql_qps.rb -H localhost -u username -p xxxx -w 500 -c 900
# OK - 123 Queries per second|QPS=123
#
# Auter: Takeshi Yako
# Licence: MIT
# 

require 'rubygems'
require 'optparse'
require 'mysql2'
require 'time'
require 'json'

# Get options

hostname = "#{ARGV[0]}"
port = "#{ARGV[1]}"
username = "#{ARGV[2]}"
password = "#{ARGV[3]}"
warning = "#{ARGV[4]}".to_i
critical = "#{ARGV[5]}".to_i

options = {}

OptionParser.new do |opt|
  opt.banner = "Usage: #{$0} command <options>"
  opt.separator ""
  opt.separator "Nagios options:"
  opt.on("-H", "--hostname ADDRESS", "Host name or IP Address") { |hostname| options[:hostname] = hostname }
  opt.on("-P", "--port INTEGER", "Port number (default: 3306)") { |port| options[:port] = port }
  opt.on("-u", "--username STRING", "Connect using the indicated username") { |username| options[:username] = username}
  opt.on("-p", "--password STRING", "Use the indicated password to authenticate the connection") { |password| options[:password] = password}
  opt.on("-w", "--warning WARNING", "Nagios warning level. warning >= current QPS") { |warning| options[:warning] = warning.to_i }
  opt.on("-c", "--critical CRITICAL", "Nagios critical level. critical >= current QPS") { |critical| options[:critical] = critical.to_i }
  opt.on_tail("-h", "--help", "Show this message") do
    puts opt
    exit 0
  end

  begin
    opt.parse!
  rescue
    puts "Invalid option. \nsee #{opt}"
    exit
  end 

end.parse!

class CheckMysqlQps

  # tmp file path
  @@tmp_filename = '/tmp/check_mysql_qps.dat'

  def initialize(options)

    # Get last data
    last_data = ''
    if File.exist?(@@tmp_filename)
      json_data = open(@@tmp_filename) do |io|
        last_data = JSON.load(io)
      end
    end

    # Get MySQL STATUS of Queries
    client = Mysql2::Client.new(:host => options[:hostname], :username => options[:username], :password => options[:password], :port => options[:port]) 
    queries = client.query("SHOW STATUS LIKE \"Queries\"").each[0]['Value']

    # Get unix timestamp
    unixtime = Time.now.to_i

    # Save Current Status
    open(@@tmp_filename, 'w') do |io|
      JSON.dump({:queries => queries, :unixtime => unixtime}, io)
    end

    # If no tmp file
    if last_data["queries"] == nil && last_data["unixtime"] == nil
      puts "OK - Current Status is saved. queries:#{queries}, unixtime:#{unixtime}"
      exit 0
    else
      # Calc fail under one second
      time_variance = unixtime.to_i - last_data["unixtime"].to_i
      if time_variance == 0
        puts "OK - Calculation is failed. Because time variance is under one second. Try again Later."
        exit 0
      else
        # Check qps
        qps =  (queries.to_i - last_data["queries"].to_i) / time_variance
        basec_message = "#{qps} Queries per second|QPS=#{qps}"
        if qps >= options[:critical]
          puts "CRITICAL - #{basec_message}"
          exit 2
        elsif qps >= options[:warning]
          puts "WARNING - #{basec_message}"
        else
          puts "OK - #{basec_message}"
        end
      end

    end
    
  end

end

CheckMysqlQps.new(options)
