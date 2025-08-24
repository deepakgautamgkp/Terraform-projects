locals {
  azs = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}" ]
  subnets = {
    public-sub = {
        "${data.aws_availability_zones.available.names[0]}"= "${var.subnet-pu1}"
        "${data.aws_availability_zones.available.names[1]}"= "${var.subnet-pu2}"
    }
    private-sub = {"${data.aws_availability_zones.available.names[0]}"= "${var.subnet-priv}"}
  }
}

locals {
  sg-ports = [22, 80,0]
}
