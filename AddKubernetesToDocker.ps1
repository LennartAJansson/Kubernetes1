# K3d is a tool to generate a K3s environment in Docker.
//https://blog.palark.com/small-local-kubernetes-comparison/
k3d cluster create k3s --volume C:\Data\K8s:/tmp/shared@server:0 --kubeconfig-update-default --kubeconfig-switch-context --registry-create registry:5000 -p 8080:80@loadbalancer -p 8443:443@loadbalancer -p 3333:3307@loadbalancer -p 4222:4222@loadbalancer -p 8222:8222@loadbalancer -p 6379:6379@loadbalancer  --api-port=16443 --wait --timeout=120s



#k3d node edit k3d-k3s-serverlb --port-add 3333:3306 --verbose
# Ports exposed:
# 8081:80 Use [hostheader]:8081 for web traffic through the loadbalancer (will use ingress/hostheader to redirect)
# 8443:443 Use [hostheader]:8443 for web traffic through the loadbalancer (will use ingress/hostheader to redirect)
# 3333:3333 Use mysql.local:3333 to access mysql inside the cluster
# 4222:4222 Use nats.local:4222 to access nats streams inside the cluster
# 8222:8222 Use nats.local:8222 to access nats web pages inside the cluster
# 6379:6379 Use redis.local:6379 to access redis inside the cluster

# Add all the basic services: certmanager, grafana, mysql, nats, prometheus, redis and sealedsecrets
kubectl apply -k ./deploy/basesvc

# Check what host port your registry publish and save it in environment:
# From Powershell you can access it as $env:REGISTRYHOST
# From CMD-files you can access it as %REGISTRYHOST%
# Following the k3d command above the value should be: "registry:5000"

$port = (docker port registry).Split(':')[1]
$registryhost = "registry:$($port)"
SETX /M REGISTRYHOST $registryhost
$env:registryhost=$registryhost

"Add following to C:\Windows\System32\drivers\etc\hosts: "
"127.0.0.1 registry"
"127.0.0.1 mysql"
"127.0.0.1 mysql.local"
"127.0.0.1 nats"
"127.0.0.1 nats.local"
"127.0.0.1 prometheus"
"127.0.0.1 prometheus.local"
"127.0.0.1 grafana"
"127.0.0.1 grafana.local"
"127.0.0.1 redis"
"127.0.0.1 redis.local"
""

# Verify that you have connection to your registry
"Trying to connect to registry:"
curl.exe http://$registryhost/v2/_catalog

"To remove everything regarding cluster, loadbalancer and registry:"
"k3d cluster delete k3slocal"
