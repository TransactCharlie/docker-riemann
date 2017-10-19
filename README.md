# Docker-Riemann

A build of the [riemann metrics platform](http://riemann.io) for docker using alpine linux.

* [Image Details](#image-details)
  * [Build / Docker Image Status](#build--docker-image-status)
* [Quickstart](#quickstart)
* [Configuration](#configuration)
  * [Injecting Config](#injecting-config)
  * [Example Config With Docker Compose](#example-config-with-docker-compose)
  * [Baking Configuration Into Your Images](#baking-configuration-into-your-images)

## Image Details
This image is built against base image: [openjdk:8-alpine](https://hub.docker.com/_/openjdk/) with an entrypoint targetting `bin/riemann`. The image looks for configuration by default in /config/riemann.config (see the [Configuration](#configuration) section for more details) and you can override that, or pass jvm / riemann command options by overriding the CMD section:

```Dockerfile
ENTRYPOINT ["bin/riemann"]
CMD ["/config/riemann.config"]
```

### Build / Docker Image Status

[![Build Status Status](https://travis-ci.org/TransactCharlie/docker-riemann.svg?branch=master)](https://travis-ci.org/TransactCharlie/docker-riemann)
[![](https://images.microbadger.com/badges/image/transactcharlie/riemann.svg)](https://microbadger.com/images/transactcharlie/riemann "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/transactcharlie/riemann.svg)](https://microbadger.com/images/transactcharlie/riemann "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/transactcharlie/riemann.svg)](https://microbadger.com/images/transactcharlie/riemann "Get your own commit badge on microbadger.com")

## Quickstart

Riemann without your custom [configuration](#configuration) is pretty pointless but if you want to check that this image actually runs you can use the riemann default configuration and play about with command line options like so:

```
docker run transactcharlie/riemann /riemann/etc/riemann.config
```

You should see some logging:
```
# docker run transactcharlie/riemann /riemann/etc/riemann.config
INFO [2017-10-19 16:25:41,829] main - riemann.bin - PID 1
INFO [2017-10-19 16:25:41,832] main - riemann.bin - Loading /riemann/etc/riemann.config
INFO [2017-10-19 16:25:41,944] clojure-agent-send-off-pool-4 - riemann.transport.websockets - Websockets server 127.0.0.1 5556 online
INFO [2017-10-19 16:25:42,076] clojure-agent-send-off-pool-0 - riemann.transport.udp - UDP server 127.0.0.1 5555 16384 -1 online
INFO [2017-10-19 16:25:42,148] clojure-agent-send-off-pool-3 - riemann.transport.tcp - TCP server 127.0.0.1 5555 online
INFO [2017-10-19 16:25:42,150] main - riemann.core - Hyperspace core online
```

## Configuration
This build does not use the default config file deliberately. Riemann doesn't have a useful default configuration for anyone. You will have to roll your own.

the Dockerfile tells riemann to look for a config file at `/config/riemann.config`. There are a few different ways of putting configuration there. Pick whatever method works for your environment and container platform.

If you try running this container without config you won't get very far :)

```
# docker run transactcharlie/riemann
INFO [2017-10-19 15:58:57,082] main - riemann.bin - PID 1
INFO [2017-10-19 15:58:57,085] main - riemann.bin - Loading /config/riemann.config
ERROR [2017-10-19 15:58:57,095] main - riemann.bin - Couldn't start
java.io.FileNotFoundException: /config/riemann.config (No such file or directory)
	at java.io.FileInputStream.open0(Native Method)
	at java.io.FileInputStream.open(FileInputStream.java:195)
	at java.io.FileInputStream.<init>(FileInputStream.java:138)
	at java.io.FileInputStream.<init>(FileInputStream.java:93)
	at clojure.lang.Compiler.loadFile(Compiler.java:7314)
	at clojure.lang.RT$3.invoke(RT.java:320)
	at riemann.config$include.invokeStatic(config.clj:443)
	at riemann.config$include.invoke(config.clj:421)
	at riemann.bin$_main.invokeStatic(bin.clj:99)
	at riemann.bin$_main.doInvoke(bin.clj:85)
	at clojure.lang.RestFn.invoke(RestFn.java:425)
	at clojure.lang.AFn.applyToHelper(AFn.java:156)
	at clojure.lang.RestFn.applyTo(RestFn.java:132)
	at riemann.bin.main(Unknown Source)
```

### Injecting Config

The examples folder contains a few different ways or running riemann with injected or baked configuration.

```
examples
├── config-volume
│   └── riemann.config
├── docker-compose.yml
└── riemann-baked.dockerfile
```

The example config file in `examples/config-volumes/riemann.config` is a minimal configuration that listens for riemann events on port 5555 (tcp and udp) and carbon format lines on port 2003. It simply prints everything to std out so you can see the metrics you send to riemann.

### Example Config With Docker Compose

docker-compose is probably the easiest way to get started on your development machine. The `docker-compose.yaml` file mounts the `config-volume` folder in the riemann container at `/config`. just `docker-compose up` and you should see output like so:

```
# docker-compose up
Creating network "examples_default" with the default driver
Creating examples_riemann_1 ...
Creating examples_riemann_1 ... done
Attaching to examples_riemann_1
riemann_1  | INFO [2017-10-19 15:36:43,187] main - riemann.bin - PID 1
riemann_1  | INFO [2017-10-19 15:36:43,192] main - riemann.bin - Loading /config/riemann.config
riemann_1  | INFO [2017-10-19 15:36:43,338] clojure-agent-send-off-pool-1 - riemann.transport.websockets - Websockets server 0.0.0.0 5556 online
riemann_1  | INFO [2017-10-19 15:36:43,481] clojure-agent-send-off-pool-0 - riemann.transport.udp - UDP server 0.0.0.0 5555 16384 -1 online
riemann_1  | INFO [2017-10-19 15:36:43,534] clojure-agent-send-off-pool-6 - riemann.transport.tcp - TCP server 0.0.0.0 2003 online
riemann_1  | INFO [2017-10-19 15:36:43,628] clojure-agent-send-off-pool-5 - riemann.transport.tcp - TCP server 0.0.0.0 5555 online
riemann_1  | INFO [2017-10-19 15:36:43,628] main - riemann.core - Hyperspace core online
..
..
```

### Baking Configuration Into Your Images
Its also easy to bake the configuration in on top of the base image. An example dokerfile to do this is `examples/riemann-baked.dockerfile`. It is trivially simple - just copying the config folder into the right place in the image

```dockerfile
FROM transactcharlie/riemann:latest
COPY ./config-volume /config
```

Build it like so:
```
# docker build -f riemann-baked.dockerfile -t riemann:baked .
```

and now you should be able to run it.
```
# docker run -p 5555:5555 riemann:baked
```
Then put the image wherever is convenient for your environment.
