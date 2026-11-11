"""A pretend ATAK device: prints the CoT it hears and drops one marker next to the first drone."""

import datetime as dt
import socket
import struct
import sys
import time
import xml.etree.ElementTree as ET

GROUP, PORT = "239.2.3.1", 6969
MY_IP = sys.argv[1] if len(sys.argv) > 1 else "127.0.0.1"
MARKER_UID = "fake-atak-marker-1"
RESEND_SECS = 30


def iso(t):
    return t.strftime("%Y-%m-%dT%H:%M:%S.000Z")


def marker_cot(lat, lon):
    now = dt.datetime.now(dt.timezone.utc)
    stale = now + dt.timedelta(minutes=2)
    return (
        f'<event version="2.0" uid="{MARKER_UID}" type="a-h-G" how="h-g-i-g-o" '
        f'time="{iso(now)}" start="{iso(now)}" stale="{iso(stale)}">'
        f'<point lat="{lat:.6f}" lon="{lon:.6f}" hae="0" ce="10" le="10"/>'
        f'<detail><contact callsign="Fake enemy"/></detail></event>'
    ).encode()


rx = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
rx.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
rx.bind(("", PORT))
rx.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
              struct.pack("4s4s", socket.inet_aton(GROUP), socket.inet_aton(MY_IP)))
rx.settimeout(1.0)

tx = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
tx.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(MY_IP))
tx.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 1)
tx.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 0)

print(f"fake ATAK device listening on {GROUP}:{PORT} via {MY_IP}", flush=True)
last_seen = {}
videos = {}
marker_at = None
last_sent = 0.0

while True:
    try:
        data, _ = rx.recvfrom(65535)
    except socket.timeout:
        data = None
    if data:
        try:
            ev = ET.fromstring(data.lstrip(b"\xef\xbb\xbf"))
        except ET.ParseError:
            print(f"<- {len(data)} bytes, not XML (TAK protobuf?)", flush=True)
            continue
        uid, kind = ev.get("uid"), ev.get("type", "")
        pt = ev.find("point")
        contact = ev.find("detail/contact")
        name = contact.get("callsign") if contact is not None else uid
        lat, lon = float(pt.get("lat")), float(pt.get("lon"))
        # Print each object at most every 5 s, vehicles report several times a second.
        if time.time() - last_seen.get(uid, 0) > 5:
            last_seen[uid] = time.time()
            print(f"<- {name:<28} {kind:<16} {lat:.5f}, {lon:.5f}", flush=True)
        video = ev.find("detail/__video")
        if video is not None and video.get("url") and videos.get(uid) != video.get("url"):
            videos[uid] = video.get("url")
            print(f"   video for {name}: {video.get('url')}", flush=True)
        if marker_at is None and kind.startswith("a-f-A"):
            marker_at = (lat + 0.0045, lon)
            print(f"   first drone is {name}, dropping a marker ~500 m north of it", flush=True)
    if marker_at and time.time() - last_sent > RESEND_SECS:
        tx.sendto(marker_cot(*marker_at), (GROUP, PORT))
        last_sent = time.time()
        print(f"-> Fake enemy (a-h-G) at {marker_at[0]:.5f}, {marker_at[1]:.5f}", flush=True)
