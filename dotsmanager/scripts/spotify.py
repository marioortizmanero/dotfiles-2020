#!/usr/bin/env python3
# Lists all the user's playlists and songs in each of them. This requires a
# refresh token in order to not need user interaction:
# https://tekore.readthedocs.io/en/stable/reference/auth.html

import sys
import tekore as tk

EXCLUDED_PLAYLISTS = [
    'Discover Weekly',
    'New Releases',
]
CLIENT_ID = "[REMOVED]"
CLIENT_SECRET = "[REMOVED]"
REDIRECT_URI = "http://localhost:8888/callback/"
REFRESH_TOKEN = "[REMOVED]"

# Temporary redirection to stderr for script usability
old_stdout = sys.stdout
sys.stdout = sys.stderr

creds = tk.Credentials(
    client_id=CLIENT_ID,
    client_secret=CLIENT_SECRET,
    redirect_uri=REDIRECT_URI,
)

cached_token = tk.refresh_user_token(
    creds.client_id,
    creds.client_secret,
    REFRESH_TOKEN
)

# If the token is invalid, prompt the user.
user_token = cached_token or tk.prompt_for_user_token(
    creds.client_id,
    creds.client_secret,
    creds.redirect_uri,
    scope=[
        tk.scope.playlist_read_private
    ]
)
s = tk.Spotify(user_token, max_limits_on=True, chunked_on=True)

# Restoring stdout
sys.stdout = old_stdout

for playlist in s.all_items(s.followed_playlists()):
    if playlist.name in EXCLUDED_PLAYLISTS:
        continue

    print(playlist.name)

    for item in s.all_items(s.playlist_items(playlist.id)):
        if not hasattr(item.track, 'name') or \
                not hasattr(item.track, 'artists'):
            continue

        # Some local songs have the artists in the name
        name = item.track.name
        artists = ", ".join(artist.name for artist in item.track.artists)
        if artists == "":
            print(f"    {name}")
        else:
            print(f"    {artists} - {name}")
