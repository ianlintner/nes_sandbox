# GitHub Actions Workflows

This directory contains CI/CD workflows for the NES Cat Mecha Shmup project.

## Available Workflows

### build.yml - Build NES ROM

Automatically builds the NES ROM on every push and pull request to main/develop branches.

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests targeting `main` or `develop`

**Steps:**
1. Checkout code
2. Install cc65 toolchain (ca65, ld65)
3. Verify toolchain installation
4. Build NES ROM using `make`
5. Verify ROM output (format, size, header)
6. Upload ROM as build artifact (30-day retention)
7. Create release asset on tags

**Artifacts:**
- `catmecha-nes-rom` - Built NES ROM file (catmecha.nes)

**Usage:**
- Download ROM from workflow runs to test changes
- ROM artifacts available in the Actions tab
- Tagged releases automatically include ROM file

---

### quality.yml - Code Quality Checks

Runs code quality and validation checks on assembly code and documentation.

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests targeting `main` or `develop`

**Steps:**
1. Checkout code
2. Install cc65 toolchain
3. Check assembly syntax (compiles without errors)
4. Verify linker configuration
5. Check required files are present
6. Validate documentation exists
7. Generate code statistics

**Checks:**
- Assembly syntax validation
- Required files present (main.s, nes.cfg, Makefile, README.md)
- Documentation complete (all .md files)
- Code statistics (line counts, function counts)

---

## Workflow Status

You can check the status of workflows:

1. Go to the repository's "Actions" tab
2. See recent workflow runs for each branch
3. View detailed logs for each step
4. Download build artifacts

## Adding New Workflows

To add a new workflow:

1. Create a new `.yml` file in this directory
2. Define triggers (push, pull_request, schedule, etc.)
3. Specify jobs and steps
4. Test locally if possible using act or similar tools
5. Document the workflow in this README

## Best Practices

- Keep workflows focused on specific tasks
- Use semantic job and step names
- Cache dependencies when possible (if needed in future)
- Set appropriate artifact retention periods
- Use workflow status badges in README if desired

## Debugging Workflows

If a workflow fails:

1. Check the workflow run logs in Actions tab
2. Look for error messages in failed steps
3. Verify cc65 installation succeeded
4. Check that all required files are committed
5. Test build locally: `make clean && make`

## Local Testing

Before pushing changes, test locally:

```bash
# Clean build
make clean

# Build ROM
make

# Verify output
file catmecha.nes
ls -lh catmecha.nes
```

This ensures workflows will succeed before committing.

## Required Secrets

Currently, no secrets are required for basic workflows.

For release creation on tags:
- `GITHUB_TOKEN` - Automatically provided by GitHub Actions

## Future Enhancements

Potential workflow additions:
- ROM testing with NES emulator
- Automated release notes generation
- Code coverage analysis (if test framework added)
- Performance benchmarking
- Documentation generation
- ROM size optimization checks
