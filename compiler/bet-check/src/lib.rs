// SPDX-License-Identifier: MIT OR Apache-2.0
//! Type checker for Betlang

use bet_syntax::ast::*;
use bet_core::{Type, TypeEnv, CompileError, CompileResult};

/// Type check an expression
pub fn check(expr: &Expr, env: &TypeEnv) -> CompileResult<Type> {
    // TODO: Implement full type checking
    match expr {
        Expr::Literal(lit) => check_literal(lit),
        Expr::Var(name) => env
            .lookup(name)
            .cloned()
            .ok_or_else(|| CompileError::UndefinedVariable {
                name: name.clone(),
                span: None,
            }),
        Expr::Bet(bet) => check_bet(bet, env),
        _ => Ok(Type::Unit), // Placeholder
    }
}

fn check_literal(lit: &Literal) -> CompileResult<Type> {
    Ok(match lit {
        Literal::Unit => Type::Unit,
        Literal::Bool(_) => Type::Bool,
        Literal::Ternary(_) => Type::Ternary,
        Literal::Int(_) => Type::Int,
        Literal::Float(_) => Type::Float,
        Literal::String(_) => Type::String,
    })
}

fn check_bet(bet: &BetExpr, env: &TypeEnv) -> CompileResult<Type> {
    // All three alternatives must have the same type
    let types: Vec<_> = bet
        .alternatives
        .iter()
        .map(|alt| check(&alt.value, env))
        .collect::<Result<_, _>>()?;

    if types.len() != 3 {
        return Err(CompileError::InvalidBet { span: None });
    }

    // Check all types match
    let first = &types[0];
    for ty in &types[1..] {
        if ty != first {
            return Err(CompileError::TypeMismatch {
                expected: format!("{:?}", first),
                found: format!("{:?}", ty),
                span: None,
            });
        }
    }

    Ok(first.clone())
}
