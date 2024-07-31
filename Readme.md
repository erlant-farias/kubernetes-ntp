# Build da imagem do servidor de ntp (com os servidores br)

- Pode utilizar uma imagem linux (no caso utilizei ubuntu 22.04) qualquer, instalar o ntp-server e após isso editar o ntp.conf para utilizar ela. Junto a isto criei um script bash para que o container não seja finalizado.
    comando no arquivo: imagem-docker
- docker commit hash-do-container erlantfarias/ntp-server:1.0.0
- docker push erlantfarias/ntp-server:1.0.0
- docker run -d -p 123:123 erlantfarias/ntp-server:1.0.0 ./ntpq_monitor.sh



# Criação do Namespace:

```bash
kubectl create ns kube-ntp
```

# Criação do Deployment:
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ntp-server-deployment
  namespace: kube-ntp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ntp-server
  template:
    metadata:
      labels:
        app: ntp-server
    spec:
      containers:
      - name: ntp-server
        image: erlantfarias/ntp-server:1.0.0
        args: ["./ntpq_monitor.sh"]
        ports:
        - containerPort: 123
```

```bash
kubectl apply -f ntp-server.yml 
```

# Criação do Service
```bash
apiVersion: v1
kind: Service
metadata:
  name: ntp-server-service
  namespace: kube-ntp
spec:
  selector:
    app: ntp-server
  ports:
  - protocol: UDP
    port: 123
    targetPort: 123     
  type: LoadBalancer
```
```bash
kubectl apply -f ntp-svc.yml 
```

# Criação do Cliente de teste

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ntp-client
  namespace: kube-ntp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ntp-client
  template:
    metadata:
      labels:
        app: ntp-client
    spec:
      containers:
      - name: ntp-client
        image: ubuntu
        command: ["/bin/bash"]
        args: ["-c", "apt-get update && apt-get install -y ntpdate && while true; do ntpdate -q ntp-server-service.kube-ntp.svc.cluster.local; sleep 60; done"]
        resources:
          limits:
            memory: "256Mi"
            cpu: "250m"
          requests:
            memory: "128Mi"
            cpu: "100m"
```

```bash
kubectl apply -f client-ntp.yml
```


## Comandos para teste:
```bash
kubectl exec -n kube-ntp -it ntp-server-deployment-XXXXXXXXXX -- ntpq -p
```
```bash
kubectl logs -n kube-ntp ntp-client-xxxxxxxxxxxx -f
```

## Na VM:
```bash
apt install ntpdate
```

```bash
ntpdate -q ntp-server-service.kube-ntp.svc.cluster.local
```