# Jump host
Для начала создадим в облаке jump host на Ubuntu, на котором развернем docker.

Виртуалку подготовим с помощью Terraform.

Затем создадим кастомный image с помощью докер файла:

```bash
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
```
```bash
docker build -t otusnginx .
```

Затем запускаем контейнер и проверяем работу:
```bash
docker run -d -p 80:80 otusnginx
docker ps
```
![img.png](files/vm-ngnix.png)

![img.png](files/browser-vm-nginx.png)

Затем создаем новый Container Registry и загружаем в него наш собранный image:

![img.png](files/registry.png)
![img.png](files/registry2.png)

Теперь переходим к Serverless Containers.
Развернем сам контейнер и в запустим несколько ревизий:

![img.png](files/Serverless-cont.png)

Ну и конечно проверим работоспособность:

![img.png](files/Serverless-browser.png)

Теперь поднимем решение Container Solution.

![img.png](files/Container-Solution.png)

Ну и традиционная его проверка:

![img.png](files/Container-Solution-curl.png)

Затем поднимаем k8s:

![img.png](files/k8s-create.png)

Создаем внутри группу узлов:

![img.png](files/k8s-group-hosts.png)

Создаем деплоймент nginx:
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```
Проверяем, что под работает:

![img.png](files/nginx-pod.png)

Теперь создаем сервис load-balancer:

```bash
apiVersion: v1
kind: Service
metadata:
  name: hello
spec:
  type: LoadBalancer
  ports:
  - port: 80
    name: plaintext
    targetPort: 80
  selector:
    app: nginx
```

Проверяем что работает:

![img.png](files/load-balancer-service.png)

![img.png](files/curl-load-balancer.png)