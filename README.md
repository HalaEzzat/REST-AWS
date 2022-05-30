## WorkMotion DevOps Task:

## _Solution Steps:_

- Created Terraform Module : "main.tf" :
> #### It Contains the following resources:  
```sh 
- aws_iam_role ,  aws_iam_role_policy_attachment For IAM Authuntication 
- archive_file to Package the executable code into a zip file
- aws_lambda_function to create the lambda function using the zip file
- aws_lambda_permission to give lambda the permission to be accessed using rest apis via the gateway invokation
- aws_api_gateway_rest_api,aws_api_gateway_resource to create the rest api
- aws_api_gateway_method , aws_api_gateway_integration for post and get
- aws_api_gateway_deployment,aws_api_gateway_stage to manage api gateway deployment
```
- Created the web App service  : "main.go"
> where I handle the get and post requests and print the request header, method, and body.
- build the code : 
```sh 
env GOOS=linux GOARCH=amd64 go build -o output/main
```
- Apply Terraform Module : 
```sh 
terraform init
terraform plan
terraform apply -auto-approve" 
```
> all resources will be created now copy the link in the output section <br />
> Note: This is created on AWS Sandbox account to test the code :<br />
> change AWS Credentials under secrets :<br />
```sh
https://github.com/HalaMEzzat/workmotion/settings/secrets/actions
```
> under "Repository secrets"<br />
> Change AWS_ACCESS_KEY_ID , AWS_SECRET_ACCESS_KEY with your creds<br />
> now run the code and test the link:<br />
```sh 
 https://uujt0h5xoh.execute-api.us-east-2.amazonaws.com/dev-01/hello
 ```
- test the code via postman send any get , post requests 
> Sending GET Request with no Params :- 
![image](https://user-images.githubusercontent.com/106016107/169697460-4fcd8f5d-ff05-4ff8-95f0-54c67c3bec4d.png)

> sending GET with params:
![image](https://user-images.githubusercontent.com/106016107/169697522-043e63e5-485f-4760-82cb-034898b59b6e.png)

> sending POST request
![image](https://user-images.githubusercontent.com/106016107/169697615-83be0466-30f6-47d9-ae54-1c712a881567.png)

- For CI/CD : I used github actions 
> 🚨 Note: This is created on AWS Sandbox account to test the code :
> 🚨 change AWS Credentials under secrets :
```sh
https://github.com/HalaEzzat/REST-AWS/settings/secrets
```
> 🚨 under "Repository secrets" <br />
> 🚨 Change AWS_ACCESS_KEY_ID , AWS_SECRET_ACCESS_KEY with your creds <br />
> Created .github\workflows\terraform.yml file where I: <br />
> I manualy checkout the newly pushed code on github for testeing 🚨 _you can change the trigger event to "on: push" instead_ 🚨 <br />
> Install Go and Build the Solution <br />
> Init => plan => apply terraform module <br />
> created secrets for aws IAM creds and Github Token <br />
![image](https://user-images.githubusercontent.com/106038156/169804977-0f348e1f-2dda-43b3-95bd-6258e85d7029.png)
> to test the CI/CD Pipline: go to Actions=>click on the workflow ".github/workflows/terraform.yml" => under "workflow runs" click on "Run Workflow" then click on the green button "Run Workflow" <br />
> See the Attached screenshot:
> ![image](https://user-images.githubusercontent.com/106038156/169806970-54ed9037-b65b-4951-b424-83dac1100142.png)



