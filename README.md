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
4. Create a yum repository config file such as:

  ```
  [user@centos docker-yumrepo]$ cat /etc/yum.repos.d/docker-yumrepo.repo
  [docker-yumrepo]
  name=docker-yumrepo
  baseurl=http://localhost/docker-yumrepo
  enabled=1
  gpgcheck=0
  ```

5. Yum repolist will now show the repository:

  ```
  [user@centos docker-yumrepo]$ yum repolist
  Loaded plugins: fastestmirror
  Loading mirror speeds from cached hostfile
   * base: mirror.net.cen.ct.gov
   * epel: dl.fedoraproject.org
   * extras: mirror.lug.udel.edu
   * updates: mirrors.advancedhosters.com
  repo id                                      repo name                                                            status
  base/7/x86_64                                CentOS-7 - Base                                                       9,363
  docker-yumrepo                               docker-yumrepo                                                            6
  ```

6. You can get info about the packages that you added to the repository now:
  ```
  [user@centos docker-yumrepo]$ yum info qemu-kvm-ev
  Loaded plugins: fastestmirror
  Loading mirror speeds from cached hostfile
   * base: mirror.net.cen.ct.gov
   * epel: dl.fedoraproject.org
   * extras: mirrors.lga7.us.voxel.net
   * updates: mirrors.advancedhosters.com
  Available Packages
  Name        : qemu-kvm-ev
  Arch        : x86_64
  Epoch       : 10
  Version     : 2.6.0
  Release     : 27.1.el7
  Size        : 2.4 M
  Repo        : docker-yumrepo
  ```
7. And install the packages:

  ```
  [user@centos docker-yumrepo]$ sudo yum install qemu-kvm-ev
  Loaded plugins: fastestmirror
  base                                                                                             | 3.6 kB  00:00:00     
  centos-sclo-rh                                                                                   | 2.9 kB  00:00:00     
  centos-sclo-sclo                                                                                 | 2.9 kB  00:00:00     
  docker-yumrepo                                                                                   | 3.0 kB  00:00:00     
  epel/x86_64/metalink                                                                             |  14 kB  00:00:00     
  epel                                                                                             | 4.3 kB  00:00:00     
  extras                                                                                           | 3.4 kB  00:00:00     
  shells_fish_release_2                                                                            | 1.2 kB  00:00:00     
  updates                                                                                          | 3.4 kB  00:00:00     
  vmware-tools                                                                                     |  951 B  00:00:00     
  (1/3): docker-yumrepo/primary_db                                                                 | 9.1 kB  00:00:00     
  (2/3): epel/x86_64/updateinfo                                                                    | 721 kB  00:00:00     
  (3/3): epel/x86_64/primary_db                                                                    | 4.5 MB  00:00:02     
  Loading mirror speeds from cached hostfile
   * base: centos.den.host-engine.com
   * epel: mirror.mrjester.net
   * extras: mirror.cogentco.com
   * updates: mirrors.advancedhosters.com
  Resolving Dependencies
  --> Running transaction check
  ---> Package qemu-kvm.x86_64 10:1.5.3-105.el7_2.7 will be obsoleted
  ---> Package qemu-kvm-ev.x86_64 10:2.6.0-27.1.el7 will be obsoleting
  --> Processing Dependency: qemu-img-ev = 10:2.6.0-27.1.el7 for package: 10:qemu-kvm-ev-2.6.0-27.1.el7.x86_64
  --> Processing Dependency: qemu-kvm-common-ev = 10:2.6.0-27.1.el7 for package: 10:qemu-kvm-ev-2.6.0-27.1.el7.x86_64
  --> Processing Dependency: ipxe-roms-qemu >= 20160127-4 for package: 10:qemu-kvm-ev-2.6.0-27.1.el7.x86_64
  --> Processing Dependency: libusbx >= 1.0.19 for package: 10:qemu-kvm-ev-2.6.0-27.1.el7.x86_64
  --> Processing Dependency: seavgabios-bin >= 1.9.1-4 for package: 10:qemu-kvm-ev-2.6.0-27.1.el7.x86_64
  --> Processing Dependency: usbredir >= 0.7.1 for package: 10:qemu-kvm-ev-2.6.0-27.1.el7.x86_64
  --> Processing Dependency: libcacard.so.0()(64bit) for package: 10:qemu-kvm-ev-2.6.0-27.1.el7.x86_64
  --> Running transaction check
  ---> Package ipxe-roms-qemu.noarch 0:20130517-8.gitc4bce43.el7_2.1 will be updated
  ---> Package ipxe-roms-qemu.noarch 0:20160127-5.git6366fa7a.el7 will be an update
  ---> Package libcacard.x86_64 40:2.5.2-2.el7 will be installed
  ---> Package libusbx.x86_64 0:1.0.15-4.el7 will be updated
  ---> Package libusbx.x86_64 0:1.0.20-1.el7 will be an update
  ---> Package qemu-img.x86_64 10:1.5.3-105.el7_2.7 will be obsoleted
  ---> Package qemu-img-ev.x86_64 10:2.6.0-27.1.el7 will be obsoleting
  ---> Package qemu-kvm-common.x86_64 10:1.5.3-105.el7_2.7 will be obsoleted
  ---> Package qemu-kvm-common-ev.x86_64 10:2.6.0-27.1.el7 will be obsoleting
  ---> Package seavgabios-bin.noarch 0:1.7.5-11.el7 will be updated
  ---> Package seavgabios-bin.noarch 0:1.9.1-5.el7_3.1 will be an update
  ---> Package usbredir.x86_64 0:0.6-7.el7 will be updated
  ---> Package usbredir.x86_64 0:0.7.1-1.el7 will be an update
  --> Finished Dependency Resolution

  Dependencies Resolved

  ========================================================================================================================
   Package                       Arch              Version                                Repository                 Size
  ========================================================================================================================
  Installing:
   qemu-img-ev                   x86_64            10:2.6.0-27.1.el7                      docker-yumrepo            1.0 M
       replacing  qemu-img.x86_64 10:1.5.3-105.el7_2.7
   qemu-kvm-common-ev            x86_64            10:2.6.0-27.1.el7                      docker-yumrepo            509 k
       replacing  qemu-kvm-common.x86_64 10:1.5.3-105.el7_2.7
   qemu-kvm-ev                   x86_64            10:2.6.0-27.1.el7                      docker-yumrepo            2.4 M
       replacing  qemu-kvm.x86_64 10:1.5.3-105.el7_2.7
  Installing for dependencies:
   libcacard                     x86_64            40:2.5.2-2.el7                         base                       23 k
  Updating for dependencies:
   ipxe-roms-qemu                noarch            20160127-5.git6366fa7a.el7             base                      692 k
   libusbx                       x86_64            1.0.20-1.el7                           base                       61 k
   seavgabios-bin                noarch            1.9.1-5.el7_3.1                        updates                    35 k
   usbredir                      x86_64            0.7.1-1.el7                            base                       46 k

  Transaction Summary
  ========================================================================================================================
  Install  3 Packages (+1 Dependent package)
  Upgrade             ( 4 Dependent packages)

  ```

## Authors

Matt Bacchi <mbacchi@gmail.com>

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
