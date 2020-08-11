[TOC]
# derecho-docker
This project provides a docker container image for testing and developing software with [Derecho](https://github.com/Derecho-Project/derecho) and [Cascade](https://github.com/Derecho-Project/cascade). Derecho is an open-source C++ distributed computing toolkit that provides strong forms of distributed coordination and consistency at RDMA speeds. Thanks to hardware independent design in Derecho, you can develop or test it without real RDMA hardware. Cascade is a LEGO-like distributed storage hierarchy for Cloud applications. It wraps distributed persistent storage and memory resources into a high-performance and fault-tolerant storage system for applications like IoT.

Our testing is performed primarily on an Intel cluster of 16 nodes equipped with 100Gbps Mellanox RDMA.  Derecho itself can be configured to use this RDMA hardware, or to run over TCP instead.  

We have also experimented with Derecho at much larger scale on HPC supercomputers.  This can be difficult to do: the startup of a large configuration can put a lot of stress on the datacenter file system and TCP layer (even in RDMA mode, we need "helper" connections which are based on TCP), and you might find it necessarily to launch Derecho processes in batches of 25 or 50 at a time.  As such, we don't recommend experimenting with large configurations until you have successful experience with smaller ones.

One further comment: Derecho is not really intended for large configurations that would run in heavily virtualized environments.  So even though you "could" potentially run 100 copies of this docker container on one machine, we guarantee that even in TCP mode, doing that would be unsuccessful -- all sorts of timeouts would occur, and the system would certainly crash.  You should be able to run 2 or 3 copies on one machine in TCP mode, for development and debugging of your applications, but we wouldn't go much beyond that.

# To build the image :
you can build the docker image without clone this repository:
```
$ docker build -t derecho-dev https://github.com/Derecho-Project/derecho-docker.git#:derecho-dev
```
Or, if you are interested in customizing this image, clone the repo at: https://github.com/Derecho-Project/derecho-docker.git.
`cd` into the directory `derecho-docker/derecho-dev` and issue the command [It may take around 3~5 min depending on network throughput]
```
$ docker build -t derecho-dev .
```

>NOTE: Now that cascade is still private, before pulling cascade, you need to set your github Username and Password in `derecho-dev/build/build-cascade.sh`.

Now derecho and cascade have been compiled and installed in the image, you just need to customize the configuration file before using.

# To configure and run Derecho 
> NOTE: the old way to configure is [here](#jump), it still works.

With kubernetes, managing multiple nodes is more convenient.

First, create `derecho-workspace` namespace with
```bash
kubectl create namespace derecho-workspace
```
Second, start pods withs `derecho-dev` image, for example, we strat 3 pods:
```bash
kubectl apply -f derecho-deployment.yaml
```
> NOTE: if your kubernetes cluster has many nodes, you need to build image on every node from the Dockerfile or push the image onto dockerhub or something. In the future we may push one.

Then generate `derecho.cfg` for them:
```bash
./config-derecho-pods.sh
```
This script can set `LEADER_IP`, `LOCAL_IP`, and `LOCAL_ID` in `/derecho.cfg`, and the environment variable `DERECHO_CONF_FILE` has been set to `/derecho.cfg` in Dockerfile.

When you see output like below, you can run tests and applications freely.
```bash
On node 10.217.0.105 (id: 0, leader: 10.217.0.105)
Configuration is successfully generated in file: derecho.cfg.
The 'DERECHO_CONF_FILE' environment variable has been set to this file: /derecho.cfg
=========================

On node 10.217.0.77 (id: 1, leader: 10.217.0.105)
Configuration is successfully generated in file: derecho.cfg.
The 'DERECHO_CONF_FILE' environment variable has been set to this file: /derecho.cfg
=========================

On node 10.217.0.53 (id: 2, leader: 10.217.0.105)
Configuration is successfully generated in file: derecho.cfg.
The 'DERECHO_CONF_FILE' environment variable has been set to this file: /derecho.cfg
=========================

On node 10.217.0.15 (id: 3, leader: 10.217.0.105)
Configuration is successfully generated in file: derecho.cfg.
The 'DERECHO_CONF_FILE' environment variable has been set to this file: /derecho.cfg
=========================

On node 10.217.0.82 (id: 4, leader: 10.217.0.105)
Configuration is successfully generated in file: derecho.cfg.
The 'DERECHO_CONF_FILE' environment variable has been set to this file: /derecho.cfg
=========================
```


# To configure and run Derecho (<span id="jump">the old way</span>)
Issue the following command to start a container with `derecho-dev` image:
```bash
$ docker run -it derecho-dev /bin/bash
```

A Derecho application is composed of multiple nodes that talk to each other. Each node is assigned an integer identifier(ID). One of the nodes, usually node `0`, is designated as the leader when system starts. To start a Derecho node, the Derecho component needs to know my ID/IP address and the IP address of the leader. In addition, it needs to know which communication protocol, e.g. TCP/IP or verbs RDMA, and which interfaces to use for talking with other nodes. There are many configuration knobs but
`config-derecho.sh` helps with the minimum configurations to run derecho.

Let's start with the `bandwith_test`, which evaluates the data throughput of a Derecho group. We want to test a small group with two nodes talking to each other using TCP/IP. Let's repeat the previous steps to run another `derecho-dev` container and build Derecho source code. Run `ifconfig` to find their network interface and ip address.
```
# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:42:ac:11:00:02  
          inet addr:172.17.0.2  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:651809 errors:0 dropped:0 overruns:0 frame:0
          TX packets:636540 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:23729106695 (23.7 GB)  TX bytes:152899589 (152.8 MB)
```
Let's assume that the two containers A and B both use interface `eth0`. A's IP address is `172.17.0.2` and B's IP address is `172.17.0.3`. Let's assign node id `0` to A, and `1` to B. And we designate A as the leader. Then issue the following commond to configure node A:
```
# /root/config/config-derecho.sh
Usage: /usr/local/bin/config-derecho.sh <leader ip> <local ip> <local id> [provider,default to 'sockets'] [domain,default to 'eth0']
# /root/config/config-derecho.sh 172.17.0.2 172.17.0.2 0 sockets eth0
On node 172.17.0.2 (id: 0, leader: 172.17.0.2)
Configuration is successfully generated in file: derecho.cfg.
The 'DERECHO_CONF_FILE' environment variable has been set to this file: /derecho.cfg
=========================
```


Configure B in a similar way:
```
# /root/config/config-derecho.sh
Usage: /usr/local/bin/config-derecho.sh <leader ip> <local ip> <local id> [provider,default to 'sockets'] [domain,default to 'eth0']
# /root/config/config-derecho.sh 172.17.0.2 172.17.0.3 0 sockets eth0
On node 172.17.0.3 (id: 0, leader: 172.17.0.2)
Configuration is successfully generated in file: derecho.cfg.
The 'DERECHO_CONF_FILE' environment variable has been set to this file: /derecho.cfg
=========================
```

Now, we are ready to run the experiments. In both A and B, go to the folder containing the binary:
```
# cd derecho/build/applications/tests/performance_tests/
```
run `bandwidth_test` in both containers:
```
# ./bandwidth_test
Insufficient number of command line arguments
Enter num_nodes, num_senders_selector (0 - all senders, 1 - half senders, 2 - one sender), num_messages, delivery_mode (0 - ordered mode, 1 - unordered mode)
Thank you
[139925796948032] shutdown_polling_thread() begins.
[139925796948032] done with shutdown_polling_thread().
# ./bandwidth_test 2 0 10000 0
[139900766643968] polling thread starts.
Initialized SST and Started Threads
Initialization complete
Finished constructing/joining Group
The order of members is :
0 1 
The persist thread started
Initialized SST and Started Threads
DerechoGroup send thread shutting down
The persist thread is exiting
Failed polling the completion queuePoll completion error with node (id=1). Freezing row 1
Exception in the failure upcall: Potential partitioning event: this node is no longer in the majority and must shut down!
timeout_thread shutting down
Connection listener thread shutting down.
Old View cleanup thread shutting down.
[139900977338432] shutdown_polling_thread() begins.
[139900977338432] joining polling thread.
[139900766643968] polling thread stops.
[139900977338432] done with shutdown_polling_thread().
# 
```
_Plesae ignore the above exception message. This is because one node quits a little bit earlier than the other node, which is detected by the other node._

On the leader node, you can see a file called `data_derecho_bw`, which contains the test results:
```
# cat data_derecho_bw
2 0 10240 16 10000 0 0.0456381
```
The last number is the tested throughput in GByte/Sec. Other numbers are parameters: <number of nodes> <sender selector> <message size> <window size> <number of messages> <delivery_mode>
  
_We are working on adding explanation on the tests._

Note: (Derecho will write group meta data, which we call `views` to disk for fault-tolerance purpose)[https://github.com/Derecho-Project/derecho-unified/issues/82]. For small tests like `bandwidth_test`, we don't need that and it will cause an exception if the old view exists. So, please delete the states (in `.plog` folder) on each node before run a new test.
```
rm -r .plog
```

For more experiments and details on Derecho, please refer to the [Derecho project](https://github.com/Derecho-Project/derecho) and [Cascade project](https://github.com/Derecho-Project/cascade).

# For cascade service
You can replace the `derecho.cfg.template` and add your own on-critical-datapath library with volumes like `derecho-deployment-with-cfg.yaml` shows.

>TODO: show how to run cascade service.
