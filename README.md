
# Development Steps

### Part 1 - Install Docker and understand concept

Refer to [Docker Orientation and setup guide](https://docs.docker.com/get-started/)

### Part 2 - build and deploy docker image

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

### Part 3 - single-machine services

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

### Part 4 - Create a multi-machine swarm

- Create virtual machines:
    - run `docker-machine create --driver virtualbox myvm1`
    - run `docker-machine create --driver virtualbox myvm2`
- List virtual machines (and obtain IP address of each node):
    - run `docker-machine ls`
- Initialize the swarm
    - Run `docker-machine ssh myvm1 "docker swarm init --advertise-addr <myvm1 ip>"`
    - `myvm1` is now a swarm manager
    - make a node of the token returned. This is required to enable other nodes to join this swarm.
- Add node `myvm2` to the swarm (manager `myvm1`)
    - `docker-machine ssh myvm2 "docker swarm join --token <token> <myvm1 ip>:2377`
- list out all swarm nodes on the swarm manager:
    - `docker-machine ssh myvm1 "docker node ls"` (record the node IDs here)
- (FYI only) To temporary make `myvm2` leave the swarm:
    - `docker-machine ssh myvm2 "docker swarm leave"`
- (FYI only) To remove `myvm2` node from swarm:
    - `docker-machine ssh myvm1 "docker node rm <myvm2 node id>"`
- **IMPORTANT**: copy the `docker-compose.yml` file from local machine to the swarm leader `myvm1`.
    (do this everytime we redeploy stack)
    Run `docker-machine scp docker-compose.yml myvm1:~`  (make sure we are at the root of this repository).
    **UNLESS** we have done a `eval $(docker-machine env myvm1)` to treat current terminal `myvm1`.
- Deploy the application (stack) to the swarm (via swarm manager`myvm1`):
    `docker-machine ssh myvm1 "docker stack deploy -c docker-compose.yml getstartedlab"`. This will:
  - Create network getstartedlab_webnet
  - Create service getstartedlab_web
- List our application (stack) within the swarm (via the swarm manager `myvm1`):
    `docker-machine ssh myvm1 "docker stack ps getstartedlab"`
- (FYI only) to view `docker-machine` info (such as IP address, etc), do something like this:
    - `docker-machine env myvm1`
    - `docker-machine env myvm2`
- Access app from IP address of either `myvm1` or `myvm2` (cool!). e.g.
    - via `myvm1` IP
    - via `myvm2` IP  
- (FYI only) To tear down stack: `docker-machine ssh myvm1 "docker stack rm getstartedlab"`
- (FYI only) To restart Docker machines: `docker-machine ssh myvm1 "docker-machine start <machine-name>"`
- (FYI only) At some point later, you can remove this swarm if you want to with
    `docker-machine ssh myvm2 "docker swarm leave"` on the worker, and
    `docker-machine ssh myvm1 "docker swarm leave --force"` on the manager,
    but you’ll need this swarm for next part, so please keep it around for now.
- (FYI only) [This is a snapshot](https://twitter.com/jAtlas7/status/923948835088621571)
    of what the output looks like
 
 ### Part 5 - Stacks
 
 Refer to [Docker Get Started Tutorial Part 5](https://docs.docker.com/get-started/part5/)
 
 - top tip (do this now): to instead of having to type out `docker-machine ssh myvm1 "<some docker commands>""`,
    we can do a
    `eval $(docker-machine env myvm1)`. This will export all the environmental variable of `myvm1` to `localhost`,
    for the current terminal. (Good news: this only affect the current terminal. To undo this just start a new terminal)
 - run (in same terminal) `docker stack deploy -c docker-compose.yml getstartedlab`
 - access visualizer via [http://192.168.99.100:8080/](http://192.168.99.100:8080/) - or whatever manager IP is.
 - run (in same terminal) `docker stack ps getstartedlab` to see all the task IDs in the stack.
    (recall: task ID and container ID are different thing. But 1-to-1.).
 