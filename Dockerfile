# Use the official Ubuntu base image
FROM ubuntu:20.04

# Avoid prompts from apt
ARG DEBIAN_FRONTEND=noninteractive

# Minimize the number of layers and clean up in one RUN to keep the image size down
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Example: Run a simple application or service
CMD ["echo", "Hello, World!"]
