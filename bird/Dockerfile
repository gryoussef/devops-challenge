# Start from the official Go image
FROM golang:1.22-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod ./

# Download all dependencies
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the application with security flags
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o getBird .

# Start a new stage from scratch
FROM gcr.io/distroless/static-debian12

# Create a non-root user
USER nonroot:nonroot

# Copy the binary from the builder stage and set permissions
COPY --from=builder --chown=nonroot:nonroot /app/getBird /getBird

# Expose port 4201
EXPOSE 4201

# Expose the BIRD_API_HOST_NAME as an environment variable
ENV BIRD_IMAGE_API_HOST=bird-image-api

# Expose the BIRD_API_HOST_PORT as an environment variable
ENV BIRD_IMAGE_API_PORT=4200

LABEL org.opencontainers.image.source="https://github.com/gryoussef/devops-challenge"
LABEL org.opencontainers.image.description="Bird API"
LABEL org.opencontainers.image.licenses="MIT"

# Command to run the executable
CMD ["/getBird"]