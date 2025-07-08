data "template_file" "user_data_blue" {
  template = file("${path.module}/user_data_blue.sh")
}

data "template_file" "user_data_green" {
  template = file("${path.module}/user_data_green.sh")
}
