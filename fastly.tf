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

  # The following is needed to work around:
  # https://github.com/hashicorp/terraform/issues/7609
  # Fastly provider: backends not mandatory when VCL defined
  backend {
    address = "127.0.0.1"
    name    = "Nowhere"
    port    = 1
  }

  default_ttl   = 10
  force_destroy = true

  vcl {
    name    = "main.vcl"
    main    = "true"
    content = "${file("files/main.vcl")}"
  }

  vcl {
    name    = "json-generate.vcl"
    content = "${file("files/json-generate.vcl")}"
  }
}
