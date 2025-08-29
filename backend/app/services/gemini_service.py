import os
import requests
import logging
from typing import Dict, List, Optional
from flask import current_app
import json

logger = logging.getLogger(__name__)

class GeminiService:
    """Secure service for interacting with Gemini API"""
    
    def __init__(self):
        self.api_key = os.environ.get('GEMINI_API_KEY')
        self.api_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
        
        if not self.api_key:
            logger.error("GEMINI_API_KEY not found in environment variables")
            raise ValueError("GEMINI_API_KEY is required")
    
    def generate_challenge(self, weekly_goals: List, long_term_goals: List, problems: List) -> Optional[Dict]:
        """
        Generate a personalized challenge using Gemini API based on user's problems and goals
        
        Args:
            weekly_goals: List of weekly goal objects
            long_term_goals: List of long-term goal objects  
            problems: List of problem objects
            
        Returns:
            Dict with challenge data or None if generation fails
        """
        try:
            # Create comprehensive prompt based on user data
            prompt = self._create_challenge_prompt(weekly_goals, long_term_goals, problems)
            
            # Log the prompt for debugging (without sensitive data)
            logger.info(f"Generating challenge with prompt length: {len(prompt)} characters")
            
            # Make API call
            response = self._call_gemini_api(prompt)
            
            if response and response.get('candidates'):
                content = response['candidates'][0]['content']['parts'][0]['text']
                logger.info(f"Received response from Gemini: {content[:100]}...")
                return self._parse_challenge_response(content)
            else:
                logger.warning("No valid response from Gemini API")
                return None
            
        except Exception as e:
            logger.error(f"Error generating challenge with Gemini: {str(e)}")
            return None
    
    def _create_challenge_prompt(self, weekly_goals: List, long_term_goals: List, problems: List) -> str:
        """Create a comprehensive prompt for challenge generation based on user data"""
        
        # Build detailed context from user data
        context_parts = []
        
        if weekly_goals:
            weekly_details = []
            for goal in weekly_goals:
                desc = f"'{goal.title}'"
                if goal.description:
                    desc += f" ({goal.description[:100]}...)"
                weekly_details.append(desc)
            context_parts.append(f"Weekly goals: {'; '.join(weekly_details)}")
        
        if long_term_goals:
            long_term_details = []
            for goal in long_term_goals:
                desc = f"'{goal.title}'"
                if goal.description:
                    desc += f" ({goal.description[:100]}...)"
                long_term_details.append(desc)
            context_parts.append(f"Long-term goals: {'; '.join(long_term_details)}")
        
        if problems:
            problem_details = []
            for problem in problems:
                desc = f"'{problem.name}'"
                if problem.description:
                    desc += f" ({problem.description[:100]}...)"
                if problem.category:
                    desc += f" [Category: {problem.category}]"
                problem_details.append(desc)
            context_parts.append(f"Active problems: {'; '.join(problem_details)}")
        
        context = "\n".join(context_parts) if context_parts else "No specific goals or problems available"
        
        # Create comprehensive prompt for personalized challenge
        prompt = f"""Based on this user's personal data, generate a personalized daily challenge:

{context}

Requirements:
- Create ONE specific, actionable challenge that directly relates to the user's goals and/or problems
- The challenge should be something that can be completed in 15-60 minutes today
- Make it specific and measurable (e.g., "Practice guitar for 30 minutes" not "Practice music")
- If the user has goals, prioritize creating a challenge that advances those goals
- If the user has problems, consider creating a challenge that helps address or work around those problems
- Be creative but realistic - the challenge should feel achievable yet meaningful
- Return ONLY the challenge sentence, no explanations or additional text
- Keep it under 25 words for clarity
- Make each challenge unique and different from previous ones
- Consider the user's context and create something relevant to their situation

Examples of good challenges:
- "Practice guitar for 30 minutes focusing on chord transitions"
- "Read 20 pages of a book related to your long-term career goal"
- "Take a 30-minute walk while thinking about solutions to your productivity problem"
- "Call 3 people you haven't spoken to in a month"
- "Spend 45 minutes learning a new skill online"
- "Research 3 strategies to overcome your current challenge"
- "Dedicate 30 minutes to planning your next steps toward your goal"
- "Practice mindfulness for 15 minutes while focusing on your problem"
- "Connect with someone who can help you with your goal"
- "Take one specific action today that moves you closer to your long-term vision"

Generate the challenge:"""
        
        return prompt
    
    def _call_gemini_api(self, prompt: str) -> Optional[Dict]:
        """Make secure API call to Gemini"""
        try:
            headers = {
                'Content-Type': 'application/json',
                'X-goog-api-key': self.api_key
            }
            
            payload = {
                "contents": [
                    {
                        "parts": [
                            {
                                "text": prompt
                            }
                        ]
                    }
                ]
            }
            
            response = requests.post(
                self.api_url,
                headers=headers,
                json=payload,
                timeout=10  # 10 second timeout
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                logger.error(f"Gemini API error: {response.status_code} - {response.text}")
                return None
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Request error calling Gemini API: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error calling Gemini API: {str(e)}")
            return None
    
    def _parse_challenge_response(self, response_text: str) -> Dict:
        """Parse the Gemini response into challenge format"""
        try:
            # Clean the response text
            challenge_text = response_text.strip()
            
            # Remove quotes if present
            if challenge_text.startswith('"') and challenge_text.endswith('"'):
                challenge_text = challenge_text[1:-1]
            
            # Remove any markdown formatting
            if challenge_text.startswith('**') and challenge_text.endswith('**'):
                challenge_text = challenge_text[2:-2]
            
            # Ensure we have a valid challenge
            if not challenge_text or len(challenge_text) < 5:
                logger.warning(f"Challenge text too short: '{challenge_text}'")
                raise ValueError("Challenge text too short")
            
            # Create challenge object
            challenge = {
                'title': challenge_text[:50] + "..." if len(challenge_text) > 50 else challenge_text,
                'description': challenge_text,
                'difficulty': 'easy',  # Default to easy as requested
                'estimated_time': '15-30 minutes'
            }
            
            logger.info(f"Successfully parsed challenge: {challenge_text}")
            return challenge
            
        except Exception as e:
            logger.error(f"Error parsing challenge response: {str(e)}")
            # Return a fallback challenge
            return {
                'title': 'Take a mindful break',
                'description': 'Spend 15 minutes doing something that brings you joy and peace.',
                'difficulty': 'easy',
                'estimated_time': '15 minutes'
            }
    
    def test_connection(self) -> bool:
        """Test if Gemini API is accessible"""
        try:
            test_prompt = "Say 'Hello' in one word."
            response = self._call_gemini_api(test_prompt)
            return response is not None and 'candidates' in response
        except Exception as e:
            logger.error(f"Gemini API connection test failed: {str(e)}")
            return False
