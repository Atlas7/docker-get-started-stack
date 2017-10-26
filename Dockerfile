# Use an official Python runtime as a parent image
FROM python:3.6

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Are you behind a proxy server?
# Proxy servers can block connections to your web app once it’s up and running. If you are behind a proxy server,
# add the following lines to your Dockerfile, using the `ENV` command to specify the host and port for your
# proxy servers:
#
# Set proxy server, replace host:port with values for your servers
#ENV http_proxy host:port
#ENV https_proxy host:port

# Run app.py when the container launches
CMD ["python", "app.py"]