# Use the official Ubuntu base image
FROM ubuntu:20.04

# Avoid prompts from apt
ARG DEBIAN_FRONTEND=noninteractive
# Example: Run a simple application or service
CMD ["echo", "Hello, World!"]
