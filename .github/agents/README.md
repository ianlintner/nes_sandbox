# Copilot Agent Instructions

This directory contains instructions for GitHub Copilot agents to better understand and assist with this NES homebrew game project.

## Available Agent Instructions

### nes-developer.md

Provides comprehensive guidance for working with the NES Cat Mecha Shmup codebase:

- **Project Context**: Overview of the game and its architecture
- **Technology Stack**: 6502 Assembly, cc65 toolchain, NES platform
- **Code Guidelines**: Assembly standards, naming conventions, memory organization
- **NES Hardware Constraints**: PPU timing, VBlank, sprite limits
- **Performance Guidelines**: Optimization techniques, cycle budgets
- **Game Development Patterns**: Game loop, collision detection, state management
- **Common Patterns**: Examples for extending weapons, enemies, and power-ups
- **Documentation Standards**: How to maintain project documentation
- **Common Pitfalls**: Things to avoid when developing for NES
- **Resources**: Links to NESdev wiki, cc65 docs, and project documentation

## How Copilot Uses These Instructions

GitHub Copilot agents automatically read these instruction files to:

1. Understand the project's specific requirements and constraints
2. Provide context-aware code suggestions
3. Follow established coding patterns and conventions
4. Avoid common pitfalls specific to NES development
5. Maintain consistency with existing code style

## Adding New Instructions

When adding new agent instructions:

1. Create a new `.md` file in this directory
2. Use clear, structured markdown with sections
3. Include specific examples and code patterns
4. Document both what to do and what to avoid
5. Link to relevant resources and documentation

## Best Practices

- Keep instructions focused and actionable
- Update instructions when significant patterns change
- Include code examples for clarity
- Document NES-specific constraints clearly
- Reference project documentation for details

## Related Documentation

For more information about the project, see:
- `/README.md` - Build instructions and gameplay overview
- `/DEVELOPMENT.md` - Developer guide for extending the game
- `/FEATURES.md` - Complete feature documentation
- `/QUICKREF.md` - Quick reference for players
- `/VISUALS.md` - Visual guides and diagrams
