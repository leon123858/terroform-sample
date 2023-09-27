package main

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"cloud.google.com/go/pubsub"
)

type PubSubInfo struct {
	ProjectID string
	ChannelId int64
	TopicID   string
	SubID     string
	Topic     *pubsub.Topic
	Sub       *pubsub.Subscription
}

type Notice struct {
	UserId string `json:"userId"`
	Msg    string `json:"msg"`
}

func byteSliceToJSON(data []byte) (*Notice, error) {
	// Unmarshal the byte slice into a MyData struct.
	var myData Notice
	err := json.Unmarshal(data, &myData)
	if err != nil {
		return nil, err
	}

	return &myData, nil
}

func (info *PubSubInfo) createTopic(client *pubsub.Client, ctx context.Context) error {
	info.ChannelId = time.Now().UnixNano()
	info.TopicID = "notice-" + fmt.Sprint(info.ChannelId)
	topic, err := client.CreateTopic(ctx, info.TopicID)
	if err != nil {
		return err
	}
	info.Topic = topic
	return nil
}

func (info *PubSubInfo) createSub(client *pubsub.Client, ctx context.Context) error {
	info.SubID = "notice-sub-" + fmt.Sprint(info.ChannelId)
	sub, err := client.CreateSubscription(ctx, info.SubID, pubsub.SubscriptionConfig{
		Topic:       info.Topic,
		AckDeadline: 20 * time.Second,
	})
	if err != nil {
		return err
	}
	info.Sub = sub
	return nil
}

func (info *PubSubInfo) deleteSub(client *pubsub.Client, ctx context.Context) error {
	if err := info.Sub.Delete(ctx); err != nil {
		return err
	}
	return nil
}

func (info *PubSubInfo) deleteTopic(client *pubsub.Client, ctx context.Context) error {
	if err := info.Topic.Delete(ctx); err != nil {
		return err
	}
	return nil
}

func (info *PubSubInfo) init(projectId string) error {
	info.ProjectID = projectId
	ctx := context.Background()
	client, err := pubsub.NewClient(ctx, info.ProjectID)
	if err != nil {
		return err
	}
	defer client.Close()

	if err := info.createTopic(client, ctx); err != nil {
		return err
	}
	if err := info.createSub(client, ctx); err != nil {
		return err
	}

	return nil
}

func PullMsgs(info PubSubInfo, channelMap *map[string](chan Notice), ctx context.Context) {
	client, err := pubsub.NewClient(ctx, info.ProjectID)
	if err != nil {
		panic(err)
	}
	defer func() {
		info.deleteSub(client, ctx)
		info.deleteTopic(client, ctx)
		client.Close()
	}()

	sub := client.Subscription(info.SubID)
	err = sub.Receive(ctx, func(_ context.Context, msg *pubsub.Message) {
		notice, err := byteSliceToJSON(msg.Data)
		if err != nil {
			println(err.Error())
			msg.Ack()
			return
		}
		if _, ok := (*channelMap)[notice.UserId]; ok {
			(*channelMap)[notice.UserId] <- *notice
		}
		// not exist user connection
		msg.Ack()
	})
	if err != nil {
		panic(err)
	}
}
