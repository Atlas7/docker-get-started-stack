
# Development Steps

### Step 1 - build and deploy docker image

Deploy a Docker container as per [this tutorial](https://docs.docker.com/get-started/part2/).

Summary:

- Create a app directory locally on the Mac / laptop
- Create `Dockerfile`: define container environment
- Create `requirement.txt`: containing python package dependencies
- Create `app.py`: a simple flask hello world app
- Build the docker image (from `Dockerfile`). Run `docker build -t friendlyhello .`
- Spin up a new container `friendlyhello` based on the `Dockerfile` image, with localhost port 4000 pointing to 
  container port 80. Run `docker run -p 4000:80 friendlyhello` to do this.
- Go to [http://localhost:4000/](http://localhost:4000/) to access Flask web application.
- Git commit!

### Step 2

Create a service (with load-balancing, distributed across task-containers in a swarm).
See this [Tutorial](https://docs.docker.com/get-started/part3/).

High level picture:

```.txt
- Stacks (aka apps)
    - services
        - containers (aka tasks)
```

Example:

```
- getstartedlab (app)
    - web (service)
        - container 1
        - container 2
        - container 3
```

- Create `docker-compose.yml`: defines how Docker containers should behave in production
- Run `docker swarm init` to create a swarm. This will:
    - Initialize a swarm node. (i.e. the swarm manager)
    - list out instructions to add a worker and/or manager to this swarm.
- Run `docker stack deploy -c docker-compose.yml getstartedlab` to run the swarm. This will:
    - Create network `getstartedlab_webnet`
    - Create service `getstartedlab_web`
- Do a `docker stack ls` to list out the apps we have, and the services per app.
- Our single service stack is running 5 container instances of our deployed image on one host. Let’s investigate.
- Do a `docker service ls` to get the service ID for the one service in our application:
    - we observe port `*:80->80/tcp`. i.e. port 80 of all container instances share port 80 of web service
    - we observe the service has 5 replicas (containers).
- Do a `docker service ps <service-id>` to list out the 5 spawned task IDs (this is not container IDs)
- Do a `docker inspect --format='{{.Status.ContainerStatus.ContainerID}}' <task>` to obtain container_id for the task.
- Open up [http://localhost/](http://localhost/) in multiple browsers. Note the app is hosted across the swarm of hosts.
- Do a `docker stack rm getstartedlab` to take down the app. (the swarm is still running). This will:
    - Remove service getstartedlab_web
    - Remove network getstartedlab_webnet
- Do a `docker swarm leave --force` to take down the swarm. This will remove the swarm node.
