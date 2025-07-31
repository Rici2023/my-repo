
# ============================================================================
# AI Product Manager Coach Project - Automatyczny Setup
# Skrypt PowerShell do utworzenia kompletnej struktury projektu
# Wersja: 1.0
# Autor: AI Assistant
# Data: 2025-07-31
# ============================================================================

param(
    [string]$ProjectPath = "C:\AI-Product-Manager-Coach",
    [switch]$SkipChecks = $false
)

# Kolory dla komunikatów
$Host.UI.RawUI.ForegroundColor = "White"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Message
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-ColorOutput "=" * 60 "Cyan"
    Write-ColorOutput " $Title" "Yellow"
    Write-ColorOutput "=" * 60 "Cyan"
    Write-Host ""
}

function Test-Prerequisites {
    Write-Header "SPRAWDZANIE WYMAGAŃ SYSTEMOWYCH"
    
    $errors = @()
    
    # Sprawdzenie Node.js
    Write-Host "Sprawdzanie Node.js..." -NoNewline
    try {
        $nodeVersion = node --version 2>$null
        if ($nodeVersion) {
            Write-ColorOutput " ✓ Znaleziono Node.js $nodeVersion" "Green"
        } else {
            throw "Node.js nie został znaleziony"
        }
    } catch {
        Write-ColorOutput " ✗ Node.js nie jest zainstalowany" "Red"
        $errors += "Node.js nie jest zainstalowany. Pobierz z: https://nodejs.org/"
    }
    
    # Sprawdzenie npm
    Write-Host "Sprawdzanie npm..." -NoNewline
    try {
        $npmVersion = npm --version 2>$null
        if ($npmVersion) {
            Write-ColorOutput " ✓ Znaleziono npm $npmVersion" "Green"
        } else {
            throw "npm nie został znaleziony"
        }
    } catch {
        Write-ColorOutput " ✗ npm nie jest dostępny" "Red"
        $errors += "npm nie jest dostępny"
    }
    
    # Sprawdzenie Git
    Write-Host "Sprawdzanie Git..." -NoNewline
    try {
        $gitVersion = git --version 2>$null
        if ($gitVersion) {
            Write-ColorOutput " ✓ Znaleziono $gitVersion" "Green"
        } else {
            throw "Git nie został znaleziony"
        }
    } catch {
        Write-ColorOutput " ✗ Git nie jest zainstalowany" "Red"
        $errors += "Git nie jest zainstalowany. Pobierz z: https://git-scm.com/"
    }
    
    # Sprawdzenie PowerShell
    Write-Host "Sprawdzanie PowerShell..." -NoNewline
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -ge 5) {
        Write-ColorOutput " ✓ PowerShell $($psVersion.Major).$($psVersion.Minor)" "Green"
    } else {
        Write-ColorOutput " ⚠ PowerShell $($psVersion.Major).$($psVersion.Minor) - zalecana wersja 5.0+" "Yellow"
    }
    
    if ($errors.Count -gt 0) {
        Write-Header "BŁĘDY WYMAGAŃ"
        foreach ($error in $errors) {
            Write-ColorOutput "• $error" "Red"
        }
        Write-Host ""
        Write-ColorOutput "Zainstaluj brakujące komponenty i uruchom skrypt ponownie." "Yellow"
        return $false
    }
    
    Write-ColorOutput "✓ Wszystkie wymagania spełnione!" "Green"
    return $true
}

