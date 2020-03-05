#env jython

#
#
# name: updateDataSource.py
# author: Shane Reddy
# version: 1.0.0v
# dob: 12/17/2019
# explanation: update the SQL server and port numbers for Express WAS ND envrionment.
# dependencies: wsadmin
# modifications:
#
# contact: shane.reddy@ttiinc.com
#
#
######################################################################################################################

######################################################################################################################
# Initialization.
######################################################################################################################
# Enter the data sources names below that needs to updated by the script.
dataSource_toUpdate=["BDG", "KLSR", "RohsCross"]

# Make sure if your data sources are created at cluster level and mention the cluster name below
clusterName = "TestCluster"

# The port number that needs to be updated, leave it empty string if there are no port numbers defined.
dsPortNumber = ""

# DataSource Server Name below
dsServerName = "TXSQLD10\TXSQLD10"

######################################################################################################################
# Defs.
######################################################################################################################
def _splitlist(s):
    """Given a string of the form [item item item], return a list of strings, one per item.
    WARNING: does not yet work right when an item has spaces.  I believe in that case we'll be
    given a string like '[item1 "item2 with spaces" item3]'.
    """
    if s[0] != '[' or s[-1] != ']':
        raise "Invalid string: %s" % s
    #endIf
    # Remove outer brackets and strip whitespace
    itemstr = s[1:-1].strip()
    if itemstr == '':
        itemarray = []
    else:
        itemarray = itemstr.split(' ')
    #endIfElse
    return itemarray
#endDef

def _splitlines(s):
    rv = [s]
    if '\r' in s:
      rv = s.split('\r\n')
    elif '\n' in s:
      rv = s.split('\n')
    #endIfElif
    if rv[-1] == '':
      rv = rv[:-1]
    #endIf
    return rv
#endDef

def getObjectAttribute(objectid, attributename):
    #sop("getObjectAttribute:","AdminConfig.showAttribute(%s, %s)" % ( repr(objectid), repr(attributename) ))
    result = AdminConfig.showAttribute(objectid, attributename)
    if result != None and result.startswith("[") and result.endswith("]"):
        # List looks like "[value1 value2 value3]"
        result = _splitlist(result)
    #endIf
    return result
#endDef

def setObjectAttributes(objectid, **settings):
    #sop(m,"ENTRY(%s,%s)" % (objectid, repr(settings)))
    attrlist = []
    for key in settings.keys():
        #sop(m,"Setting %s=%s" % (key,settings[key]))
        attrlist.append( [ key, settings[key] ] )
    #endFor
    #sop(m,"Calling AdminConfig.modify(%s,%s)" % (repr(objectid),repr(attrlist)))
    AdminConfig.modify(objectid, attrlist)
#endDef

def getObjectsOfType(typename, scope = None):
    if scope:
        #sop(m, "AdminConfig.list(%s, %s)" % ( repr(typename), repr(scope) ) )
        return _splitlines(AdminConfig.list(typename, scope))
    else:
        #sop(m, "AdminConfig.list(%s)" % ( repr(typename) ) )
        return _splitlines(AdminConfig.list(typename))
    #endIfElse
#endDef

def getCfgItemId (scope, clusterName, nodeName, serverName, objectType, item):
    if (scope == "cell"):
        cellName = getCellName()
        cfgItemId = AdminConfig.getid("/Cell:"+cellName+"/"+objectType+":"+item)
    elif (scope == "node"):
        cfgItemId = AdminConfig.getid("/Node:"+nodeName+"/"+objectType+":"+item)
    elif (scope == "cluster"):
        cfgItemId = AdminConfig.getid("/ServerCluster:"+clusterName+"/"+objectType+":"+item)
    elif (scope == "server"):
        cfgItemId = AdminConfig.getid("/Node:"+nodeName+"/Server:"+serverName+"/"+objectType+":"+item)
    #endIfElif
    return cfgItemId
#endDef

def isDefined(varname):
    try:
        x = eval(varname)
        return 1
    except NameError:
        return 0
    #endTryExcept
#endDef

def getCellName():
    cellObjects = getObjectsOfType('Cell')  # should only be one
    cellname = getObjectAttribute(cellObjects[0], 'name')
    return cellname
#endDef

def getNodeId( nodename ):
    """Given a node name, get its config ID"""
    return AdminConfig.getid( '/Cell:%s/Node:%s/' % ( getCellName(), nodename ) )
#endDef

def getNodeIdWithCellId ( cellname, nodename ):
     """Given a cell name and node name, get its config ID"""
     return AdminConfig.getid( '/Cell:%s/Node:%s/' % ( cellname, nodename ) )
#endDef

