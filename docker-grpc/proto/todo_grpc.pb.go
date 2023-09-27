// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.2.0
// - protoc             v4.24.3
// source: todo.proto

package proto

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

// NoticeServiceClient is the client API for NoticeService service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type NoticeServiceClient interface {
	// 定義api名稱，傳入參數與回傳值
	Connect(ctx context.Context, in *UserId, opts ...grpc.CallOption) (NoticeService_ConnectClient, error)
}

type noticeServiceClient struct {
	cc grpc.ClientConnInterface
}

func NewNoticeServiceClient(cc grpc.ClientConnInterface) NoticeServiceClient {
	return &noticeServiceClient{cc}
}

func (c *noticeServiceClient) Connect(ctx context.Context, in *UserId, opts ...grpc.CallOption) (NoticeService_ConnectClient, error) {
	stream, err := c.cc.NewStream(ctx, &NoticeService_ServiceDesc.Streams[0], "/NoticeService/Connect", opts...)
	if err != nil {
		return nil, err
	}
	x := &noticeServiceConnectClient{stream}
	if err := x.ClientStream.SendMsg(in); err != nil {
		return nil, err
	}
	if err := x.ClientStream.CloseSend(); err != nil {
		return nil, err
	}
	return x, nil
}

type NoticeService_ConnectClient interface {
	Recv() (*Notice, error)
	grpc.ClientStream
}

type noticeServiceConnectClient struct {
	grpc.ClientStream
}

func (x *noticeServiceConnectClient) Recv() (*Notice, error) {
	m := new(Notice)
	if err := x.ClientStream.RecvMsg(m); err != nil {
		return nil, err
	}
	return m, nil
}

// NoticeServiceServer is the server API for NoticeService service.
// All implementations must embed UnimplementedNoticeServiceServer
// for forward compatibility
type NoticeServiceServer interface {
	// 定義api名稱，傳入參數與回傳值
	Connect(*UserId, NoticeService_ConnectServer) error
	mustEmbedUnimplementedNoticeServiceServer()
}

// UnimplementedNoticeServiceServer must be embedded to have forward compatible implementations.
type UnimplementedNoticeServiceServer struct {
}

func (UnimplementedNoticeServiceServer) Connect(*UserId, NoticeService_ConnectServer) error {
	return status.Errorf(codes.Unimplemented, "method Connect not implemented")
}
func (UnimplementedNoticeServiceServer) mustEmbedUnimplementedNoticeServiceServer() {}

// UnsafeNoticeServiceServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to NoticeServiceServer will
// result in compilation errors.
type UnsafeNoticeServiceServer interface {
	mustEmbedUnimplementedNoticeServiceServer()
}

func RegisterNoticeServiceServer(s grpc.ServiceRegistrar, srv NoticeServiceServer) {
	s.RegisterService(&NoticeService_ServiceDesc, srv)
}

func _NoticeService_Connect_Handler(srv interface{}, stream grpc.ServerStream) error {
	m := new(UserId)
	if err := stream.RecvMsg(m); err != nil {
		return err
	}
	return srv.(NoticeServiceServer).Connect(m, &noticeServiceConnectServer{stream})
}

type NoticeService_ConnectServer interface {
	Send(*Notice) error
	grpc.ServerStream
}

type noticeServiceConnectServer struct {
	grpc.ServerStream
}

func (x *noticeServiceConnectServer) Send(m *Notice) error {
	return x.ServerStream.SendMsg(m)
}

// NoticeService_ServiceDesc is the grpc.ServiceDesc for NoticeService service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var NoticeService_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "NoticeService",
	HandlerType: (*NoticeServiceServer)(nil),
	Methods:     []grpc.MethodDesc{},
	Streams: []grpc.StreamDesc{
		{
			StreamName:    "Connect",
			Handler:       _NoticeService_Connect_Handler,
			ServerStreams: true,
		},
	},
	Metadata: "todo.proto",
}
