# docker-yumrepo

This is a very simple Dockerfile to build and run a docker container which will
serve your RPMs in a Yum repository.  It is based on Centos 7 and uses the 
Apache webserver.

## Getting Started

To run this docker container, you will require your RPMs that you want to be
installable via Yum, and docker.

### Prerequisites

* docker
* createrepo_c

### Installation Instructions

1. To install the prerequisites run:

  ```
  sudo yum install -y docker createrepo_c
  ```

2. Start the docker subsystem:

  ```
  sudo systemctl start docker
  ```

3. Add your user to the dockerroot group run:

  ```
  sudo usermod -aG dockerroot USER
  ```

## Building docker image

1. Create the "src" directory and place your RPMs in it:

  ```
  make src
  ```

2. Build the image with the command:

  ```
  make build
  ```

This will output something like the following:

```
[user@centos docker-yumrepo]$ make build
mkdir workdir
cp -r src/* workdir
createrepo_c workdir
Directory walk started
Directory walk done - 6 packages
Temporary output repo path: workdir/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished
docker build -t docker-yumrepo .
Sending build context to Docker daemon 87.66 MB
Step 1 : FROM centos
 ---> 67591570dd29
Step 2 : LABEL description "A Yum repo in a docker container." maintainer "Matt Bacchi <mbacchi@gmail.com>" version "0.1.0"
 ---> Running in a931f80e1c37
 ---> 081c938d7212
Removing intermediate container a931f80e1c37
Step 3 : WORKDIR workdir
 ---> Running in a7550f678753
 ---> 22dc10cca7f6
Removing intermediate container a7550f678753
Step 4 : RUN yum install -y httpd
 ---> Running in 7d97093290dc
 ...
Installed:
  httpd.x86_64 0:2.4.6-45.el7.centos                                            

Dependency Installed:
  apr.x86_64 0:1.4.8-3.el7                                                      
  apr-util.x86_64 0:1.5.2-6.el7                                                 
  centos-logos.noarch 0:70.0.6-3.el7.centos                                     
  httpd-tools.x86_64 0:2.4.6-45.el7.centos                                      
  mailcap.noarch 0:2.1.41-2.el7                                                 

Complete!
 ---> db971bd67f39
Removing intermediate container 7d97093290dc
Step 5 : COPY workdir/* /var/www/html/docker-yumrepo/
 ---> 6380b1e4059f
Removing intermediate container 5b9644e68124
Step 6 : COPY docker-yumrepo.conf /etc/httpd/conf.d/
 ---> 656727464c62
Removing intermediate container a14c1ed5fe3a
Step 7 : CMD -D FOREGROUND
 ---> Running in e493f495fb37
 ---> 1b1c18d8703e
Removing intermediate container e493f495fb37
Step 8 : ENTRYPOINT /usr/sbin/httpd
 ---> Running in 281fe62586fc
 ---> 18ade366bec4
Removing intermediate container 281fe62586fc
Successfully built 18ade366bec4
```

## Running docker image

1. You can now look at your docker images:

  ```
  [user@centos docker-yumrepo]$ docker images
  REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
  docker-yumrepo            latest              18ade366bec4        5 seconds ago       338.4 MB
  docker.io/centos          latest              67591570dd29        5 weeks ago         191.8 MB
  ```

2. To run the container use the command:

  ```
  make run
  ```
This will show something like:

  ```
  [user@centos docker-yumrepo]$ make run
  docker run -d -p 80:80 docker-yumrepo
  056e4ecb22a5e56ecb430b4c16ce1c07e50e97d75944130e3c9d1099aa323a05
  ```

3. You can verify whether the yum repository is functioning using  the curl command such as:

```
[user@centos docker-yumrepo]$ curl http://localhost/docker-yumrepo/repomd.xml
<?xml version="1.0" encoding="UTF-8"?>
<repomd xmlns="http://linux.duke.edu/metadata/repo" xmlns:rpm="http://linux.duke.edu/metadata/rpm">
  <revision>1485293260</revision>
  <data type="primary">
    <checksum type="sha256">54f8d9392c540b33f63d035971d7914cf4fbfda74f8d30d9b741e7f0945dd239</checksum>
    <open-checksum type="sha256">2c8de840440531ca630e236ed486b659251f6b7bf9ab05cc916c268278335ea8</open-checksum>
    <location href="repodata/54f8d9392c540b33f63d035971d7914cf4fbfda74f8d30d9b741e7f0945dd239-primary.xml.gz"/>
    <timestamp>1485293260</timestamp>
    <size>3120</size>
    <open-size>21763</open-size>
...
```

## Authors

Matt Bacchi <mbacchi@gmail.com>

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
