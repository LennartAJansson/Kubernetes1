# K3d is a tool to generate a K3s environment in Docker.
# https://blog.palark.com/small-local-kubernetes-comparison/

$hostname = [System.Net.Dns]::GetHostName()

if($hostname -ne "ubk3s")
{
	$hostname=""
}
else
{
	$hostname=".${hostname}"

}
	k3d cluster create --config ./config${hostname}.yaml --api-port=6443

# Ports exposed:
# 8080:80 Use [hostheader]:8080 for web traffic through the loadbalancer (will use ingress/hostheader to redirect)
# 8443:443 Use [hostheader]:8443 for web traffic through the loadbalancer (will use ingress/hostheader to redirect)
# 3333:3307 Use mysql.local:3333 to access mysql inside the cluster (3307 instead of def 3306 since the lb is adding another mapping that conflicts)
# 4222:4222 Use nats.local:4222 to access nats streams inside the cluster
# 8222:8222 Use nats.local:8222 to access nats web pages inside the cluster
# 6379:6379 Use redis.local:6379 to access redis inside the cluster

# Add all the basic services: certmanager, grafana, mysql, nats, prometheus, redis and sealedsecrets
kubectl apply -k ./deploy/basesvc

# Check what host port your registry publish and save it in environment:
# From Powershell you can access it as $env:REGISTRYHOST
# From CMD-files you can access it as %REGISTRYHOST%
# Following the k3d command above the value should be: "registry:5000"

$port = (docker port registry${hostname}).Split(':')[1]
$registryhost = "registry${hostname}:$($port)"
$env:registryhost=$registryhost

"Add following to C:\Windows\System32\drivers\etc\hosts (In linux /etc/hosts):"
"127.0.0.1 registry${hostname}"
"127.0.0.1 mysql${hostname}"
"127.0.0.1 mysql${hostname}.local"
"127.0.0.1 nats${hostname}"
"127.0.0.1 nats${hostname}.local"
"127.0.0.1 prometheus${hostname}"
"127.0.0.1 prometheus${hostname}.local"
"127.0.0.1 grafana${hostname}"
"127.0.0.1 grafana${hostname}.local"
"127.0.0.1 redis${hostname}"
"127.0.0.1 redis${hostname}.local"
""

# Verify that you have connection to your registry
"Trying to connect to registry:"
if($hostname -eq "")
{
	SETX /M REGISTRYHOST $registryhost
	curl.exe http://$registryhost/v2/_catalog
}
else
{
	$env:REGISTRYHOST=$registryhost
	curl http://$registryhost/v2/_catalog
}

"To remove everything regarding cluster, loadbalancer and registry:"
"k3d cluster delete k3s"
