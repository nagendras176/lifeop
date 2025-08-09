# Queue of Life - Implementation Summary

## 1. Summary (≤80 words)

Enhanced Task Definition screen supports simple tasks, weighted objectives (sum=100%), and recursive subtask queues. Data models use immutable patterns with copyWith, parentId/orderIndex for tree structure, and pure progress computation. SQL schema enforces constraints via triggers, with comprehensive validation and performance indexes.

## 2. UX Spec for "Task Definition" Screen

### Fields/Controls
- **Task Name** (required): Text input with validation
- **Description** (required): Multi-line text area
- **Task Type**: Radio buttons for Simple/Composite
- **Objectives Section** (Simple tasks only):
  - Dynamic list of objectives with name, weight (%), completion checkbox
  - Live "Remaining weight" indicator
  - Auto-balance button for unassigned weights
  - Add/Remove objective buttons
- **Subtasks Section** (Composite tasks only):
  - Reorderable list of subtasks
  - Add/Remove subtask buttons
  - Drag handles for reordering
- **Priority**: Dropdown (Low, Medium, High, Urgent)
- **Deadline**: Date and time pickers
- **Color**: Color picker with preview
- **Reminder**: Toggle with time picker
- **Notes**: Optional multi-line text area

### Empty/Valid/Error States
- **Empty**: Placeholder text and helpful guidance
- **Valid**: Green checkmarks, enabled save button
- **Error**: Red error messages below fields, disabled save until resolved

### Interactions
- **Task Type Switching**: Automatically clears objectives when switching to composite
- **Weight Validation**: Real-time calculation with inline error display
- **Auto-balance**: Distributes remaining weight evenly among unassigned objectives
- **Subtask Reordering**: Drag-and-drop with visual feedback
- **Form Validation**: Prevents save until all required fields are valid

### Objective Editor
- **Name Field**: Text input with duplicate name validation
- **Weight Field**: Number input (0-100) with validation
- **Completion Checkbox**: Toggle for objective status
- **Live Indicator**: Shows remaining weight percentage
- **Auto-balance**: Smart distribution of unassigned weights

### Subtask Queue Editor
- **Add Button**: Creates new subtask with default values
- **Delete Button**: Removes subtask and reorders remaining
- **Drag Handles**: Visual indicators for reordering
- **Disabled State**: When validation fails, prevents modifications

### Microcopy Examples
- "Weights must total 100% (currently 85%)"
- "Objective name must be unique"
- "Task title is required"
- "Description must be 1000 characters or less"

## 3. Data Models (Dart)

### Task Class
```dart
class Task {
  final String id;
  final String title;
  final String description;
  final String? notes;
  final Priority priority;
  final TaskType taskType;
  final DateTime? deadline;
  final Color color;
  final DateTime? reminderTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TaskStatus status;
  final String? parentId;
  final int orderIndex;
  final List<Objective> objectives;
  
  // copyWith method for immutable updates
  // toJson/fromJson for serialization
}
```

### Objective Class
```dart
class Objective {
  final String id;
  final String name;
  final int weight;
  final bool isCompleted;
  
  // copyWith method for immutable updates
  // toJson/fromJson for serialization
}
```

### Progress Computation Function
```dart
int computeTaskProgress(Task task, List<Task> children, List<Objective> objectives)
```

**Rules:**
1. **Objectives Only**: Return weighted completion of objectives
2. **Children Only**: Return weighted average of children progress
3. **Both Exist**: Children override objectives (default behavior)
4. **Neither**: Return 0

## 4. JSON Schema (Draft 2020-12)

### Task Schema
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["id", "title", "description", "priority", "taskType", "color", "createdAt", "updatedAt"],
  "properties": {
    "id": { "type": "string", "pattern": "^[a-zA-Z0-9_-]+$" },
    "title": { "type": "string", "maxLength": 255 },
    "description": { "type": "string", "maxLength": 1000 },
    "notes": { "type": "string" },
    "priority": { "enum": ["low", "medium", "high", "urgent"] },
    "taskType": { "enum": ["simple", "composite"] },
    "deadline": { "type": "string", "format": "date-time" },
    "color": { "type": "integer" },
    "reminderTime": { "type": "string", "format": "date-time" },
    "createdAt": { "type": "string", "format": "date-time" },
    "updatedAt": { "type": "string", "format": "date-time" },
    "status": { "enum": ["pending", "in_progress", "completed", "cancelled"] },
    "parentId": { "type": "string" },
    "orderIndex": { "type": "integer", "minimum": 0 },
    "objectives": {
      "type": "array",
      "items": { "$ref": "#/definitions/objective" }
    }
  }
}
```

### Objective Schema
```json
{
  "definitions": {
    "objective": {
      "type": "object",
      "required": ["id", "name", "weight"],
      "properties": {
        "id": { "type": "string" },
        "name": { "type": "string", "maxLength": 255 },
        "weight": { "type": "integer", "minimum": 0, "maximum": 100 },
        "isCompleted": { "type": "boolean" }
      }
    }
  }
}
```

## 5. SQL Schema (PostgreSQL)

### Tables Structure
```sql
-- Tasks table with tree support
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
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Objectives table
CREATE TABLE objectives (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    weight INTEGER NOT NULL CHECK (weight BETWEEN 0 AND 100),
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(task_id, name)
);
```

### Constraints and Triggers
- **Weight Validation**: Trigger ensures objectives sum to 100% per task
- **Composite Constraint**: Composite tasks cannot have objectives
- **Unique Names**: Objective names must be unique per task
- **Cascade Delete**: Deleting a task removes all children and objectives

### Performance Indexes
```sql
CREATE INDEX idx_tasks_parent_order ON tasks(parent_id, order_index);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);
CREATE INDEX idx_objectives_task_id ON objectives(task_id);
```

### SQLite Variant Notes
- Replace UUID with TEXT PRIMARY KEY
- Remove uuid-ossp extension
- Replace TIMESTAMP WITH TIME ZONE with TEXT (ISO8601 format)
- Use CHECK constraints instead of triggers for weight validation
- Replace NOW() with datetime('now')

## Implementation Status

✅ **Completed:**
- Enhanced data models with objectives and recursive subtasks
- Immutable models with copyWith and JSON serialization
- Pure progress computation function
- Comprehensive validation utilities
- Updated Task Definition screen with objectives and subtasks
- Updated Task Queue screen for new models
- SQL schema with constraints and triggers
- Test examples demonstrating all functionality

🔄 **Ready for:**
- Database integration
- API development
- Advanced subtask management
- Progress visualization
- Performance optimization

## Key Features Implemented

1. **Simple Tasks**: Support objectives with weighted completion
2. **Composite Tasks**: Support recursive subtask hierarchies
3. **Weight Validation**: Ensures objectives sum to exactly 100%
4. **Progress Computation**: Pure function with clear precedence rules
5. **Tree Structure**: Parent-child relationships with ordering
6. **Immutable Models**: Safe updates with copyWith pattern
7. **JSON Serialization**: Full round-trip serialization support
8. **Comprehensive Validation**: Field-level and business rule validation
9. **SQL Schema**: Production-ready database design
10. **Test Coverage**: Examples of all features and edge cases
