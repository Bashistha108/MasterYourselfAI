# Import all models to ensure they are registered with SQLAlchemy
from app.models.weekly_goals import WeeklyGoals
from app.models.long_term_goals import LongTermGoals
from app.models.problems import Problems
from app.models.problem_logs import ProblemLogs
from app.models.daily_problem_logs import DailyProblemLogs
from app.models.ai_challenges import AIChallenges
from app.models.challenges import Challenges
from app.models.goal_ratings import GoalRatings
from app.models.quick_wins import QuickWins
from app.models.goal_notes import GoalNotes
from app.models.weekly_goal_intensities import WeeklyGoalIntensities
from app.models.daily_goal_intensities import DailyGoalIntensities
from app.models.quick_notes import QuickNotes
from app.models.todo_items import TodoItems
from app.models.emails import Email

__all__ = [
    'WeeklyGoals',
    'LongTermGoals', 
    'Problems',
    'ProblemLogs',
    'DailyProblemLogs',
    'AIChallenges',
    'Challenges',
    'GoalRatings',
    'QuickWins',
    'GoalNotes',
    'WeeklyGoalIntensities',
    'DailyGoalIntensities',
    'QuickNotes',
    'TodoItems',
    'Email'
]
