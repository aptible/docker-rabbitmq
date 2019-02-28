require "bunny"

conn = Bunny.new('amqps://testuser:pass@localhost.aptible.in:5671/db', verify_peer: false)
conn.start

# open a channel
ch = conn.create_channel

# declare a queue
q  = ch.queue("test1")

# publish a message to the default econnchange which then gets routed to this queue
q.publish("Test value")

# fetch a message from the queue
delivery_info, metadata, payload = q.pop

if payload != "Test value"
	raise "Queued message not found"
end

conn.stop
