import requests
import json
import os

github_token = "REMOVED_TOKEN"
codeberg_token = "019604c7a08745d2cbf037de7d2294abeaaa9ab8"

with open("release_notes_2.0.0.md", "r") as f:
    notes = f.read()

# GitHub Release
gh_url = "https://api.github.com/repos/funbinet/ichito/releases"
gh_headers = {
    "Authorization": f"Bearer {github_token}",
    "Accept": "application/vnd.github+json"
}
gh_data = {
    "tag_name": "v2.0.0",
    "name": "ICHITO v2.0.0",
    "body": notes,
    "draft": False,
    "prerelease": False
}

gh_resp = requests.post(gh_url, headers=gh_headers, json=gh_data)
if gh_resp.status_code == 201:
    print("GitHub release created successfully.")
    gh_release_id = gh_resp.json()["id"]
    upload_url = gh_resp.json()["upload_url"].replace("{?name,label}", "?name=app-release.apk")
    
    # Upload Asset
    with open("build/app/outputs/flutter-apk/app-release.apk", "rb") as f:
        apk_data = f.read()
    
    upload_headers = {
        "Authorization": f"Bearer {github_token}",
        "Content-Type": "application/vnd.android.package-archive"
    }
    upload_resp = requests.post(upload_url, headers=upload_headers, data=apk_data)
    if upload_resp.status_code == 201:
        print("GitHub asset uploaded successfully.")
    else:
        print("GitHub asset upload failed:", upload_resp.text)
else:
    print("GitHub release creation failed:", gh_resp.text)


# Codeberg Release (Gitea API)
cb_url = "https://codeberg.org/api/v1/repos/funbinet/ichito/releases"
cb_headers = {
    "Authorization": f"token {codeberg_token}",
    "Content-Type": "application/json"
}
cb_data = {
    "tag_name": "v2.0.0",
    "name": "ICHITO v2.0.0",
    "body": notes,
    "draft": False,
    "prerelease": False
}

cb_resp = requests.post(cb_url, headers=cb_headers, json=cb_data)
if cb_resp.status_code == 201:
    print("Codeberg release created successfully.")
    cb_release_id = cb_resp.json()["id"]
    
    # Upload Asset
    asset_url = f"https://codeberg.org/api/v1/repos/funbinet/ichito/releases/{cb_release_id}/assets?name=app-release.apk"
    upload_headers = {
        "Authorization": f"token {codeberg_token}"
    }
    with open("build/app/outputs/flutter-apk/app-release.apk", "rb") as f:
        upload_resp = requests.post(asset_url, headers=upload_headers, files={"attachment": ("app-release.apk", f, "application/vnd.android.package-archive")})
    
    if upload_resp.status_code == 201:
        print("Codeberg asset uploaded successfully.")
    else:
        print("Codeberg asset upload failed:", upload_resp.text)
else:
    print("Codeberg release creation failed:", cb_resp.text)
