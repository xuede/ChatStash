# ChatStash

*Automated ChatGPT conversation export and synchronization system with cross-machine support*

## Overview

ChatStash is an intelligent conversation management system designed to automatically export, deduplicate, and synchronize ChatGPT conversations across multiple machines. Built for power users who maintain ChatGPT sessions on different devices and need seamless conversation history management.

## Architecture

### Core Components

- **Playwright-based Web Automation**: Robust browser automation for ChatGPT interaction
- **ChatGPT Plus API Integration**: Leverages official export APIs for reliable data extraction
- **Cross-Machine Synchronization**: Cloud storage integration with intelligent deduplication
- **Database Centralization**: SQLite/PostgreSQL backend for conversation threading and metadata
- **Windows Scheduler Integration**: Automated daily exports via WSL2 and gemini-cli

### Workflow

1. **Daily Export Trigger**: Windows Task Scheduler launches gemini-cli in WSL2
2. **Conversation Extraction**: Playwright navigates ChatGPT interface, extracts conversation data
3. **Deduplication Logic**: Identifies and merges overlapping conversations across machines
4. **Cloud Synchronization**: Deposits processed exports to shared cloud storage
5. **Database Updates**: Maintains conversation threading and searchable metadata

## Features

- ✅ **Multi-Machine Support**: Seamless synchronization across Windows, macOS, Linux
- ✅ **Intelligent Deduplication**: Prevents duplicate conversations in merged datasets
- ✅ **Conversation Threading**: Maintains chronological conversation flow
- ✅ **Cloud Storage Integration**: Dropbox, Google Drive, OneDrive support
- ✅ **Automated Scheduling**: Set-and-forget daily export automation
- ✅ **Metadata Preservation**: Timestamps, conversation IDs, model versions
- ✅ **Export Formats**: JSON, Markdown, CSV export options

## Quick Start

### Prerequisites

- ChatGPT Plus subscription
- Node.js 18+ and Python 3.9+
- WSL2 (Windows) or native Unix environment
- Cloud storage account (Dropbox/Google Drive/OneDrive)

### Installation

```bash
git clone https://github.com/xuede/ChatStash.git
cd ChatStash
npm install
pip install -r requirements.txt
```

### Configuration

1. Copy `.env.example` to `.env`
2. Configure ChatGPT credentials and cloud storage tokens
3. Set up Windows Task Scheduler (see `.gemini/runbook.md`)
4. Initialize database: `python scripts/init_db.py`

### Usage

```bash
# Manual export
python chatgpt_exporter.py --days 1

# Full synchronization
python sync_manager.py --full-sync

# Database query
python query_conversations.py --search "AI strategy"
```

## Project Structure

```
ChatStash/
├── .gemini/                 # Gemini CLI workflows and runbooks
│   ├── runbook.md          # Detailed automation workflow
│   ├── export_workflow.yml # Gemini CLI configuration
│   └── scheduler_setup.ps1 # Windows Task Scheduler setup
├── src/
│   ├── exporters/          # ChatGPT data extraction modules
│   ├── sync/               # Cross-machine synchronization
│   ├── storage/            # Cloud storage integrations
│   └── database/           # Conversation database management
├── scripts/                # Utility and setup scripts
├── config/                 # Configuration templates
└── docs/                   # Documentation and guides
```

## Development

### Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Testing

```bash
# Run test suite
npm test
pytest tests/

# Integration tests
python tests/test_integration.py
```

## Roadmap

- [ ] **v1.0**: Core export and sync functionality
- [ ] **v1.1**: Advanced search and filtering
- [ ] **v1.2**: Conversation analytics and insights
- [ ] **v2.0**: Multi-platform GUI application
- [ ] **v2.1**: Plugin system for custom exporters

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

For issues, feature requests, or questions:
- Open an [Issue](https://github.com/xuede/ChatStash/issues)
- Join our [Discussions](https://github.com/xuede/ChatStash/discussions)
- Email: support@chatstash.dev

---

*Built for the modern AI-powered workflow by [@xuede](https://github.com/xuede)*