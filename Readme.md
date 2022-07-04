### Vault, K8s, Terraform Playground

A repo with some artifacts to setup a playground to practice and understand how these 3 things can work together. 


![Diagram](images/diagram.png?raw=true "Diagram")


I took as inspiration the below great repo from [@marcel-dempers](https://github.com/marcel-dempers)

https://github.com/marcel-dempers/docker-development-youtube-series/tree/master/hashicorp/vault-2022





### Prepare Kubernetes

First, lets create a new cluster identified with the name `vault` and we will specify the kubernetes version  `1.21.1`

```
kind create cluster --name vault --image kindest/node:v1.21.1 --config kind.yaml
```

Prepare kubectl context:
```
kubectl cluster-info --context kind-vault
```



Let's see if the nodes are ready


```
kubectl get nodes
```



### Terraform

Go to the terraform folder and initialize the repo. You can look at the `provider.tf` file to see the settings that it will use to authenticate to the cluster

```
terraform init
```

Let's partially apply only the resources that are required for the next steps:

```
terraform apply -target=kubernetes_secret.tls-server -target=kubernetes_secret.tls-transit-server -target=kubernetes_secret.tls-ca -target=kubernetes_namespace.vault
```

Save the output into a file and set your VAULT_CACERT variable pointing to that file, in this case I written the content of the CA file into : `/home/xxxx/vaultca` so, lets set the variable

```
export VAULT_CACERT=/home/xxxx/vaultca
```

### If you don't have the vault transit server created already we can create one for testing
With all those values created, lets move to kubernetes for a bit

```
kubectl -n vault apply -f ./manifests/vault-transit.yaml
```

wait for the pod to be ready:

```
kubectl -n vault get pods
```

and connect to it to initialize it and unseal it:

```
kubectl -n vault exec -it vault-transit-0 -- sh

```
Then:

```
vault operator init

# Next, run it 3 times with different keys 
vault operator unseal
```

Finally set these 2 extra variables
```
export VAULT_ADDR='https://127.0.0.1:30000'
export VAULT_TOKEN='<Use the root token from your previous step>' 
```


### Back to terraform

Go to the terraform folder and run the apply globally

```
terraform apply
```

This will create some configuration in vault required for the auto-unseal process to work




### Helm
```
helm repo add hashicorp https://helm.releases.hashicorp.com

helm search repo hashicorp/vault --versions
```

Now, lets create the main YAML for the deployment using the hashicorp

```
helm template vault hashicorp/vault \
  --namespace vault \
  --version 0.19.0 \
  -f vault-values.yaml \
  > ./manifests/vault5.yaml
```

This template will have some modifications because we have some custom needs/fixes that are required:

*Fix:*
1. Under `vault-server-test` pod there are no values to mount the CA, so all the operations agains vault will fail due to invalid certificate errors, so we just added the below:
An extra volume under `volumeMounts`:
```
volumeMounts:
        - name: userconfig-tls-ca
          readOnly: true
          mountPath: /vault/userconfig/tls-ca
```
And the corresponding mount
```
volumes:
    - name: userconfig-tls-ca
      secret:
        secretName: tls-ca
        defaultMode: 420
```

*Update:*
1. For the main StatefulSet: `vault` we have to specify an extra environment variable to pull the token and set it under VAULT_TOKEN, this will enable each vault instance to authenticate agains the transit instance to perform the unseal operations
```
env:
            - name: VAULT_TOKEN
              valueFrom:
                secretKeyRef:
                  name: transit
                  key: token
                  optional: false
```


### Back to Kubernetes


Lets check if the namespace and secrets were actually created:

```
kubectl -n vault get secrets
```

Go to the parent dir ( `cd ..`) and let's apply the deployment:

```
kubectl -n vault apply -f ./manifests/vault4.yaml
```



### Initialize

Get into one of the pods:
```
kubectl -n vault exec -it vault-0 -- sh
```

and run the init command

```
vault operator init
```

you should get a list of keys and certs