. install-cluster.sh
if [ $? -ne 0 ]; then return 1; fi

. install-project.sh
if [ $? -ne 0 ]; then return 1; fi

. install-app.sh
if [ $? -ne 0 ]; then return 1; fi

[ -d route ] \
    && (cd route &&  ./install.sh)
if [ $? -ne 0 ]; then return 1; fi
