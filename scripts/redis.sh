tar -zxvf redis-3.2.8.tar.gz
cd redis-3.2.8
make && make install
cd ../redis
./bin/redis-server &
./bin/redis-cli
vim redis.conf
bind 
daemonize 

ps aux | grep redis

select 1
HGETALL app::users:click