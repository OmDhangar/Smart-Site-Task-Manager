# Smart Site Task Manager - Backend API


## 📋 Project Overview
A sophisticated task management backend system that automatically classifies, prioritizes, and organizes tasks using intelligent keyword analysis and entity extraction. Built with production-grade architecture, comprehensive error handling, and extensive testing.

## 🚀 Tech Stack
- **Runtime**: Node.js (v18+)
- **Framework**: Express.js
- **Database**: PostgreSQL (via Supabase)
- **Validation**: Zod
- **Testing**: Jest + Supertest
- **Documentation**: Swagger/OpenAPI
- **Deployment**: Render.com
- **Additional**: Winston (logging), Helmet (security), CORS

## 📁 Project Structure
```
backend/
├── src/
│   ├── config/
│   │   ├── database.js          # Supabase connection
│   │   └── logger.js            # Winston logger setup
│   ├── controllers/
│   │   └── taskController.js    # Request handlers
│   ├── services/
│   │   ├── taskService.js       # Business logic
│   │   └── classificationService.js  # Auto-classification
│   ├── models/
│   │   └── taskModel.js         # Database queries
│   ├── middlewares/
│   │   ├── errorHandler.js      # Global error handling
│   │   ├── validator.js         # Zod validation
│   │   └── rateLimiter.js       # Rate limiting
│   ├── routes/
│   │   └── taskRoutes.js        # API routes
│   ├── utils/
│   │   ├── entityExtractor.js   # Entity extraction logic
│   │   └── responseHandler.js   # Standardized responses
│   ├── schemas/
│   │   └── taskSchema.js        # Zod schemas
│   └── app.js                   # Express app setup
├── tests/
│   ├── unit/
│   │   └── classification.test.js
│   └── integration/
│       └── tasks.test.js
├── .env.example
├── .gitignore
├── package.json
├── jest.config.js
└── README.md
```

## 🗄️ Database Schema

### Tasks Table
```sql
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL CHECK (category IN ('scheduling', 'finance', 'technical', 'safety', 'general')),
    priority TEXT NOT NULL CHECK (priority IN ('high', 'medium', 'low')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
    assigned_to TEXT,
    due_date TIMESTAMP,
    extracted_entities JSONB DEFAULT '{}',
    suggested_actions JSONB DEFAULT '[]',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_category ON tasks(category);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
```

### Task History Table
```sql
CREATE TABLE task_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    action TEXT NOT NULL CHECK (action IN ('created', 'updated', 'status_changed', 'completed', 'deleted')),
    old_value JSONB,
    new_value JSONB,
    changed_by TEXT DEFAULT 'system',
    changed_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_task_history_task_id ON task_history(task_id);
CREATE INDEX idx_task_history_action ON task_history(action);
```

## 🔧 Installation & Setup

### Prerequisites
- Node.js v18 or higher
- PostgreSQL database (Supabase account)
- npm or yarn

### Step 1: Clone Repository
```bash
git clone <your-repo-url>
cd backend
```

### Step 2: Install Dependencies
```bash
npm install
```

### Step 3: Environment Setup
Create `.env` file in the root directory:
```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database (Supabase)
DATABASE_URL=postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres
SUPABASE_URL=https://[PROJECT].supabase.co
SUPABASE_KEY=your_supabase_anon_key

# Security(this is the API key used to authenticate requests for the deployed link)
API_KEY=OD24formeAPIKey!

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### Step 4: Initialize Database
Run the SQL schemas provided above in your Supabase SQL Editor.

### Step 5: Run Development Server
```bash
npm run dev
```

### Step 6: Run Tests
```bash
npm test
```

## 📡 API Documentation

### Base URL
- **Local**: `http://localhost:3000`
- **Production**: `https://your-app.onrender.com`

### Authentication
All endpoints require an API key in the header:
```
X-API-Key: your_secret_api_key_here
```

---

### 1. Create Task
**POST** `/api/tasks`

Creates a new task with automatic classification.

