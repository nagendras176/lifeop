-- Queue of Life - Database Schema
-- PostgreSQL implementation with SQLite notes

-- Enable UUID extension (PostgreSQL only)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tasks table
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    order_index INTEGER NOT NULL DEFAULT 0,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    notes TEXT,
    priority VARCHAR(20) NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    task_type VARCHAR(20) NOT NULL CHECK (task_type IN ('simple', 'composite')),
    deadline TIMESTAMP WITH TIME ZONE,
    color INTEGER NOT NULL,
    reminder_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Ensure composite tasks have no objectives
    CONSTRAINT composite_no_objectives CHECK (
        (task_type = 'composite' AND NOT EXISTS (
            SELECT 1 FROM objectives WHERE task_id = id
        )) OR task_type = 'simple'
    )
);

-- Objectives table
CREATE TABLE objectives (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    weight INTEGER NOT NULL CHECK (weight BETWEEN 0 AND 100),
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Ensure unique names per task
    UNIQUE(task_id, name)
);

-- Tags table (simplified - directly linked to tasks)
CREATE TABLE tag (
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    color INTEGER,
    
    -- Composite primary key: task_id + name
    PRIMARY KEY (task_id, name)
);

-- Task links table
CREATE TABLE task_links (
    from_task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    to_task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    
    PRIMARY KEY (from_task_id, to_task_id)
);

-- Indexes for performance
CREATE INDEX idx_tasks_parent_order ON tasks(parent_id, order_index);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);
CREATE INDEX idx_objectives_task_id ON objectives(task_id);
CREATE INDEX idx_objectives_completed ON objectives(is_completed);
CREATE INDEX idx_tag_task_id ON tag(task_id);
CREATE INDEX idx_task_links_from ON task_links(from_task_id);
CREATE INDEX idx_task_links_to ON task_links(to_task_id);

-- Trigger function to validate weight sum = 100
CREATE OR REPLACE FUNCTION validate_objective_weights()
RETURNS TRIGGER AS $$
DECLARE
    total_weight INTEGER;
    task_type_val VARCHAR(20);
BEGIN
    -- Get task type
    SELECT t.task_type INTO task_type_val
    FROM tasks t
    WHERE t.id = COALESCE(NEW.task_id, OLD.task_id);
    
    -- Only validate for simple tasks
    IF task_type_val = 'simple' THEN
        -- Calculate total weight for this task
        SELECT COALESCE(SUM(weight), 0) INTO total_weight
        FROM objectives
        WHERE task_id = COALESCE(NEW.task_id, OLD.task_id);
        
        -- Check if total equals 100
        IF total_weight != 100 THEN
            RAISE EXCEPTION 'Objective weights must sum to 100%% (currently %%)', total_weight;
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Create triggers for weight validation
CREATE TRIGGER trigger_validate_objective_weights_insert
    AFTER INSERT ON objectives
    FOR EACH ROW
    EXECUTE FUNCTION validate_objective_weights();

CREATE TRIGGER trigger_validate_objective_weights_update
    AFTER UPDATE ON objectives
    FOR EACH ROW
    EXECUTE FUNCTION validate_objective_weights();

CREATE TRIGGER trigger_validate_objective_weights_delete
    AFTER DELETE ON objectives
    FOR EACH ROW
    EXECUTE FUNCTION validate_objective_weights();

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to compute task progress
CREATE OR REPLACE FUNCTION compute_task_progress(task_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
    task_rec RECORD;
    has_objectives BOOLEAN;
    has_children BOOLEAN;
    obj_progress INTEGER;
    child_progress INTEGER;
BEGIN
    -- Get task info
    SELECT * INTO task_rec FROM tasks WHERE id = task_uuid;
    
    -- Check if task has objectives
    SELECT EXISTS(SELECT 1 FROM objectives WHERE task_id = task_uuid) INTO has_objectives;
    
    -- Check if task has children
    SELECT EXISTS(SELECT 1 FROM tasks WHERE parent_id = task_uuid) INTO has_children;
    
    -- Case 1: Only objectives exist
    IF has_objectives AND NOT has_children THEN
        SELECT COALESCE(SUM(
            CASE WHEN is_completed THEN 100 ELSE 0 END * weight
        ), 0) / 100 INTO obj_progress
        FROM objectives 
        WHERE task_id = task_uuid;
        
        RETURN obj_progress;
    END IF;
    
    -- Case 2: Only children exist
    IF has_children AND NOT has_objectives THEN
        SELECT COALESCE(AVG(compute_task_progress(id)), 0) INTO child_progress
        FROM tasks 
        WHERE parent_id = task_uuid
        ORDER BY order_index;
        
        RETURN child_progress;
    END IF;
    
    -- Case 3: Both exist - children override (default behavior)
    IF has_children AND has_objectives THEN
        SELECT COALESCE(AVG(compute_task_progress(id)), 0) INTO child_progress
        FROM tasks 
        WHERE parent_id = task_uuid
        ORDER BY order_index;
        
        RETURN child_progress;
    END IF;
    
    -- Case 4: Neither exists
    RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Views for common queries
CREATE VIEW task_with_progress AS
SELECT 
    t.*,
    compute_task_progress(t.id) as progress,
    CASE 
        WHEN t.task_type = 'simple' THEN 
            (SELECT COUNT(*) FROM objectives WHERE task_id = t.id)
        ELSE 
            (SELECT COUNT(*) FROM tasks WHERE parent_id = t.id)
    END as item_count
FROM tasks t;

-- Sample data insertion
INSERT INTO tasks (id, title, description, priority, task_type, color, status) VALUES
    (uuid_generate_v4(), 'Design User Interface', 'Create wireframes and mockups for the new app', 'high', 'simple', 4280391411, 'in_progress'),
    (uuid_generate_v4(), 'Launch Marketing Campaign', 'Execute Q1 marketing campaign across all channels', 'urgent', 'composite', 4294198070, 'pending');

-- SQLite Variant Notes:
-- 1. Replace UUID with TEXT PRIMARY KEY
-- 2. Remove uuid-ossp extension
-- 3. Replace TIMESTAMP WITH TIME ZONE with TEXT (ISO8601 format)
-- 4. Triggers work differently in SQLite - use CHECK constraints or application-level validation
-- 5. Replace NOW() with datetime('now')
-- 6. Replace uuid_generate_v4() with custom function or application-generated IDs

-- Example SQLite table creation:
/*
CREATE TABLE tasks (
    id TEXT PRIMARY KEY,
    parent_id TEXT REFERENCES tasks(id) ON DELETE CASCADE,
    order_index INTEGER NOT NULL DEFAULT 0,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    notes TEXT,
    priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    task_type TEXT NOT NULL CHECK (task_type IN ('simple', 'composite')),
    deadline TEXT,
    color INTEGER NOT NULL,
    reminder_time TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    created_at TEXT NOT NULL DEFAULT datetime('now'),
    updated_at TEXT NOT NULL DEFAULT datetime('now')
);
*/
