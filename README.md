# QQ Pet Platform - QQ宠物管理平台

> A web-based platform for managing QQ pets with automatic care, battles, and community features.

## Features 功能特性

- **User Management** / 用户管理: Registration, login, session recovery, password change
- **Wallet System** / 钱包系统: Independent gold wallet, transfer history, redeem code exchange
- **QQ Account Integration** / QQ账号接入: Add/manage QQ accounts via MengkaNT framework
- **Pet Care** / 宠物养护: Feed, bathe, interact, study, work, adventure
- **Auto-Control** / 自动托管: Scheduled auto-feed, auto-bathe, auto-interact
- **PK Battles** / 自动PK: Strategy cache, opponent matching, auto-PK scheduler
- **Ranking** / 战力排行: Global rankings, daily stats tracking
- **Admin Panel** / 管理后台: User management, role assignment, wallet adjustments
- **MQTT Plugin Support** / 插件支持: MengkaNT WebSocket plugin integration

## Architecture 架构

```
Browser ──HTTP/WebSocket──> Vue Frontend ──API──> Go Backend ──WS──> MengkaNT Plugin
                                                                    ↕
                                                              QQ Official API
```

### Tech Stack 技术栈

| Layer | Technology |
|-------|------------|
| **Frontend** | Vue 3 + TypeScript + Vite + Element Plus + Pinia |
| **Backend** | Go (Chi router) + SQLite (modernc.org/sqlite) |
| **Auth** | HttpOnly Cookie Sessions + bcrypt |
| **WebSocket** | Gorilla WebSocket (MengkaNT plugin communication) |
| **Deployment** | Windows Installer (nssm services) + Docker (optional) |

## Quick Start 快速开始

### Prerequisites 环境要求
- Go 1.26+
- Node.js 20+ / npm

### Backend Setup 后端设置
```bash
cd backend/cmd/server
go run .
# Follow prompts to set port, admin username/password on first run
```

### Frontend Development 前端开发
```bash
cd frontend
npm install
npm run dev
```

## Project Structure 项目结构

```
memgke-qq-pet/
├── backend/           # Go backend service
│   ├── cmd/server/    # Entry point
│   └── internal/      # Business logic (auth, mokant, wallet, etc.)
├── frontend/          # Vue 3 frontend + embedded Go static server
│   ├── src/
│   │   ├── api/       # API request modules (auth, qq, admin, etc.)
│   │   ├── views/     # Page components (admin/, user/, auth/)
│   │   ├── stores/    # Pinia state stores
│   │   └── ...
│   └── public/        # Static assets (captcha pages)
├── deploy/            # Windows installer & service scripts
├── scripts/           # Build & utility scripts
├── docs/              # Documentation
├── data/              # External data files (PK strangers list, etc.)
└── .gitignore         # Excluded files (secrets, build artifacts)
```

## Deployment 部署

### Windows Service (Recommended 推荐)
Use `deploy/windows-installer.iss` with Inno Setup to create an installer that:
- Installs both backend and frontend executables
- Registers as Windows Services via NSSM
- Creates start menu shortcuts

See `docs/install-guide.md` for full instructions.

### Docker
```bash
docker compose up -d --build
```
Access at http://localhost:5173

## Security 安全须知
⚠️ Never commit `config.ini`, tokens, or database files. The `.gitignore` excludes these automatically.

## License 许可
MIT — see [LICENSE](LICENSE)

---
Built with ❤️ for QQ Pet enthusiasts
