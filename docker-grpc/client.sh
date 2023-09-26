grpcurl \
  -plaintext \
  -proto proto/todo.proto \
  -d '{"id": 1}' \
  127.0.0.1:50051 \
  NoticeService.Connect
