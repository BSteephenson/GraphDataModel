# Graph Data Model

**A work in progress**

I wanted to make something like a database which organizes data in terms of a graph.

I also wanted to build a query tool that makes it easy to think about how you want to get the data that you need by traversing a graph.

At the end of the day, I want to make deep complicated queries to a database like this

```
// Find every user who has commented at least twice
// and has exactly one post that is about cats

graph.query()
	.type('User')
	.traverse('CommentList')
	.filter (commentList, done) ->
		commentList.count (count) ->
			done(count >= 2)
	.traverse('User')
	.traverse('PostList')
	.filter (postList, done) ->
		postList.count (count) ->
			done(count == 1)
	.traverse('Post')
	.traverse('Topic')
	.filter (topic, done) ->
		topic.getValue (value) ->
			done(value == 'Cats')
	.traverse('Post')
	.traverse('PostList')
	.traverse('User')
	.evaluate (users) ->
		console.log users
```