cd ${KAFKA_HOME}
./bin/zookeeper-server-start.sh ./config/zookeeper.properties &
./bin/kafka-server-start.sh ./config/server.properties &
./bin/kafka-topics.sh --create --topic topic1 --replication-factor 1 --partitions 3 --zookeeper localhost:2181  
./bin/kafka-topics.sh --list --zookeeper localhost:2181  
./bin/kafka-topics.sh --delete --zookeeper localhost:2181 --topic topic5  
./bin/kafka-console-producer.sh --broker-list localhost:9092 --topic topic1 
./bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic topic1 --from-beginning 


#设置多个broker集群
cp config/server.properties config/server-1.properties 
cp config/server.properties config/server-2.properties

config/server-1.properties: 
    broker.id=1 
    listeners=PLAINTEXT://:9093 
    log.dir=/tmp/kafka-logs-1

config/server-2.properties: 
    broker.id=2 
    listeners=PLAINTEXT://:9094 
    log.dir=/tmp/kafka-logs-2

bin/kafka-server-start.sh config/server-1.properties &
bin/kafka-server-start.sh config/server-2.properties &
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3 --partitions 1 --topic my-replicated-topic
bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic my-replicated-topic

bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic test

#测试容错
#先杀掉leader
ps | grep server-1.properties
kill -9 7564
#备份节点成为新的leader
bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic my-replicated-topic
#消息没丢
bin/kafka-console-consumer.sh --zookeeper localhost:2181 --from-beginning --topic my-replicated-topic


#使用 Kafka Connect 来 导入/导出 数据
#创建种子数据
echo -e "foo\nbar" > test.txt
#导入连接器（外部文件数据导入到主题）、导出连接器（从主题导出到外部文件）
bin/connect-standalone.sh config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties

#使用Kafka Stream来处理数据
#Kafka Stream是kafka的客户端，用于实时处理与分析存储在kafka中的数据
#WordCount
KTable wordCounts = textLines
    // Split each text line, by whitespace, into words.
    .flatMapValues(value -> Arrays.asList(value.toLowerCase().split("W+")))

    // Ensure the words are available as record keys for the next aggregate operation.
    .map((key, value) -> new KeyValue<>(value, value))

    // Count the occurrences of each word (record key) and store the results into a table named "Counts".
    .countByKey("Counts")
#通过外部文件写入数据导入到主题中
echo -e "all streams lead to kafka\nhello kafka streams\njoin kafka summit" > file-input.txt
#创建主题
bin/kafka-topics.sh --create \
            --zookeeper localhost:2181 \
            --replication-factor 1 \
            --partitions 1 \
            --topic streams-file-input

cat /tmp/file-input.txt | ./bin/kafka-console-producer --broker-list localhost:9092 --topic streams-file-input
#启动WordCount
./bin/kafka-run-class org.apache.kafka.streams.examples.wordcount.WordCountDemo
#验证结果是否写入
./bin/kafka-console-consumer --zookeeper localhost:2181 
            --topic streams-wordcount-output 
            --from-beginning 
            --formatter kafka.tools.DefaultMessageFormatter 
            --property print.key=true 
            --property print.key=true 
            --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer 
            --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer

