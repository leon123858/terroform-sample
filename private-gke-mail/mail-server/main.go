package main

import (
	"github.com/labstack/echo/v4"
	"log"
	"net/smtp"
)

func main() {
	// use echo create a http server
	e := echo.New()
	e.GET("/", func(c echo.Context) error {
		return c.String(200, "Hello, World!")
	})

	e.GET("/send", func(c echo.Context) error {
		email := c.QueryParam("email")
		text := c.QueryParam("text")
		if err := send(text, email); err != nil {
			return c.String(500, "send email to "+email+" fail")
		}
		return c.String(200, "send email to "+email+" success")
	})

	// start server
	e.Logger.Fatal(e.Start(":8080"))
}

func send(body string, to string) error {
	from := "mail-tester@test-mail.trantrithong.com"
	pass := "cloudmile1234858"
	//to := "a0970785699@gmail.com"

	msg := "From: " + from + "\n" +
		"To: " + to + "\n" +
		"Subject: Hello there\n\n" +
		body

	err := smtp.SendMail("smtp.gmail.com:587",
		smtp.PlainAuth("", from, pass, "smtp.gmail.com"),
		from, []string{to}, []byte(msg))

	if err != nil {
		log.Printf("smtp error: %s", err)
		return err
	}

	println("send email to " + to + " success")
	return nil
}
