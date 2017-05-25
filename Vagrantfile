# -*- mode: ruby -*-
# vi: set ft=ruby :

script_provisionInstallBase = <<SCRIPT
	apt-get update
	apt-get install -y build-essential libpcre3 libpcre3-dev libssl-dev software-properties-common devscripts unzip wget diffutils || { echo ERROR; exit 1; }
	apt-get build-dep -y nginx || { echo ERROR; exit 1; }
SCRIPT

script_provisionInstallNginx = <<SCRIPT
	mkdir -p /usr/nginx-build
	cd /usr/nginx-build
	wget http://nginx.org/download/nginx-1.12.0.tar.gz
	wget https://github.com/arut/nginx-rtmp-module/archive/v1.1.11.tar.gz
	tar -zxvf nginx-1.12.0.tar.gz || { echo ERROR; exit 1; }
	tar -zxvf v1.1.11.tar.gz || { echo ERROR; exit 1; }
	cd nginx-1.12.0
	./configure --with-http_ssl_module --with-http_stub_status_module --with-http_secure_link_module --with-http_flv_module --with-http_mp4_module --add-module=../nginx-rtmp-module-1.1.11 || { echo ERROR; exit 1; }
	make
	make install || { echo ERROR; exit 1; }
	# pull init
	wget https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx
	chmod +x /etc/init.d/nginx
	update-rc.d nginx defaults
	#Start and stop Nginx to generate configuration files
	service nginx start
	service nginx stop
	service nginx start
SCRIPT

script_provisionInstallFfmpeg = <<SCRIPT
	if [ ! -f "/etc/apt/sources.list.d/backports.list" ]; then
		echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/backports.list
	fi
	apt-get update
	apt-get install -y ffmpeg || { echo ERROR; exit 1; }
SCRIPT

script_provisionInstallFlowplayer = <<SCRIPT
	mkdir -p /usr/flowplayer-build
	cd /usr/flowplayer-build
	if [ ! -f "flowplayer-3.2.18.zip" ] || [ ! -d "flowplayer" ] ; then
		wget http://releases.flowplayer.org/flowplayer/flowplayer-3.2.18.zip && \
		unzip flowplayer-3.2.18.zip
	fi
	if [ ! -f "flowplayer/flowplayer.rtmp-3.2.13.swf" ]; then
		cd flowplayer && \
		wget http://releases.flowplayer.org/flowplayer.rtmp/flowplayer.rtmp-3.2.13.swf && \
		cd ..
	fi
	cp -pr flowplayer /usr/local/nginx/html/ || { echo ERROR; exit 1; }
SCRIPT

script_nginxReconfigure = <<SCRIPT
	
	twitch_streamserver=$1
	twitch_streamkey=$2
	
	encoding_preset=${3-medium}
	encoding_framerate=${4-30}
	encoding_kilobitrate=${5-2000}
	encoding_kilobuffer=${6-2000}
	encoding_threads=${7-6}
	encoding_resolution=${8}
	encoding_scaler=${9}
	
	livepush_replacement="#NOT_CONFIGURED"
	if [ "x$twitch_streamserver" != "x" ] && [ "x$twitch_streamkey" != "x" ]; then
		livepush_replacement="push ${twitch_streamserver}/${twitch_streamkey};"
	fi
	sed -i -e "s~#MARKER-LIVEPUSH-REPLACEMENT#~$livepush_replacement~g" /tmp/vagrantprovisioner/nginx/conf/nginx.conf
	
	encoding_keyframes=$(($encoding_framerate*2))
	if [ "x$encoding_resolution" != "x" ]; then
		encoding_resolution="-s ${encoding_resolution}"
	fi
	if [ "x$encoding_scaler" != "x" ]; then
		encoding_scaler="-sws_flags ${encoding_scaler}"
	fi
	encoding_replacement="-vcodec libx264 -preset ${encoding_preset} -x264opts nal-hrd=cbr:force-cfr=1:keyint=${encoding_keyframes} -r ${encoding_framerate} -b:v ${encoding_kilobitrate}k -maxrate ${encoding_kilobitrate}k -bufsize ${encoding_kilobuffer}k -threads ${encoding_threads} ${encoding_resolution} ${encoding_scaler} -acodec copy -f flv"
	sed -i -e "s~#MARKER-ENCODING-REPLACEMENT#~$encoding_replacement~g" /tmp/vagrantprovisioner/nginx/conf/nginx.conf
	
	
	diff /usr/local/nginx/conf/nginx.conf /tmp/vagrantprovisioner/nginx/conf/nginx.conf
	if [ $? -eq 0 ]; then
		echo "NO CHANGES MADE"
		exit 0
	else
		echo "Found changes, check+apply..."
	fi
	cp -p /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.vgprovbak && \
	cp /tmp/vagrantprovisioner/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf && service nginx restart && echo SUCCESS || { 
		echo ERROR
		systemctl status nginx.service
		cp -p /usr/local/nginx/conf/nginx.conf.vgprovbak /usr/local/nginx/conf/nginx.conf
		service nginx restart
		exit 1
	}
SCRIPT

