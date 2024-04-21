resource "yandex_function" "fn01" {
    name               = "otus-fn01"
    user_hash          = "fn01"
    runtime            = "python312"
    entrypoint         = "index.handler"
    memory             = "128"
    execution_timeout  = "5"
    service_account_id = var.service_account_id
    content {
        zip_filename = "index.py"
    }
}

resource "yandex_api_gateway" "apigw" {
  name        = "otus-apigw"
  spec = <<-EOT
    openapi: 3.0.0
    info:
      title: Sample API
      version: 1.0.0
    paths:
      /:
        get:
          x-yc-apigateway-integration:
            type: cloud_functions
            function_id: ${yandex_function.fn01.id}
          operationId: redirect
          parameters:
          - description: id of the url
            explode: false
            in: path
            name: id
            required: true
            schema:
              type: string
            style: simple
    EOT
}