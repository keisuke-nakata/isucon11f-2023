export PATH=/home/isucon/bin/FlameGraph:$PATH
go tool pprof -http=":8081" result/20231029-060647_6c5290da549609d179418cdf9b6e6512ae982a3b/appserver1/profile/cpu.pprof
