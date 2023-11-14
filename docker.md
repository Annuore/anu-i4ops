Here are some common kubectl commands to deploy, monitor, and stop the deployment described in the YAML manifest:

## 1. i4deploy.yaml

```
apiVersion: apps/v1  
kind: Deployment
metadata:
  name: i4deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: i4instance
        image: i4docker:latest
        ports:
        - containerPort: 80
```

## 2. Deploy:

```
kubectl apply -f i4deploy.yaml 
```

## 3. Expose the container as a service to make it accessible:

``` 
kubectl expose deployment my-container --type=LoadBalancer --port=8080
```

## 4. Check that the service is available and the container is running correctly:

```
kubectl get services 
curl <service-ip>:8080
```
This will create the deployment and pods on the Kubernetes cluster.

## 5. Monitor:

```
kubectl get deployments 
kubectl get pods
kubectl logs -f [podname]
kubectl describe deployment i4deploy
```

These commands let you view the status of the deployment, pods, container logs, and full details.

## 6. Stop: 

```
kubectl scale deployment i4deploy --replicas=0
kubectl delete deployment i4deploy
``` 

Scaling the replicas to 0 will terminate the running pods. Deleting the deployment completely will remove the deployment object and all pods.

## 7. Other useful commands:

```
kubectl port-forward [podname] 8080:80 # Forward local port to pod
kubectl exec [podname] -- commands    # Execute command in pod
```
