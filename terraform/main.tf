provider "google" {
	project = "my-new-project-237916"
	region = "europe-west1"
}
#to start VM we need to use resource google_compute_instance
resource "google_compute_instance" "app" {
	name 			= "reddit-app"
	machine_type 	= "g1-small"
	zone			= "europe-west1-b"
	boot_disk {
		initialize_params {
			image = "reddit-base-1555525238"
		}
	}
	metadata {
		sshKeys = "appuser:${file("~/Dropbox/ssh/appuser.pub")}"
	}
	tags = ["reddit-app"]
	#defining of network interface
	network_interface {
		#network name
		network = "default"
		#using ephemeral IP for internet access
		access_config {}
	}
	connection {
		type 				= "ssh"
		user 				= "appuser"
		agent				= false
		private_key = "${file("~/.ssh/appuser")}" 
	}
	provisioner "file" {
		source 				= "files/puma.service"
		destination 	= "/tmp/puma.service"
	}
	# provisioner "file" {
	# 	source 				= "files/deploy.sh"
	# 	destination 	= "/tmp/deploy.sh"
	# }
	provisioner "remote-exec" {
		# inline = [
		# 	"chmod +x /tmp/deploy.sh",
		# 	"/tmp/deploy.sh"
		# ]
		script = "files/deploy.sh"
	}
}

resource "google_compute_firewall" "firewall_puma" {
	name 		= "allow-puma-default"
	network = "default"
	allow {
		protocol 	= "tcp"
		ports 		= ["9292"]
	}
	source_ranges = ["0.0.0.0/0"]
	target_tags = ["reddit-app"]
}