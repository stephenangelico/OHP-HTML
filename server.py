import os
import re
import sys
import json
import socket
import asyncio
import hashlib
from aiohttp import web, WSMsgType

app = web.Application()
rooms = {}

class Room:
	def __init__(self, id):
		if os.environ.get("WS_KEEPALIVE"):
			asyncio.ensure_future(self.keepalive())
		self.clients = []
		self.id = id; rooms[self.id] = self # floop
		print("Creating new room %s [%d rooms]" % (self.id, len(rooms)))
		self.dying = None # Set to true when we run out of clients
		self.position = 0

	async def keepalive(self):
		while True:
			await asyncio.sleep(30)
			self.send_users()

	async def websocket(self, ws):
		self.dying = None # Whenever anyone joins, even if they disconnect fast, reset the death timer.
		self.clients.append(ws)
		print("New socket in %s (now %d)" % (self.id, len(self.clients)))

		ws.send_json({"type": "position", "data": self.position});
		async for msg in ws:
			# Ignore non-JSON messages
			if msg.type != WSMsgType.TEXT: continue
			try: msg = json.loads(msg.data)
			except ValueError: continue
			print("MESSAGE", msg)
			if "type" not in msg or "data" not in msg: continue
			resp = None
			if msg["type"] == "setpos":
				self.position = int(msg["data"])
				resp = {"type": "position", "data": self.position}
			if resp is None: continue
			for client in self.clients:
				if client is not ws: # Announce only to others, to prevent hysteresis
					client.send_json(resp)

		self.clients.remove(ws)
		await ws.close()
		print("Socket gone from %s (%d left)" % (self.id, len(self.clients)))
		if not self.clients:
			asyncio.ensure_future(self.die())
		return ws

	async def die(self):
		"""Destroy this room after a revive delay"""
		sentinel = object()
		self.dying = sentinel
		print("Room %s dying" % self.id)
		await asyncio.sleep(60)
		if self.dying is sentinel:
			# If it's not sentinel, we got revived. Maybe the
			# other connection is in dying mode, maybe not;
			# either way, we aren't in charge of death.
			assert not self.clients
			del rooms[self.id]
			print("Room %s dead - %d rooms left" % (self.id, len(rooms)))
		else:
			if self.dying:
				print("Room %s revived-but-still-dying" % self.id)
			else:
				print("Room %s revived" % self.id)

def route(url):
	def deco(f):
		app.router.add_get(url, f)
		return f
	return deco

@route("/")
async def home(req):
	with open("slides.html") as f:
		txt = f.read()
		# Add a unique ID based on the content
		# This breaks all caching. I'd really like the browser to calculate
		# a hash based on the actual content. :(
		txt = txt.replace("<script",
			"<script>window.socketid = %r</script><script" % hashlib.md5(txt.encode()).hexdigest(),
			1)
		return web.Response(text=txt, content_type="text/html")

@route("/ws")
async def websocket(req):
	ws = web.WebSocketResponse()
	await ws.prepare(req)
	async for msg in ws:
		if msg.type != WSMsgType.TEXT: continue
		try:
			msg = json.loads(msg.data)
			if msg["type"] != "socketid": continue
			room = msg["data"][:32]
			if room: break
		except (ValueError, KeyError, TypeError):
			# Any parsing error, just wait for another message
			continue
	else:
		# Something went wrong with the handshake. Kick
		# the client and let them reconnect.
		await ws.close()
		return ws
	if room not in rooms: Room(room)
	return await rooms[room].websocket(ws)

# Some things don't seem to work with the default static router.
# Since I currently don't have time to figure out why, just this.
def hackstatic():
	for fn in os.listdir():
		# Serve video files this way
		if fn.split(".")[-1] not in {"mkv", "avi", "mp4"}: continue
		with open(fn, "rb") as _f:
			content = _f.read()
		@route("/" + fn)
		async def video(req):
			return web.Response(body=content)
hackstatic()

# After all the custom routes, handle everything else by loading static files.
# Note that this can reveal the source code, so don't have anything sensitive.
app.router.add_static("/", path=".", name="static")

# Lifted from appension
async def serve_http(loop, port, sock=None):
	if sock:
		srv = await loop.create_server(app.make_handler(), sock=sock)
	else:
		srv = await loop.create_server(app.make_handler(), "0.0.0.0", port)
		sock = srv.sockets[0]
	print("Listening on %s:%s" % sock.getsockname(), file=sys.stderr)

def run(port=8080, sock=None):
	loop = asyncio.get_event_loop()
	loop.run_until_complete(serve_http(loop, port, sock))
	# TODO: Announce that we're "ready" in whatever way
	try: loop.run_forever()
	except KeyboardInterrupt: pass

if __name__ == '__main__':
	# Look for a socket provided by systemd
	sock = None
	try:
		pid = int(os.environ.get("LISTEN_PID", ""))
		fd_count = int(os.environ.get("LISTEN_FDS", ""))
	except ValueError:
		pid = fd_count = 0
	if pid == os.getpid() and fd_count >= 1:
		# The PID matches - we've been given at least one socket.
		# The sd_listen_fds docs say that they should start at FD 3.
		sock = socket.socket(fileno=3)
		print("Got %d socket(s)" % fd_count, file=sys.stderr)
	run(port=int(os.environ.get("PORT", "8080")), sock=sock)
