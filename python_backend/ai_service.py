import logging
from pydantic import BaseModel

logger = logging.getLogger(__name__)

class AIAnalysisResult(BaseModel):
    aiBio: str
    githubSeniority: str
    topAiSkills: list[str]

def analyze_developer_metrics(metrics: dict) -> AIAnalysisResult:
    logger.info("Executing algorithmic analysis of GitHub metrics.")
    
    public_repos = metrics.get('public_repos', 0)
    total_stars = metrics.get('total_stars_earned', 0)
    language_dist = metrics.get('language_distribution', {})
    
    # 1. Determine Seniority
    if public_repos >= 20 or total_stars >= 20:
        seniority = "Senior"
    elif public_repos >= 5 or total_stars >= 5:
        seniority = "Mid-Level"
    else:
        seniority = "Junior"
        
    # 2. Extract Top Skills
    # Sort languages by frequency descending
    sorted_languages = sorted(language_dist.items(), key=lambda item: item[1], reverse=True)
    top_skills = [lang[0] for lang in sorted_languages[:4]] # Take up to top 4 languages
    
    # 3. Generate Bio
    skills_str = ", ".join(top_skills) if top_skills else "various technologies"
    bio = f"A passionate {seniority} developer specializing in {skills_str}. Built {public_repos} public projects and earned {total_stars} GitHub stars."
    
    return AIAnalysisResult(
        aiBio=bio,
        githubSeniority=seniority,
        topAiSkills=top_skills
    )