**Request Body:**
```json
{
  "title": "Schedule urgent meeting with team today about budget allocation",
  "description": "Need to discuss Q4 budget with finance team and John from operations",
  "assigned_to": "John Doe",
  "due_date": "2024-12-25T10:00:00Z"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "task": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Schedule urgent meeting with team today about budget allocation",
      "description": "Need to discuss Q4 budget with finance team and John from operations",
      "category": "scheduling",
      "priority": "high",
      "status": "pending",
      "assigned_to": "John Doe",
      "due_date": "2024-12-25T10:00:00.000Z",
      "extracted_entities": {
        "people": ["John"],
        "dates": ["today"],
        "keywords": ["meeting", "team", "budget", "allocation"]
      },
      "suggested_actions": [
        "Block calendar",
        "Send invite",
        "Prepare agenda",
        "Set reminder"
      ],
      "created_at": "2024-12-20T10:30:00.000Z",
      "updated_at": "2024-12-20T10:30:00.000Z"
    }
  },
  "message": "Task created successfully"
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "title",
        "message": "Title is required"
      }
    ]
  }
}
```

---

### 2. Get All Tasks
**GET** `/api/tasks`

Retrieves tasks with optional filtering, sorting, and pagination.

**Query Parameters:**
- `status` (optional): `pending`, `in_progress`, `completed`
- `category` (optional): `scheduling`, `finance`, `technical`, `safety`, `general`
- `priority` (optional): `high`, `medium`, `low`
- `search` (optional): Search in title and description
- `sortBy` (optional): Field to sort by (default: `created_at`)
- `sortOrder` (optional): `asc` or `desc` (default: `desc`)
- `limit` (optional): Number of results (default: 10, max: 100)
- `offset` (optional): Pagination offset (default: 0)

**Example Request:**
```
GET /api/tasks?status=pending&category=scheduling&priority=high&limit=5&offset=0
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "tasks": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "title": "Schedule urgent meeting",
        "category": "scheduling",
        "priority": "high",
        "status": "pending",
        "assigned_to": "John Doe",
        "due_date": "2024-12-25T10:00:00.000Z",
        "created_at": "2024-12-20T10:30:00.000Z"
      }
    ],
    "pagination": {
      "total": 45,
      "limit": 5,
      "offset": 0,
      "totalPages": 9,
      "currentPage": 1,
      "hasNext": true,
      "hasPrevious": false
    }
  }
}
```

---

### 3. Get Task by ID
**GET** `/api/tasks/:id`

Retrieves a specific task with its complete history.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "task": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Schedule urgent meeting",
      "description": "Need to discuss Q4 budget",
      "category": "scheduling",
      "priority": "high",
      "status": "in_progress",
      "assigned_to": "John Doe",
      "due_date": "2024-12-25T10:00:00.000Z",
      "extracted_entities": {
        "people": ["John"],
        "dates": ["today"]
      },
      "suggested_actions": ["Block calendar", "Send invite"],
      "created_at": "2024-12-20T10:30:00.000Z",
      "updated_at": "2024-12-20T11:00:00.000Z"
    },
    "history": [
      {
        "action": "created",
        "changed_by": "system",
        "changed_at": "2024-12-20T10:30:00.000Z",
        "new_value": {
          "status": "pending"
        }
      },
      {
        "action": "status_changed",
        "changed_by": "user_123",
        "changed_at": "2024-12-20T11:00:00.000Z",
        "old_value": {
          "status": "pending"
        },
        "new_value": {
          "status": "in_progress"
        }
      }
    ]
  }
}
```

---

### 4. Update Task
**PATCH** `/api/tasks/:id`

Updates an existing task. Re-runs classification if title/description changes.

**Request Body:**
```json
{
  "status": "in_progress",
  "assigned_to": "Jane Smith"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "task": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Schedule urgent meeting",
      "status": "in_progress",
      "assigned_to": "Jane Smith",
      "updated_at": "2024-12-20T12:00:00.000Z"
    }
  },
  "message": "Task updated successfully"
}
```

---

### 5. Delete Task
**DELETE** `/api/tasks/:id`

Soft deletes a task (marks as deleted in history).

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Task deleted successfully"
}
```

---

## 🧪 Testing

### Run All Tests
```bash
npm test
```

### Run Tests with Coverage
```bash
npm run test:coverage
```

### Test Coverage Includes:
- ✅ Classification logic (category detection)
- ✅ Priority assignment (urgency detection)
- ✅ Entity extraction (people, dates, keywords)
- ✅ API endpoint integration tests
- ✅ Error handling scenarios
- ✅ Validation tests

**Example Test Output:**
```
PASS  tests/unit/classification.test.js
  Classification Service
    ✓ detects scheduling category (15ms)
    ✓ detects finance category (8ms)
    ✓ detects technical category (7ms)
    ✓ assigns high priority for urgent tasks (5ms)
    ✓ assigns medium priority correctly (4ms)
    ✓ extracts person names (6ms)
    ✓ extracts dates and times (5ms)
    ✓ generates appropriate suggested actions (4ms)

Test Suites: 2 passed, 2 total
Tests:       12 passed, 12 total
```

