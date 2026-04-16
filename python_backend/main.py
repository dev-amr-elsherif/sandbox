from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import logging
from github_service import fetch_github_data
from ai_service import analyze_developer_metrics

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="DevSync AI Analyzer")

class AnalyzeRequest(BaseModel):
    username: str
    token: str

class AnalyzeResponse(BaseModel):
    githubUrl: str
    aiBio: str
    githubSeniority: str
    topAiSkills: list[str]
    publicRepos: int
    followers: int
    accountAgeYears: int

@app.post("/analyze", response_model=AnalyzeResponse)
async def analyze_github_profile(request: AnalyzeRequest):
    logger.info(f"Received analysis request for GitHub user: {request.username}")
    
    if not request.token:
        raise HTTPException(status_code=400, detail="GitHub Access Token is required")
        
    try:
        # 1. Fetch data from github_service
        metrics = fetch_github_data(request.username, request.token)
        
        # 2. Process data with ai_service
        ai_result = analyze_developer_metrics(metrics)
        
        return AnalyzeResponse(
            githubUrl=f"https://github.com/{request.username}",
            aiBio=ai_result.aiBio,
            githubSeniority=ai_result.githubSeniority,
            topAiSkills=ai_result.topAiSkills,
            publicRepos=ai_result.publicRepos,
            followers=ai_result.followers,
            accountAgeYears=ai_result.accountAgeYears
        )
    except Exception as e:
        logger.error(f"Error analyzing profile: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal Server Error during analysis")

@app.get("/")
def read_root():
    return {"message": "DevSync AI Analyzer API is running"}
