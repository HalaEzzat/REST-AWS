package main

import (
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/valyala/fastjson"
)

func HandleRequest(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	ApiResponse := events.APIGatewayProxyResponse{}
	// Switch for identifying the HTTP request
	fmt.Println("Headers:")
	var Headers = ""
	for key, value := range request.Headers {
		Headers += key
		Headers += " : "
		Headers += value
		Headers += "\n"
	}
	var Params = ""
	for key, value := range request.QueryStringParameters {
		Params += key
		Params += " : "
		Params += value
		Params += "\n"
	}
	switch request.HTTPMethod {
	case "GET":
		if Params != "" {
			ApiResponse = events.APIGatewayProxyResponse{Body: "Method: " + request.HTTPMethod + "\nHeaders:\n" + Headers + "\nParams:\n" + Params, StatusCode: 200}
		} else {
			ApiResponse = events.APIGatewayProxyResponse{Body: "Method: " + request.HTTPMethod + "\nHeaders:\n" + Headers, StatusCode: 200}
		}

	case "POST":
		//validates json and returns error if not working
		err := fastjson.Validate(request.Body)

		if err != nil {
			ApiResponse = events.APIGatewayProxyResponse{Body: "Error!", StatusCode: 500}
		} else {
			ApiResponse = events.APIGatewayProxyResponse{Body: "Body: " + request.Body + "\nMethod: " + request.HTTPMethod + "\nHeaders:\n" + Headers, StatusCode: 200}
		}

	}
	// Response
	return ApiResponse, nil
}

func main() {
	lambda.Start(HandleRequest)
}
