## Introduction

This performance benchmark is design to reproduce the result from (kip 780).

In the previous result, we know that there is potential tuning could be make to reduce memory footprint in the kafka cluster.

The hypothesis is that instead of the default setting, we could further optimize it to the smaller size without compromise the performance.

## Goal

1. Benchmark the influence of compression buffer for each compression type for **cluster side compression** for throughput
2. Benchmark the influence of compression buffer for each compression type for **producer side compression** for throughput

## Steps

execute below

```sh
./test-compression-cluster.sh KAFKA_DIR=/Users/kevinzhang/Projects/kafka
```

1. The data pass from producer to cluster would be pre-generated using `gen_mock_data.sh` under `data/mock` with size per line as 100, 1000 and 10,000 byte
2. Execute he script
   2.1 which would form a three nodes kafka cluster using docker ontop of the bare metal

<!-- - setup limitatino 16 GB memory for docker --memory=16g
- set the memory and memory swap to same value to prevent potential influence from swap () -->

2.2 it would then create the kafka topic and form

## Note

- The producer would collocate with the broker, controller in master machine. In here we would make sure the machine's resoucrs is enough to host all three and won't have
  potential hidden bottleneck
- Curently, the script is desgined to be executed in the leader machine
- Each mock data file size is 10MB, we leverage on that to check how much we send to cluster
- Just run the script should automatically build required broker docker image by the support of astraea. However, you could also prebuild and upload to github. And since our machine contains multiple architecture, we build the multi-arch docker image as below (Note: the user account should match to the account used in `test-compressions-*.sh` scripts)

```sh
docker push ghcr.io/kevinztw/astraea/broker:kip-780-arm64
docker push ghcr.io/kevinztw/astraea/broker:kip-780-amd64

docker manifest create ghcr.io/kevinztw/astraea/broker:kip-780 \
	--amend ghcr.io/kevinztw/astraea/broker:kip-780-arm64 \
	--amend ghcr.io/kevinztw/astraea/broker:kip-780-amd64

docker manifest push ghcr.io/kevinztw/astraea/broker:kip-780
```
