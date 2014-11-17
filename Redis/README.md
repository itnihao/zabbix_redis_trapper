Template Redis
============

此模板采用zabbix (Low Level Discovery) 的功能

安装模板
-------

* `redis_data.sh` 调用复制在zabbix/bin/目录下
* `redis_data.conf` 加入到zabbix_agentd.conf.d/目录下
* `leon_redis_templates.xml` 导入leon_redis模板
* 重启zabbix agent


如何工作
------------

### 使用方式

`mysql-check-v2.sh` 使用方式:

* `./redis_data.sh discovery`  发现redis端口并提供给Server
* `./mysql-check-v2.sh collector "$host" $port` 通过Hostname也就是Zabbix的主机名称以及端口,将获取的数据传输给Zabbix,模板中是客户端主动推数据给Server,采用类型是`zabbix trapper`


### 特别注意
1.在发送给Server时采用的是zabbix_sender命令,其中-s 所要的是zabbix获取的名称,并不是IP就是对的。
2.手动执行zabbix_get来确认是否真的生效的,特别是agnet是否重启。
