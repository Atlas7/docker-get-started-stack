
# Development Steps

### Step 1

Deploy a Docker container as per [this tutorial](https://docs.docker.com/get-started/part2/#run-the-app).

Summary:

- Create a app directory locally on the Mac / laptop
- Create `Dockerfile`: define container environment
- Create `requirement.txt`: containing python package dependencies
- Create `app.py`: a simple flask hello world app
- Build the docker image (from `Dockerfile`)
- Spin up a new container `friendlyhello` based on the `Dockerfile` image, with localhost port 4000 pointing to 
  container port 80.
- Go to [http://localhost:4000/](http://localhost:4000/) to access Flask web application.
- Git commit!

