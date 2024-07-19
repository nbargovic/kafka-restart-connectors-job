# kafka-restart-connectors-job
An openshift cron job that looks for Kafka Connectors in a failed state, and restarts them using the Connect REST API.

### How to build
This image uses an ironbank hardend base image that contains Curl and JQ libraries. You can rebuild the container using another base image if you'd like.

To build the docker image:
```
docker login registry1.dso.mil
docker pull registry1.dso.mil/ironbank/big-bang/base:2.1.0
docker buildx build --platform linux/amd64 --no-cache -t bargovic/restart-connectors:1.0.0 .
```

### How to deploy to OpenShift
```
kubectl apply -f secret.yaml -n confluent
kubectl apply -f restart-cron.yml -n confluent
```

### How to debug/test the container and script
You can manually run the restart script in the container using the following commands:
```
docker run -it --rm bargovic/restart-connectors:1.0.0
/opt/restart-connectors.sh <connect-api-url> <username> <password>
```
