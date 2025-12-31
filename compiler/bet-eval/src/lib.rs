// SPDX-License-Identifier: MIT OR Apache-2.0
//! Interpreter for Betlang

use bet_syntax::ast::*;
use bet_core::{ValueEnv, CompileError, CompileResult};
use rand::prelude::*;
use std::sync::Arc;

/// Runtime value
#[derive(Debug, Clone)]
pub enum Value {
    Unit,
    Bool(bool),
    Ternary(TernaryValue),
    Int(i64),
    Float(f64),
    String(Arc<String>),
    List(Vec<Value>),
    Closure(Arc<Closure>),
}

#[derive(Debug, Clone, Copy)]
pub enum TernaryValue {
    True,
    False,
    Unknown,
}

#[derive(Debug)]
pub struct Closure {
    pub param: String,
    pub body: Expr,
    pub env: ValueEnv<Value>,
}

/// Evaluate an expression
pub fn eval(expr: &Expr, env: &mut ValueEnv<Value>) -> CompileResult<Value> {
    match expr {
        Expr::Literal(lit) => eval_literal(lit),
        Expr::Var(name) => env
            .lookup(name)
            .ok_or_else(|| CompileError::UndefinedVariable {
                name: name.clone(),
                span: None,
            }),
        Expr::Bet(bet) => eval_bet(bet, env),
        Expr::Let(binding) => {
            let value = eval(&binding.value, env)?;
            env.bind(binding.name.clone(), value.clone());
            eval(&binding.body, env)
        }
        _ => Ok(Value::Unit), // Placeholder
    }
}

fn eval_literal(lit: &Literal) -> CompileResult<Value> {
    Ok(match lit {
        Literal::Unit => Value::Unit,
        Literal::Bool(b) => Value::Bool(*b),
        Literal::Ternary(t) => Value::Ternary(match t {
            bet_syntax::ast::TernaryValue::True => TernaryValue::True,
            bet_syntax::ast::TernaryValue::False => TernaryValue::False,
            bet_syntax::ast::TernaryValue::Unknown => TernaryValue::Unknown,
        }),
        Literal::Int(i) => Value::Int(*i),
        Literal::Float(f) => Value::Float(*f),
        Literal::String(s) => Value::String(Arc::new(s.clone())),
    })
}

fn eval_bet(bet: &BetExpr, env: &mut ValueEnv<Value>) -> CompileResult<Value> {
    // Evaluate all three alternatives
    let values: Vec<_> = bet
        .alternatives
        .iter()
        .map(|alt| eval(&alt.value, env))
        .collect::<Result<_, _>>()?;

    // Randomly select one
    let idx = thread_rng().gen_range(0..3);
    Ok(values.into_iter().nth(idx).unwrap())
}

impl std::fmt::Display for Value {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Value::Unit => write!(f, "()"),
            Value::Bool(b) => write!(f, "{}", b),
            Value::Ternary(t) => write!(f, "{:?}", t),
            Value::Int(i) => write!(f, "{}", i),
            Value::Float(x) => write!(f, "{}", x),
            Value::String(s) => write!(f, "\"{}\"", s),
            Value::List(l) => {
                write!(f, "[")?;
                for (i, v) in l.iter().enumerate() {
                    if i > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{}", v)?;
                }
                write!(f, "]")
            }
            Value::Closure(_) => write!(f, "<closure>"),
        }
    }
}
