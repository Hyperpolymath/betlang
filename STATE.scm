;;; STATE.scm - Project Checkpoint
;;; betlang
;;; Format: Guile Scheme S-expressions
;;; Purpose: Preserve AI conversation context across sessions
;;; Reference: https://github.com/hyperpolymath/state.scm

;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell

;;;============================================================================
;;; METADATA
;;;============================================================================

(define metadata
  '((version . "0.1.1")
    (schema-version . "1.0")
    (created . "2025-12-15")
    (updated . "2025-12-18")
    (project . "betlang")
    (repo . "github.com/hyperpolymath/betlang")))

;;;============================================================================
;;; PROJECT CONTEXT
;;;============================================================================

(define project-context
  '((name . "betlang")
    (tagline . "*A ternary probabilistic programming language for modeling uncertainty*")
    (version . "0.1.0")
    (license . "AGPL-3.0-or-later")
    (rsr-compliance . "gold-target")

    (tech-stack
     ((primary . "See repository languages")
      (ci-cd . "GitHub Actions + GitLab CI + Bitbucket Pipelines")
      (security . "CodeQL + OSSF Scorecard")))))

;;;============================================================================
;;; CURRENT POSITION
;;;============================================================================

(define current-position
  '((phase . "v0.1.1 - Security Hardening Complete")
    (overall-completion . 40)

    (components
     ((rsr-compliance
       ((status . "complete")
        (completion . 100)
        (notes . "All workflows SHA-pinned, SPDX headers, permissions declared")))

      (security
       ((status . "complete")
        (completion . 100)
        (notes . "All GitHub Actions SHA-pinned, removed @main refs, permissions: read-all")))

      (documentation
       ((status . "foundation")
        (completion . 35)
        (notes . "README, META/ECOSYSTEM/STATE.scm, SECURITY.md complete")))

      (testing
       ((status . "scaffolded")
        (completion . 15)
        (notes . "CI/CD pipeline configured, cross-platform test matrix")))

      (core-functionality
       ((status . "in-progress")
        (completion . 25)
        (notes . "bet primitives, ternary logic, REPL implemented")))))

    (working-features
     ("RSR-compliant CI/CD pipeline"
      "Multi-platform mirroring (GitHub, GitLab, Bitbucket)"
      "SPDX license headers on all files"
      "SHA-pinned GitHub Actions (all workflows)"
      "OSSF Scorecard integration"
      "Security policy workflows"
      "Cross-platform Racket testing (8.11, 8.12, current)"))))

;;;============================================================================
;;; ROUTE TO MVP
;;;============================================================================

(define route-to-mvp
  '((target-version . "1.0.0")
    (definition . "Stable release with comprehensive documentation and tests")

    (milestones
     ((v0.1.1
       ((name . "Security Hardening")
        (status . "complete")
        (completed . "2025-12-18")
        (items
         ("SHA-pin all GitHub Actions"
          "Add SPDX headers to all workflows"
          "Add permissions: read-all declarations"
          "Remove @main branch references"
          "Update STATE.scm roadmap"))))

      (v0.2
       ((name . "Core Functionality")
        (status . "in-progress")
        (items
         ("Extend bet primitive with weighted probabilities"
          "Add bet-parallel for concurrent sampling"
          "Implement bet-conditional for conditional logic"
          "Add statistical analysis functions"
          "Comprehensive unit tests for core"))))

      (v0.3
       ((name . "Library Expansion")
        (status . "pending")
        (items
         ("Markov chain support"
          "Bayesian inference primitives"
          "Distribution sampling library"
          "Optimization algorithms"))))

      (v0.5
       ((name . "Feature Complete")
        (status . "pending")
        (items
         ("All planned features implemented"
          "Test coverage > 70%"
          "API stability"
          "Performance benchmarks established"))))

      (v0.8
       ((name . "Pre-Release Polish")
        (status . "pending")
        (items
         ("Documentation complete"
          "REPL enhancements"
          "Error messages improved"
          "Examples expanded"))))

      (v1.0
       ((name . "Production Release")
        (status . "pending")
        (items
         ("Comprehensive test coverage > 80%"
          "Performance optimization"
          "External security audit"
          "User documentation complete"
          "Guix package published"))))))))

;;;============================================================================
;;; BLOCKERS & ISSUES
;;;============================================================================

(define blockers-and-issues
  '((critical
     ())  ;; No critical blockers

    (high-priority
     ())  ;; No high-priority blockers

    (medium-priority
     ((test-coverage
       ((description . "Limited test infrastructure")
        (impact . "Risk of regressions")
        (needed . "Comprehensive test suites")))))

    (low-priority
     ((documentation-gaps
       ((description . "Some documentation areas incomplete")
        (impact . "Harder for new contributors")
        (needed . "Expand documentation")))))))

;;;============================================================================
;;; CRITICAL NEXT ACTIONS
;;;============================================================================

(define critical-next-actions
  '((immediate
     (("Verify CI/CD pipeline with SHA-pinned actions" . high)
      ("Resolve GitLab mirror sync status" . medium)
      ("Add unit tests for bet primitives" . high)))

    (this-week
     (("Implement weighted bet probabilities" . high)
      ("Add bet-parallel for concurrent sampling" . high)
      ("Expand test coverage to 30%" . medium)))

    (this-month
     (("Complete v0.2 Core Functionality milestone" . high)
      ("Begin v0.3 Library Expansion" . medium)
      ("Add Markov chain support" . medium)))))

;;;============================================================================
;;; SESSION HISTORY
;;;============================================================================

(define session-history
  '((snapshots
     ((date . "2025-12-18")
      (session . "security-hardening")
      (accomplishments
       ("SHA-pinned all GitHub Actions to commit hashes"
        "Added SPDX license headers to all workflows"
        "Added permissions: read-all to all workflows"
        "Removed insecure @main branch references"
        "Updated roadmap with detailed milestones"))
      (notes . "Security audit and hardening complete"))

     ((date . "2025-12-15")
      (session . "initial-state-creation")
      (accomplishments
       ("Added META.scm, ECOSYSTEM.scm, STATE.scm"
        "Established RSR compliance"
        "Created initial project checkpoint"))
      (notes . "First STATE.scm checkpoint created via automated script")))))

;;;============================================================================
;;; HELPER FUNCTIONS (for Guile evaluation)
;;;============================================================================

(define (get-completion-percentage component)
  "Get completion percentage for a component"
  (let ((comp (assoc component (cdr (assoc 'components current-position)))))
    (if comp
        (cdr (assoc 'completion (cdr comp)))
        #f)))

(define (get-blockers priority)
  "Get blockers by priority level"
  (cdr (assoc priority blockers-and-issues)))

(define (get-milestone version)
  "Get milestone details by version"
  (assoc version (cdr (assoc 'milestones route-to-mvp))))

;;;============================================================================
;;; EXPORT SUMMARY
;;;============================================================================

(define state-summary
  '((project . "betlang")
    (version . "0.1.1")
    (overall-completion . 40)
    (last-milestone . "v0.1.1 - Security Hardening (complete)")
    (next-milestone . "v0.2 - Core Functionality")
    (critical-blockers . 0)
    (high-priority-issues . 0)
    (updated . "2025-12-18")))

;;; End of STATE.scm
