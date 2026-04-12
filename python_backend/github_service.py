import requests
import logging

logger = logging.getLogger(__name__)

def fetch_github_data(username: str, token: str):
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    logger.info(f"Fetching GitHub data for {username}")
    
    # Get List of Repositories
    repos_url = f"https://api.github.com/user/repos?sort=updated&per_page=30"
    repos_res = requests.get(repos_url, headers=headers)
    
    if repos_res.status_code != 200:
        logger.error(f"GitHub API Error: {repos_res.status_code} - {repos_res.text}")
        raise Exception(f"Failed to fetch repositories. Status: {repos_res.status_code}")
        
    repos = repos_res.json()
    
    # Aggregate data
    languages = {}
    total_stars = 0
    topics = set()
    
    for repo in repos:
        # Ignore forks for primary skill assessment, unless you want them
        if repo.get('fork', False):
            continue
            
        lang = repo.get('language')
        if lang:
            languages[lang] = languages.get(lang, 0) + 1
            
        total_stars += repo.get('stargazers_count', 0)
        
        for topic in repo.get('topics', []):
            topics.add(topic)

    # Simplified user snippet to send to Gemini
    metrics = {
        "username": username,
        "public_repos": len(repos),
        "total_stars_earned": total_stars,
        "language_distribution": languages,
        "repo_topics": list(topics)
    }
    
    logger.info(f"Metrics gathered: {metrics}")
    return metrics
