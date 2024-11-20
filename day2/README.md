### Create Docker file

```
touch Dockerfile
```

### Clone the getting started repo

```
git clone https://github.com/docker/getting-started-app.git
```

### Update the docker file

```
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]
EXPOSE 3000

```

### Create docker image

```
docker build -t "day2-todo" .

docker images

```
### Pushing the docker image to ECR repo
Referenc for pushing image to AWS ECR private repository

https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html

```
aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 272577611462.dkr.ecr.us-east-1.amazonaws.com


docker tag 341e7e616a03 272577611462.dkr.ecr.us-east-1.amazonaws.com/demo-repo:todo-app


docker push 272577611462.dkr.ecr.us-east-1.amazonaws.com/demo-repo:todo-app

```

### Running the docker image

```
docker run -dp 3000:3000 --name test day2-todo:latest
```

docker exec -it
