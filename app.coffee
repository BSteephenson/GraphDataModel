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
	.traverse('CommentList')
	.traverse('Comment')
	.filter (comment, done) ->
		done(comment.value == 'This is comment2')
	.each (comment) ->
		console.log comment
	.perform () ->
		# done
###
Find every friend of user. Populate the name of that user
###

userA = graph.createNode('User')
userB = graph.createNode('User')
userA_name = graph.createNode('Name', 'Bob')
userB_name = graph.createNode('Name', 'Smith')
user_friend_list = graph.createNode('FriendsList')

graph.createConnection(user, user_friend_list)
graph.createConnection(user_friend_list, userA)
graph.createConnection(user_friend_list, userB)
graph.createConnection(userA, userA_name)
graph.createConnection(userB, userB_name)


results = {}

graph
	.query()
	.node(user.id)
	.traverse('FriendsList')
	.traverse('User')
	.each (user, query) ->
		query
			.traverse('Name')
			.first (name) ->
				results[user.id] = name.value
		return query
	.perform () ->
		console.log JSON.stringify(results)
