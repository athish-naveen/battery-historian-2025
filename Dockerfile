# Use the official Golang image as a base
FROM golang:1.19 as builder

# Set environment variables
ENV GOPATH=/go
ENV GOBIN=$GOPATH/bin
ENV PATH=$PATH:$GOBIN

# Create a working directory inside the container
WORKDIR /go/src/github.com/google/battery-historian

# Copy the local code into the Docker container
COPY . .

RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Oracle JDK 23 (x64) from the provided link
RUN wget https://download.oracle.com/java/23/latest/jdk-23_linux-x64_bin.tar.gz \
    && mkdir -p /opt/openjdk \
    && tar -xzf jdk-23_linux-x64_bin.tar.gz -C /opt/openjdk \
    && rm jdk-23_linux-x64_bin.tar.gz

# Set Java environment variables
ENV JAVA_HOME=/opt/openjdk/jdk-23
ENV PATH=$JAVA_HOME/bin:$PATH

# Download Go dependencies (Battery Historian's Go dependencies)
RUN go mod tidy

# Compile JavaScript files using Closure compiler
RUN go run setup.go

# Expose the port Battery Historian will run on
EXPOSE 9999

# Command to run Battery Historian
CMD ["go", "run", "cmd/battery-historian/battery-historian.go", "--port", "9999"]
