# Quant42 - Complete Application Architecture

## Table of Contents
1. [System Overview](#system-overview)
2. [Technology Stack](#technology-stack)
3. [Architecture Diagram](#architecture-diagram)
4. [Frontend Architecture](#frontend-architecture)
5. [Backend Architecture](#backend-architecture)
6. [Database Schema](#database-schema)
7. [API Architecture](#api-architecture)
8. [Authentication & Authorization](#authentication--authorization)
9. [Real-Time Features](#real-time-features)
10. [AI Integration](#ai-integration)
11. [Market Data Pipeline](#market-data-pipeline)
12. [Deployment Architecture](#deployment-architecture)
13. [Data Flow](#data-flow)
14. [Security Considerations](#security-considerations)

---

## System Overview

Quant42 is a professional algorithmic trading platform consisting of three main applications:

### Applications
1. **Landing Page** (`quant42-ui`) - Marketing and information website
2. **Dashboard** (`quant42-dashboard`) - Main trading platform application
3. **Backend API** (`quant42-backend`) - RESTful API and SignalR hub

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                         Users                                │
└────────────┬────────────────────────────┬───────────────────┘
             │                            │
             ▼                            ▼
┌────────────────────┐         ┌──────────────────────┐
│   Landing Page     │         │    Dashboard App     │
│   (quant42-ui)     │         │  (quant42-dashboard) │
│                    │         │                      │
│  Next.js 15        │         │   React 19 + Vite    │
│  Vercel            │         │   Vercel             │
└────────────────────┘         └──────────┬───────────┘
                                          │
                                          │ HTTPS/WSS
                                          │
                              ┌───────────▼────────────┐
                              │   Backend API          │
                              │  (quant42-backend)     │
                              │                        │
                              │  .NET 8 ASP.NET Core   │
                              │  Railway               │
                              └───────┬────────────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
         ┌──────────────┐  ┌─────────────┐  ┌──────────────┐
         │  PostgreSQL  │  │  OpenAI API │  │  Polygon.io  │
         │   Database   │  │   (GPT-4)   │  │  (Massive)   │
         │   Railway    │  │             │  │   Market     │
         └──────────────┘  └─────────────┘  │     Data     │
                                             └──────────────┘
```

---

## Technology Stack

### Frontend - Landing Page (`quant42-ui`)

**Framework & Core**
- **Next.js 15** - React framework with App Router
- **React 19** - UI library
- **TypeScript** - Type safety
- **TailwindCSS** - Utility-first CSS

**UI Components & Animation**
- **Framer Motion** - Animations and transitions
- **Radix UI** - Accessible UI primitives
- **Lucide React** - Icon library
- **Custom Components** - Liquid glass effects, text effects

**Deployment**
- **Vercel** - Hosting and CDN
- **Repository**: `quant42-ui` / `K4L-EL/quant42-ui`

---

### Frontend - Dashboard (`quant42-dashboard`)

**Framework & Core**
- **Vite** - Build tool and dev server
- **React 19** - UI library
- **TypeScript** - Type safety
- **TailwindCSS** - Styling

**Routing & State Management**
- **TanStack Router** - File-based routing
- **React Hooks** - Local state management
- **Context API** - Global state (auth, user)

**UI Components**
- **Radix UI** - Accessible primitives
- **Shadcn/ui** - Component library
- **Sonner** - Toast notifications
- **Lucide React** - Icons

**Data Visualization & Trading**
- **@xyflow/react (React Flow)** - Node-based strategy builder
- **Recharts** - Charts and graphs
- **Custom Nodes** - Trigger, Condition, Action, Router, Note nodes

**API Communication**
- **Axios** - HTTP client
- **Microsoft SignalR** - WebSocket real-time updates
- **Custom API Client** - Centralized API configuration

**Deployment**
- **Vercel** - Hosting and CDN
- **Repository**: `quant42-dashboard` / `K4L-EL/algo-ui`

---

### Backend API (`quant42-backend`)

**Framework & Core**
- **.NET 8** - Runtime
- **ASP.NET Core Web API** - RESTful API framework
- **C#** - Programming language

**Database & ORM**
- **PostgreSQL** - Relational database
- **Entity Framework Core** - ORM
- **Npgsql** - PostgreSQL driver

**Authentication & Security**
- **JWT Bearer Tokens** - Authentication
- **ASP.NET Core Identity** - User management
- **CORS** - Cross-origin resource sharing
- **BCrypt** - Password hashing

**Real-Time Communication**
- **SignalR** - WebSocket hub for live updates

**Background Jobs**
- **Hangfire** - Job scheduling and processing
- **Cronos** - Cron expression parsing

**External Integrations**
- **HttpClient** - HTTP requests
- **Newtonsoft.Json** - JSON serialization
- **System.Text.Json** - Alternative JSON serializer

**Caching**
- **IMemoryCache** - In-memory caching
- **30-second cache** - Market data

**Deployment**
- **Railway** - Hosting platform
- **PostgreSQL on Railway** - Database
- **Repository**: `quant42-backend` / `K4L-EL/quant42-server`

---

## Architecture Diagram

### Component Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONTEND LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Landing Page (Next.js)              Dashboard (React + Vite)   │
│  ├─ Hero Section                     ├─ Auth Pages              │
│  ├─ Features                         ├─ Portfolio               │
│  ├─ Use Cases                        ├─ Markets                 │
│  ├─ Contact Form                     ├─ Builder                 │
│  └─ Footer                           │  ├─ Strategy Canvas       │
│                                      │  ├─ Node Palette          │
│                                      │  ├─ Node Inspector        │
│                                      │  ├─ AI Chat              │
│                                      │  └─ Tree List            │
│                                      ├─ Watchlist               │
│                                      ├─ Discover                │
│                                      ├─ Team                    │
│                                      └─ Settings                │
│                                                                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │ REST API + SignalR
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                        BACKEND LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Controllers                      Services                       │
│  ├─ AuthController                ├─ MassiveClient              │
│  ├─ MarketsController             ├─ ScheduleService            │
│  ├─ AssetsController              ├─ StrategyExecutionService   │
│  ├─ WatchlistsController          └─ HangfireJobService         │
│  ├─ StrategiesController                                        │
│  ├─ AIController                  Hubs                           │
│  ├─ IndicatorsController          └─ MarketHub (SignalR)        │
│  └─ UsersController                                             │
│                                                                  │
│  Background Jobs (Hangfire)                                     │
│  ├─ Scheduled Strategy Execution                                │
│  ├─ Market Data Updates                                         │
│  └─ Cron-based Triggers                                         │
│                                                                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌───────────────┐  ┌──────────────┐  ┌──────────────┐
│  PostgreSQL   │  │  OpenAI API  │  │  Polygon.io  │
│   Database    │  │   (GPT-4)    │  │   (Massive)  │
├───────────────┤  ├──────────────┤  ├──────────────┤
│ - Users       │  │ - Strategy   │  │ - Real-time  │
│ - Assets      │  │   Generation │  │   Snapshots  │
│ - Strategies  │  │ - Strategy   │  │ - Historical │
│ - Watchlists  │  │   Editing    │  │   Data       │
│ - Backtests   │  │ - Explain    │  │ - Indices    │
│ - Executions  │  │   Strategy   │  │ - Forex      │
└───────────────┘  └──────────────┘  │ - Crypto     │
                                      └──────────────┘
```

---

## Frontend Architecture

### Landing Page (`quant42-ui`)

#### Project Structure
```
quant42-ui/
├── src/
│   ├── app/                      # Next.js App Router
│   │   ├── layout.tsx           # Root layout
│   │   ├── page.tsx             # Home page
│   │   └── globals.css          # Global styles
│   ├── components/
│   │   ├── layout/              # Layout components
│   │   │   ├── Header.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── Container.tsx
│   │   ├── sections/            # Page sections
│   │   │   ├── Hero.tsx
│   │   │   ├── Features.tsx
│   │   │   ├── UseCases.tsx
│   │   │   ├── ContactFooter.tsx
│   │   │   └── WhatQuant42Does.tsx
│   │   └── ui/                  # Reusable UI components
│   │       ├── Button.tsx
│   │       ├── Card.tsx
│   │       ├── Motion.tsx
│   │       └── TextEffect.tsx
│   ├── data/
│   │   └── features.ts          # Feature data
│   └── lib/
│       ├── motion.ts            # Animation variants
│       └── utils.ts             # Utility functions
├── public/                       # Static assets
└── package.json
```

#### Key Features
- **Responsive Design** - Mobile-first approach
- **Animations** - Framer Motion for smooth transitions
- **SEO Optimized** - Next.js metadata and SSR
- **Liquid Glass Effects** - Custom glassmorphism components
- **Performance** - Optimized images and lazy loading

---

### Dashboard (`quant42-dashboard`)

#### Project Structure
```
quant42-dashboard/
├── src/
│   ├── routes/                   # TanStack Router routes
│   │   ├── __root.tsx           # Root route
│   │   ├── index.tsx            # Landing/auth
│   │   └── app/                 # Protected routes
│   │       ├── portfolio.tsx
│   │       ├── markets.tsx
│   │       ├── builder.tsx
│   │       ├── builder.$strategyId.tsx
│   │       ├── watchlist.tsx
│   │       ├── discover.tsx
│   │       ├── team.tsx
│   │       └── settings.tsx
│   ├── features/                 # Feature modules
│   │   ├── auth/
│   │   │   ├── components/      # Login, Register forms
│   │   │   └── context/         # Auth context
│   │   ├── portfolio/
│   │   │   └── pages/
│   │   ├── markets/
│   │   │   └── pages/
│   │   ├── builder/
│   │   │   ├── pages/
│   │   │   │   └── builder-page.tsx
│   │   │   └── components/
│   │   │       ├── custom-node.tsx
│   │   │       ├── sticky-note.tsx
│   │   │       ├── node-palette.tsx
│   │   │       ├── tree-list.tsx
│   │   │       ├── quant-chat.tsx
│   │   │       └── node-inspector/
│   │   │           ├── index.tsx
│   │   │           ├── components/
│   │   │           │   ├── basic-info.tsx
│   │   │           │   └── asset-picker.tsx
│   │   │           ├── config/
│   │   │           │   ├── trigger-config.tsx
│   │   │           │   ├── condition-config.tsx
│   │   │           │   ├── action-config.tsx
│   │   │           │   ├── router-config.tsx
│   │   │           │   └── note-config.tsx
│   │   │           └── tabs/
│   │   │               ├── api-tab.tsx
│   │   │               ├── variables-tab.tsx
│   │   │               ├── branches-tab.tsx
│   │   │               ├── advanced-tab.tsx
│   │   │               └── test-tab.tsx
│   │   ├── watchlist/
│   │   ├── discover/
│   │   ├── team/
│   │   └── settings/
│   ├── services/
│   │   └── stubs/               # API services
│   │       ├── auth-service.ts
│   │       ├── market-service.ts
│   │       ├── watchlist-service.ts
│   │       ├── tree-service.ts
│   │       ├── ai-strategy-service.ts
│   │       └── tree-types.ts
│   ├── components/
│   │   ├── layout/              # Layout components
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Navbar.tsx
│   │   │   └── TickerTape.tsx
│   │   └── ui/                  # Shadcn/ui components
│   ├── lib/
│   │   ├── api-client.ts        # Axios configuration
│   │   └── utils.ts
│   └── utils/
│       └── format/              # Formatting utilities
│           ├── currency.ts
│           └── date.ts
├── public/
└── package.json
```

#### Key Components

**Strategy Builder**
- **React Flow Canvas** - Visual node editor
- **Custom Nodes** - Trigger, Condition, Action, Router, Note
- **Node Inspector** - Configuration panel with tabs
- **AI Chat** - Strategy generation and editing
- **Asset Picker** - Searchable dropdown for assets

**Node Types**
1. **Trigger** - When strategy executes (price change, indicator, schedule, manual)
2. **Condition** - Decision logic (indicator comparisons, variable checks)
3. **Action** - What to execute (buy, sell, API request, notification)
4. **Router** - Conditional branching
5. **Note** - Sticky notes for documentation

---

## Backend Architecture

### Project Structure
```
quant42-backend/
├── Quant42-backend/
│   ├── Controllers/              # API controllers
│   │   ├── AuthController.cs
│   │   ├── MarketsController.cs
│   │   ├── AssetsController.cs
│   │   ├── WatchlistsController.cs
│   │   ├── StrategiesController.cs
│   │   ├── AIController.cs
│   │   ├── IndicatorsController.cs
│   │   └── UsersController.cs
│   ├── Services/                 # Business logic
│   │   ├── MassiveClient.cs     # Polygon.io integration
│   │   ├── ScheduleService.cs   # Cron scheduling
│   │   ├── StrategyExecutionService.cs
│   │   └── HangfireJobService.cs
│   ├── Data/
│   │   ├── Quant42DbContext.cs  # EF Core context
│   │   └── Entities/            # Database models
│   │       ├── User.cs
│   │       ├── Asset.cs
│   │       ├── Strategy.cs
│   │       ├── Watchlist.cs
│   │       ├── WatchlistItem.cs
│   │       ├── Backtest.cs
│   │       └── StrategyExecution.cs
│   ├── DTOs/                     # Data transfer objects
│   │   └── AllDtos.cs
│   ├── Hubs/                     # SignalR hubs
│   │   └── MarketHub.cs
│   ├── Migrations/               # EF Core migrations
│   ├── Program.cs                # App configuration
│   ├── appsettings.json
│   └── Quant42-backend.csproj
└── Quant42-backend.sln
```

### API Controllers

#### AuthController
- **POST** `/api/auth/register` - User registration
- **POST** `/api/auth/login` - User login (returns JWT)
- **GET** `/api/auth/me` - Get current user

#### MarketsController
- **GET** `/api/market/snapshots` - Get stock snapshots
- **GET** `/api/market/snapshots/all-markets` - Get all markets (stocks, indices, forex, crypto)
- **GET** `/api/market/{assetId}/history` - Get historical bars
- **GET** `/api/market/last-quote` - Get last quote for symbol
- **GET** `/api/market/last-trade` - Get last trade for symbol
- **GET** `/api/market/debug/test-polygon` - Debug endpoint

#### AssetsController
- **GET** `/api/assets` - Get assets with filtering
- **GET** `/api/assets/{assetId}` - Get asset by ID

#### WatchlistsController (Authorized)
- **GET** `/api/watchlists` - Get user's watchlists
- **GET** `/api/watchlists/{watchlistId}` - Get specific watchlist
- **POST** `/api/watchlists` - Create watchlist
- **PUT** `/api/watchlists/{watchlistId}` - Update watchlist
- **DELETE** `/api/watchlists/{watchlistId}` - Delete watchlist
- **POST** `/api/watchlists/{watchlistId}/items` - Add item to watchlist
- **DELETE** `/api/watchlists/{watchlistId}/items/{assetId}` - Remove item

#### StrategiesController (Authorized)
- **GET** `/api/strategies` - Get user's strategies
- **GET** `/api/strategies/{strategyId}` - Get strategy details
- **POST** `/api/strategies` - Create strategy
- **PUT** `/api/strategies/{strategyId}` - Update strategy
- **DELETE** `/api/strategies/{strategyId}` - Delete strategy
- **POST** `/api/strategies/{strategyId}/activate` - Activate strategy
- **POST** `/api/strategies/{strategyId}/deactivate` - Deactivate strategy

#### AIController (Authorized)
- **POST** `/api/ai/generate-strategy` - Generate new strategy from description
- **POST** `/api/ai/edit-strategy` - Edit existing strategy
- **POST** `/api/ai/explain-strategy` - Generate sticky notes explaining strategy

#### IndicatorsController
- **GET** `/api/indicators` - Get available indicators
- **GET** `/api/indicators/{indicatorId}/schema` - Get indicator parameters

---

## Database Schema

### Entity Relationship Diagram

```
┌─────────────────┐
│      Users      │
├─────────────────┤
│ Id (PK)         │
│ Email           │
│ PasswordHash    │
│ FirstName       │
│ LastName        │
│ CreatedAt       │
└────────┬────────┘
         │
         │ 1:N
         │
    ┌────┴──────────────────────────────┐
    │                                   │
    ▼                                   ▼
┌─────────────────┐           ┌──────────────────┐
│   Watchlists    │           │    Strategies    │
├─────────────────┤           ├──────────────────┤
│ Id (PK)         │           │ Id (PK)          │
│ UserId (FK)     │           │ UserId (FK)      │
│ Name            │           │ Name             │
│ CreatedAt       │           │ Description      │
│ UpdatedAt       │           │ GraphJson        │
└────────┬────────┘           │ CronExpression   │
         │                    │ Timezone         │
         │ 1:N                │ IsActive         │
         │                    │ CreatedAt        │
         ▼                    │ UpdatedAt        │
┌─────────────────┐           └──────────┬───────┘
│ WatchlistItems  │                      │
├─────────────────┤                      │ 1:N
│ WatchlistId(FK) │◄─────┐               │
│ AssetId (FK)    │      │               ▼
│ AddedAt         │      │   ┌─────────────────────┐
│ CreatedAt       │      │   │ StrategyExecutions  │
└────────┬────────┘      │   ├─────────────────────┤
         │               │   │ Id (PK)             │
         │               │   │ StrategyId (FK)     │
         │               │   │ ExecutedAt          │
         │               │   │ Status              │
         │               │   │ ResultJson          │
         │               │   │ ErrorMessage        │
         │               │   └─────────────────────┘
         │               │
         │ N:1           │
         ▼               │
┌─────────────────┐      │
│     Assets      │──────┘
├─────────────────┤
│ Id (PK)         │
│ Symbol          │
│ Name            │
│ AssetType       │
│ MassiveTicker   │
│ Currency        │
│ IsActive        │
└─────────────────┘
```

### Database Tables

#### Users
```sql
CREATE TABLE Users (
    Id UUID PRIMARY KEY,
    Email VARCHAR(255) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    CreatedAt TIMESTAMP NOT NULL
);
```

#### Assets
```sql
CREATE TABLE Assets (
    Id UUID PRIMARY KEY,
    Symbol VARCHAR(20) UNIQUE NOT NULL,
    Name VARCHAR(200),
    AssetType VARCHAR(50),  -- 'stock', 'crypto', 'forex', 'index'
    MassiveTicker VARCHAR(50),
    Currency VARCHAR(10),
    IsActive BOOLEAN DEFAULT TRUE
);
```

#### Strategies
```sql
CREATE TABLE Strategies (
    Id UUID PRIMARY KEY,
    UserId UUID NOT NULL REFERENCES Users(Id),
    Name VARCHAR(200) NOT NULL,
    Description TEXT,
    GraphJson TEXT,  -- React Flow graph stored as JSON
    CronExpression VARCHAR(100),
    Timezone VARCHAR(50) DEFAULT 'America/New_York',
    IsActive BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP NOT NULL,
    UpdatedAt TIMESTAMP NOT NULL
);
```

#### Watchlists
```sql
CREATE TABLE Watchlists (
    Id UUID PRIMARY KEY,
    UserId UUID NOT NULL REFERENCES Users(Id),
    Name VARCHAR(100) NOT NULL,
    CreatedAt TIMESTAMP NOT NULL,
    UpdatedAt TIMESTAMP NOT NULL
);
```

#### WatchlistItems
```sql
CREATE TABLE WatchlistItems (
    WatchlistId UUID NOT NULL REFERENCES Watchlists(Id) ON DELETE CASCADE,
    AssetId UUID NOT NULL REFERENCES Assets(Id),
    AddedAt TIMESTAMP NOT NULL,
    CreatedAt TIMESTAMP NOT NULL,
    PRIMARY KEY (WatchlistId, AssetId)
);
```

#### StrategyExecutions
```sql
CREATE TABLE StrategyExecutions (
    Id UUID PRIMARY KEY,
    StrategyId UUID NOT NULL REFERENCES Strategies(Id) ON DELETE CASCADE,
    ExecutedAt TIMESTAMP NOT NULL,
    Status VARCHAR(50),  -- 'success', 'failed', 'pending'
    ResultJson TEXT,
    ErrorMessage TEXT
);
```

---

## API Architecture

### Request/Response Flow

```
┌──────────┐
│  Client  │
└────┬─────┘
     │
     │ 1. HTTP Request (with JWT)
     │
     ▼
┌────────────────────────────────────┐
│   ASP.NET Core Middleware          │
├────────────────────────────────────┤
│  1. CORS                           │
│  2. Authentication (JWT)           │
│  3. Authorization                  │
│  4. Exception Handler              │
└──────────┬─────────────────────────┘
           │
           │ 2. Route to Controller
           │
           ▼
┌──────────────────────────┐
│      Controller          │
├──────────────────────────┤
│  - Validate request      │
│  - Extract user context  │
│  - Call service layer    │
└──────────┬───────────────┘
           │
           │ 3. Business logic
           │
           ▼
┌──────────────────────────┐
│      Service Layer       │
├──────────────────────────┤
│  - MassiveClient         │
│  - ScheduleService       │
│  - ExecutionService      │
└──────────┬───────────────┘
           │
      ┌────┴────┐
      │         │
      ▼         ▼
┌──────────┐ ┌───────────┐
│ Database │ │ External  │
│          │ │    APIs   │
└──────────┘ └───────────┘
```

### Authentication Flow

```
1. User Registration
   ┌────────┐                          ┌─────────┐
   │ Client │─── POST /api/auth/register ───►│ Backend │
   └────────┘                          └────┬────┘
                                            │
                                            │ Hash password (BCrypt)
                                            │ Save to database
                                            │
                                       ┌────▼────┐
                                       │   User  │
                                       │ Created │
                                       └─────────┘

2. User Login
   ┌────────┐                          ┌─────────┐
   │ Client │─── POST /api/auth/login ───────►│ Backend │
   └────────┘                          └────┬────┘
                                            │
                                            │ Verify password
                                            │ Generate JWT token
                                            │
   ┌────────┐                          ┌────▼────┐
   │ Client │◄──── JWT Token ────────────│ Backend │
   └────────┘                          └─────────┘
       │
       │ Store in localStorage
       │
       ▼
   Subsequent requests include:
   Authorization: Bearer <JWT_TOKEN>
```

---

## Authentication & Authorization

### JWT Token Structure

```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user-guid",
    "email": "user@example.com",
    "nameid": "user-guid",
    "exp": 1234567890,
    "iat": 1234567890
  },
  "signature": "..."
}
```

### Authorization Levels

1. **Public Routes** - No authentication required
   - Landing page
   - Login/Register
   - Market data (read-only)

2. **Authenticated Routes** - Requires valid JWT
   - All `/app/*` routes in dashboard
   - Most API endpoints

3. **Owner-Only Actions** - User can only access their own data
   - Strategies
   - Watchlists
   - Backtests

---

## Real-Time Features

### SignalR Hub Architecture

```
┌──────────────────────────────────────────────────────┐
│                  MarketHub (SignalR)                  │
├──────────────────────────────────────────────────────┤
│                                                       │
│  Server Methods:                                     │
│  - JoinMarketGroup(symbol)                          │
│  - LeaveMarketGroup(symbol)                         │
│                                                       │
│  Client Methods (pushed to browser):                │
│  - ReceiveMarketUpdate(symbol, data)                │
│  - ReceiveStrategyUpdate(strategyId, status)        │
│                                                       │
└──────────────────────────────────────────────────────┘
```

### Connection Flow

```
1. Client connects
   ┌────────┐                              ┌──────────┐
   │ Client │─── WSS connection ─────────►│ SignalR  │
   └────────┘                              │   Hub    │
                                           └──────────┘

2. Join market group
   ┌────────┐                              ┌──────────┐
   │ Client │─── JoinMarketGroup("AAPL") ─►│ SignalR  │
   └────────┘                              │   Hub    │
                                           └──────────┘

3. Receive updates
   ┌────────┐                              ┌──────────┐
   │ Client │◄── ReceiveMarketUpdate() ────│ SignalR  │
   └────────┘                              │   Hub    │
                                           └──────────┘
```

---

## AI Integration

### OpenAI GPT-4 Integration

```
┌──────────────────────────────────────────────────────┐
│                  AIController                         │
├──────────────────────────────────────────────────────┤
│                                                       │
│  1. Generate Strategy                                │
│     - User description → GPT-4                       │
│     - Returns: Strategy graph JSON                   │
│                                                       │
│  2. Edit Strategy                                    │
│     - Current graph + edit request → GPT-4          │
│     - Returns: Modified graph JSON                   │
│                                                       │
│  3. Explain Strategy                                 │
│     - Strategy graph → GPT-4                         │
│     - Returns: Sticky notes explaining logic         │
│                                                       │
└──────────────────────────────────────────────────────┘
```

### System Prompt Structure

The backend sends a comprehensive system prompt to GPT-4 that includes:
- Available node types (Trigger, Condition, Action, Router, Note)
- Configuration options for each node type
- Examples of valid strategies
- Cron expression reference
- Available assets and indicators
- Validation rules

### Response Format

GPT-4 returns structured JSON:
```json
{
  "name": "Strategy Name",
  "description": "Strategy description",
  "nodes": [
    {
      "id": "node-1",
      "type": "trigger",
      "position": { "x": 100, "y": 100 },
      "data": {
        "label": "Market Open Trigger",
        "config": {
          "triggerType": "schedule",
          "cronExpression": "30 9 * * 1-5",
          "timezone": "America/New_York"
        }
      }
    }
  ],
  "edges": [
    {
      "id": "edge-1",
      "source": "node-1",
      "target": "node-2"
    }
  ]
}
```

---

## Market Data Pipeline

### Polygon.io (Massive) Integration

```
┌──────────────────────────────────────────────────────┐
│              MassiveClient.cs                         │
├──────────────────────────────────────────────────────┤
│                                                       │
│  1. GetRealtimeSnapshots(market)                     │
│     - Fetches live stock data during market hours    │
│     - Endpoint: /v2/snapshot/locale/us/markets/...   │
│                                                       │
│  2. GetDailyGrouped(date)                            │
│     - Fetches previous day's data (fallback)         │
│     - Endpoint: /v2/aggs/grouped/locale/us/...       │
│                                                       │
│  3. GetAllMarketsSnapshots()                         │
│     - Stocks: Real-time or previous day              │
│     - Indices: I:SPX, I:NDX, I:DJI, I:RUT            │
│     - Forex: C:EURUSD, C:GBPUSD, etc.                │
│     - Crypto: X:BTCUSD, X:ETHUSD, X:SOLUSD           │
│                                                       │
│  4. GetBars(symbol, timeframe, from, to)             │
│     - Historical OHLCV data                          │
│                                                       │
└──────────────────────────────────────────────────────┘
```

### Caching Strategy

```
┌────────────────────────────────────────┐
│        IMemoryCache                     │
├────────────────────────────────────────┤
│                                         │
│  Key: "market_snapshots"                │
│  Duration: 30 seconds                   │
│  Data: Stock snapshots                  │
│                                         │
│  Key: "all_markets_snapshots"           │
│  Duration: 30 seconds                   │
│  Data: All markets (stocks + indices    │
│        + forex + crypto)                │
│                                         │
└────────────────────────────────────────┘
```

### Data Filtering (Backend)

1. **Mega Cap Stocks** (50 companies)
   - AAPL, MSFT, GOOGL, META, AMZN, etc.
   - Must have volume > 0

2. **Liquid Stocks**
   - Volume > 100,000
   - Price > $1 (no penny stocks)

3. **Indices** (4)
   - I:SPX, I:NDX, I:DJI, I:RUT

4. **Crypto** (3)
   - X:BTCUSD, X:ETHUSD, X:SOLUSD
   - Must have volume > 0

5. **Forex** (4)
   - C:EURUSD, C:GBPUSD, C:USDJPY, C:AUDUSD

### Priority Order

```
Response Priority:
1. Mega Caps (always first)
2. Indices
3. Crypto
4. Forex
5. Other liquid stocks

Result: ~200 high-quality assets
```

---

## Deployment Architecture

### Production Environment

```
┌─────────────────────────────────────────────────────┐
│                    Vercel CDN                        │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Landing Page: quant42-ui.vercel.app                │
│  Dashboard: quant42-dashboard.vercel.app            │
│                                                      │
│  - Auto-deploy from main branch                     │
│  - Edge network (global CDN)                        │
│  - Automatic HTTPS                                  │
│  - Preview deployments for PRs                      │
│                                                      │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                  Railway Platform                    │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Backend API: quant42-server.railway.app            │
│  PostgreSQL: Managed database                       │
│                                                      │
│  - Auto-deploy from main branch                     │
│  - Container-based deployment                       │
│  - Environment variables                            │
│  - Automatic SSL                                    │
│  - Database backups                                 │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### Environment Variables

**Frontend (Dashboard)**
```bash
VITE_API_BASE_URL=https://quant42-server.railway.app
```

**Backend**
```bash
# Database
ConnectionStrings__DefaultConnection=postgresql://...

# JWT
JWT_SECRET=<secret-key>
JWT_ISSUER=quant42-backend
JWT_AUDIENCE=quant42-frontend

# External APIs
OPENAI_API_KEY=<openai-key>
POLYGON_API_KEY=<polygon-key>

# CORS
ALLOWED_ORIGINS=https://quant42-dashboard.vercel.app
```

---

## Data Flow

### Strategy Creation Flow

```
1. User Types Description in AI Chat
   ┌─────────┐
   │ User UI │
   └────┬────┘
        │
        │ "Buy NASDAQ at market open if SPY is positive"
        │
        ▼
   ┌──────────────┐
   │  AI Service  │
   └──────┬───────┘
          │
          │ POST /api/ai/generate-strategy
          │
          ▼
   ┌─────────────────┐
   │  AIController   │
   └────────┬────────┘
            │
            │ Send to OpenAI with system prompt
            │
            ▼
   ┌─────────────────┐
   │   OpenAI GPT-4  │
   └────────┬────────┘
            │
            │ Returns strategy JSON
            │
            ▼
   ┌──────────────────┐
   │   AIController   │
   │                  │
   │  1. Parse JSON   │
   │  2. Validate     │
   │  3. Transform    │
   └────────┬─────────┘
            │
            │ Return to frontend
            │
            ▼
   ┌──────────────────┐
   │  AI Service      │
   └────────┬─────────┘
            │
            │ Update React Flow canvas
            │
            ▼
   ┌──────────────────┐
   │  Builder Page    │
   │                  │
   │  Renders nodes   │
   │  and edges       │
   └──────────────────┘
```

### Market Data Flow

```
1. User Opens Markets Page
   ┌─────────┐
   │ User UI │
   └────┬────┘
        │
        │ useEffect() on mount
        │
        ▼
   ┌──────────────────┐
   │  Market Service  │
   └────────┬─────────┘
            │
            │ GET /api/market/snapshots/all-markets
            │
            ▼
   ┌────────────────────┐
   │ MarketsController  │
   └────────┬───────────┘
            │
            │ Check cache (30s)
            │
       ┌────┴────┐
       │ Hit?    │
       └────┬────┘
            │
      ┌─────┴─────┐
      │           │
     Yes         No
      │           │
      │           ▼
      │    ┌──────────────┐
      │    │MassiveClient │
      │    └──────┬───────┘
      │           │
      │           │ Call Polygon.io API
      │           │
      │           ▼
      │    ┌──────────────┐
      │    │ Polygon.io   │
      │    └──────┬───────┘
      │           │
      │           │ Return market data
      │           │
      │           ▼
      │    ┌──────────────┐
      │    │MassiveClient │
      │    │              │
      │    │ 1. Parse     │
      │    │ 2. Filter    │
      │    │ 3. Prioritize│
      │    └──────┬───────┘
      │           │
      │           │ Cache result
      │           │
      └───────────┘
            │
            │ Return filtered data
            │
            ▼
   ┌──────────────────┐
   │  Market Service  │
   └────────┬─────────┘
            │
            │ Update state
            │
            ▼
   ┌──────────────────┐
   │   Markets Page   │
   │                  │
   │ Display:         │
   │ - Mega caps      │
   │ - Indices        │
   │ - Crypto         │
   │ - Forex          │
   └──────────────────┘
```

### Watchlist Persistence Flow

```
1. User Adds Asset to Watchlist
   ┌─────────┐
   │ User UI │
   └────┬────┘
        │
        │ Click "+ Add to Watchlist"
        │
        ▼
   ┌─────────────────────┐
   │  Watchlist Service  │
   └────────┬────────────┘
            │
            │ POST /api/watchlists/{id}/items
            │ Body: { assetId: "AAPL" }
            │
            ▼
   ┌──────────────────────────┐
   │  WatchlistsController    │
   └────────┬─────────────────┘
            │
            │ 1. Parse assetId (symbol)
            │ 2. Lookup Asset by symbol
            │ 3. If not found, create Asset
            │ 4. Add WatchlistItem
            │
            ▼
   ┌──────────────────────────┐
   │      PostgreSQL          │
   │                          │
   │  INSERT INTO            │
   │  WatchlistItems         │
   │  (WatchlistId, AssetId) │
   └────────┬─────────────────┘
            │
            │ Return updated watchlist
            │
            ▼
   ┌──────────────────────────┐
   │  WatchlistsController    │
   │                          │
   │  Include Asset.Symbol in │
   │  response (not GUID)     │
   └────────┬─────────────────┘
            │
            │ { assetId: "AAPL", ... }
            │
            ▼
   ┌─────────────────────┐
   │  Watchlist Service  │
   └────────┬────────────┘
            │
            │ Update local state
            │
            ▼
   ┌──────────────────────────┐
   │     Watchlist Page       │
   │                          │
   │  Display asset with      │
   │  real-time price data    │
   └──────────────────────────┘

2. User Refreshes Page
   ┌─────────┐
   │ User UI │
   └────┬────┘
        │
        │ Page reload
        │
        ▼
   ┌─────────────────────┐
   │  Watchlist Service  │
   └────────┬────────────┘
            │
            │ GET /api/watchlists
            │
            ▼
   ┌──────────────────────────┐
   │  WatchlistsController    │
   └────────┬─────────────────┘
            │
            │ .Include(w => w.Items)
            │    .ThenInclude(i => i.Asset)
            │
            ▼
   ┌──────────────────────────┐
   │      PostgreSQL          │
   │                          │
   │  JOIN WatchlistItems     │
   │  with Assets             │
   └────────┬─────────────────┘
            │
            │ Return items with symbols
            │
            ▼
   ┌──────────────────────────┐
   │  WatchlistsController    │
   │                          │
   │  Items: [                │
   │    { assetId: "AAPL" }   │
   │  ]                       │
   └────────┬─────────────────┘
            │
            ▼
   ┌──────────────────────────┐
   │     Watchlist Page       │
   │                          │
   │  Match "AAPL" to market  │
   │  data by symbol          │
   │                          │
   │  ✅ Persists correctly   │
   └──────────────────────────┘
```

---

## Security Considerations

### Frontend Security
- **HTTPS Only** - All traffic encrypted
- **JWT Storage** - localStorage (consider httpOnly cookies for production)
- **CORS** - Strict origin checking
- **Input Validation** - Client-side validation
- **XSS Prevention** - React's built-in escaping

### Backend Security
- **JWT Authentication** - Secure token-based auth
- **Password Hashing** - BCrypt with salt
- **SQL Injection Prevention** - Entity Framework parameterized queries
- **CORS Policy** - Whitelist allowed origins
- **Rate Limiting** - TODO: Implement for production
- **API Key Security** - Environment variables only

### Database Security
- **Connection String** - Stored in environment variables
- **Encrypted Connection** - SSL/TLS to PostgreSQL
- **Principle of Least Privilege** - User can only access their own data
- **Foreign Keys** - Enforce referential integrity
- **Cascade Deletes** - Properly configured relationships

---

## Performance Optimizations

### Frontend
- **Code Splitting** - Route-based lazy loading
- **Asset Optimization** - Vite build optimization
- **Caching** - React Query (future enhancement)
- **Memoization** - React.memo for expensive components
- **Virtual Scrolling** - For large lists (future enhancement)

### Backend
- **Response Caching** - 30-second cache for market data
- **Database Indexing** - On UserId, Symbol, AssetId
- **Eager Loading** - .Include() to prevent N+1 queries
- **Connection Pooling** - PostgreSQL connection pooling
- **Asynchronous Operations** - async/await throughout

### API
- **Pagination** - Limit responses to 200 items max
- **Field Selection** - Return only needed fields in DTOs
- **Compression** - Gzip compression (TODO)
- **CDN** - Vercel's edge network for static assets

---

## Monitoring & Logging

### Frontend
- **Console Logging** - Development only
- **Error Boundaries** - Catch React errors
- **Toasts** - User-friendly error messages
- **Vercel Analytics** - Usage metrics

### Backend
- **Console.WriteLine** - Development logging
- **Exception Handling** - Global exception handler
- **Hangfire Dashboard** - Job monitoring
- **Railway Logs** - Centralized logging

### Future Enhancements
- **Application Insights** - Telemetry
- **Sentry** - Error tracking
- **Custom logging** - Structured logging with Serilog

---

## Testing Strategy

### Frontend Testing (TODO)
- **Unit Tests** - Vitest
- **Component Tests** - React Testing Library
- **E2E Tests** - Playwright
- **Type Safety** - TypeScript strict mode

### Backend Testing (TODO)
- **Unit Tests** - xUnit
- **Integration Tests** - TestServer
- **API Tests** - Postman/Newman
- **Load Tests** - k6

---

## Future Architecture Enhancements

### Planned Features
1. **WebSocket Market Data** - Real-time price updates via SignalR
2. **Redis Cache** - Distributed caching layer
3. **Message Queue** - RabbitMQ for background jobs
4. **Microservices** - Split into strategy, execution, data services
5. **GraphQL** - Alternative to REST for complex queries
6. **Kubernetes** - Container orchestration
7. **CI/CD Pipeline** - GitHub Actions for automated testing/deployment

### Scalability Considerations
- **Horizontal Scaling** - Load balancer + multiple backend instances
- **Database Read Replicas** - Separate read/write databases
- **CDN Optimization** - Cache static assets globally
- **API Gateway** - Rate limiting and request routing
- **Microservices** - Independent scaling of services

---

## Technology Versions

### Frontend
- **Node.js**: 20.x
- **React**: 19.x
- **Next.js**: 15.x
- **Vite**: 7.x
- **TypeScript**: 5.x
- **TailwindCSS**: 4.x

### Backend
- **.NET**: 8.0
- **Entity Framework Core**: 8.0
- **PostgreSQL**: 15.x
- **SignalR**: 8.0
- **Hangfire**: 1.8.x

### External Services
- **OpenAI**: GPT-4
- **Polygon.io**: v2 API (upgraded subscription)
- **Vercel**: Latest
- **Railway**: Latest

---

## Repository Structure

```
quant42/
├── quant42-ui/              # Landing page (Next.js)
│   ├── .git/
│   └── ...
│
├── quant42-dashboard/       # Dashboard app (React + Vite)
│   ├── .git/
│   └── ...
│
├── quant42-backend/         # Backend API (.NET 8)
│   ├── .git/
│   └── ...
│
└── Documentation files (this folder)
    ├── ARCHITECTURE.md
    ├── DASHBOARD_COMPREHENSIVE_FIXES.md
    ├── MARKET_DATA_AND_WATCHLIST_FIXES.md
    ├── AI_EXPLAIN_STRATEGY_FEATURE.md
    └── ...
```

---

## Contact & Support

For questions about the architecture or implementation details, refer to:
- Code comments in repositories
- Other markdown documentation files
- Git commit history for detailed change logs

---

**Document Version**: 1.0  
**Last Updated**: February 9, 2026  
**Author**: AI Assistant with User (Khalil Mohamed)
