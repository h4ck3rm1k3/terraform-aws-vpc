provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "us-east-1"
}

resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
	tags {  Name = "terraform-v1"    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
	tags {  Name = "terraform-v1"    }
}

# NAT instance

resource "aws_security_group" "nat" {
    tags {  Name = "terraform-v1"    }
	name = "nat"
	description = "Allow services from the private subnet through NAT"

	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["${aws_subnet.us-east-1c-private.cidr_block}"]
	}
	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["${aws_subnet.us-east-1d-private.cidr_block}"]
	}

	vpc_id = "${aws_vpc.default.id}"
}

resource "aws_instance" "nat" {
    tags {  Name = "terraform-v1"    }
 	ami = "${var.aws_nat_ami}"
 	availability_zone = "us-east-1c"
 	instance_type = "t2.nano"
 	key_name = "${var.aws_key_name}"
 	#security_groups = ["${aws_security_group.nat.id}"]
	vpc_security_group_ids = [ "${aws_security_group.nat.id}" ]
 	subnet_id = "${aws_subnet.us-east-1c-public.id}"
 	#	associate_public_ip_address = true
 	source_dest_check = false


}


# resource "aws_eip" "nat" {
# 	instance = "${aws_instance.nat.id}"
# 	vpc = true
# }

# Public subnets

resource "aws_subnet" "us-east-1c-public" {
    tags {  Name = "terraform-v1"    }
	vpc_id = "${aws_vpc.default.id}"

	cidr_block = "10.0.0.0/24"
	availability_zone = "us-east-1c"
}

resource "aws_subnet" "us-east-1d-public" {
    tags {  Name = "terraform-v1"    }
	vpc_id = "${aws_vpc.default.id}"

	cidr_block = "10.0.2.0/24"
	availability_zone = "us-east-1d"
}

# Routing table for public subnets

resource "aws_route_table" "us-east-1-public" {
    tags {  Name = "terraform-v1"    }
	vpc_id = "${aws_vpc.default.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.default.id}"
	}
}

resource "aws_route_table_association" "us-east-1c-public" {

	subnet_id = "${aws_subnet.us-east-1c-public.id}"
	route_table_id = "${aws_route_table.us-east-1-public.id}"
}

resource "aws_route_table_association" "us-east-1d-public" {
	subnet_id = "${aws_subnet.us-east-1d-public.id}"
	route_table_id = "${aws_route_table.us-east-1-public.id}"
}

# Private subsets

resource "aws_subnet" "us-east-1c-private" {

	vpc_id = "${aws_vpc.default.id}"

	cidr_block = "10.0.1.0/24"
	availability_zone = "us-east-1c"
}

resource "aws_subnet" "us-east-1d-private" {
    tags {  Name = "terraform-v1"    }
	vpc_id = "${aws_vpc.default.id}"

	cidr_block = "10.0.3.0/24"
	availability_zone = "us-east-1d"
}

# Routing table for private subnets
resource "aws_network_interface" "eth0" {
    tags {  Name = "terraform-v1"    }
	 # "${aws_network_interface.eth0}"
    subnet_id = "${aws_subnet.us-east-1c-public.id}"
    private_ips = ["10.0.0.50"]
    #security_groups = ["${aws_security_group.nat.id}"]
    #vpc_security_group_ids = [ "${aws_security_group.nat.id}" ]
    # attachment {
    #         instance = "${aws_instance.test.id}"
    #     device_index = 1
    # }

    	attachment {
	    instance = "${aws_instance.nat.id}"
	    device_index = 1
        }

}

resource "aws_route_table" "us-east-1-private" {
    tags {  Name = "terraform-v1"    }
    vpc_id = "${aws_vpc.default.id}"
	
	route {
	    cidr_block = "0.0.0.0/0"
		#		gatewayId, natGatewayId, networkInterfaceId, vpcPeeringConnectionId or instanceId
		network_interface_id =	"${aws_network_interface.eth0.id}"
		#	#instance_id = "${aws_instance.nat.id}"
    }
}

resource "aws_route_table_association" "us-east-1c-private" {

	subnet_id = "${aws_subnet.us-east-1c-private.id}"
	route_table_id = "${aws_route_table.us-east-1-private.id}"
}

resource "aws_route_table_association" "us-east-1d-private" {

	subnet_id = "${aws_subnet.us-east-1d-private.id}"
	route_table_id = "${aws_route_table.us-east-1-private.id}"
}

# Bastion

# resource "aws_security_group" "bastion" {
# 	name = "bastion"
# 	description = "Allow SSH traffic from the internet"

# 	ingress {
# 		from_port = 22
# 		to_port = 22
# 		protocol = "tcp"
# 		cidr_blocks = ["0.0.0.0/0"]
# 	}

# 	vpc_id = "${aws_vpc.default.id}"
# }

# resource "aws_instance" "bastion" {
# 	ami = "${var.aws_ubuntu_ami}"
# 	availability_zone = "us-east-1c"
# 	instance_type = "t2.nano"
# 	key_name = "${var.aws_key_name}"
# 	security_groups = ["${aws_security_group.bastion.id}"]
# 	subnet_id = "${aws_subnet.us-east-1c-public.id}"
# }

# resource "aws_eip" "bastion" {
# 	instance = "${aws_instance.bastion.id}"
# 	vpc = true
# }
