package main

import (
	"log"
	"net"
	"os"

	"google.golang.org/grpc"

	pb "github.com/leon123858/terroform-sample/docker-grpc/proto"
)

type NoticeService struct {
	pb.UnsafeNoticeServiceServer
}

func (s *NoticeService) Connect(in *pb.ChannelId, stream pb.NoticeService_ConnectServer) error {
	// 向客戶端發送回應。
	resp := &pb.Notice{
		Id:  in.Id,
		Msg: "Received GRPC",
	}
	// 從客戶端接收消息。
	for {
		err := stream.Send(resp)
		if err != nil {
			return err
		}
	}
}

func main() {
	PORT := os.Getenv("PORT")
	if PORT == "" {
		PORT = "50051"
	}
	listen, err := net.Listen("tcp", ":"+PORT)
	if err != nil {
		log.Fatalln(err)
	}

	server := grpc.NewServer()
	pb.RegisterNoticeServiceServer(server, &NoticeService{})

	if err := server.Serve(listen); err != nil {
		log.Fatalln(err)
	}
}
