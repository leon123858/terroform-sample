package main

import (
	"context"
	"log"
	"net"
	"os"

	"google.golang.org/grpc"

	pb "github.com/leon123858/terroform-sample/docker-grpc/proto"
)

var ProjectID = "tw-rd-ca-leon-lin"

type NoticeService struct {
	pb.UnsafeNoticeServiceServer
	// custom local variable
	ChannelId      int64
	noticesChannel *map[string](chan Notice)
}

func (s *NoticeService) Connect(in *pb.UserId, stream pb.NoticeService_ConnectServer) error {
	// create a channel for this user
	(*s.noticesChannel)[in.UserId] = make(chan Notice)
	defer func() {
		close((*s.noticesChannel)[in.UserId])
		delete(*s.noticesChannel, in.UserId)
	}()
	// set channel id
	if err := stream.Send(&pb.Notice{ChannelId: s.ChannelId, Msg: ""}); err != nil {
		return err
	}
	for {
		// get message from channel
		msg := <-(*s.noticesChannel)[in.UserId]
		// send message to client
		if err := stream.Send(&pb.Notice{ChannelId: s.ChannelId, Msg: msg.Msg}); err != nil {
			return err
		}
	}
}

func main() {
	PORT := os.Getenv("PORT")
	if PORT == "" {
		PORT = "50051"
	}

	noticesChannel := make(map[string](chan Notice), 0)

	ctx := context.Background()
	cancelCtx, cancel := context.WithCancel(ctx)
	defer cancel()

	pubSubInfo := PubSubInfo{}
	pubSubInfo.init(ProjectID)
	go func(p PubSubInfo, c *map[string](chan Notice)) {
		PullMsgs(p, c, cancelCtx) // pass the address of the c variable
	}(pubSubInfo, &noticesChannel)

	listen, err := net.Listen("tcp", ":"+PORT)
	if err != nil {
		log.Fatalln(err)
	}

	server := grpc.NewServer()
	pb.RegisterNoticeServiceServer(server, &NoticeService{ChannelId: pubSubInfo.ChannelId, noticesChannel: &noticesChannel})

	if err := server.Serve(listen); err != nil {
		log.Fatalln(err)
	}
}
