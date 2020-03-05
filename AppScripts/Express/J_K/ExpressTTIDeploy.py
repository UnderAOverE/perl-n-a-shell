#!/usr/bin/env jython

#
#
# Version : 1.0.0v
# Tool Name: ExpressTTIDeploy.py
# DoB: 02/25/2020
# Shane Reddy
#
#

# Imports
import sys, time

# Variables
earLocation="/tti/deploy/"
kServer1="tti_WLM_kserver1"
jServer1="tti_WLM_jserver1"
kServer2="tti_WLM_kserver2"
jServer2="tti_WLM_jserver2"
appName="TTIXEar"
kCluster="tti_k_cluster"
jCluster="tti_j_cluster"

# Defs
def nodeSync():
    Nodes = AdminConfig.list('Node').splitlines()
    for Node in Nodes:
        nodeName = AdminConfig.showAttribute(Node, 'name').strip()
        NodeSync = AdminControl.completeObjectName("type=NodeSync,node="+nodeName+",*")
        try:
            _excp_ = 0
            error = AdminControl.invoke(NodeSync, "sync")
        except:
            _type_, _value_, _tbck_ = sys.exc_info()
            error = `_value_`
            _excp_ = 1
        #endTryExcept
        if (_excp_):
            print " WARN| synchronization with node '%s'." %(nodeName)
            print " INFO| make sure that node agent is started for '%s'." %(nodeName)
            print " INFO| DMGR node ???"
        else:
            print " INFO| node '%s' synchronization successfull" %(nodeName)
        #endIfElse
    #endFor
#endDef

def stopCluster(clusterName):
    cluster = AdminControl.completeObjectName('cell='+cellName+',type=Cluster,name='+clusterName+',*')
    State = AdminControl.getAttribute(cluster, 'state')
    loopNumber=0
    if State == "websphere.cluster.stopped":
        print " INFO| '%s' is already stopped." %(clusterName)
    else:
        AdminControl.invoke(cluster, 'stop')
        while 1:
            if loopNumber==10:
                print " ERROR| cluster '%s' is taking longer than usual time to stop!" %(clusterName)
                print " WARN| exiting the program, please engage the Middleware Team."
                sys.exit(1)
            #endIf
            State1 = AdminControl.getAttribute(cluster, 'state')
            if State1 == "websphere.cluster.stopped":
                print " INFO| '%s' stopped." %(clusterName)
                break
            else:
                print " INFO| '%s' stopping..." %(clusterName)
                loopNumber=loopNumber+1
            #endIfElse
            print " INFO| status refresh in 15 seconds..."
            time.sleep(15)
        #endWhile
    #endIfElse
#endDef

def startCluster(clusterName):
    cluster = AdminControl.completeObjectName('cell='+cellName+',type=Cluster,name='+clusterName+',*')
    State = AdminControl.getAttribute(cluster, 'state')
    loopNumber=0
    if State == "websphere.cluster.running":
        print " INFO| '%s' is already started." %(clusterName)
    else:
        AdminControl.invoke(cluster, 'start')
        while 1:
            if loopNumber==10:
                print " ERROR| cluster '%s' is taking longer than usual time to start!" %(clusterName)
                print " WARN| exiting the program, please engage the Middleware Team."
                sys.exit(1)
            #endIf
            State2 = AdminControl.getAttribute(cluster, 'state')
            if State2 == "websphere.cluster.running":
                print " INFO| '%s' started." %(clusterName)
                break;
            else:
                print " INFO| '%s' starting..." %(clusterName)
                loopNumber=loopNumber+1
            #endIfElse
            print " INFO| status refresh in 15 seconds..."
            time.sleep(15)
        #endWhile
    #endIfElse
#endDef

# Main
if len(sys.argv) == 1:
    cellName = AdminControl.getCell()
    Environment = sys.argv[0]
    if Environment == "K":
        print " INFO| starting deployment of '%s' installed on '%s'." %(appName, kCluster)
        earFile=earLocation+"K/ExpressEnterpriseApplication.ear"
        app_exists = AdminControl.completeObjectName('type=Application,name='+appName+',Server='+kServer1+',*')
        if len(app_exists) == 0:
            print " WARN| application '%s' does not exists, installing now..." %(appName)
            stopCluster(kCluster)
            AdminApp.install(earFile, '[-cluster '+kCluster+']')
            AdminConfig.save()
            print " INFO| application '%s' installed on '%s'." %(appName, kCluster)
            print " INFO| waiting 10 seconds to sync nodes..."
            time.sleep(10)
            nodeSync()
            startCluster(kCluster)
        else:
            print " WARN| application '%s' exists, updating the current version now..." %(appName)
            stopCluster(kCluster)
            AdminApp.uninstall(appName)
            AdminConfig.save()
            print " INFO| waiting 10 seconds to sync nodes..."
            time.sleep(10)
            nodeSync()
            AdminApp.install(earFile, '[-cluster '+kCluster+']')
            AdminConfig.save()
            print " INFO| application '%s' installed on '%s'." %(appName, kCluster)
            print " INFO| waiting 10 seconds to sync nodes..."
            time.sleep(10)
            nodeSync()
            startCluster(kCluster)
            print " INFO| deployment of '%s' installed on '%s' completed." %(appName, kCluster)
        #endIfElse
    #endIf
    if Environment == "J":
        print " INFO| starting deployment of '%s' installed on '%s'." %(appName, jCluster)
        earFile=earLocation+"J/ExpressEnterpriseApplication.ear"
        app_exists = AdminControl.completeObjectName('type=Application,name='+appName+',Server='+jServer1+',*')
        if len(app_exists) == 0:
            print " WARN| application '%s' does not exists, installing now..." %(appName)
            stopCluster(jCluster)
            AdminApp.install(earFile, '[-cluster '+jCluster+']')
            AdminConfig.save()
            print " INFO| application '%s' installed on '%s'." %(appName, jCluster)
            print " INFO| waiting 10 seconds to sync nodes..."
            time.sleep(10)
            nodeSync()
            startCluster(jCluster)
        else:
            print " WARN| application '%s' exists, updating the current version now..." %(appName)
            stopCluster(jCluster)
            AdminApp.uninstall(appName)
            AdminConfig.save()
            time.sleep(10)
            AdminApp.install(earFile, '[-cluster '+jCluster+']')
            AdminConfig.save()
            print " INFO| application '%s' installed on '%s'." %(appName, jCluster)
            print " INFO| waiting 10 seconds to sync nodes..."
            time.sleep(10)
            nodeSync()
            startCluster(jCluster)
            print " INFO| deployment of '%s' installed on '%s' completed." %(appName, jCluster)
        #endIfElse
    #endIf
else:
    print " ERROR| Please provide the environment name \"J\" or \"K\"."
    sys.exit(1)
#endIfElse

#end_ExpressTTIDeploy.py