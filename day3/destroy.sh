#! /bin/bash


aws ecr delete-repository \
    --repository-name demo-repo \
    --force