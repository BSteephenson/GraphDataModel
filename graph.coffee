
Query = require './query'

Graph = ->
	# todo
	types = {}
	nodes = []
	connections = {}
	invertedConnections = {}

	return {

		createNode: (type, val) ->
			if !types[type] 
				types[type] = Object.keys(types).length
			
			typeID = types[type]
			index = nodes.length
			node = {id:index, type: typeID, value: val}
			nodes.push(node)
			return node
		createConnection: (parentNode, childNode) ->
			if !connections[parentNode.id] 
				connections[parentNode.id] = Array()
			
			connections[parentNode.id].push(childNode.id)

			if !invertedConnections[childNode.id] 
				invertedConnections[childNode.id] = Array()
			
			invertedConnections[childNode.id].push(parentNode.id)
		
		getNode: (id) -> nodes[id]

		getType: (type) -> types[type]

		getChildren: (parentNode) ->
			children = []
			indices = connections[parentNode.id]
			if indices
				for i in indices
					children.push nodes[i]
				return children
			else
				return []
		getParents: (childNode) ->
			parents = []
			indices = invertedConnections[childNode.id]
			if indices
				for i in indices
					parents.push nodes[i]
				return parents
			else
				return []


		removeConnection: (parentNode, childNode) ->
			# todo
		query: ->
			return new Query(this)
	}


module.exports = Graph





