
async = require 'async'

query = (graph) ->
	list = []

	nodes = {}

	return {
		node: (id) ->
			list.push (cb) ->
				nodes = {id: graph.getNode(id)}
				cb()
			return this
		getChildren: (type) ->
			list.push (cb) ->
				type = graph.getType(type)
				allChildren = []
				for key, node of nodes
					allChildren = allChildren.concat graph.getChildren(node)
				filteredChildren = {}
				for node in allChildren
					if node.type == type
						filteredChildren[node.id] = node
				nodes = filteredChildren
				cb()
			return this

		getParents: (type) ->
			list.push (cb) ->
				type = graph.getType(type)
				allParents = []
				for key, node of nodes
					allParents = allParents.concat graph.getParents(node)
				filteredParents = {}
				for node in allParents
					if node.type == type
						filteredParents[node.id] = node
				nodes = filteredParents
				cb()
			return this

		filter: (fun) ->
			list.push (cb) ->
				newNodes = {}
				arr = (key for key, val of nodes)
				async.each(arr, (nodeID, asyncCB) ->
					q = new query(graph)
					q.node(nodeID)
					fun(q, (success) ->
						if !success
							delete nodes[nodeID]
						asyncCB()
					)
				, cb)
			return this

		evaluate: (cb) ->
			async.series(list, () ->

				cb(nodes)
			)

		getValues: (cb) ->
			async.series(list, () ->

				cb((val.value for key, val of nodes))
			)

		getValue: (cb) ->
			this.getValues (values) ->
				cb(values[0])

	}


module.exports = query