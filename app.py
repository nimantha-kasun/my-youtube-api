from flask import Flask, request, jsonify
import subprocess
import json
import logging
import os

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_video_info(url):
    """
    Fetches video info using yt-dlp.
    Returns the JSON object or raises an exception.
    """
    command = [
        "yt-dlp",
        "--dump-json",
        "--no-warnings",
        "--no-playlist",  # We usually want single video info
        url
    ]
    
    try:
        # Run yt-dlp command
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True
        )
        # Parse output as JSON
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        logger.error(f"yt-dlp error: {e.stderr}")
        raise Exception(f"yt-dlp failed: {e.stderr}")
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {e}")
        raise Exception("Failed to parse video information")

@app.route('/api/info', methods=['GET'])
def api_info():
    url = request.args.get('url')
    
    if not url:
        return jsonify({"error": "Missing 'url' parameter"}), 400

    try:
        logger.info(f"Fetching info for: {url}")
        video_info = get_video_info(url)
        return jsonify(video_info)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "service": "youtube-dl-api"})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)
