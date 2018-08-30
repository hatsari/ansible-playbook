# ansible로 Vdbench 성능 테스트
Date: 2018. 08. 27

디스크 I/O 성능을 테스트할 때 많이 사용하는 프로그램이 vdbench 입니다. 하지만 여러 호스트들에 한번에 벤치마크 테스트를 수행해야할 때 ansible 을 이용하면 편할것으로 생각하여 이를 테스트하고 이 문서를 만들게 되었습니다. 
여러 서버에서 vdbench를 실행하는 기능이 vdbench 자체적으로 내장하고 있어, 이를 활용하여 기능 구현.
  - [vdbencn download](https://www.oracle.com/technetwork/server-storage/vdbench-downloads-1901681.html)

## 사전준비사항
- ssh connection w/o root passwd
- mount filesystem to /mnt

## vdbench 기본 사용법
```
vdbench -f _vdconfig_ -o result
```

##  설정파일 설명
vdbench는 설정 파일을 기반으로 작업을 수행합니다. 그러므로 이 설정파일(or script)을 어떻게 만드느냐가 원하는 벤치마크 테스트를 수행하는 관건입니다. 
### 단독 노드에서 실행할 때 설정 파일

```
cat $ vdbencn-standalone.conf

host=default,user=root,shell=bash,vdbench=./

fsd=fsd1,anchor=./local-test/a,depth=2,width=10,file=10,size=4KB
fsd=fsd2,anchor=/mnt/block-test/a,depth=2,width=10,file=10,size=4KB

fwd=fwd1,fsd=fsd1,operation=create,fileio=sequential,threads=1
fwd=fwd2,fsd=fsd2,operation=create,fileio=sequential,threads=1
fwd=fwd3,fsd=fsd1,operation=read,fileio=sequential,threads=1
fwd=fwd4,fsd=fsd1,operation=write,fileio=sequential,threads=1
fwd=fwd5,fsd=fsd2,operation=read,fileio=sequential,threads=1
fwd=fwd6,fsd=fsd2,operation=write,fileio=sequential,threads=1

rd=rd1,fwd=(fwd1,fwd2),fwdrate=max,format=yes,interval=1
rd=rd2,fwd=(fwd3,fwd4),fwdrate=max,format=no,interval=1,elapsed=30
rd=rd3,fwd=(fwd5,fwd6),fwdrate=max,format=no,interval=1,elapsed=30

#// SD: Storage Definition
#// WD: Workload Definition
#// RD: Run Definition
```

- host: 벤치마크 테스트가 진행될 노드
- fsd: 파일시스템, LUN 등 벤치마크 대상 파일 시스템 또는 스토리지블록(파일시스템 테스트시에는 사전에 mount 를 읽지 마세요)
- fwd: 실행될 작업 정의, create: 테스트를 위한 임시 파일 생성 작업, read: 읽기 작업, write: 쓰기 작업
- rd: 실제 테스트 수행 

### vdbench.conf template
```
[root@ansible-tower vdbench]# cat templates/vdbench.conf.j2


hd=default,user=root,shell=ssh,vdbench={{ vd_exec_path }}
{% for host in ansible_play_hosts %}
hd={{ host }}, system={{ host }}
{% endfor %}

fsd=fsd0,anchor={{ anchor_dir }},depth=2,width=10,file=10,size=1MB

# fwd to create test files
{% for host,num in ansible_play_hosts|zip(range(ansible_play_hosts|length)) %}
fwd=fwd{{ num }},host={{ host }},fsd=fsd0,operation=create,xfersize=256k,fileio=sequential,threads=1
{% endfor %}

# fwd to read and write operation
{% for host,num in ansible_play_hosts|zip(range(ansible_play_hosts|length, ansible_play_hosts|length*3,2)) %}
fwd=fwd{{ num + 0 }},host={{ host }},fsd=fsd0,operation=read,xfersize=256k,fileio=sequential,threads=1
fwd=fwd{{ num + 1 }},host={{ host }},fsd=fsd0,operation=write,xfersize=256k,fileio=sequential,threads=1
{% endfor %}

# job to create test environment on each nodes
rd=rd0,fwd=({% for num in range(ansible_play_hosts|length) %}fwd{{num}},{% endfor %}),fwdrate=max,format=yes,interval=1

# job to read and write operation on each nodes
{% for num3 in range(ansible_play_hosts|length, ansible_play_hosts|length*3) %}
rd=rd{{ num3 }},fwd=(fwd{{ num3 }}),fwdrate=max,format=no,interval=1,elapsed=10
{% endfor %}
```


#### ansible이 이용할 vdbench 설정파일 template 설명
[vdbench_template](templates/vdbench.conf.j2)

### vdbench.conf generated from template
```
hd=default,user=root,shell=ssh,vdbench=/root/vdbench/vdbench50407/
hd=172.28.128.3, system=172.28.128.3
hd=172.28.128.4, system=172.28.128.4

fsd=fsd0,anchor=/mnt/iotest/a,depth=2,width=10,file=10,size=1MB

# fwd to create test files
fwd=fwd0,host=172.28.128.3,fsd=fsd0,operation=create,xfersize=256k,fileio=sequential,threads=1
fwd=fwd1,host=172.28.128.4,fsd=fsd0,operation=create,xfersize=256k,fileio=sequential,threads=1

# fwd to read and write operation
fwd=fwd2,host=172.28.128.3,fsd=fsd0,operation=read,xfersize=256k,fileio=sequential,threads=1
fwd=fwd3,host=172.28.128.3,fsd=fsd0,operation=write,xfersize=256k,fileio=sequential,threads=1
fwd=fwd4,host=172.28.128.4,fsd=fsd0,operation=read,xfersize=256k,fileio=sequential,threads=1
fwd=fwd5,host=172.28.128.4,fsd=fsd0,operation=write,xfersize=256k,fileio=sequential,threads=1

# job to create test environment on each nodes
rd=rd0,fwd=(fwd0,fwd1,),fwdrate=max,format=yes,interval=1

# job to read and write operation on each nodes
rd=rd2,fwd=(fwd2),fwdrate=max,format=no,interval=1,elapsed=10
rd=rd3,fwd=(fwd3),fwdrate=max,format=no,interval=1,elapsed=10
rd=rd4,fwd=(fwd4),fwdrate=max,format=no,interval=1,elapsed=10
rd=rd5,fwd=(fwd5),fwdrate=max,format=no,interval=1,elapsed=10
```

## ansible로 vdbench 실행
```
echo "192.168.1.100_테스트대상IP" >> ./hosts
ansible-playbook -i hosts vdbench-auto.yaml
```

## 실형 결과 분석 방법
### IOPS & Throughput 결과
![vdbench result](images/vdbench-result.png]

RD 작업에서 read 를 수행했으며, 
- 평균 IOPS: 1606.0, 
- 평균 Throughput: 371.0 mb/sec

RD-2 작업에서 write 수행
- 평균 write IOPS: 1334.3
- 평균 write Throughput: 333.4 mb/sec

## issue:
if vdbench's master node has multiple ip address, it could cause connection issue.
vdbench의 master ip 설정에 따라 connection 이슈 발생 