script_getDetails = <<SCRIPT
	ipfull=$(ip addr show dev eth1 | grep 'inet ' | awk '{print $2}')
	iponly=${ipfull%%/*}
	echo ""
	echo ""
	echo "Serving on: $iponly"
	echo ""
	echo "Stream to: rtmp://${iponly}:1935/transcode"
	echo "Using Key: \"live\" will actually stream to Twitch"
	echo "Using Key: \"test\" will allow you to check the transcoded stream with VLCPlayer"
	echo ""
	echo "To watch the test stream open: http://${iponly}/streams.html"
	echo ""
	echo ""
	echo "You can run GET_DETAILS to view this information."
	echo ""
	echo ""
SCRIPT

script_getPerformance = <<SCRIPT
	echo ""
	echo ""
	echo "Top 10 - CPU"
	ps -eo pcpu,pid,user,args | sort -r -k1 | head -n 10
	echo ""
	echo ""
	echo "CPU loadavg"
	cat /proc/loadavg
	echo ""
	echo ""
	echo "Memory"
	free -m
	echo ""
	echo ""
SCRIPT

script_getLogs = <<SCRIPT
	echo ""
	echo ""
	tail -n 20 /usr/local/nginx/logs/*.log
	echo ""
	echo ""
SCRIPT



require 'yaml'
if File.file?("vagrant.defaults.yml")
	settings = YAML.load_file 'vagrant.defaults.yml'
else
	print "ERROR Could not find vagrant.defaults.yml\r\n"
	exit 100
end

if File.file?("vagrant.local.yml")
	localSettings = YAML.load_file 'vagrant.local.yml'
	settings.merge!(localSettings)
end



# All Vagrant configuration is done below.
Vagrant.configure(2) do |config|
	config.vm.box = "debian/jessie64"
	#config.vm.box = "driebit/debian-8-x86_64"
	
	## debian/jessie64 has no guesttools - in case, driebit/debian-8-x86_64 is a good alternative.
	config.vm.synced_folder ".", "/vagrant", disabled: true
	
	config.vm.hostname = "tab-streambox"
	
	if defined?(settings['public_network']) && settings['public_network']
		config.vm.network "public_network", \
			ip: (defined?(settings['public_network_ip']) && ! settings['public_network_ip'].to_s.empty?)?settings['public_network_ip']:nil, \
			bridge: (defined?(settings['public_network_bridge']) && ! settings['public_network_bridge'].to_s.empty?)?settings['public_network_bridge']:nil
	end
	
	config.vm.provider "virtualbox" do |vb|
		if defined?(settings['vmopt_memory']) && ! settings['vmopt_memory'].to_s.empty?
			vb.memory = settings['vmopt_memory']
		end
		if defined?(settings['vmopt_cpus']) && ! settings['vmopt_cpus'].to_s.empty?
			vb.cpus = settings['vmopt_cpus']
		end
	end
	
	## this breaks 'vagrant ssh -c ""' - but thats okay for us...
	config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
	
	
	config.vm.provision "install_base", type: "shell", :inline => script_provisionInstallBase
	config.vm.provision "install_nginx", type: "shell", :inline => script_provisionInstallNginx
	config.vm.provision "install_ffmpeg", type: "shell", :inline => script_provisionInstallFfmpeg
	config.vm.provision "install_flowplayer", type: "shell", :inline => script_provisionInstallFlowplayer
	
	config.vm.provision "nginx_config_main", type: "file", run: "always", source: "./nginx/nginx.conf", destination: "/tmp/vagrantprovisioner/nginx/conf/nginx.conf"
	config.vm.provision "nginx_config_apply", type: "shell", run: "always", :inline => script_nginxReconfigure, :args => [
		(defined?(settings['twitch_streamserver']) && ! settings['twitch_streamserver'].to_s.empty?)?settings['twitch_streamserver']:"",
		(defined?(settings['twitch_streamkey']) && ! settings['twitch_streamkey'].to_s.empty?)?settings['twitch_streamkey']:"",
		(defined?(settings['encoding_preset']) && ! settings['encoding_preset'].to_s.empty?)?settings['encoding_preset']:"medium",
		(defined?(settings['encoding_framerate']) && ! settings['encoding_framerate'].to_s.empty?)?settings['encoding_framerate']:30,
		(defined?(settings['encoding_kilobitrate']) && ! settings['encoding_kilobitrate'].to_s.empty?)?settings['encoding_kilobitrate']:2000,
		(defined?(settings['encoding_kilobuffer']) && ! settings['encoding_kilobuffer'].to_s.empty?)?settings['encoding_kilobuffer']:2000,
		(defined?(settings['encoding_threads']) && ! settings['encoding_threads'].to_s.empty?)?settings['encoding_threads']:6,
		(defined?(settings['encoding_resolution']) && ! settings['encoding_resolution'].to_s.empty?)?settings['encoding_resolution']:"",
		(defined?(settings['encoding_scaler']) && ! settings['encoding_scaler'].to_s.empty?)?settings['encoding_scaler']:""
	]
	
	
	config.vm.provision "htmlcontent_flowplayer", type: "file", run: "always", source: "./html/streams.html", destination: "/tmp/vagrantprovisioner/html/streams.html"
	config.vm.provision "htmlcontent_apply", type: "shell", run: "always", inline: "cp -pr /tmp/vagrantprovisioner/html/* /usr/local/nginx/html/"
	
	
	config.vm.provision "get_details_autorun", type: "shell", run: "always", :inline => script_getDetails
	
	## run: "never", is broken - https://github.com/mitchellh/vagrant/issues/8016
	if ARGV.include? '--provision-with' || ( (ARGV.include? 'provision') && (ARGV[1].include? '--provision-with=') )
		config.vm.provision "get_details", type: "shell", run: "never", :inline => script_getDetails
		config.vm.provision "get_performance", type: "shell", run: "never", :inline => script_getPerformance
		config.vm.provision "get_logs", type: "shell", run: "never", :inline => script_getLogs
	end
end
