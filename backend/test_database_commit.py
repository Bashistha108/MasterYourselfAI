#!/usr/bin/env python3
"""
Test if database commits are working
"""

import os
import sys
import subprocess

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def test_database_commit():
    """Test if database commits are working"""
    print("🔍 Testing Database Commit")
    print("=" * 30)
    
    # Load MySQL environment variables
    os.environ['MYSQL_HOST'] = 'localhost'
    os.environ['MYSQL_PORT'] = '3306'
    os.environ['MYSQL_USER'] = 'master_ai_user'
    os.environ['MYSQL_PASSWORD'] = 'MasterAI2024!@#'
    os.environ['MYSQL_DATABASE'] = 'master_yourself_ai'
    
    app = create_app()
    
    with app.app_context():
        try:
            from app.models.user import User
            
            # Test email
            test_email = 'mikecpp82@gmail.com'
            
            print(f"1. Getting user: {test_email}")
            user = User.get_by_email(test_email)
            
            if user:
                print(f"✅ User found: {user.email}")
                print(f"   Current password hash: {user.password_hash[:50]}...")
                print(f"   Current updated_at: {user.updated_at}")
                
                # Test direct database update
                print(f"\n2. Testing direct database update...")
                
                # Get current hash from database
                result = subprocess.run([
                    'mysql', '-u', 'master_ai_user', '-pMasterAI2024!@#', 'master_yourself_ai',
                    '-e', f"SELECT password_hash, updated_at FROM users WHERE email='{test_email}';"
                ], capture_output=True, text=True)
                
                if result.returncode == 0:
                    lines = result.stdout.strip().split('\n')
                    if len(lines) >= 2:
                        parts = lines[1].split('\t')
                        db_hash = parts[0]
                        db_updated_at = parts[1] if len(parts) > 1 else 'N/A'
                        print(f"   Database hash: {db_hash[:50]}...")
                        print(f"   Database updated_at: {db_updated_at}")
                        
                        # Check if SQLAlchemy and database match
                        if user.password_hash == db_hash:
                            print("   ✅ SQLAlchemy and database match")
                        else:
                            print("   ❌ SQLAlchemy and database don't match!")
                
                # Test password update
                print(f"\n3. Testing password update...")
                new_password = 'test_commit_123'
                
                # Update password
                user.set_password(new_password)
                print(f"   Password hash after set_password: {user.password_hash[:50]}...")
                
                # Commit to database
                print(f"   Committing to database...")
                db.session.commit()
                print(f"   ✅ Commit completed")
                
                # Check database immediately after commit
                print(f"\n4. Checking database after commit...")
                result = subprocess.run([
                    'mysql', '-u', 'master_ai_user', '-pMasterAI2024!@#', 'master_yourself_ai',
                    '-e', f"SELECT password_hash, updated_at FROM users WHERE email='{test_email}';"
                ], capture_output=True, text=True)
                
                if result.returncode == 0:
                    lines = result.stdout.strip().split('\n')
                    if len(lines) >= 2:
                        parts = lines[1].split('\t')
                        new_db_hash = parts[0]
                        new_db_updated_at = parts[1] if len(parts) > 1 else 'N/A'
                        print(f"   New database hash: {new_db_hash[:50]}...")
                        print(f"   New database updated_at: {new_db_updated_at}")
                        
                        if new_db_hash != db_hash:
                            print("   ✅ Database was updated!")
                        else:
                            print("   ❌ Database was NOT updated!")
                            
                        # Check if SQLAlchemy matches new database
                        if user.password_hash == new_db_hash:
                            print("   ✅ SQLAlchemy matches new database")
                        else:
                            print("   ❌ SQLAlchemy doesn't match new database")
                            
                        # Test password verification
                        print(f"\n5. Testing password verification...")
                        if user.check_password(new_password):
                            print("   ✅ New password works!")
                        else:
                            print("   ❌ New password doesn't work!")
                            
                else:
                    print(f"   ❌ Error querying database: {result.stderr}")
                    
            else:
                print(f"❌ User not found: {test_email}")
                
        except Exception as e:
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    test_database_commit()
