# docker-webtools

Docker container loaded up with the Web tools of trade !

Table of Contents
=================
* [Purpose](#purpose)
* [Images](#images)
  * [Build](#build)
  * [Use](#use)
  * [Software installed](#software-installed)
    * [Ali](#ali)
    * [Apache Bench](#apache-bench)
    * [Autocannon](#autocannon)
    * [Curl-loader](#curl-loader)
    * [Dirb](#dirb)
    * [Gobench](#gobench)
    * [Httperf](#httperf)
    * [Siege](#siege)
    * [Sqlmap](#sqlmap)
    * [Whatweb](#whatweb)
    * [Wpscan](#wpscan)
* [Continuous Integration](#continuous-integration)
* [Continuous Deployment](#continuous-deployment)
* [Feedback & Bug Reports](#feedback--bug-reports)
* [Copyright & License](#copyright--license)


Purpose
=======

When building my own [docker-openresty](https://github.com/oorabona/docker-openresty) project, it was important at some point to be able to compare performance and features and to have a adversarial (i.e. some kind of red team) for the CI phase to implement.

There are many tools out there, for both benchmarking web servers and hacking them ...

So here we go with a (non exhaustive) list for starter.

Feel free to submit an issue or even a PR if you want to have more tools installed.

> Only HTTP server benchmarking tools and HTTP server offensive security tools accepted !

Images
======

As of today, only `Alpine` and `Debian` based images are supported.

The former to allow all these tools to take as little disk as possible (less than 1G in disk space today), the latter for its usability and versatility.

It is unlikely any other base image will be used, unless there is a *very* good reason :wink:

After hours spent trying to figure out why some software (I'm looking at you `curl-loader`) failed to compile so badly, most likely because it is 10+ years without any update, conclusion is that for now there is no compatibility with anything but `linux/amd64`. You can probably try to compile for `i386` but no `armv7` or other platforms... :unamused:

Build
=====

To build these images, simply run :

```sh
$ ./build <base_os>
# E.g.
$ ./build alpine
# Or
$ ./build buster
```

Where `base_os` has two values, either `alpine` or one of the two **Debian** flavors, namely `buster` or `stretch`.

If you want to tweak a bit more the building process, this is the current available parameters:

```sh
$ ./build
build <base-image> [packages-versions-file] [platforms]

- base-image is the fully qualified base image to build on.
  From this value is infered whether 'alpine' or 'debian' installation methods.

- packages-versions-file contains for each package the strategy to download its
  source code. It can be either a version pinned, a branch name, or 'latest'
  to automatically retrieve its latest tag.

  By default the file used is 'versions.vars', have a look and tweak it :)

  Note: this only works for GitHub hosted source code.

- platforms is a comma separated list of platforms to build the source.
  By default platforms linux/amd64 and linux/amd64 are built, 'all' is accepted.
```

A typical [versions.vars](versions.vars) is provided.

> **NOTES**
> * The packages versions file collects all strategies to know which version (or branch) it will need to download and compile from.
> * Not all software rely on `versions.vars` file, only the ones hosted on GitHub and that need to be compiled. Others already available at Docker images (e.g. `wpscan`) will not be recompiled but instead `COPY`-ed over from their built image.

Use
===

To use these images it is the usual :

```sh
$ docker run --pull=always --rm -it oorabona/webtools:<version>-<os>
# E.g.
$ docker run --pull=always --rm -it oorabona/webtools:1.0.0-alpine
# Or
$ docker run --pull=always --rm -it oorabona/webtools:latest-buster
```

The `version` here is related to the `versions.vars` package file. When new software will be added, this file (and therefore its version) will be updated.

`latest` tag is automatically pointing to the latest built image.

Software installed
==================

Ali
---

[Ali](https://github.com/nakabonne/ali) is a load testing tool capable of performing real-time analysis, inspired by [vegeta](https://github.com/tsenart/vegeta) and [jplot](https://github.com/rs/jplot).

Apache Bench
------------

[Apache Bench](https://httpd.apache.org/docs/2.4/programs/ab.html) is the Apache HTTP server benchmarking tool.

Autocannon
----------

[Autocannon](https://github.com/mcollina/autocannon) is HTTP/1.1 benchmarking tool written in node, greatly inspired by [wrk][wrk] and [wrk2][wrk2], with support for HTTP pipelining and HTTPS.

Curl-loader
-----------

[curl-loader](http://curl-loader.sourceforge.net/) (also known as "omes-nik" and "davilka") is an open-source tool written in C-language, simulating application load and application behavior of thousands and tens of thousand HTTP/HTTPS and FTP/FTPS clients, each with its own source IP-address. In contrast to other tools curl-loader is using real C-written client protocol stacks, namely, HTTP and FTP stacks of libcurl and TLS/SSL of openssl, and simulates user behavior with support for login and authentication flavors.

Dirb
----

[DIRB](http://dirb.sourceforge.net/) is a Web Content Scanner. It looks for existing (and/or hidden) Web Objects. It basically works by launching a dictionary based attack against a web server and analizing the response.

Gobench
-------

[Gobench](https://github.com/cmpxchg16/gobench) is a HTTP/HTTPS load testing and benchmarking tool written in Go.

Httperf
-------

[Httperf](https://github.com/httperf/httperf) is a tool for measuring web server performance. It provides a flexible facility for generating various HTTP workloads and for measuring server performance.

Siege
-----

[Siege](https://github.com/JoeDog/siege) is an open source regression test and benchmark utility. It can stress test a single URL with a user defined number of simulated users, or it can read many URLs into memory and stress them simultaneously. The program reports the total number of hits recorded, bytes transferred, response time, concurrency, and return status. Siege supports HTTP/1.0 and 1.1 protocols, the GET and POST directives, cookies, transaction logging, and basic authentication. Its features are configurable on a per user basis.

Sqlmap
------

[sqlmap](https://github.com/sqlmapproject/sqlmap) is an open source penetration testing tool that automates the process of detecting and exploiting SQL injection flaws and taking over of database servers. It comes with a powerful detection engine, many niche features for the ultimate penetration tester, and a broad range of switches including database fingerprinting, over data fetching from the database, accessing the underlying file system, and executing commands on the operating system via out-of-band connections.

Whatweb
-------

[WhatWeb](https://github.com/urbanadventurer/WhatWeb) identifies websites. Its goal is to answer the question, "What is that Website?". WhatWeb recognises web technologies including content management systems (CMS), blogging platforms, statistic/analytics packages, JavaScript libraries, web servers, and embedded devices. WhatWeb has over 1800 plugins, each to recognise something different. WhatWeb also identifies version numbers, email addresses, account IDs, web framework modules, SQL errors, and more.

Wpscan
------

[WPScan](https://github.com/wpscanteam/wpscan) WordPress security scanner. Written for security professionals and blog maintainers to test the security of their WordPress websites.


Continuous Integration
======================

None so far. Will do that sometime soon.

Also Github Actions seem to be able to trigger builds upon a commit on a remote repository (as long as it is hosted on GitHub) but for now it does not seem necessary to setup such trigger.

Feel free to open an issue if you think otherwise.

Continuous Deployment
=====================

This container is used in my other project [docker-openresty](https://github.com/oorabona/docker-openresty). But that is not what a continuous deployment really is, so consider it as not *yet* implemented.

Feedback & Bug Reports
======================

Feel free to submit an issue or better a PR and contribute to this project.
Also, if you find it useful for your projects, drop a line too, your project can be added here too !

Copyright & License
===================

This work is licensed under MIT [license](LICENSE).

Of course all included software have their respective licenses and belong to their original authors. Kudos to all.