def nodeIsDmgr( nodename ):
    """Return true if the node is the deployment manager"""
    return nodeHasServerOfType( nodename, 'DEPLOYMENT_MANAGER' )
#endDef

def nodeIsUnmanaged( nodename ):
    """Return true if the node is an unmanaged node."""
    return not nodeHasServerOfType( nodename, 'NODE_AGENT' )
#endDef

def nodeHasServerOfType( nodename, servertype ):
    node_id = getNodeId(nodename)
    serverEntries = _splitlines(AdminConfig.list( 'ServerEntry', node_id ))
    for serverEntry in serverEntries:
        sType = AdminConfig.showAttribute( serverEntry, "serverType" )
        if sType == servertype:
            return 1
        #endIf
    #endFor
    return 0
#endDef

def getNodeName(node_id):
    """Get the name of the node with the given config object ID"""
    return getObjectAttribute(node_id, 'name')
#endDef

def listNodes():
    node_ids = _splitlines(AdminConfig.list( 'Node' ))
    result = []
    for node_id in node_ids:
        nodename = getNodeName(node_id)
        if not nodeIsDmgr(nodename):
            result.append(nodename)
        #endIf
    #endFor
    if 0 == len(result):
        print "Warning. No non-manager nodes are defined!!!"
    #endIf
    return result
#endDef

def syncall():
    if whatEnv() == 'base':
        print "WebSphere Base, not syncing!"
        return 0
    #endIf
    returncode = 0
    nodenames = listNodes()
    for nodename in nodenames:
        # Note: listNodes() doesn't include the dmgr node - if it did, we'd
        # have to skip it
        # We do, however, have to skip unmanaged nodes.  These will show up
        # when there is a web server defined on a remote machine.
        if not nodeIsDmgr( nodename ) and not nodeIsUnmanaged( nodename ):
            print "Sync config to node %s" %(nodename)
            Sync1 = AdminControl.completeObjectName( "type=NodeSync,node=%s,*" % nodename )
            if Sync1:
                rc = AdminControl.invoke( Sync1, 'sync' )
                if rc != 'true':  # failed
                    print "Sync of node [%s] FAILED!" %(nodename)
                    returncode = 1
                else:
                    print "Sync of node [%s] completed!" %(nodename)
                #endIfElse
            else:
                print "WARNING: was unable to get sync object for node [%s] - is node agent running?" %(nodename)
                returncode = 2
            #endIfElse
        #endIf
    if returncode != 0:
        print "Syncall FAILED!"
    #endIf
    print "Syncall completed successfully!"
    return returncode
#endDef

######################################################################################################################
# Main.
######################################################################################################################
cellName = AdminControl.getCell()
dataSources = AdminConfig.list("DataSource", AdminConfig.getid( "/Cell:"+cellName+"/ServerCluster:"+clusterName+"/")).splitlines()
#dataSources = AdminConfig.list("DataSource", AdminConfig.getid( "/Cell:"+cellName+"/Server:server1/")).splitlines()
changesMade=0
for dataSource in dataSources:
    dsName = AdminConfig.showAttribute(dataSource, "name")
    for dsUpdateName in dataSource_toUpdate:
        if dsUpdateName == dsName:
            dsProperties = AdminConfig.list('J2EEResourceProperty', dataSource)
            lProperties = AdminUtilities.convertToList(dsProperties)
            propSet = AdminConfig.list("J2EEResourcePropertySet", dataSource)
            for prop in AdminConfig.list("J2EEResourceProperty", propSet).splitlines():
                if (AdminConfig.showAttribute(prop, "name") == 'portNumber'):
                    if (AdminConfig.showAttribute(prop, "value") == dsPortNumber):
                        print "Property= 'portNumber' is already set to "+dsPortNumber+" for DataSource= "+dsName
                    else:
                        AdminConfig.modify(prop, [["value", dsPortNumber]])
                        print "Property= 'portNumber' updated to "+dsPortNumber+" for DataSource= "+dsName
                        changesMade=1
                    #endIfElse
                #endIf
                if (AdminConfig.showAttribute(prop, "name") == 'serverName'):
                    if (AdminConfig.showAttribute(prop, "value") == dsServerName):
                        print "Property= 'serverName' is already set to "+dsServerName+" for DataSource= "+dsName
                    else:
                        AdminConfig.modify(prop, [["value", dsServerName]])
                        print "Property= 'serverName' updated to "+dsServerName+" for DataSource= "+dsName
                        changesMade=1
                    #endIfElse
                #endIf
            #endFor
    #endFor
#endFor

# Call the node synchronization across all the nodes.
if changesMade:
    AdminConfig.save()
    syncall()
else:
    print "No changes were made to the master configuration."
    print "No sync and save operations are performed."
#endIfElse

#end_updateDataSource.py