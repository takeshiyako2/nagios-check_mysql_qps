# check_mysql_qps.rb

This is Monitoring Script for MYSQL QPS.

## Usage


### 1) Init script and instll Ruby mysql2 library
```
$ git clone git@github.com:takeshiyako2/nagios-check_mysql_qps.git
$ cd nagios-check_mysql_qps
$ bundle
```

### 2) Run script
```
$ ruby check_mysql_qps.rb -H localhost -u username -p xxxx -w 500 -c 900
OK - Current Status is saved. queries:10000, unixtime:1423816070

$ ruby check_mysql_qps.rb -H localhost -u username -p xxxx -w 500 -c 900
OK - 123 Queries per second|QPS=123
```

### 3) Remove tmp file for nagios check
```
$ rm /tmp/check_mysql_qps.dat
```

### 4) Set up Nagios

## Auteur

Takeshi Yako

## Licence

MIT

