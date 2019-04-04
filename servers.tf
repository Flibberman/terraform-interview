data "aws_ami" "amazon_windows_2019" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

variable "subnet_ids" {
  default = ["subnet-636df004", "subnet-915ee9d8"]
}

variable "securitygroup_ids" {
  default = ["sg-46e5ee3e", "sg-084a5670"]
}

resource "aws_instance" "webheads" {
  count                  = "2"
  ami                    = "${data.aws_ami.amazon_windows_2019.image_id}"
  subnet_id              = "${element(var.subnet_ids, count.index)}"
  instance_type          = "t2.medium"
  ebs_optimized          = "false"
  key_name               = "SBXOPSINFKEY"
  get_password_data      = "true"
  vpc_security_group_ids = "${var.securitygroup_ids}"

  user_data = <<EOF
  <powershell>
  Enable-PSRemoting -Force
  Set-ExecutionPolicy RemoteSigned –Force

  Import-Module ServerManager
  Add-WindowsFeature Web-Server -IncludeAllSubFeature
  Add-WindowsFeature Web-Mgmt-Tools
  Add-WindowsFeature NET-Framework-Features, NET-Framework-Core

$hostname="platformselfsigned"
$iisSite="Default Web Site"

New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname $hostname

$cert = (Get-ChildItem cert:\LocalMachine\My | where-object { $_.Subject -like "*$hostname*" } | Select-Object -First 1).Thumbprint

New-WebBinding -name $iisSite -Protocol https -Port 443

cd IIS:\SslBindings
get-item cert:\LocalMachine\MY\$cert | new-item 0.0.0.0!443

  $indexContent = '<!DOCTYPE html>
<html>

<head>
<meta charset="utf-8">
<meta name="google" value="notranslate">
<title>Lorem Ipsum Dolor Sit Amet</title>
<style>

body {
  background-color: #faf2e4;
  margin: 0 15%;
  font-family: sans-serif;
  }

h1 {
  text-align: center;
  font-family: serif;
  font-weight: normal;
  text-transform: uppercase;
  border-bottom: 1px solid #57b1dc;
  margin-top: 30px;
}

h2 {
  color: #d1633c;
  font-size: 1em;
}

svg {
  width: 200px;
}

</style>

<script>
if (location.protocol != "https:")
{
 location.href = "https:" + window.location.href.substring(window.location.protocol.length);
}
</script>

</head>

<body>

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 70" preserveAspectRatio="xMinYMin meet"><title>Tripwire</title><path fill="#FFF" d="M136.2 38.3c0 2.9-2.9 5.3-6.4 5.3H16.5c-3.5 0-6.4-2.4-6.4-5.3v-33C10.1 2.4 13 0 16.5 0h113.3c3.5 0 6.4 2.4 6.4 5.3v33z"></path><path fill="#FF7B17" d="M111.9 25.6c-.4-.2-.9-.3-1.4-.3-1.9 0-4.6 1.2-4.6 4.9v13.4h-4.5V21h4.5v2.4c1.9-1.6 3.4-2.7 6-2.7v4.9zM98 16.8h-4.5v-4.9H98v4.9zm0 26.8h-4.5V21H98v22.6zm-12.9 0h-4l-2.5-13.4h-.1L76 43.6h-4L66.7 21h4.8l2.8 14h.1l2.5-14h3.6l2.4 14h.1l2.7-14h4.8l-5.4 22.6zM47.9 16.8h-4.5v-4.9h4.5v4.9zm0 26.8h-4.5V21h4.5v22.6zm-7.4-18c-.4-.2-.9-.3-1.4-.3-1.9 0-4.6 1.2-4.6 4.9v13.4H30V21h4.5v2.4c1.9-1.6 3.4-2.7 6-2.7v4.9zm77.7 8.4v3.1c0 2.1.8 2.2 2.8 2.2h15.2V10c0-3.3-2.7-6-6-6H16c-3.3 0-6 2.7-6 6v11h9.4v-9.1H24V21h2.8v4.3H24v11.8c0 2.1.8 2.2 2.8 2.2v4.3h-1.9c-4.1 0-5.5-2.9-5.5-5.3v-13H10v25.6c0 3 2.3 5.5 5.2 5.9C29 50 40.1 48.6 51.2 47V21h4.5v2c1.2-1.3 2-2.3 4.3-2.3 1.8 0 3.2.7 4 2.1.5 1 .8 2.4.8 4.8v8.6c0 3.2-.1 4.5-.7 5.5-.8 1.2-1.9 2-4 2-1.8 0-3.2-.8-4.2-2.3h-.1v4.9c26.6-3.3 53.6.1 80.4-.2v-2.6h-17.1c-4.1 0-5.5-2.9-5.5-5.3v-9.6c0-1.8.2-3.4.8-4.6 1.1-2 3.2-3.2 5.9-3.2 4.2 0 6.8 3.1 6.8 7V34h-8.9zm2.2-8.7c-1.4 0-2.2.9-2.2 2.6v2.6h4.4v-2.6c0-1.7-.8-2.6-2.2-2.6zm-62.3 14c1.7 0 2.2-1.2 2.2-2.7v-8.3c0-1.8-.7-3.1-2.2-3.1-1.4 0-2.3 1.2-2.3 2.8v8.8c0 1.5 1 2.5 2.3 2.5zm1.6 9.7c-1.3 0-2.6 0-3.9.1v3.6h-4.5v-3.4c-14 1-25.3 4.3-33.5 7.6h112.4c3.3 0 6-2.7 6-6v-3.8c-13 .9-36.3 2-76.5 1.9z"></path><path fill="#EA1837" d="M15.2 56.8c-3.9 1.9-8.1 4.3-12.5 7.2v1s5.3-4.1 15.1-8.1c8.1-3.3 19.4-6.6 33.5-7.6V47c-11.2 1.6-22.2 3-36.1 9.8z"></path><circle fill="#FFF" cx="130.2" cy="22" r="1.2"></circle><path fill="#FF7B17" d="M130.2 21.1c-.5 0-1 .4-1 1 0 .5.4 1 1 1 .5 0 .9-.4.9-1s-.4-1-.9-1z"></path><path fill="#FFF" d="M130.4 22.7l-.3-.5h-.1v.5h-.2v-1.3h.5c.2 0 .4.2.4.4s-.1.3-.3.3l.3.5h-.3z"></path><path fill="#FF7B17" d="M130.2 21.6h-.2v.4h.2c.1 0 .2-.1.2-.2s0-.2-.2-.2zM55.8 44.4h80.4v5.3H55.8z"></path><path fill="#EA1837" d="M136.2 46.1c-26.8.4-53.8-3.1-80.4.2V49c1.3 0 2.6-.1 3.9-.1 40.2.1 63.5-.9 76.6-1.9 5.7-.4 9.4-.8 11.7-1.1l.4-.3c-4.1.3-8.2.5-12.2.5z"></path><path fill="#FFF" d="M51.3 21h4.5v31.6h-4.5z"></path></svg>

<br>
<h1>Lorem Ipsum</h1>

<h2>Dolor Sit Amet</h2>
<p>Lorem ipsum dolor sit amet, denique imperdiet instructior sed eu, eum sale tantas probatus in, mundi aperiri mea eu. Ut legendos inimicus volutpat eos. Sint justo homero in pro, ne mea soluta dicunt eloquentiam. Illud denique eu his. Aliquip salutandi democritum ne has, eam cu quod accumsan apeirian, vocent appareat invenire vis et.
</p>

<h2>Denique Imperdiet</h2>
<p>Vix ei possit option, sit error liberavisse ad. Quo doctus scripserit efficiantur no, falli fabulas inciderint mea at. An tation utroque sit, enim prompta splendide in cum. Ipsum corpora ea pro. His vidisse accusata ut, at debet zril utamur pri.
</p>

<h2>Instructior Sed Eu</h2>
<p>In tantas nostrud sit, ius ut mollis conceptam. Modo probo vocibus qui at. At summo eripuit nam, tale causae mel id, per augue aliquid in. Putent appellantur sit cu. Pro timeam ceteros copiosae at, pri habemus petentium constituto in, quando persequeris nam ea.
</p>
</body>

</html>'

$indexContent | Set-Content 'c:\inetpub\wwwroot\index.html'

$serverContent = 'You are on server ${count.index + 1}'
$serverContent | Set-Content 'c:\inetpub\wwwroot\server.txt'


  </powershell>
  EOF

  tags {
    Environment = "ENV"
    Location    = "SBX"
    Name        = "SBXENVPLAWEB00${count.index + 1}"
    Role        = "PLA"
    Service     = "WEB"
  }

  root_block_device {
    volume_size = 100
    volume_type = "gp2"
  }

  volume_tags {
    Environment = "ENV"
    Location    = "SBX"
    Name        = "SBXENVPLAWEBVOL00${count.index + 1}"
    Role        = "PLA"
    Service     = "WEB"
    SubService  = "VOL"
  }
}

resource "aws_elb" "load_balancer" {
  name            = "SBXENVPLALB001"
  subnets         = "${var.subnet_ids}"
  security_groups = "${var.securitygroup_ids}"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 443
    instance_protocol  = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:973868890006:certificate/8738c7c4-93b4-4823-8a7c-c858cca62603"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 10
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${aws_instance.webheads.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 3600
  connection_draining         = true
  connection_draining_timeout = 60

  tags {
    Environment = "ENV"
    Location    = "SBX"
    Name        = "SBXENVPLALB001"
    Role        = "PLA"
    Service     = "LB"
  }
}

resource "aws_load_balancer_policy" "lb_policy" {
  load_balancer_name = "${aws_elb.load_balancer.name}"
  policy_name        = "ssl-policy"
  policy_type_name   = "SSLNegotiationPolicyType"

  policy_attribute {
    name  = "Reference-Security-Policy"
    value = "ELBSecurityPolicy-TLS-1-2-2017-01"
  }
}

resource "aws_load_balancer_listener_policy" "lb_listener_policy" {
  load_balancer_name = "${aws_elb.load_balancer.name}"
  load_balancer_port = 443

  policy_names = [
    "${aws_load_balancer_policy.lb_policy.policy_name}",
  ]
}
