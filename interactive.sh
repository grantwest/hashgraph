#!/bin/bash

docker build -t hashgraph-dev -f Dockerfile.dev .

docker run -it --rm \
-u $(id -u):$(id -g) \
-v $(pwd):/src \
-w /src \
--name hashgraph_dev \
hashgraph-dev /bin/bash
