# terraform-redact-secrets
redact secrets, api keys, private keys etc.. during terraform plan/apply.

As a part of the terraform plan/apply, it would print all secrets (SQL passwords/api keys/private keys/certificates, etc..) which are confidential information that needs to be redacted. This can be avoided by wrapping terraform binary with a [custom bash script](./terraform.sh).Assuming terraform binary from Hashicorp is installed on the path `/opt/terraform`, we can wrap it with a bash script in path `/usr/local/bin/terraform`.

As an example I tried to create an aws lambda function that has environment variables `PRIVATE_KEY` & `API_KEY` which are read from aws parameter store. 
ps: Please store secrets as secure string in aws parameter store.

### Without redaction

#### Commands
```bash
/opt/terraform init
/opt/terraform plan -out tf.plan
```

#### Outputs
```
data.archive_file.test: Refreshing state...
data.aws_ssm_parameter.test_api_key: Refreshing state...
data.aws_ssm_parameter.test_private_key: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_role.test_lambda_role will be created
  + resource "aws_iam_role" "test_lambda_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "lambda.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + max_session_duration  = 3600
      + name                  = "test_lambda_role"
      + path                  = "/"
      + unique_id             = (known after apply)
    }

  # aws_lambda_function.example will be created
  + resource "aws_lambda_function" "example" {
      + arn                            = (known after apply)
      + filename                       = "test_lambda_function.zip"
      + function_name                  = "test_function"
      + handler                        = "main.handler"
      + id                             = (known after apply)
      + invoke_arn                     = (known after apply)
      + last_modified                  = (known after apply)
      + memory_size                    = 128
      + publish                        = false
      + qualified_arn                  = (known after apply)
      + reserved_concurrent_executions = -1
      + role                           = (known after apply)
      + runtime                        = "nodejs10.x"
      + source_code_hash               = (known after apply)
      + source_code_size               = (known after apply)
      + timeout                        = 3
      + version                        = (known after apply)

      + environment {
          + variables = {
              + "API_KEY"     = "test"
              + "PRIVATE_KEY" = <<~EOT
                    -----BEGIN RSA PRIVATE KEY-----
                    abcdefghijklmnopqrstuvwxyz
                    abcdefghijklmnopqrstuvwxyz
                    -----END RSA PRIVATE KEY-----
                EOT
            }
        }

      + tracing_config {
          + mode = (known after apply)
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

### With redaction

#### Commands
```bash
/usr/local/bin/terraform init
/usr/local/bin/terraform plan -out tf.plan
```

#### Outputs

```
data.archive_file.test: Refreshing state...
data.aws_ssm_parameter.test_private_key: Refreshing state...
data.aws_ssm_parameter.test_api_key: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_role.test_lambda_role will be created
  + resource "aws_iam_role" "test_lambda_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "lambda.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + max_session_duration  = 3600
      + name                  = "test_lambda_role"
      + path                  = "/"
      + unique_id             = (known after apply)
    }

  # aws_lambda_function.example will be created
  + resource "aws_lambda_function" "example" {
      + arn                            = (known after apply)
      + filename                       = "test_lambda_function.zip"
      + function_name                  = "test_function"
      + handler                        = "main.handler"
      + id                             = (known after apply)
      + invoke_arn                     = (known after apply)
      + last_modified                  = (known after apply)
      + memory_size                    = 128
      + publish                        = false
      + qualified_arn                  = (known after apply)
      + reserved_concurrent_executions = -1
      + role                           = (known after apply)
      + runtime                        = "nodejs10.x"
      + source_code_hash               = (known after apply)
      + source_code_size               = (known after apply)
      + timeout                        = 3
      + version                        = (known after apply)

      + environment {
          + variables = {
              + "API_KEY" = "****"<redacted>
              + "PRIVATE_KEY" = <<~EOT
                    "****"<redacted>
                EOT
            }
        }

      + tracing_config {
          + mode = (known after apply)
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

As you can see it from above `PRIVATE_KEY` and `API_KEY` are redacted.