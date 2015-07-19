Graph = require './graph'

graph = new Graph()

user = graph.createNode('User')
commentList = graph.createNode('CommentList')
comment1 = graph.createNode('Comment', 'This is comment1')
comment2 = graph.createNode('Comment', 'This is comment2')
comment3 = graph.createNode('Comment', 'This is comment3')

graph.createConnection(user, commentList)
graph.createConnection(commentList, comment1)
graph.createConnection(commentList, comment2)
graph.createConnection(commentList, comment3)


###
Find every comment of user which is equal to "This is comment2"
###

graph.query()
	.node(0)
	.getChildren('CommentList')
	.getChildren('Comment')
	.filter (comment, done) ->
		comment.getValue (value) ->
			done(value == "This is comment2")
	.evaluate (nodes) ->
		console.log nodes
