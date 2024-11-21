### Clone the getting started repo

```
git clone https://github.com/piyushsachdeva/todoapp-docker
```
### Create Docker file

```
cd todoapp-docker
touch Dockerfile
```
### Update the docker file

```
FROM node:18-alpine AS installer

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .

RUN npm run build 

FROM ngnix:latest AS deployer

COPY --from==installer /app/build /usr/share/ngnix/html


```

### Create docker image

```
docker build -t "day3-todo" .

docker images

```


### Running the docker image

```
docker run -dp 3000:80 --name day3-app day3-todo:latest
```

docker exec -it

docker inspect day3-app