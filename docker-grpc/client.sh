grpcurl \
  -plaintext \
  -proto proto/todo.proto \
  -d '{"channelId": "123"}' \
  127.0.0.1:50051 \
  MailBox.GetNotify
