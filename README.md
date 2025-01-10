# Actions Runner

## Quick Guide

1. Build the Docker image
```bash
docker build -t actions-runner .
```

2. Create a `docker-compose.yml` file and set the environment variables
```bash
cp docker-compose.yml.example docker-compose.yml
vim docker-compose.yml
```

3. Run the Docker container
```bash
docker-compose up -d
```
