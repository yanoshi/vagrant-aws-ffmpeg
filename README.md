# vagrant-aws-ffmpeg
Easy setup ffmpeg encoder to AWS using vagrant

## Requirements
- [Vagrant](https://www.vagrantup.com/) `>=2.0`
- [vagrant-aws](https://github.com/mitchellh/vagrant-aws)
  - install command: `vagrant plugin install vagrant-aws`
- [dotenv](https://github.com/bkeepers/dotenv)
  - install command: `vagrant plugin install dotenv`
- [vagrant-rsync-back](https://github.com/smerrill/vagrant-rsync-back)
  - install command: `vagrant plugin install vagrant-rsync-back`
- rsync

## Getting started
Please make `.env` file with reference to `.env.example`

```
echo EOF > .env
# EC2 Auth Config
EC2_ACCESS_KEY_ID="AAAAAAAAAAAAAA"
EC2_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxx"
EC2_KEYPAIR="foo"
SSH_KEY_PATH="~/.ssh/foo.pem)"

# VM Config(no need to be changed)
EC2_REGION="us-west-2" # US West Oregon
EC2_INSTANCE_TYPE="c4.8xlarge"
EC2_AMI="ami-01ed306a12b7d1c96" # CentOS 7
EC2_USERNAME="centos"
EOF
```

Note:
If you don't change `Vagrantfile` about Security Group, it is connected default VPC and default Security Group.
So if not accept ssh connection in your default Security Group, it does not work properly.


## Usage
### Quick start
If you want to encode easily, please run this command:

```
./easy_encode.sh
```

This will start the instance and encode `input/*.mp4` to `output/*.mp4` using ffmpeg(libx264), then destroy the instance.

Note: if you want change encode config, please edit `easy_encode.sh`.

### Start the instance
You can start instance at AWS(us-west-2) with just one line of command:
```
vagrant up
```

### Connect to inscance
You can connect instance using ssh:
```
vagrant ssh
```

### Sync folder
If you want sync files, please run those commands.

Host:`./sync_folder/*` -> AWS:`/sync_folder` :
```
vagrant rsync
```

AWS:`./sync_folder/*` -> Host:`/sync_folder` :
```
vagrant rsync-back
```

WARN: It is the sync. So it might erase your data. (Use at your own risk.)

### Example
#### case1: AV1 Encode
When this command run, you can encode using av1 encoder(libaom).
( `sync_folder/test_input.mp4` -> `sync_folder/test_output.mp4` )

```
vagrant rsync \
&& vagrant ssh -- -t \
'ffmpeg \\
  -i /sync_folder/test_input.mp4 \\
  -c:v libaom-av1 \\
  -strict experimental \\
  -row-mt 1 \\
  -cpu-used 1 \\
  -crf 30 \\
  -b:v 2000k \\
  -c:a libopus \\
  -ac 2 \\
  -ar 48000 \\
  -b:a 128k \\
  /sync_folder/test_output.mp4' \
&& vagrant rsync-back
```

#### case2: x264 Encode

When this command run, you can encode using x264 encoder(libx264).
( `sync_folder/test_input.mp4` -> `sync_folder/test_output.mp4` )

```
vagrant rsync \
&& vagrant ssh -- -t \
'ffmpeg -i "/sync_folder/test_input.mp4" \\
  -crf 30 \\
  -c:v libx264 \\
  -b:v 2000k \\
  -profile:v main \\
  -preset:v veryfast \\
  -c:a libmp3lame \\
  -b:a 128k \\
  -ac 2 \\
  -ar 48000 \\
  "/sync_folder/test_output.mp4"' \
&& vagrant rsync-back
```

#### case3: VP9 Encode

When this command run, you can encode using VP9 encoder(libvpx).
( `sync_folder/test_input.mp4` -> `sync_folder/test_output.mp4` )

```
vagrant rsync \
&& vagrant ssh -- -t \
'ffmpeg -i "/sync_folder/test_input.mp4" \\
  -crf 30 \\
  -strict -2 \\
  -c:v libvpx-vp9 \\
  -b:v 2000k \\
  -c:a libopus \\
  -b:a 128k \\
  -ac 2 \\
  -ar 48000 \\
  "/sync_folder/test_output.mp4"' \
&& vagrant rsync-back
```

### Destroy the instance
```
vagrant destroy
```

Note: 
When run this command, it does not delete the storage(EBS). If you want delete the storage(EBS), please delete that at AWS Console yourself.

## Enable nofree mode
Please change `FREE_FLAG` in `Vagrantfile` (Ln: 30)

```
...
          shell.inline = <<-SHELL
            export FREE_FLAG=FALSE

            yum -y install \
...
```

WARN: Please set after understanding the license about ffmpeg.
After `vagrant up`, you can check ffmpeg configured result(license) by `/sync_folder/ffmpeg_cofigure.txt`@AWS .
