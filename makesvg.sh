export PATH=/home/isucon/bin/FlameGraph:$PATH
go-torch -b $PPORF_DIR/cpu.pprof -f $PPORF_DIR/prof.svg
