#!/bin/bash

COMPRESSION_TYPE=(gzip lz4 zstd snappy)
KAFKA_DIR=/Users/kevinzhang/Projects/kafka

GZIP_BUFFER_SIZES=(512 2048 8192 32768)
LZ4_BLOCK_SIZES=(4 5 6 7)
ZSTD_WINDOW_SIZES=(0 10 16 22)
SNAPPY_BLOCK_SIZES=(1024 4096 16384 65536)

BROKER_0_ADDRESS=""


# compression type, buffer size
function setup_cluster(){
    cleanup
    echo "----------------- cluster setup -----------------"

    compression_type=$1
    buffer_size=$2

    echo "compression type: $compression_type"
    echo "buffer size: $buffer_size"


    echo "start the controller"
    CONTROLLER_OUTPUT=$(./docker/start_controller.sh)
    echo "$CONTROLLER_OUTPUT"

    temp=$(echo "$CONTROLLER_OUTPUT" | grep -o 'controller.quorum.voters=[0-9]*@[^ ]*')
    CONTROLLER_ADDRESS=$(echo "$temp" | awk -F'=' '{print $2}')
    CLUSTER_ID=$(echo "$CONTROLLER_OUTPUT" | grep -oE 'run CLUSTER_ID=[^ ]+' | cut -d '=' -f 2)

    echo $CONTROLLER_IP
    echo $CLUSTER_ID

    echo "start the broker"
    broker_output=$(BUFFER_SIZE=$buffer_size COMPRESSION_TYPE=$compression_type CLUSTER_ID=$CLUSTER_ID BROKER_PORT=9092 ACCOUNT=kevinztw REVISION=kip-780 KAFKA_ACCOUNT=kevinztw /Users/kevinzhang/Projects/astraea/docker/start_broker.sh controller.quorum.voters=$CONTROLLER_ADDRESS)
    
    BROKER_0_ADDRESS=$(echo "$broker_output" | awk '/broker address:/ {print $3}')
    
    BUFFER_SIZE=$buffer_size COMPRESSION_TYPE=$compression_type CLUSTER_ID=$CLUSTER_ID BROKER_PORT=9092 ACCOUNT=kevinztw REVISION=kip-780 KAFKA_ACCOUNT=kevinztw /Users/kevinzhang/Projects/astraea/docker/start_broker.sh controller.quorum.voters=$CONTROLLER_ADDRESS
    BUFFER_SIZE=$buffer_size COMPRESSION_TYPE=$compression_type CLUSTER_ID=$CLUSTER_ID BROKER_PORT=9092 ACCOUNT=kevinztw REVISION=kip-780 KAFKA_ACCOUNT=kevinztw /Users/kevinzhang/Projects/astraea/docker/start_broker.sh controller.quorum.voters=$CONTROLLER_ADDRESS
    
    # wait the cluster to be ready
    sleep 10
    
}

function cleanup(){
    echo "clean up"
    CONTROLLER_ID=$(docker ps -a | grep "ghcr.io/skiptests/astraea/controller" | awk '{print $1}')
    echo $CONTROLLER_ID |  xargs docker stop
    echo $CONTROLLER_ID |  xargs docker rm

    BROKER_ID=$(docker ps -a | grep "ghcr.io/kevinztw/astraea/broker" | awk '{print $1}')
    echo $BROKER_ID |  xargs docker stop
    echo $BROKER_ID |  xargs docker rm
}

function run_cluster_compression_benchmark(){
    for compression_type in "${COMPRESSION_TYPE[@]}"
    do
        buffer_sizes=()
        if [ "$compression_type" == "gzip" ]; then
            buffer_sizes=("${GZIP_BUFFER_SIZES[@]}")
        elif [ "$compression_type" == "lz4" ]; then
            buffer_sizes=("${LZ4_BLOCK_SIZES[@]}")
        elif [ "$compression_type" == "zstd" ]; then
            buffer_sizes=("${ZSTD_WINDOW_SIZES[@]}")
        elif [ "$compression_type" == "snappy" ]; then
            buffer_sizes=("${SNAPPY_BLOCK_SIZES[@]}")
        fi


        for buffer_size in "${buffer_sizes[@]}"
        do
            echo "test type: $compression_type buffer size: $buffer_size"
            setup_cluster $compression_type $buffer_size
            $KAFKA_DIR/bin/kafka-topics.sh --create --topic test-compression --replication-factor 3 --bootstrap-server $BROKER_0_ADDRESS
            
            output=$(KAFKA_HEAP_OPTS="-Xms12G -Xmx12G" $KAFKA_DIR/bin/kafka-run-class.sh org.apache.kafka.tools.TestCompression \
                --bootstrap-server $BROKER_0_ADDRESS \
                --compression-type $compression_type \
                --topic test-compression \
                --buffer-size $buffer_size)
                
            echo "$output" >> "test_compression.log"
        done      
        echo "clean up"
    done
}

function exec(){
    run_cluster_compression_benchmark
}


exec