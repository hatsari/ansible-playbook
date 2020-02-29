#! /bin/sh
#
# pre-requsite.sh
# Copyright (C) 2017 ykim <ykim@KimYongKis-MacBook-Pro-2.local>
#
# Distributed under terms of the MIT license.
#


mkdir ~/bin
wget http://www.opentlc.com/download/ansible_bootcamp/scripts/common.sh
wget http://www.opentlc.com/download/ansible_bootcamp/scripts/order_svc.sh
wget http://www.opentlc.com/download/ansible_bootcamp/scripts/jq-linux64 -O ~/bin/jq
chmod +x order_svc.sh ~/bin/jq
