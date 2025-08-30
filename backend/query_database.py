clear
#!/usr/bin/env python3
"""
Run custom SQL queries on MySQL database
"""

import os
import sys
from tabulate import tabulate

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def query_database():
    """Run custom SQL queries"""
    print("🔍 MySQL Database Query Tool")
    print("=" * 30)
    
    # Load MySQL environment variables
    os.environ['MYSQL_HOST'] = 'localhost'
    os.environ['MYSQL_PORT'] = '3306'
    os.environ['MYSQL_USER'] = 'master_ai_user'
    os.environ['MYSQL_PASSWORD'] = 'MasterAI2024!@#'
    os.environ['MYSQL_DATABASE'] = 'master_yourself_ai'
    
    app = create_app()
    
    with app.app_context():
        # Predefined useful queries
        queries = {
            '1': {
                'name': 'All Users',
                'sql': 'SELECT id, email, display_name, created_at FROM users'
            },
            '2': {
                'name': 'All Weekly Goals',
                'sql': 'SELECT wg.id, u.email, wg.title, wg.description, wg.rating, wg.completed FROM weekly_goals wg JOIN users u ON wg.user_id = u.id'
            },
            '3': {
                'name': 'All AI Challenges',
                'sql': 'SELECT ac.id, u.email, ac.title, ac.description, ac.difficulty, ac.completed FROM ai_challenges ac JOIN users u ON ac.user_id = u.id'
            },
            '4': {
                'name': 'Goals by User',
                'sql': 'SELECT u.email, COUNT(wg.id) as goal_count FROM users u LEFT JOIN weekly_goals wg ON u.id = wg.user_id GROUP BY u.id, u.email'
            },
            '5': {
                'name': 'Table Row Counts',
                'sql': '''
                SELECT 
                    'users' as table_name, COUNT(*) as row_count FROM users
                UNION ALL
                SELECT 
                    'weekly_goals' as table_name, COUNT(*) as row_count FROM weekly_goals
                UNION ALL
                SELECT 
                    'ai_challenges' as table_name, COUNT(*) as row_count FROM ai_challenges
                UNION ALL
                SELECT 
                    'problems' as table_name, COUNT(*) as row_count FROM problems
                UNION ALL
                SELECT 
                    'challenges' as table_name, COUNT(*) as row_count FROM challenges
                '''
            }
        }
        
        print("Available queries:")
        for key, query in queries.items():
            print(f"  {key}. {query['name']}")
        print("  custom. Enter custom SQL query")
        print("  exit. Exit")
        
        while True:
            try:
                choice = input("\nEnter your choice (1-5, custom, exit): ").strip().lower()
                
                if choice == 'exit':
                    print("Goodbye!")
                    break
                elif choice == 'custom':
                    sql = input("Enter your SQL query: ").strip()
                    if not sql:
                        continue
                elif choice in queries:
                    sql = queries[choice]['sql']
                    print(f"\nRunning: {queries[choice]['name']}")
                else:
                    print("Invalid choice. Please try again.")
                    continue
                
                # Execute query
                with db.engine.connect() as conn:
                    result = conn.execute(db.text(sql))
                    rows = result.fetchall()
                    
                    if rows:
                        # Get column names
                        columns = result.keys()
                        
                        # Format data for display
                        data = []
                        for row in rows:
                            formatted_row = []
                            for value in row:
                                if value is None:
                                    formatted_row.append("NULL")
                                elif isinstance(value, str) and len(value) > 50:
                                    formatted_row.append(value[:47] + "...")
                                else:
                                    formatted_row.append(str(value))
                            data.append(formatted_row)
                        
                        # Display with tabulate
                        print(tabulate(data, headers=columns, tablefmt="grid"))
                        print(f"Total rows: {len(rows)}")
                    else:
                        print("No data found")
                        
            except KeyboardInterrupt:
                print("\nGoodbye!")
                break
            except Exception as e:
                print(f"❌ Error: {e}")

if __name__ == "__main__":
    query_database()
