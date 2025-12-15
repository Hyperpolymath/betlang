;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;; ECOSYSTEM.scm — betlang

(ecosystem
  (version "1.0.0")
  (name "betlang")
  (type "project")
  (purpose "*A ternary probabilistic programming language for modeling uncertainty*")

  (position-in-ecosystem
    "Part of hyperpolymath ecosystem. Follows RSR guidelines.")

  (related-projects
    (project (name "rhodium-standard-repositories")
             (url "https://github.com/hyperpolymath/rhodium-standard-repositories")
             (relationship "standard")))

  (what-this-is "*A ternary probabilistic programming language for modeling uncertainty*")
  (what-this-is-not "- NOT exempt from RSR compliance"))