## 🏗️ Architecture Decisions

### 1. **Layered Architecture**
- **Controllers**: Handle HTTP requests/responses
- **Services**: Business logic and classification
- **Models**: Database operations
- **Separation of Concerns**: Each layer has a single responsibility

### 2. **Error Handling Strategy**
- Custom error classes for different error types
- Global error middleware catches all errors
- Consistent error response format
- Detailed logging for debugging

### 3. **Validation Approach**
- Zod for schema validation (type-safe, runtime validation)
- Middleware-based validation
- Clear error messages for client

### 4. **Database Design**
- UUID primary keys for distributed systems
- JSONB for flexible entity storage
- Proper indexing on frequently queried fields
- Audit trail via task_history table

### 5. **Classification Logic**
- Keyword-based detection (extensible)
- Priority weighting system
- Entity extraction using regex patterns
- Configurable action suggestions

## 🚀 Deployment on Render

### Step 1: Push to GitHub
```bash
git init
git add .
git commit -m "Initial commit: Smart Task Manager Backend"
git remote add origin <your-github-repo>
git push -u origin main
```

### Step 2: Create Render Web Service
1. Go to [render.com](https://render.com) and sign in
2. Click "New +" → "Web Service"
3. Connect your GitHub repository
4. Configure:
   - **Name**: `smart-task-manager-api`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free

### Step 3: Add Environment Variables
In Render dashboard, add all variables from `.env`:
- `DATABASE_URL`
- `SUPABASE_URL`
- `SUPABASE_KEY`
- `API_KEY`
- `NODE_ENV=production`

### Step 4: Deploy
Click "Create Web Service" and wait for deployment.

### Health Check Endpoint
```
GET /health
```
Response:
```json
{
  "status": "healthy",
  "timestamp": "2024-12-20T10:30:00.000Z",
  "uptime": 3600
}
```

## 📊 API Response Standards

### Success Response Format
```json
{
  "success": true,
  "data": { ... },
  "message": "Optional success message"
}
```

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": []
  }
}
```

### Error Codes
- `VALIDATION_ERROR`: Invalid input data
- `NOT_FOUND`: Resource not found
- `DATABASE_ERROR`: Database operation failed
- `INTERNAL_ERROR`: Unexpected server error
- `AUTHENTICATION_ERROR`: Invalid API key

## 🔒 Security Features

- **Helmet.js**: Sets secure HTTP headers
- **CORS**: Configured for specific origins
- **Rate Limiting**: 100 requests per 15 minutes
- **API Key Authentication**: Required for all endpoints
- **Input Validation**: Zod schema validation
- **SQL Injection Prevention**: Parameterized queries
- **XSS Protection**: Input sanitization

## 📈 Performance Optimizations

- Database connection pooling
- Indexed database queries
- Pagination for large datasets
- Response compression
- Efficient JSONB queries

## 🔮 What I'd Improve (Given More Time)

1. **Advanced Features**
   - WebSocket for real-time updates
   - Full-text search with PostgreSQL
   - Task attachments/file uploads
   - Recurring tasks support
   - Task dependencies and subtasks

2. **AI Enhancements**
   - LangChain integration for better NLP
   - ML model for classification accuracy
   - Smart due date suggestions
   - Sentiment analysis

3. **Infrastructure**
   - Redis caching layer
   - Background job processing (Bull/BullMQ)
   - Monitoring (Sentry, DataDog)
   - CI/CD pipeline (GitHub Actions)
   - Docker containerization

4. **Testing**
   - E2E tests with Playwright
   - Load testing (k6, Artillery)
   - 90%+ code coverage
   - API contract testing

5. **Documentation**
   - Interactive Swagger UI
   - Postman collection
   - Architecture diagrams
   - API versioning strategy

## 📝 Git Commit Best Practices

This project follows conventional commits:
```
feat: Add task classification service
fix: Handle null due_date in validation
docs: Update API documentation
test: Add entity extraction tests
refactor: Improve error handling middleware
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

MIT License - feel free to use for your projects!

## 👨‍💻 Author

Built with ❤️ for Navicon Infraprojects internship assessment

---

## 📞 Support

For issues or questions:
- Open a GitHub issue
- Email: your-email@example.com

**Live API**: `https://your-app.onrender.com`
**Documentation**: See this README
**Status**: All systems operational ✅