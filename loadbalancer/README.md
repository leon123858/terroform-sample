# loadbalancer sample

## How to use

should put your image file in `bucket_1/one/*` and `bucket_2/two/*`

then request in browser below url

```ssh

http://<lb-ip>/one/*

http://<lb-ip>/two/*

```

each request may go to different backend
