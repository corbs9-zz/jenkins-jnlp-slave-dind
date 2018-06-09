# jenkins-jnlp-slave-dind
Jenkins JNLP slave which utilises docker in docker

The idea of this slave is to be used in an environment where any risks which stem from using 
docker within a docker container do not pose a problem.

There is a great post on why you shouldn't use Docker in Docker [here](http://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)

## Overview

- Jenkins Slave version: 3.19
- Java version: 8.151.12-r0

## Why a docker in docker jenkins slave?

If you have your Jenkins installation within an orchestrated environment i.e. Kubernetes, DC/OS etc, 
you may find that there are some issues especially when you start using docker in your tests.

Let's say you have some integration tests which spin up a database and in your tests, you can access this
by pointing to a local address with exposing some container ports. What if your CI/CD pipeline is 
in Kubernetes and everything is a docker container? Your Jenkins master is a container and your 
slaves are containers, too. 

In order to run docker within your slaves, you could mount /var/run/docker.sock from your host machine into the docker container.
However, doing so causes some problems with regards to accessing these containers. In order to 
access the same database, you can no longer talk to a local address, but you have to talk to the host 
address. Sure, you could pass in an environment variable which gives you the IP of the host machine, 
but your tests will have to account for the fact that you either need a local address or this host manchine.

This jenkins slave tries to remove all of these problems by allowing the slave to create docker containers
just like the host is able to. This means that your tests remain the same, regardless if you're running them
from your local machine, or whether you're running them from a Jenkins slave as part of your CI/CD pipeline.
