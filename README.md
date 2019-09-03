# K-ONE-M-CORD-Monitoring

Note that
* containers of M-CORD Lite are implemented by [K-ONE M-CORD Lite](https://github.com/K-OpenNet/K-ONE-M-CORD-Lite)
* influxDB container for time-series database and Grafana container for dashboard are used
* monitor contianer and shell scripts are implemented by Jibum Hong @ POSTECH


## Specification
* OS: Ubuntu 16.04 (Fin to test) and 18.04 (under test)
* CPU: Intel CPU (More than Haswell CPU microarchitecture)
* Memory: more than 16GB

## Preliminaries

### 1. Need to install Docker engine
```
node$ ./set_env.sh
```

**NOTE: To make sure that the user is in the `docker` group, please log off and then log in again. You can check which groups belong to the user with the below command.**

```
node$ groups
```
If you can see the group `docker`, everything looks good!

**NOTE: If you install [K-ONE M-CORD Lite](https://github.com/K-OpenNet/K-ONE-M-CORD-Lite), you don't need to this process.


## Release information
* Release 1 - Monitoring system resource metrics of each containers in EPC
* Release 2 - Monitoring network statistics of internal link in EPC
