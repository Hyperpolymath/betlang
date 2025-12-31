// SPDX-License-Identifier: MIT OR Apache-2.0
//! Julia language bindings for Betlang
//!
//! Provides C-compatible FFI for Julia programs to use betlang primitives.
//!
//! Julia can call these functions using ccall:
//!
//! ```julia
//! bet_uniform(low, high) = ccall((:bet_uniform, libbet_julia), Cdouble, (Cdouble, Cdouble), low, high)
//! ```

// Re-export from chapel bindings since they share the same C interface
// In a real build, you might want to share code differently

use libc::{c_char, c_double, c_int, c_long, c_uint, size_t};
use rand::prelude::*;
use rand_distr::{Beta, Bernoulli, Binomial, Exp, Gamma, Normal, Poisson};
use std::ffi::CString;

// ============================================================================
// Core Ternary Bet Primitive
// ============================================================================

/// Ternary bet: returns 0, 1, or 2 with equal probability
#[no_mangle]
pub extern "C" fn bet_ternary() -> c_int {
    thread_rng().gen_range(0..3)
}

/// Weighted ternary bet
#[no_mangle]
pub extern "C" fn bet_weighted_ternary(w0: c_double, w1: c_double, w2: c_double) -> c_int {
    let total = w0 + w1 + w2;
    let r: f64 = thread_rng().gen();

    if r < w0 / total {
        0
    } else if r < (w0 + w1) / total {
        1
    } else {
        2
    }
}

/// Ternary logic value
#[no_mangle]
pub extern "C" fn bet_ternary_logic() -> c_int {
    thread_rng().gen_range(-1..=1)
}

// ============================================================================
// Discrete Distributions
// ============================================================================

#[no_mangle]
pub extern "C" fn bet_uniform_int(low: c_long, high: c_long) -> c_long {
    thread_rng().gen_range(low..=high)
}

#[no_mangle]
pub extern "C" fn bet_bernoulli(p: c_double) -> c_int {
    if let Ok(dist) = Bernoulli::new(p) {
        if dist.sample(&mut thread_rng()) { 1 } else { 0 }
    } else {
        0
    }
}

#[no_mangle]
pub extern "C" fn bet_binomial(n: c_uint, p: c_double) -> c_long {
    if let Ok(dist) = Binomial::new(n as u64, p) {
        dist.sample(&mut thread_rng()) as c_long
    } else {
        0
    }
}

#[no_mangle]
pub extern "C" fn bet_poisson(lambda: c_double) -> c_long {
    if let Ok(dist) = Poisson::new(lambda) {
        dist.sample(&mut thread_rng()) as c_long
    } else {
        0
    }
}

#[no_mangle]
pub extern "C" fn bet_categorical(weights: *const c_double, n: size_t) -> c_int {
    if weights.is_null() || n == 0 {
        return 0;
    }

    let weights_slice = unsafe { std::slice::from_raw_parts(weights, n) };
    let total: f64 = weights_slice.iter().sum();

    if total <= 0.0 {
        return 0;
    }

    let r: f64 = thread_rng().gen::<f64>() * total;
    let mut cumulative = 0.0;

    for (i, &w) in weights_slice.iter().enumerate() {
        cumulative += w;
        if r < cumulative {
            return i as c_int;
        }
    }

    (n - 1) as c_int
}

// ============================================================================
// Continuous Distributions
// ============================================================================

#[no_mangle]
pub extern "C" fn bet_uniform(low: c_double, high: c_double) -> c_double {
    thread_rng().gen_range(low..high)
}

#[no_mangle]
pub extern "C" fn bet_standard_normal() -> c_double {
    Normal::new(0.0, 1.0).unwrap().sample(&mut thread_rng())
}

#[no_mangle]
pub extern "C" fn bet_normal(mean: c_double, std: c_double) -> c_double {
    if let Ok(dist) = Normal::new(mean, std) {
        dist.sample(&mut thread_rng())
    } else {
        mean
    }
}

#[no_mangle]
pub extern "C" fn bet_exponential(rate: c_double) -> c_double {
    if let Ok(dist) = Exp::new(rate) {
        dist.sample(&mut thread_rng())
    } else {
        0.0
    }
}

