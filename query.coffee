
async = require 'async'

query = (graph) ->
	list = []

	nodes = {}

	computedValue = undefined

	return {
		findNode: (id) ->
			list.push (cb) ->
				nodes = {id: graph.getNode(id)}
				cb()
			return this
		
		node: (node) ->
			list.push (cb) ->
				nodes = {}
				nodes[node.id] = node
				cb()
			return this


		nodes: (nodeList) ->
			list.push (cb) ->
				nodes = nodeList
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
				if !computedValue
					computedValue = for key, node of nodes
						node.value
					if computedValue.length == 1
						computedValue = computedValue[0]
				cb(computedValue)
			)

		populate: (args...) ->
			if args.length == 1
				fun = args[0]
			else
				field = args[0]
				fun = args[1]
			list.push (cb) ->
				arr = (val for key, val of nodes)
				
				results = []

				async.each arr, (node, next) ->
					q = new query(graph)
					q.node(node)
					q = fun(q)
					q.perform (result) ->
						results.push result
						next()
				, () ->
					if field
						if !computedValue then computedValue = {}
						if results.length == 1
							computedValue[field] = results[0]
						else
							computedValue[field] = results
					else
						if results.length == 1
							computedValue = results[0]
						else
							computedValue = results

					cb()
			return this

		first: (fun) ->
			list.push (cb) ->
				node = (val for key, val of nodes)[0]
				q = new query(graph)
				q.node(node)
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
					q.node(node)
					q = fun(node, q)
					if q && typeof q.perform is 'function'
						q.perform asyncCB
					else
						asyncCB()
				, cb
			return this
}


module.exports = query