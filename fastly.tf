# Configure the Fastly Provider
provider "fastly" {
  api_key = "${var.fastly_api_key}"
}

# Create a Service
resource "fastly_service_v1" "myservice" {
  name = "${var.domain}"

  domain {
    name = "${var.domain}"
  }

  default_ttl   = 10
  force_destroy = true

  vcl {
    name    = "main.vcl"
    main    = "true"
    content = "${file("files/main.vcl")}"
  }

  vcl {
    name    = "json_generate.vcl"
    content = "${file("files/json_generate.vcl")}"
  }

  condition {
    name      = "Disable"
    statement = "!req.url"
    priority  = 10
    type      = "response"
  }

  papertrail {
    name               = "Papertrail"
    format             = "req.http.log"
    address            = "${var.papertrail_address}"
    port               = "${var.papertrail_port}"
    response_condition = "Disable"
  }
}