function New-ProjectStructure {
    param([string]$BasePath)
    
    Write-Header "TWORZENIE STRUKTURY KATALOGÓW"
    
    $directories = @(
        "",
        "app",
        "app\components",
        "app\components\ui",
        "app\components\course",
        "app\components\chat",
        "app\components\gamification",
        "app\components\dashboard",
        "app\pages",
        "app\pages\api",
        "app\pages\api\auth",
        "app\pages\api\course",
        "app\pages\api\chat",
        "app\pages\api\gamification",
        "app\lib",
        "app\lib\auth",
        "app\lib\database",
        "app\lib\ai",
        "app\styles",
        "app\public",
        "app\public\images",
        "app\public\icons",
        "course-content",
        "course-content\modules",
        "course-content\modules\module-01-introduction",
        "course-content\modules\module-02-market-research",
        "course-content\modules\module-03-user-personas",
        "course-content\modules\module-04-product-strategy",
        "course-content\modules\module-05-roadmap-planning",
        "course-content\modules\module-06-feature-prioritization",
        "course-content\modules\module-07-data-analysis",
        "course-content\modules\module-08-ai-integration",
        "course-content\modules\module-09-testing-validation",
        "course-content\modules\module-10-launch-strategy",
        "course-content\modules\module-11-metrics-kpis",
        "course-content\modules\module-12-scaling-optimization",
        "course-content\exercises",
        "course-content\templates",
        "course-content\resources",
        "database",
        "database\migrations",
        "database\seeds",
        "database\schemas",
        "docs",
        "docs\api",
        "docs\course",
        "docs\deployment",
        "scripts",
        "tests",
        "tests\unit",
        "tests\integration",
        "tests\e2e",
        "config"
    )
    
    foreach ($dir in $directories) {
        $fullPath = if ($dir -eq "") { $BasePath } else { Join-Path $BasePath $dir }
        try {
            if (!(Test-Path $fullPath)) {
                New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
                Write-Host "✓ Utworzono: $dir" -ForegroundColor Green
            } else {
                Write-Host "• Istnieje: $dir" -ForegroundColor Yellow
            }
        } catch {
            Write-ColorOutput "✗ Błąd tworzenia: $dir - $($_.Exception.Message)" "Red"
        }
    }
}

function New-ConfigurationFiles {
    param([string]$BasePath)
    
    Write-Header "TWORZENIE PLIKÓW KONFIGURACYJNYCH"
    
    # package.json
    $packageJson = @"
{
  "name": "ai-product-manager-coach",
  "version": "1.0.0",
  "description": "AI Product Manager Coach - Interaktywny kurs z chatbotem AI",
  "main": "index.js",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "jest",
    "test:watch": "jest --watch",
    "db:migrate": "npx prisma migrate dev",
    "db:seed": "npx prisma db seed",
    "db:studio": "npx prisma studio"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "@prisma/client": "^5.0.0",
    "next-auth": "^4.24.0",
    "openai": "^4.0.0",
    "tailwindcss": "^3.3.0",
    "framer-motion": "^10.0.0",
    "lucide-react": "^0.290.0",
    "recharts": "^2.8.0",
    "react-hook-form": "^7.47.0",
    "zod": "^3.22.0",
    "@hookform/resolvers": "^3.3.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "typescript": "^5.0.0",
    "eslint": "^8.0.0",
    "eslint-config-next": "^14.0.0",
    "prisma": "^5.0.0",
    "jest": "^29.0.0",
    "@testing-library/react": "^13.0.0",
    "@testing-library/jest-dom": "^6.0.0"
  },
  "keywords": [
    "ai",
    "product-manager",
    "course",
    "chatbot",
    "education",
    "nextjs"
  ],
  "author": "AI Product Manager Coach Team",
  "license": "MIT"
}
"@
    
    # .env.example
    $envExample = @"
# Konfiguracja bazy danych
DATABASE_URL="postgresql://username:password@localhost:5432/ai_product_manager_coach"

# Konfiguracja NextAuth.js
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-secret-key-here"

# Konfiguracja OpenAI
OPENAI_API_KEY="your-openai-api-key-here"

# Konfiguracja aplikacji
NODE_ENV="development"
PORT=3000

# Konfiguracja email (opcjonalne)
EMAIL_SERVER_HOST="smtp.gmail.com"
EMAIL_SERVER_PORT=587
EMAIL_SERVER_USER="your-email@gmail.com"
EMAIL_SERVER_PASSWORD="your-app-password"
EMAIL_FROM="noreply@aiproductmanager.com"

