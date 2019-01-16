

### Create Deployment of Demo Application "Hello-Node"
```
kubectl create deployment hello-node --image=gcr.io/hello-minikube-zero-install/hello-node
```

### Deploy Mandatory Addons
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
```

### Create the Ingress Controller YAML
Below is an example of what it would look like.  Salt and pepper to taste
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hello-node
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /hello-node
        backend:
          serviceName: hello-node
          servicePort: 80
```

### Deploy Ingress YAML
```
kubectl apply -f ingress.yaml
```

### Deploy nGinX Ingress Controller
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml
```

List the information for Ingress Controllers
```
kubectl get ing
```
List the Services
```
kubectl -n ingress-nginx get svc
```
