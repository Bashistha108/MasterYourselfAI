"""Fix weekly_goal_intensities foreign key reference with proper names

Revision ID: 88737502b575
Revises: 20ddee707d4e
Create Date: 2025-08-25 11:03:04.339109

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '88737502b575'
down_revision = '20ddee707d4e'
branch_labels = None
depends_on = None


def upgrade():
    # Drop the existing table and recreate it with correct foreign key
    op.drop_table('weekly_goal_intensities')
    
    op.create_table('weekly_goal_intensities',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('goal_id', sa.Integer(), nullable=False),
        sa.Column('week_start', sa.Date(), nullable=False),
        sa.Column('intensity', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['goal_id'], ['weekly_goals.id'], ),
        sa.PrimaryKeyConstraint('id')
    )


def downgrade():
    # Drop the table and recreate it with the old foreign key
    op.drop_table('weekly_goal_intensities')
    
    op.create_table('weekly_goal_intensities',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('goal_id', sa.Integer(), nullable=False),
        sa.Column('week_start', sa.Date(), nullable=False),
        sa.Column('intensity', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['goal_id'], ['long_term_goals.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