# Konfiguracja Redis (dla sesji i cache)
REDIS_URL="redis://localhost:6379"

# Konfiguracja S3/CloudFlare (dla plików)
AWS_ACCESS_KEY_ID="your-access-key"
AWS_SECRET_ACCESS_KEY="your-secret-key"
AWS_REGION="us-east-1"
AWS_BUCKET_NAME="ai-pm-coach-files"
"@
    
    # next.config.js
    $nextConfig = @"
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
  },
  images: {
    domains: ['localhost', 'your-domain.com'],
  },
  env: {
    CUSTOM_KEY: process.env.CUSTOM_KEY,
  },
}

module.exports = nextConfig
"@
    
    # tailwind.config.js
    $tailwindConfig = @"
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
        secondary: {
          50: '#f0fdf4',
          500: '#22c55e',
          600: '#16a34a',
        },
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
"@
    
    # tsconfig.json
    $tsConfig = @"
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "es6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./app/*"],
      "@/components/*": ["./app/components/*"],
      "@/lib/*": ["./app/lib/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
"@
    
    # .gitignore
    $gitignore = @"
# Dependencies
node_modules/
/.pnp
.pnp.js

# Testing
/coverage

# Next.js
/.next/
/out/

# Production
/build

# Misc
.DS_Store
*.pem

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Local env files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Vercel
.vercel

# TypeScript
*.tsbuildinfo
next-env.d.ts

# Database
/database/*.db
/database/*.sqlite

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
Thumbs.db
"@
    
    # README.md
    $readme = @"
# AI Product Manager Coach Project

Interaktywny kurs Product Managera z chatbotem AI, systemem gamifikacji i kompleksowym programem szkoleniowym.

## 🚀 Funkcje

- **12 modułów kursu** - Kompletny program szkoleniowy
- **Chatbot AI** - Inteligentny asystent oparty na OpenAI
- **System gamifikacji** - Punkty, odznaki, rankingi
- **Dashboard analityczny** - Śledzenie postępów
- **Baza danych PostgreSQL** - Przechowywanie danych użytkowników
- **Responsywny design** - Działa na wszystkich urządzeniach

## 📋 Wymagania

- Node.js 18.0+
- PostgreSQL 13+
- Git
- Konto OpenAI (dla chatbota)

## 🛠️ Instalacja

1. **Sklonuj repozytorium:**
   \`\`\`bash
   git clone <repository-url>
   cd ai-product-manager-coach
   \`\`\`

2. **Zainstaluj zależności:**
   \`\`\`bash
   npm install
   \`\`\`

3. **Skonfiguruj zmienne środowiskowe:**
   \`\`\`bash
   cp .env.example .env
   # Edytuj .env i uzupełnij wymagane wartości
   \`\`\`

4. **Skonfiguruj bazę danych:**
   \`\`\`bash
   npm run db:migrate
   npm run db:seed
   \`\`\`

5. **Uruchom aplikację:**
   \`\`\`bash
   npm run dev
   \`\`\`

## 📚 Struktura projektu

\`\`\`
ai-product-manager-coach/
├── app/                    # Aplikacja Next.js
│   ├── components/         # Komponenty React
│   ├── pages/             # Strony i API routes
│   ├── lib/               # Biblioteki i utilities
│   └── styles/            # Style CSS/Tailwind
├── course-content/        # Treści kursu
│   ├── modules/           # 12 modułów kursu
│   ├── exercises/         # Ćwiczenia praktyczne
│   └── resources/         # Zasoby dodatkowe
├── database/              # Konfiguracja bazy danych
├── docs/                  # Dokumentacja
└── tests/                 # Testy automatyczne
\`\`\`

## 🎯 Moduły kursu

1. **Wprowadzenie do Product Management**
2. **Badanie rynku i konkurencji**
3. **Tworzenie person użytkowników**
4. **Strategia produktowa**
5. **Planowanie roadmapy**
6. **Priorytetyzacja funkcji**
7. **Analiza danych i metryki**
8. **Integracja AI w produktach**
9. **Testowanie i walidacja**
10. **Strategia wprowadzenia na rynek**
11. **Metryki i KPI**
12. **Skalowanie i optymalizacja**

## 🤖 Chatbot AI

Inteligentny asystent wykorzystujący OpenAI GPT-4 do:
- Odpowiadania na pytania o kurs
- Pomocy w rozwiązywaniu ćwiczeń
- Personalizowanych porad
- Analizy przypadków biznesowych

## 🏆 System gamifikacji

- **Punkty doświadczenia (XP)** za ukończone lekcje
- **Odznaki** za osiągnięcia specjalne
- **Rankingi** użytkowników
- **Wyzwania tygodniowe**
- **Certyfikaty** po ukończeniu modułów

## 📊 Dashboard

- Postęp w kursie
- Statystyki nauki
- Historia chatbota
- Zdobyte odznaki
- Ranking użytkowników

## 🧪 Testowanie

\`\`\`bash
# Testy jednostkowe
npm run test

# Testy w trybie watch
npm run test:watch

# Testy E2E
npm run test:e2e
\`\`\`

## 🚀 Deployment

### Vercel (zalecane)
\`\`\`bash
npm install -g vercel
vercel
\`\`\`

### Docker
\`\`\`bash
docker build -t ai-pm-coach .
docker run -p 3000:3000 ai-pm-coach
\`\`\`

## 📝 Licencja

MIT License - zobacz plik LICENSE dla szczegółów.

## 🤝 Wsparcie

Jeśli masz pytania lub problemy:
1. Sprawdź dokumentację w folderze \`docs/\`
2. Otwórz issue na GitHubie
3. Skontaktuj się z zespołem

## 🔄 Aktualizacje

Projekt jest aktywnie rozwijany. Sprawdzaj regularnie aktualizacje:
\`\`\`bash
git pull origin main
npm install
npm run db:migrate
\`\`\`
"@
    
    # Prisma schema
    $prismaSchema = @"
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  image     String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  // Gamification
  xp        Int      @default(0)
  level     Int      @default(1)
  badges    Badge[]
  
  // Course progress
  progress  CourseProgress[]
  
  // Chat history
  chatMessages ChatMessage[]
  
  @@map("users")
}

model CourseProgress {
  id         String   @id @default(cuid())
  userId     String
  moduleId   String
  lessonId   String?
  completed  Boolean  @default(false)
  score      Int?
  completedAt DateTime?
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt
  
  user       User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@unique([userId, moduleId, lessonId])
  @@map("course_progress")
}

model Badge {
  id          String   @id @default(cuid())
  name        String
  description String
  icon        String
  userId      String
  earnedAt    DateTime @default(now())
  
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("badges")
}

model ChatMessage {
  id        String   @id @default(cuid())
  userId    String
  message   String
  response  String
  createdAt DateTime @default(now())
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("chat_messages")
}
"@
    
    $files = @{
        "package.json" = $packageJson
        ".env.example" = $envExample
        "next.config.js" = $nextConfig
        "tailwind.config.js" = $tailwindConfig
        "tsconfig.json" = $tsConfig
        ".gitignore" = $gitignore
        "README.md" = $readme
        "database\schema.prisma" = $prismaSchema
    }
    
    foreach ($file in $files.GetEnumerator()) {
        $filePath = Join-Path $BasePath $file.Key
        $directory = Split-Path $filePath -Parent
        
        if (!(Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        
        try {
            Set-Content -Path $filePath -Value $file.Value -Encoding UTF8
            Write-Host "✓ Utworzono: $($file.Key)" -ForegroundColor Green
        } catch {
            Write-ColorOutput "✗ Błąd tworzenia pliku: $($file.Key) - $($_.Exception.Message)" "Red"
        }
    }
}

function New-CourseContent {
    param([string]$BasePath)
    
    Write-Header "TWORZENIE TREŚCI KURSU"
    
    $modules = @(
        @{ id = "01"; name = "introduction"; title = "Wprowadzenie do Product Management" },
        @{ id = "02"; name = "market-research"; title = "Badanie rynku i konkurencji" },
        @{ id = "03"; name = "user-personas"; title = "Tworzenie person użytkowników" },
        @{ id = "04"; name = "product-strategy"; title = "Strategia produktowa" },
        @{ id = "05"; name = "roadmap-planning"; title = "Planowanie roadmapy" },
        @{ id = "06"; name = "feature-prioritization"; title = "Priorytetyzacja funkcji" },
        @{ id = "07"; name = "data-analysis"; title = "Analiza danych i metryki" },
        @{ id = "08"; name = "ai-integration"; title = "Integracja AI w produktach" },
        @{ id = "09"; name = "testing-validation"; title = "Testowanie i walidacja" },
        @{ id = "10"; name = "launch-strategy"; title = "Strategia wprowadzenia na rynek" },
        @{ id = "11"; name = "metrics-kpis"; title = "Metryki i KPI" },
        @{ id = "12"; name = "scaling-optimization"; title = "Skalowanie i optymalizacja" }
    )
    
    foreach ($module in $modules) {
        $moduleDir = Join-Path $BasePath "course-content\modules\module-$($module.id)-$($module.name)"
        
        # Tworzenie pliku README dla modułu
        $moduleReadme = @"
# Moduł $($module.id): $($module.title)

## Cele modułu
- Zrozumienie kluczowych koncepcji
- Praktyczne zastosowanie wiedzy
- Rozwój umiejętności analitycznych

## Struktura lekcji
1. Wprowadzenie teoretyczne
2. Przykłady praktyczne
3. Ćwiczenia interaktywne
4. Quiz sprawdzający
5. Projekt praktyczny

## Materiały
- Prezentacje
- Studia przypadków
- Szablony do pobrania
- Dodatkowe zasoby

## Czas realizacji
Szacowany czas: 2-3 godziny

## Wymagania wstępne
- Ukończenie poprzednich modułów
- Podstawowa znajomość biznesu

## Rezultaty
Po ukończeniu modułu będziesz potrafił:
- [Cel 1]
- [Cel 2]
- [Cel 3]
"@
        
        $readmePath = Join-Path $moduleDir "README.md"
        Set-Content -Path $readmePath -Value $moduleReadme -Encoding UTF8
        
        # Tworzenie pliku konfiguracyjnego modułu
        $moduleConfig = @"
{
  "id": "$($module.id)",
  "name": "$($module.name)",
  "title": "$($module.title)",
  "description": "Opis modułu $($module.title)",
  "duration": "2-3 godziny",
  "difficulty": "średni",
  "prerequisites": [],
  "lessons": [
    {
      "id": "lesson-01",
      "title": "Wprowadzenie",
      "type": "video",
      "duration": "15 min"
    },
    {
      "id": "lesson-02",
      "title": "Teoria",
      "type": "text",
      "duration": "30 min"
    },
    {
      "id": "lesson-03",
      "title": "Przykłady",
      "type": "interactive",
      "duration": "45 min"
    },
    {
      "id": "lesson-04",
      "title": "Quiz",
      "type": "quiz",
      "duration": "15 min"
    },
    {
      "id": "lesson-05",
      "title": "Projekt",
      "type": "project",
      "duration": "60 min"
    }
  ],
  "resources": [
    "templates/template-$($module.name).pdf",
    "examples/example-$($module.name).md"
  ]
}
"@
        
        $configPath = Join-Path $moduleDir "config.json"
        Set-Content -Path $configPath -Value $moduleConfig -Encoding UTF8
        
        Write-Host "✓ Utworzono moduł: $($module.title)" -ForegroundColor Green
    }
}

function New-BasicComponents {
    param([string]$BasePath)
    
    Write-Header "TWORZENIE PODSTAWOWYCH KOMPONENTÓW"
    
    # Layout component
    $layoutComponent = @"
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'AI Product Manager Coach',
  description: 'Interaktywny kurs Product Managera z chatbotem AI',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pl">
      <body className={inter.className}>
        <div className="min-h-screen bg-gray-50">
          <header className="bg-white shadow-sm border-b">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
              <div className="flex justify-between items-center py-4">
                <h1 className="text-2xl font-bold text-gray-900">
                  AI Product Manager Coach
                </h1>
                <nav className="space-x-4">
                  <a href="/" className="text-gray-600 hover:text-gray-900">
                    Dashboard
                  </a>
                  <a href="/course" className="text-gray-600 hover:text-gray-900">
                    Kurs
                  </a>
                  <a href="/chat" className="text-gray-600 hover:text-gray-900">
                    Chatbot
                  </a>
                </nav>
              </div>
            </div>
          </header>
          <main>{children}</main>
        </div>
      </body>
    </html>
  )
}
"@
    
    # Home page
    $homePage = @"
export default function Home() {
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">
          Witaj w AI Product Manager Coach!
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          Interaktywny kurs Product Managera z chatbotem AI i systemem gamifikacji
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-12">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-lg font-semibold mb-2">12 Modułów Kursu</h3>
            <p className="text-gray-600">
              Kompletny program szkoleniowy od podstaw do zaawansowanych technik
            </p>
          </div>
          
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-lg font-semibold mb-2">Chatbot AI</h3>
            <p className="text-gray-600">
              Inteligentny asystent oparty na OpenAI do pomocy w nauce
            </p>
          </div>
          
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-lg font-semibold mb-2">Gamifikacja</h3>
            <p className="text-gray-600">
              System punktów, odznak i rankingów motywujący do nauki
            </p>
          </div>
        </div>
        
        <div className="mt-8">
          <a
            href="/course"
            className="bg-blue-600 text-white px-8 py-3 rounded-lg text-lg font-semibold hover:bg-blue-700 transition-colors"
          >
            Rozpocznij Kurs
          </a>
        </div>
      </div>
    </div>
  )
}
"@
    
    # Global CSS
    $globalCSS = @"
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html {
    font-family: 'Inter', system-ui, sans-serif;
  }
}

@layer components {
  .btn-primary {
    @apply bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors;
  }
  
  .btn-secondary {
    @apply bg-gray-200 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-300 transition-colors;
  }
  
  .card {
    @apply bg-white rounded-lg shadow-md p-6;
  }
}
"@
    
    $components = @{
        "app\layout.tsx" = $layoutComponent
        "app\page.tsx" = $homePage
        "app\globals.css" = $globalCSS
    }
    
    foreach ($component in $components.GetEnumerator()) {
        $filePath = Join-Path $BasePath $component.Key
        $directory = Split-Path $filePath -Parent
        
        if (!(Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        
        try {
            Set-Content -Path $filePath -Value $component.Value -Encoding UTF8
            Write-Host "✓ Utworzono: $($component.Key)" -ForegroundColor Green
        } catch {
            Write-ColorOutput "✗ Błąd tworzenia komponentu: $($component.Key)" "Red"
        }
    }
}

function Show-NextSteps {
    param([string]$ProjectPath)
    
    Write-Header "NASTĘPNE KROKI"
    
    Write-ColorOutput "Projekt został pomyślnie utworzony w: $ProjectPath" "Green"
    Write-Host ""
    
    Write-ColorOutput "Aby uruchomić projekt:" "Yellow"
    Write-Host "1. cd `"$ProjectPath`""
    Write-Host "2. npm install"
    Write-Host "3. cp .env.example .env"
    Write-Host "4. # Edytuj plik .env i uzupełnij wymagane wartości"
    Write-Host "5. npm run dev"
    Write-Host ""
    
    Write-ColorOutput "Konfiguracja bazy danych:" "Yellow"
    Write-Host "1. Zainstaluj PostgreSQL"
    Write-Host "2. Utwórz bazę danych 'ai_product_manager_coach'"
    Write-Host "3. Uzupełnij DATABASE_URL w pliku .env"
    Write-Host "4. npm run db:migrate"
    Write-Host "5. npm run db:seed"
    Write-Host ""
    
    Write-ColorOutput "Konfiguracja OpenAI:" "Yellow"
    Write-Host "1. Utwórz konto na https://platform.openai.com/"
    Write-Host "2. Wygeneruj klucz API"
    Write-Host "3. Uzupełnij OPENAI_API_KEY w pliku .env"
    Write-Host ""
    
    Write-ColorOutput "Przydatne komendy:" "Yellow"
    Write-Host "• npm run dev          - Uruchomienie w trybie deweloperskim"
    Write-Host "• npm run build        - Budowanie aplikacji produkcyjnej"
    Write-Host "• npm run test         - Uruchomienie testów"
    Write-Host "• npm run db:studio    - Interfejs graficzny bazy danych"
    Write-Host ""
    
    Write-ColorOutput "Dokumentacja:" "Yellow"
    Write-Host "• README.md            - Główna dokumentacja"
    Write-Host "• docs/                - Szczegółowa dokumentacja"
    Write-Host "• course-content/      - Treści kursu"
    Write-Host ""
    
    Write-ColorOutput "Aplikacja będzie dostępna pod adresem: http://localhost:3000" "Green"
}

# ============================================================================
# GŁÓWNA LOGIKA SKRYPTU
# ============================================================================

try {
    Write-Header "AI PRODUCT MANAGER COACH - AUTOMATYCZNY SETUP"
    Write-ColorOutput "Rozpoczynam tworzenie struktury projektu..." "Cyan"
    Write-Host ""
    
    # Sprawdzenie wymagań systemowych
    if (-not $SkipChecks) {
        if (-not (Test-Prerequisites)) {
            exit 1
        }
    } else {
        Write-ColorOutput "⚠ Pominięto sprawdzanie wymagań systemowych" "Yellow"
    }
    
    # Sprawdzenie czy katalog już istnieje
    if (Test-Path $ProjectPath) {
        Write-ColorOutput "⚠ Katalog $ProjectPath już istnieje!" "Yellow"
        $response = Read-Host "Czy chcesz kontynuować? Istniejące pliki mogą zostać nadpisane (y/N)"
        if ($response -ne "y" -and $response -ne "Y") {
            Write-ColorOutput "Anulowano przez użytkownika." "Yellow"
            exit 0
        }
    }
    
    # Tworzenie struktury katalogów
    New-ProjectStructure -BasePath $ProjectPath
    
    # Tworzenie plików konfiguracyjnych
    New-ConfigurationFiles -BasePath $ProjectPath
    
    # Tworzenie treści kursu
    New-CourseContent -BasePath $ProjectPath
    
    # Tworzenie podstawowych komponentów
    New-BasicComponents -BasePath $ProjectPath
    
    # Wyświetlenie następnych kroków
    Show-NextSteps -ProjectPath $ProjectPath
    
    Write-Header "SETUP ZAKOŃCZONY POMYŚLNIE!"
    Write-ColorOutput "Projekt AI Product Manager Coach został utworzony!" "Green"
    
} catch {
    Write-Header "BŁĄD PODCZAS SETUPU"
    Write-ColorOutput "Wystąpił błąd: $($_.Exception.Message)" "Red"
    Write-ColorOutput "Szczegóły: $($_.ScriptStackTrace)" "Red"
    exit 1
}
