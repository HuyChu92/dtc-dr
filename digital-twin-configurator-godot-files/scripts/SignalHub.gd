extends Node


#Signaal dat in raster-main wordt meegegeven aan een nieuwe graph-node
signal NewSendNodeName(NewSendNodeName)
signal NewReceiveNodeName(NewReceiveNodeName)

#Signaal dat de boolean van het ComponentMenu behandelt.
signal ComponentMenuStatus(ComponentMenuVisBool, sender_node_name)

#NodeInformatie 
signal NodeInformation(sender_node_name, ApiInput, rawApiData)

#dict van de nodeinformation
signal nodeInformationDict(nodeInformationDict)

#Connection Line registratie
signal ConnectionLine(from, from_slot, to, to_slot)

#dict van alle connecties
signal connectionDict(connectionDict)
