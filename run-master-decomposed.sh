
export PATH=$PATH:$VDS_HOME/bin
export CLASSPATH=
export GLOBUS_TCP_PORT_RANGE=50000,51000

echo "running decomposed GJ"
swift -tc.file swift.conf/tc.data -sites.file swift.conf/sites.xml gj-master-decomposed.swift
