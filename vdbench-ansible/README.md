# ansible로 Vdbench 성능 테스트
Date: 2018. 08. 27

디스크 I/O 성능을 테스트할 때 많이 사용하는 프로그램이 vdbench 입니다. 하지만 여러 호스트들에 한번에 벤치마크 테스트를 수행해야할 때 ansible 을 이용하면 편할것으로 생각하여 이를 테스트하고 이 문서를 만들게 되었습니다. 
여러 서버에서 vdbench를 실행하는 기능이 vdbench 자체적으로 내장하고 있어, 이를 활용하여 기능 구현.
  - [vdbencn download](https://www.oracle.com/technetwork/server-storage/vdbench-downloads-1901681.html)

## 사전준비사항
- ssh connection w/o root passwd

## vdbench 기본 사용법

## ansible로 vdbench 설정파일 template 설명
[vdbench_template](templates/vdbench.conf.j2)
### 기본 설정파일 설명

## ansible로 vdbench 실행
```
echo "192.168.1.100_테스트대상IP" >> ./hosts
ansible-playbook -i hosts vdbench-auto.yaml
```

## 실형 결과 분석 방법
### IOPS 결과
### Throughput 결과


##issue:
vdbench의 master ip 설정에 따라 connection 이슈 발생 
