# AGENTS.md - Codex Development Instructions

*Special instructions for AI development agents working on ChatStash*

## Project Context

ChatStash is a sophisticated conversation management system for ChatGPT Plus users who operate across multiple machines. The system automates daily conversation exports, implements intelligent deduplication, and maintains synchronized conversation history via cloud storage and database centralization.

## Architecture Principles

### Core Design Philosophy
- **Elegance over Complexity**: Prefer simple, maintainable solutions
- **Reliability First**: Prioritize robust error handling and graceful degradation
- **Cross-Platform Compatibility**: Ensure seamless operation across Windows, macOS, Linux
- **Minimal Dependencies**: Use established, well-maintained libraries only
- **Modular Design**: Each component should be independently testable and replaceable

### Technical Stack Requirements

**Primary Languages**: Python 3.9+ (core logic), Node.js 18+ (Playwright automation)
**Browser Automation**: Playwright (preferred over Selenium for modern web app handling)
**Database**: SQLite for single-machine, PostgreSQL for multi-user deployments
**Cloud Storage**: Native APIs for Dropbox, Google Drive, OneDrive
**Scheduling**: Windows Task Scheduler + WSL2 integration
**CLI Framework**: Click (Python) for command-line interfaces

## Implementation Guidelines

### 1. ChatGPT Integration

**Authentication Handling**
- Implement secure credential storage using keyring library
- Support both session cookies and API tokens
- Handle authentication refresh automatically
- Graceful fallback for expired sessions

**Data Extraction Strategy**
- Use Playwright to navigate ChatGPT interface programmatically
- Implement conversation pagination handling
- Extract conversation metadata (timestamps, model versions, conversation IDs)
- Handle rate limiting and request throttling
- Support both individual conversation and bulk export modes

**Error Handling**
- Retry logic for network failures
- Graceful handling of UI changes
- Comprehensive logging for debugging
- User-friendly error messages

### 2. Deduplication Algorithm

**Conversation Identification**
- Generate stable conversation hashes based on content and metadata
- Implement fuzzy matching for partial conversations
- Handle conversation continuation across sessions
- Maintain conversation threading integrity

**Merge Strategy**
- Prefer most complete conversation version
- Merge partial conversations intelligently
- Preserve all metadata from source conversations
- Log merge decisions for audit trail

### 3. Database Design

**Schema Requirements**
```sql
-- Core tables needed
conversations (id, hash, title, created_at, updated_at, machine_id, raw_data)
messages (id, conversation_id, role, content, timestamp, sequence)
machines (id, hostname, last_sync, config)
sync_log (id, machine_id, operation, timestamp, status)
```

**Query Optimization**
- Index on conversation hashes for deduplication
- Full-text search on message content
- Efficient pagination for large datasets
- Conversation threading queries

### 4. Cloud Storage Integration

**Storage Strategy**
- Hierarchical folder structure: `/ChatStash/{machine_id}/{date}/`
- Atomic uploads to prevent partial file corruption
- Conflict resolution for simultaneous uploads
- Incremental sync to minimize bandwidth usage

**Supported Providers**
- Dropbox API v2 integration
- Google Drive API v3 integration
- OneDrive Graph API integration
- Abstract storage interface for easy provider addition

### 5. Windows Scheduler Integration

**WSL2 Integration**
- PowerShell script to launch WSL2 environment
- Environment variable passing to WSL2
- Proper exit code handling
- Logging redirection to Windows event log

**Task Configuration**
- Daily execution at user-configurable time
- Retry logic for failed executions
- Email notifications for persistent failures
- Resource usage monitoring

## Code Quality Standards

### Python Code Style
- Follow PEP 8 with 88-character line limit (Black formatter)
- Use type hints throughout
- Comprehensive docstrings for all public functions
- Unit tests with >90% coverage
- Use dataclasses for structured data

### JavaScript/Node.js Style
- ESLint with Airbnb configuration
- Prettier formatting
- JSDoc comments for all functions
- Jest for testing

### Error Handling Patterns
```python
# Preferred error handling pattern
try:
    result = risky_operation()
except SpecificException as e:
    logger.error(f"Operation failed: {e}")
    return ErrorResult(str(e))
except Exception as e:
    logger.exception("Unexpected error in operation")
    raise ChatStashError(f"Unexpected error: {e}") from e
```

### Configuration Management
- Use Pydantic for configuration validation
- Support both environment variables and config files
- Hierarchical configuration (system → user → project)
- Sensitive data in separate encrypted config

## Testing Requirements

### Unit Testing
- Pytest with fixtures for database and mock services
- Mock external API calls
- Test edge cases and error conditions
- Parametrized tests for multiple input scenarios

### Integration Testing
- Docker containers for isolated test environments
- Real API integration tests (with test accounts)
- End-to-end workflow testing
- Performance benchmarks for large datasets

### Test Data Management
- Anonymized conversation samples for testing
- Reproducible test scenarios
- Cleanup procedures for test artifacts

## Security Considerations

### Data Protection
- Encrypt conversation data at rest
- Secure credential storage
- Audit logging for all data access
- GDPR compliance for personal data

### API Security
- Rate limiting compliance
- Secure token storage and rotation
- Input validation and sanitization
- Protection against injection attacks

## Performance Requirements

### Scalability Targets
- Handle 10,000+ conversations per machine
- Sub-second search response times
- Efficient memory usage for large datasets
- Graceful degradation under load

### Optimization Strategies
- Lazy loading for conversation content
- Caching frequently accessed data
- Batch processing for bulk operations
- Parallel processing where appropriate

## Development Workflow

### Git Workflow
- Feature branches with descriptive names
- Conventional commit messages
- Pull request reviews required
- Automated testing before merge

### Release Process
- Semantic versioning (MAJOR.MINOR.PATCH)
- Changelog maintenance
- Tagged releases with binaries
- Migration scripts for database changes

## Monitoring and Observability

### Logging Strategy
- Structured logging with JSON format
- Log levels: DEBUG, INFO, WARN, ERROR, CRITICAL
- Separate logs for different components
- Log rotation and retention policies

### Metrics Collection
- Export success/failure rates
- Sync performance metrics
- Database query performance
- Storage usage tracking

## Documentation Requirements

### Code Documentation
- Comprehensive README with quick start guide
- API documentation with examples
- Architecture decision records (ADRs)
- Troubleshooting guides

### User Documentation
- Installation and setup guides
- Configuration reference
- Common use cases and workflows
- FAQ and troubleshooting

---

**Note for AI Agents**: This document serves as the authoritative guide for ChatStash development. When implementing features, always refer back to these principles and requirements. If you encounter conflicts or ambiguities, prioritize user experience and system reliability over feature completeness.