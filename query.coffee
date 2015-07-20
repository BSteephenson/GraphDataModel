
async = require 'async'

query = (graph) ->
	list = []

	nodes = {}

	currentType = undefined

	return {
		node: (id) ->
			list.push (cb) ->
				nodes = {id: graph.getNode(id)}
				cb()
			return this
		
		traverse: (type) ->
			list.push (cb) ->
				nodes = graph.traverse(nodes, type)
				cb()
			return this

		filter: (fun) ->
			list.push (cb) ->
				newNodes = {}
				arr = (key for key, val of nodes)
				async.each(arr, (nodeID, asyncCB) ->
					fun(nodes[nodeID], (success) ->
						if !success
							delete nodes[nodeID]
						asyncCB()
					)
				, cb)
			return this

		perform: (cb) ->
			async.series(list, () ->
				cb()
			)

		first: (fun) ->
			list.push (cb) ->
				node = (val for key, val of nodes)[0]
				q = new query(graph)
				q.node(node.id)
				q = fun(node, q)
				if typeof q.perform is 'function'
					q.perform cb
				else
					cb()
			return this
		
		each: (fun) ->
			list.push (cb) ->
				async.each (val for key, val of nodes) , (node, asyncCB) ->
					q = new query(graph)
					q.node(node.id)
					q = fun(node, q)
					if q && typeof q.perform is 'function'
						q.perform asyncCB
					else
						asyncCB()
				, cb
			return this
}


module.exports = query