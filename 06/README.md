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
