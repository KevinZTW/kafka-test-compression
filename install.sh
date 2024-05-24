WORK_DIR=~/kafka-experiment
if [ ! -d "$WORK_DIR" ]; then
    mkdir -p "$WORK_DIR"
fi

# git clone astrea
cd $WORK_DIR
git clone git@github.com:skiptests/astraea.git
