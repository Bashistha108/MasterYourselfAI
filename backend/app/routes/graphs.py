from flask import Blueprint, request, jsonify
from app.models.weekly_goals import WeeklyGoals
from app.models.problem_logs import ProblemLogs
from app.models.problems import Problems
from app.models.ai_challenges import AIChallenges
from app.models.quick_wins import QuickWins
from app.models.goal_ratings import GoalRatings
from app import db
from datetime import datetime, date, timedelta
from sqlalchemy import func, case

graphs_bp = Blueprint('graphs', __name__)

@graphs_bp.route('/weekly-goals-progress', methods=['GET'])
def get_weekly_goals_progress():
    """Get weekly goals progress data for charts"""
    try:
        weeks_back = int(request.args.get('weeks', 4))
        end_date = date.today()
        start_date = end_date - timedelta(weeks=weeks_back)
        
        # Get weekly goals with their ratings
        goals_data = db.session.query(
            WeeklyGoals.week_start_date,
            func.avg(WeeklyGoals.rating).label('avg_rating'),
            func.count(WeeklyGoals.id).label('total_goals'),
            func.sum(case((WeeklyGoals.rating >= 7, 1), else_=0)).label('high_rated_goals')
        ).filter(
            WeeklyGoals.week_start_date >= start_date
        ).group_by(WeeklyGoals.week_start_date).all()
        
        chart_data = {
            'labels': [],
            'datasets': [
                {
                    'label': 'Average Rating',
                    'data': [],
                    'borderColor': '#4CAF50',
                    'backgroundColor': 'rgba(76, 175, 80, 0.1)',
                    'yAxisID': 'y'
                },
                {
                    'label': 'Total Goals',
                    'data': [],
                    'borderColor': '#2196F3',
                    'backgroundColor': 'rgba(33, 150, 243, 0.1)',
                    'yAxisID': 'y1'
                }
            ]
        }
        
        for week_data in goals_data:
            chart_data['labels'].append(week_data.week_start_date.strftime('%Y-%m-%d'))
            chart_data['datasets'][0]['data'].append(float(week_data.avg_rating) if week_data.avg_rating else 0)
            chart_data['datasets'][1]['data'].append(week_data.total_goals)
        
        return jsonify({
            'success': True,
            'data': chart_data
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@graphs_bp.route('/problem-intensity-trends', methods=['GET'])
def get_problem_intensity_trends():
    """Get problem intensity trends over time"""
    try:
        days_back = int(request.args.get('days', 30))
        end_date = date.today()
        start_date = end_date - timedelta(days=days_back)
        
        # Get problem intensity data
        intensity_data = db.session.query(
            ProblemLogs.log_date,
            func.avg(ProblemLogs.intensity).label('avg_intensity'),
            func.count(ProblemLogs.id).label('total_logs')
        ).filter(
            ProblemLogs.log_date >= start_date
        ).group_by(ProblemLogs.log_date).order_by(ProblemLogs.log_date).all()
        
        chart_data = {
            'labels': [],
            'datasets': [
                {
                    'label': 'Average Intensity',
                    'data': [],
                    'borderColor': '#FF5722',
                    'backgroundColor': 'rgba(255, 87, 34, 0.1)',
                    'yAxisID': 'y'
                },
                {
                    'label': 'Number of Problems',
                    'data': [],
                    'borderColor': '#9C27B0',
                    'backgroundColor': 'rgba(156, 39, 176, 0.1)',
                    'yAxisID': 'y1'
                }
            ]
        }
        
        for day_data in intensity_data:
            chart_data['labels'].append(day_data.log_date.strftime('%Y-%m-%d'))
            chart_data['datasets'][0]['data'].append(float(day_data.avg_intensity) if day_data.avg_intensity else 0)
            chart_data['datasets'][1]['data'].append(day_data.total_logs)
        
        return jsonify({
            'success': True,
            'data': chart_data
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@graphs_bp.route('/ai-challenges-completion', methods=['GET'])
def get_ai_challenges_completion():
    """Get AI challenges completion rates"""
    try:
        days_back = int(request.args.get('days', 30))
        end_date = date.today()
        start_date = end_date - timedelta(days=days_back)
        
        # Get challenge completion data
        challenge_data = db.session.query(
            AIChallenges.challenge_date,
            func.count(AIChallenges.id).label('total_challenges'),
            func.sum(case((AIChallenges.completed == True, 1), else_=0)).label('completed_challenges'),
            func.avg(AIChallenges.rating).label('avg_rating')
        ).filter(
            AIChallenges.challenge_date >= start_date
        ).group_by(AIChallenges.challenge_date).order_by(AIChallenges.challenge_date).all()
        
        chart_data = {
            'labels': [],
            'datasets': [
                {
                    'label': 'Completion Rate (%)',
                    'data': [],
                    'borderColor': '#00BCD4',
                    'backgroundColor': 'rgba(0, 188, 212, 0.1)',
                    'yAxisID': 'y'
                },
                {
                    'label': 'Average Rating',
                    'data': [],
                    'borderColor': '#FF9800',
                    'backgroundColor': 'rgba(255, 152, 0, 0.1)',
                    'yAxisID': 'y1'
                }
            ]
        }
        
        for day_data in challenge_data:
            chart_data['labels'].append(day_data.challenge_date.strftime('%Y-%m-%d'))
            
            # Calculate completion rate
            completion_rate = (day_data.completed_challenges / day_data.total_challenges * 100) if day_data.total_challenges > 0 else 0
            chart_data['datasets'][0]['data'].append(round(completion_rate, 1))
            
            # Average rating
            avg_rating = float(day_data.avg_rating) if day_data.avg_rating else 0
            chart_data['datasets'][1]['data'].append(round(avg_rating, 1))
        
        return jsonify({
            'success': True,
            'data': chart_data
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@graphs_bp.route('/quick-wins-accumulation', methods=['GET'])
def get_quick_wins_accumulation():
    """Get quick wins points accumulation over time"""
    try:
        days_back = int(request.args.get('days', 7))
        end_date = date.today()
        start_date = end_date - timedelta(days=days_back)
        
        # Get quick wins data
        wins_data = db.session.query(
            QuickWins.win_date,
            func.count(QuickWins.id).label('total_wins'),
            func.sum(case((QuickWins.completed == True, QuickWins.points), else_=0)).label('total_points'),
            func.sum(case((QuickWins.completed == True, 1), else_=0)).label('completed_wins')
        ).filter(
            QuickWins.win_date >= start_date
        ).group_by(QuickWins.win_date).order_by(QuickWins.win_date).all()
        
        chart_data = {
            'labels': [],
            'datasets': [
                {
                    'label': 'Points Earned',
                    'data': [],
                    'borderColor': '#4CAF50',
                    'backgroundColor': 'rgba(76, 175, 80, 0.1)',
                    'yAxisID': 'y'
                },
                {
                    'label': 'Wins Completed',
                    'data': [],
                    'borderColor': '#E91E63',
                    'backgroundColor': 'rgba(233, 30, 99, 0.1)',
                    'yAxisID': 'y1'
                }
            ]
        }
        
        for day_data in wins_data:
            chart_data['labels'].append(day_data.win_date.strftime('%Y-%m-%d'))
            chart_data['datasets'][0]['data'].append(day_data.total_points or 0)
            chart_data['datasets'][1]['data'].append(day_data.completed_wins or 0)
        
        return jsonify({
            'success': True,
            'data': chart_data
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@graphs_bp.route('/category-breakdown', methods=['GET'])
def get_category_breakdown():
    """Get breakdown of activities by category"""
    try:
        days_back = int(request.args.get('days', 7))
        end_date = date.today()
        start_date = end_date - timedelta(days=days_back)
        
        # Get category data from different sources
        categories = {}
        
        # Quick wins by category
        quick_wins_categories = db.session.query(
            QuickWins.category,
            func.count(QuickWins.id).label('count'),
            func.sum(case((QuickWins.completed == True, QuickWins.points), else_=0)).label('points')
        ).filter(
            QuickWins.win_date >= start_date,
            QuickWins.completed == True
        ).group_by(QuickWins.category).all()
        
        for cat_data in quick_wins_categories:
            if cat_data.category not in categories:
                categories[cat_data.category] = {'wins': 0, 'points': 0, 'challenges': 0, 'problems': 0}
            categories[cat_data.category]['wins'] = cat_data.count
            categories[cat_data.category]['points'] = cat_data.points
        
        # AI challenges by category
        challenge_categories = db.session.query(
            AIChallenges.category,
            func.count(AIChallenges.id).label('count')
        ).filter(
            AIChallenges.challenge_date >= start_date,
            AIChallenges.completed == True
        ).group_by(AIChallenges.category).all()
        
        for cat_data in challenge_categories:
            if cat_data.category not in categories:
                categories[cat_data.category] = {'wins': 0, 'points': 0, 'challenges': 0, 'problems': 0}
            categories[cat_data.category]['challenges'] = cat_data.count
        
        # Problems by category
        problem_categories = db.session.query(
            func.count(ProblemLogs.id).label('count')
        ).join(Problems).filter(
            ProblemLogs.log_date >= start_date
        ).group_by(Problems.category).all()
        
        # Convert to chart format
        chart_data = {
            'labels': list(categories.keys()),
            'datasets': [
                {
                    'label': 'Quick Wins',
                    'data': [categories[cat]['wins'] for cat in categories.keys()],
                    'backgroundColor': [
                        '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0',
                        '#9966FF', '#FF9F40', '#FF6384', '#C9CBCF'
                    ]
                },
                {
                    'label': 'AI Challenges',
                    'data': [categories[cat]['challenges'] for cat in categories.keys()],
                    'backgroundColor': [
                        '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0',
                        '#9966FF', '#FF9F40', '#FF6384', '#C9CBCF'
                    ]
                }
            ]
        }
        
        return jsonify({
            'success': True,
            'data': chart_data,
            'summary': categories
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@graphs_bp.route('/overall-progress', methods=['GET'])
def get_overall_progress():
    """Get overall progress summary for dashboard"""
    try:
        # Get data for last 7 days
        week_ago = date.today() - timedelta(days=7)
        
        # Weekly goals progress
        weekly_goals = WeeklyGoals.query.filter(
            WeeklyGoals.week_start_date >= week_ago
        ).all()
        avg_goal_rating = sum(g.rating or 0 for g in weekly_goals) / len(weekly_goals) if weekly_goals else 0
        
        # Problem intensity
        problem_logs = ProblemLogs.query.filter(
            ProblemLogs.log_date >= week_ago
        ).all()
        avg_problem_intensity = sum(log.intensity for log in problem_logs) / len(problem_logs) if problem_logs else 0
        
        # AI challenges completion
        ai_challenges = AIChallenges.query.filter(
            AIChallenges.challenge_date >= week_ago
        ).all()
        challenge_completion_rate = len([c for c in ai_challenges if c.completed]) / len(ai_challenges) * 100 if ai_challenges else 0
        
        # Quick wins
        quick_wins = QuickWins.query.filter(
            QuickWins.win_date >= week_ago
        ).all()
        total_points = sum(w.points for w in quick_wins if w.completed)
        
        progress_data = {
            'weekly_goals': {
                'average_rating': round(avg_goal_rating, 1),
                'total_goals': len(weekly_goals)
            },
            'problems': {
                'average_intensity': round(avg_problem_intensity, 1),
                'total_logs': len(problem_logs)
            },
            'ai_challenges': {
                'completion_rate': round(challenge_completion_rate, 1),
                'total_challenges': len(ai_challenges)
            },
            'quick_wins': {
                'total_points': total_points,
                'total_wins': len([w for w in quick_wins if w.completed])
            }
        }
        
        return jsonify({
            'success': True,
            'data': progress_data
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@graphs_bp.route('/ai-challenge-points', methods=['GET'])
def get_ai_challenge_points():
    """Get AI challenge points over time - based on user-selected intensity (-3 to 3) or -1 if not selected"""
    try:
        days_back = int(request.args.get('days', 30))
        
        # Get the first and last dates with challenge data
        first_challenge = AIChallenges.query.order_by(AIChallenges.challenge_date.asc()).first()
        last_challenge = AIChallenges.query.order_by(AIChallenges.challenge_date.desc()).first()
        
        if not first_challenge and not last_challenge:
            # No challenges exist, return empty data
            return jsonify({
                'success': True,
                'data': {
                    'labels': [],
                    'datasets': [{
                        'label': 'AI Challenge Points',
                        'data': [],
                        'borderColor': '#9C27B0',
                        'backgroundColor': 'rgba(156, 39, 176, 0.1)',
                        'fill': True,
                        'tension': 0.4
                    }]
                },
                'total_points': 0,
                'total_days': 0,
                'aggregated_by_week': False
            }), 200
        
        # Use actual challenge date range or fallback to requested days
        if first_challenge and last_challenge:
            start_date = first_challenge.challenge_date
            end_date = last_challenge.challenge_date
        else:
            end_date = date.today()
            start_date = end_date - timedelta(days=days_back)
        
        # Get completed AI challenges data with intensity
        challenge_data = db.session.query(
            AIChallenges.challenge_date,
            func.count(AIChallenges.id).label('completed_challenges'),
            func.sum(AIChallenges.intensity).label('total_intensity'),
            func.sum(case((AIChallenges.intensity == 0, 1), else_=0)).label('zero_intensity_count')
        ).filter(
            AIChallenges.challenge_date >= start_date,
            AIChallenges.completed == True
        ).group_by(AIChallenges.challenge_date).order_by(AIChallenges.challenge_date).all()
        
        # Create a complete date range
        date_range = []
        current_date = start_date
        while current_date <= end_date:
            date_range.append(current_date)
            current_date += timedelta(days=1)
        
        # Create a dictionary for quick lookup of completed challenges and intensity
        challenge_dict = {}
        for day in challenge_data:
            total_intensity = day.total_intensity or 0
            zero_count = day.zero_intensity_count or 0
            
            # Calculate total points: sum of intensities - (zero_count * 1)
            # If someone has intensity 0, it counts as -1
            total_points = total_intensity - zero_count
            
            challenge_dict[day.challenge_date] = {
                'count': day.completed_challenges,
                'points': total_points
            }
        
        # Calculate points for each day with credit system
        daily_points = []
        accumulated_credits = 0
        
        for day in date_range:
            if day in challenge_dict:
                day_points = challenge_dict[day]['points']
                
                # Apply credit system
                if day_points < 0:
                    # Negative points become credits
                    accumulated_credits += abs(day_points)
                    daily_points.append(0)  # Stay at level 0
                elif day_points > 0:
                    # Positive points first pay off credits
                    if accumulated_credits > 0:
                        remaining_points = day_points - accumulated_credits
                        if remaining_points > 0:
                            # Credits paid off, show positive points
                            daily_points.append(remaining_points)
                            accumulated_credits = 0
                        else:
                            # Still paying off credits
                            daily_points.append(0)
                            accumulated_credits = abs(remaining_points)
                    else:
                        # No credits to pay off, show positive points
                        daily_points.append(day_points)
                else:
                    # Zero points
                    daily_points.append(0)
            else:
                # No completed challenges for this day - show 0
                daily_points.append(0)
        
        # Determine if we should aggregate by weeks
        should_aggregate_by_week = len(date_range) >= 7
        
        if should_aggregate_by_week:
            # Aggregate by weeks
            weekly_data = []
            week_labels = []
            
            # Group dates into weeks
            current_week_start = start_date
            week_number = 1
            while current_week_start <= end_date:
                week_end = min(current_week_start + timedelta(days=6), end_date)
                
                # Calculate week points
                week_points = 0
                week_days = 0
                for i, day in enumerate(date_range):
                    if current_week_start <= day <= week_end:
                        week_points += daily_points[i]
                        week_days += 1
                
                # Only include weeks that have data
                if week_days > 0:
                    weekly_data.append(week_points)
                    week_labels.append(f"Week {week_number}")
                    week_number += 1
                
                current_week_start += timedelta(days=7)
            
            chart_data = {
                'labels': week_labels,
                'datasets': [
                    {
                        'label': 'AI Challenge Points',
                        'data': weekly_data,
                        'borderColor': '#9C27B0',
                        'backgroundColor': 'rgba(156, 39, 176, 0.1)',
                        'fill': True,
                        'tension': 0.4
                    }
                ]
            }
        else:
            # Use daily data with sequential day numbers starting from 1
            day_labels = [f"Day {i+1}" for i in range(len(date_range))]
            chart_data = {
                'labels': day_labels,
                'datasets': [
                    {
                        'label': 'AI Challenge Points',
                        'data': daily_points,
                        'borderColor': '#9C27B0',
                        'backgroundColor': 'rgba(156, 39, 176, 0.1)',
                        'fill': True,
                        'tension': 0.4
                    }
                ]
            }
        
        return jsonify({
            'success': True,
            'data': chart_data,
            'total_points': sum(chart_data['datasets'][0]['data']),
            'total_days': len(chart_data['labels']),
            'aggregated_by_week': should_aggregate_by_week
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
