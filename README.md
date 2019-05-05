# kubernete.sh

Deploy "throw-away" Kubernetes Cluster(s) using a small Bash CLI.

[Home](https://kubernete.sh) |
[About](https://kubernete.sh/about/) |
[Installation](https://kubernete.sh/install/) |
[Usage](https://kubernete.sh/usage/)

![kubernete.sh Example](https://kubernete.sh/assets/kubernete.sh.svg "kubernete.sh")


## tl;dr

````
$ kubernete.sh 
kubernete.sh
https://github.com/brotandgames/kubernete.sh

Usage: kubernete.sh [command]

Commands:
  deploy       Deploy a Kubernetes Cluster
  token        Get Kubernetes Dashboard Token <sensitive>
  proxy        Creates a proxy between localhost and the Kubernetes API Server
  print_nodes  Print node configuration in HCL (for Debugging)
  version      Print version
  *            Help

````

````
$ kubernete.sh deploy
== kubernete.sh 2019-05-03T18:46:14Z ERROR: No nodes argument found.
Command: 
  kubernete.sh deploy

Usage: 
  kubernete.sh deploy user@node1[,user@node2,user@nodeN] [ssh_private_key_path]

Examples:
  kubernete.sh deploy root@n1.kubernete.sh
  kubernete.sh deploy root@n1.kubernete.sh,root@n2.kubernete.sh ~/.ssh/id_rsa
````

## Maintainer

https://github.com/brotandgames
