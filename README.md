# check_mysql_qps.rb

This is Monitoring Script for MYSQL QPS.

## Usage


Init script and instll mysql2
```
$ git clone git@github.com:takeshiyako2/nagios-check_mysql_qps.git
$ cd nagios-check_mysql_qps
$ bundle
```

Run script
```
$ ruby check_mysql_qps.rb -H localhost -u username -p xxxx -w 500 -c 900
OK - 123 Queries per second|QPS=123
```

## Auteur

Takeshi Yako

## Licence

MIT

