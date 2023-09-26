package main

import (
	"log"
	"net"
	"os"

	pb "github.com/leon123858/terroform-sample/docker-grpc/notify"

	"google.golang.org/grpc"
)

type MailBoxService struct {
	pb.UnimplementedMailBoxServer
	// can save local var below
	// mu sync.Mutex
}

func (s *MailBoxService) GetNotify(in *pb.NotifyRequest, stream pb.MailBox_GetNotifyServer) error {
	// for {
	// when 2 direction stream, we need to use Recv() to get data from client
	// in, err := stream.Recv()
	// if err == io.EOF {
	// 	return nil
	// }
	// if err != nil {
	// 	return err
	// }
	// key := serialize(in.Location)

	err := stream.Send(&pb.NotifyReply{
		Message: "Hello " + in.ChannelId,
	})
	if err != nil {
		return err
	}
	return nil
	// }
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "50051"
	}

	listen, err := net.Listen("tcp", ":"+port)
	if err != nil {
		log.Fatalln(err)
	}

	server := grpc.NewServer()
	// register service
	service := MailBoxService{}
	pb.RegisterMailBoxServer(server, &service)

	println("start server on tcp://127.0.0.1:" + port)
	server.Serve(listen)
}
