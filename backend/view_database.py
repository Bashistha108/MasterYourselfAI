#!/usr/bin/env python3
"""
View MySQL database content easily
"""

import os
import sys
from tabulate import tabulate

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def view_database():
    """View database content"""
    print("🔍 MySQL Database Content Viewer")
    print("=" * 40)
    
    # Load MySQL environment variables
    os.environ['MYSQL_HOST'] = 'localhost'
    os.environ['MYSQL_PORT'] = '3306'
    os.environ['MYSQL_USER'] = 'master_ai_user'
    os.environ['MYSQL_PASSWORD'] = 'MasterAI2024!@#'
    os.environ['MYSQL_DATABASE'] = 'master_yourself_ai'
    
    app = create_app()
    
    with app.app_context():
        try:
            # Get all tables
            with db.engine.connect() as conn:
                result = conn.execute(db.text("SHOW TABLES"))
                tables = [row[0] for row in result.fetchall()]
            
            print(f"📋 Found {len(tables)} tables:")
            for i, table in enumerate(tables, 1):
                print(f"  {i}. {table}")
            
            print("\n" + "="*50)
            
            # Show content of main tables
            main_tables = ['users', 'weekly_goals', 'ai_challenges', 'problems', 'challenges']
            
            for table in main_tables:
                if table in tables:
                    print(f"\n📊 Table: {table}")
                    print("-" * 30)
                    
                    try:
                        with db.engine.connect() as conn:
                            result = conn.execute(db.text(f"SELECT * FROM {table}"))
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
                                
                    except Exception as e:
                        print(f"Error reading {table}: {e}")
            
            print("\n" + "="*50)
            print("✅ Database content displayed successfully!")
            
        except Exception as e:
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    view_database()