#[no_mangle]
pub extern "C" fn bet_gamma(shape: c_double, scale: c_double) -> c_double {
    if let Ok(dist) = Gamma::new(shape, scale) {
        dist.sample(&mut thread_rng())
    } else {
        0.0
    }
}

#[no_mangle]
pub extern "C" fn bet_beta(alpha: c_double, beta: c_double) -> c_double {
    if let Ok(dist) = Beta::new(alpha, beta) {
        dist.sample(&mut thread_rng())
    } else {
        0.5
    }
}

// ============================================================================
// Array Operations
// ============================================================================

#[no_mangle]
pub extern "C" fn bet_sample_uniform_array(out: *mut c_double, n: size_t) {
    if out.is_null() || n == 0 {
        return;
    }

    let slice = unsafe { std::slice::from_raw_parts_mut(out, n) };
    let mut rng = thread_rng();

    for x in slice.iter_mut() {
        *x = rng.gen();
    }
}

#[no_mangle]
pub extern "C" fn bet_sample_normal_array(
    out: *mut c_double,
    n: size_t,
    mean: c_double,
    std: c_double,
) {
    if out.is_null() || n == 0 {
        return;
    }

    if let Ok(dist) = Normal::new(mean, std) {
        let slice = unsafe { std::slice::from_raw_parts_mut(out, n) };
        let mut rng = thread_rng();

        for x in slice.iter_mut() {
            *x = dist.sample(&mut rng);
        }
    }
}

#[no_mangle]
pub extern "C" fn bet_shuffle_real(arr: *mut c_double, n: size_t) {
    if arr.is_null() || n == 0 {
        return;
    }

    let slice = unsafe { std::slice::from_raw_parts_mut(arr, n) };
    slice.shuffle(&mut thread_rng());
}

// ============================================================================
// Statistics
// ============================================================================

#[no_mangle]
pub extern "C" fn bet_mean(arr: *const c_double, n: size_t) -> c_double {
    if arr.is_null() || n == 0 {
        return 0.0;
    }

    let slice = unsafe { std::slice::from_raw_parts(arr, n) };
    slice.iter().sum::<f64>() / n as f64
}

#[no_mangle]
pub extern "C" fn bet_variance(arr: *const c_double, n: size_t) -> c_double {
    if arr.is_null() || n == 0 {
        return 0.0;
    }

    let slice = unsafe { std::slice::from_raw_parts(arr, n) };
    let mean = slice.iter().sum::<f64>() / n as f64;
    slice.iter().map(|x| (x - mean).powi(2)).sum::<f64>() / n as f64
}

#[no_mangle]
pub extern "C" fn bet_std(arr: *const c_double, n: size_t) -> c_double {
    bet_variance(arr, n).sqrt()
}

#[no_mangle]
pub extern "C" fn bet_covariance(x: *const c_double, y: *const c_double, n: size_t) -> c_double {
    if x.is_null() || y.is_null() || n == 0 {
        return 0.0;
    }

    let x_slice = unsafe { std::slice::from_raw_parts(x, n) };
    let y_slice = unsafe { std::slice::from_raw_parts(y, n) };

    let x_mean = x_slice.iter().sum::<f64>() / n as f64;
    let y_mean = y_slice.iter().sum::<f64>() / n as f64;

    x_slice
        .iter()
        .zip(y_slice.iter())
        .map(|(xi, yi)| (xi - x_mean) * (yi - y_mean))
        .sum::<f64>()
        / n as f64
}

#[no_mangle]
pub extern "C" fn bet_correlation(x: *const c_double, y: *const c_double, n: size_t) -> c_double {
    let cov = bet_covariance(x, y, n);
    let std_x = bet_std(x, n);
    let std_y = bet_std(y, n);

    if std_x == 0.0 || std_y == 0.0 {
        0.0
    } else {
        cov / (std_x * std_y)
    }
}

#[no_mangle]
pub extern "C" fn bet_version() -> *const c_char {
    static VERSION: &str = concat!(env!("CARGO_PKG_VERSION"), "\0");
    VERSION.as_ptr() as *const c_char
}
