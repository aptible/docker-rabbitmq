# ![](https://gravatar.com/avatar/11d3bc4c3163e3d238d558d5c9d98efe?s=64) aptible/rabbitmq

[![Docker Repository on Quay.io](https://quay.io/repository/aptible/rabbitmq/status "Docker Repository on Quay.io")](https://quay.io/repository/aptible/rabbitmq)
[![Build Status](https://travis-ci.org/aptible/docker-rabbitmq.svg?branch=master)](https://travis-ci.org/aptible/docker-rabbitmq)

RabbitMQ, on top of Alpine.

## Installation and Usage

    docker pull quay.io/aptible/rabbitmq:${VERSION:-latest}

This is an image conforming to the [Aptible database specification](https://support.aptible.com/topics/paas/deploy-custom-database/). To run a server for development purposes, execute

    docker create --name data quay.io/aptible/rabbitmq
    docker run --volumes-from data -h aptible -e USERNAME=aptible -e PASSPHRASE=pass -e DATABASE=db quay.io/aptible/rabbitmq --initialize
    docker run --volumes-from data -h aptible -P quay.io/aptible/rabbitmq

The first command sets up a data container named `data` which will hold the configuration and data for the database. 
The second command creates a RabbitMQ instance with a hostname, username, passphrase and database name of your choice. 
The third command starts the database server.

### SSL

The RabbitMQ server is configured to enforce SSL for any TCP connection. It uses a self-signed certificate generated at 
startup time.

`verify_peer` is set, so if a client certificate and private key is supplied RabbitMQ will verify the client. For most 
 AMQP clients, you can only forego providing a client certificate and private key by explicitly setting `verify_peer` to
 `false`, as in the example below using [Bunny](http://rubybunny.info/):
 
 ```
 Bunny.new("amqps://bunny_gem:bunny_password@127.0.0.1/bunny_testbed", verify_peer: false)
 ```
 
 Setting `fail_if_no_peer_cert` in `rabbitmq.config` to true forces all clients to connect using a client
 certificate + key.

## Available Versions (Tags)

* `latest`: Currently RabbitMQ 3.7
* `3.7`: RabbitMQ 3.7.14
* `3.5`: RabbitMQ 3.5.7

## Tests

Tests are run as part of the `Dockerfile` build.

## Continuous Integration

Images are built and pushed to Quay.io on every merge to master.

## Copyright and License

MIT License, see [LICENSE](LICENSE.md) for details.

Copyright (c) 2015 [Aptible](https://www.aptible.com) and contributors.
