# Contributing to betlang

Thank you for your interest in contributing to betlang! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contribution Guidelines](#contribution-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Ternary Philosophy](#ternary-philosophy)

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

## Getting Started

### Prerequisites

- Racket 7.0 or later
- Git
- Basic understanding of functional programming
- Familiarity with probabilistic programming concepts (helpful but not required)

### Finding Issues

- Check the [Issues](../../issues) page for open issues
- Look for issues labeled `good first issue` for beginner-friendly tasks
- Issues labeled `help wanted` are especially looking for contributors

## Development Setup

1. **Fork the repository** on GitHub

2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/betlang.git
   cd betlang
   ```

3. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Verify installation:**
   ```bash
   racket --version
   racket repl/shell.rkt
   ```

5. **Run tests:**
   ```bash
   racket tests/basics.rkt
   ```

## Contribution Guidelines

### Code Style

- Follow standard [Racket Style Guide](https://docs.racket-lang.org/style/)
- Use meaningful variable and function names
- Add docstrings to all exported functions
- Keep functions focused and composable
- Prefer immutable data structures
- Use pattern matching where appropriate

**Example:**
```racket
;; Good: Clear, documented, type-safe
(define (bet-probability n pred a b c)
  "Estimate probability that predicate holds over n trials.

   Parameters:
     n - number of trials (positive integer)
     pred - predicate function
     a, b, c - bet values

   Returns: probability estimate (0.0 to 1.0)"
  (/ (count pred (bet-parallel n a b c)) n))

;; Bad: Unclear, undocumented
(define (bp n p a b c)
  (/ (count p (bet-parallel n a b c)) n))
```

### Ternary Philosophy

betlang is built on the ternary principle. **All core primitives must involve three choices.**

✅ **Acceptable:**
- `(bet A B C)` - three-way choice
- Ternary logic operations
- Three-state systems

❌ **Not acceptable:**
- Binary operations as primitives (use ternary with repeated value instead)
- Four-way or N-way choices in core
- Breaking the ternary abstraction

**Rationale:** The ternary principle:
- Distinguishes betlang from binary probabilistic languages
- Creates interesting mathematical properties
- Models real-world three-way decisions
- Inspired by musical ternary form (A-B-A)

### What to Contribute

**We welcome contributions in these areas:**

1. **Core Language Features**
   - New bet primitives (must be ternary)
   - Performance optimizations
   - Bug fixes

2. **Libraries**
   - New probability distributions
   - Statistical functions
   - Mathematical utilities
   - Sampling algorithms

3. **Examples**
   - Real-world applications
   - Tutorial content
   - Domain-specific use cases

4. **Documentation**
   - API documentation
   - Tutorials and guides
   - Academic papers
   - Blog posts

5. **Tools**
   - Analysis utilities
   - Visualization tools
   - IDE integrations
   - Build tools

6. **Testing**
   - Unit tests
   - Integration tests
   - Property-based tests
   - Benchmarks

## Testing

### Running Tests

```bash
# Run all tests
racket tests/basics.rkt

# Run benchmarks
racket benchmarks/performance.rkt

# Run specific example
racket examples/monte-carlo.rkt
```

### Writing Tests

- Add tests to `tests/basics.rkt` or create new test files
- Use `rackunit` testing framework
- Test both deterministic and probabilistic behavior
- For probabilistic tests, use large sample sizes (n ≥ 1000)
- Include edge cases and error conditions

**Example test:**
```racket
(displayln "Test: Bet produces all three outcomes")
(define results (bet-parallel 1000 'A 'B 'C))
(check-true (member 'A results))
(check-true (member 'B results))
(check-true (member 'C results))
```

### Test Requirements

- All new functions must have tests
- Maintain or improve test coverage
- Tests must pass before PR is merged
- Probabilistic tests should verify statistical properties

## Documentation

### Code Documentation

- Add docstrings to all exported functions
- Include parameter descriptions
- Specify return types
- Provide usage examples
- Document edge cases

### External Documentation

- Update `docs/api-reference.md` for new functions
- Add examples to `docs/tutorial.md` if appropriate
- Update `README.md` for significant features
- Add changelog entries for user-facing changes

## Pull Request Process

### Before Submitting

1. **Update your fork:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests:**
   ```bash
   racket tests/basics.rkt
   ```

3. **Check code style:**
   - Ensure consistent formatting
   - Remove debugging code
   - Clean up comments

4. **Update documentation:**
   - Add/update docstrings
   - Update relevant .md files
   - Add CHANGELOG entry

### Submitting PR

1. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request:**
   - Use descriptive title: "Add [feature]" or "Fix [bug]"
   - Fill out PR template
   - Reference related issues
   - Describe changes in detail
   - Add screenshots/examples if applicable

3. **PR Description Should Include:**
   - **What**: What changes were made?
   - **Why**: Why were these changes needed?
   - **How**: How were they implemented?
   - **Testing**: How were they tested?
   - **Breaking Changes**: Any API changes?

### Review Process

1. Maintainers will review your PR
2. Address feedback in new commits
3. Once approved, your PR will be merged
4. Your contribution will be acknowledged in CONTRIBUTORS.md

### After Merge

- Delete your feature branch
- Pull latest changes from main
- Celebrate! 🎉

## Questions or Problems?

- **Bug reports:** Open an [issue](../../issues/new)
- **Feature requests:** Open an [issue](../../issues/new)
- **Questions:** Open a [discussion](../../discussions) or ask in the issue tracker
- **Security:** See [SECURITY.md](SECURITY.md) for reporting security vulnerabilities

## License

By contributing to betlang, you agree that your contributions will be licensed under the CC0 1.0 Universal (Public Domain) license, the same as the project itself.

## Recognition

Contributors are recognized in:
- Git commit history
- CONTRIBUTORS.md (coming soon)
- Release notes
- Academic papers citing betlang

Thank you for making betlang better! 🎲
