"""Update AI challenges table structure

Revision ID: 80912d32d6b6
Revises: 8b6eb3a1e8c8
Create Date: 2025-08-25 16:42:30.180365

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '80912d32d6b6'
down_revision = '8b6eb3a1e8c8'
branch_labels = None
depends_on = None


def upgrade():
    # Drop the old table and recreate it with new structure
    op.drop_table('ai_challenges')
    
    # Create new table with updated structure
    op.create_table('ai_challenges',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.String(length=255), nullable=False),
        sa.Column('title', sa.String(length=255), nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('challenge_date', sa.Date(), nullable=False),
        sa.Column('completed', sa.Boolean(), nullable=True),
        sa.Column('completed_at', sa.DateTime(), nullable=True),
        sa.Column('difficulty', sa.String(length=20), nullable=True),
        sa.Column('points', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )


def downgrade():
    # Drop the new table
    op.drop_table('ai_challenges')
    
    # Recreate the old table structure
    op.create_table('ai_challenges',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('problem_id', sa.Integer(), nullable=False),
        sa.Column('challenge_text', sa.Text(), nullable=False),
        sa.Column('date', sa.Date(), nullable=False),
        sa.Column('completed', sa.Boolean(), nullable=True),
        sa.Column('difficulty', sa.String(length=20), nullable=True),
        sa.Column('points', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['problem_id'], ['problems.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
