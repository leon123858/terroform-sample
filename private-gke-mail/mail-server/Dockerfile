# Use the offical Go image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.21.0 as builder
WORKDIR /app

# Copy local code to the container image.
COPY . ./

# Build the command inside the container.
RUN CGO_ENABLED=0 GOOS=linux go build -o /main

# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM gcr.io/distroless/base-debian11

# Change the working directory.
WORKDIR /

# Copy the binary to the production image from the builder stage.
COPY --from=builder /main /main

# port
EXPOSE 8080

# Run the web service on container startup.
USER nonroot:nonroot
ENTRYPOINT ["/main"]