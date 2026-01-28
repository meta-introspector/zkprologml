
// Prolog interpreter extracted from MetaCoq
#![no_std]
extern crate alloc;
use alloc::vec::Vec;
use alloc::boxed::Box;

#[derive(Clone, Debug, PartialEq)]
pub enum Term {
    Var(u32),
    Atom(u32),  // String index
    Compound(u32, Vec<Term>),
}

#[derive(Clone, Debug)]
pub enum Goal {
    True,
    Unify(Term, Term),
    Call(Term),
    Conj(Box<Goal>, Box<Goal>),
}

pub type Clause = (Term, Goal);
pub type Env = Vec<Clause>;
pub type Subst = Vec<(u32, Term)>;

// Occurs check
fn occurs_check(v: u32, t: &Term) -> bool {
    match t {
        Term::Var(v2) => v == *v2,
        Term::Atom(_) => false,
        Term::Compound(_, args) => args.iter().any(|arg| occurs_check(v, arg)),
    }
}

// Unification
pub fn unify_terms(t1: &Term, t2: &Term, mut s: Subst) -> Option<Subst> {
    match (t1, t2) {
        (Term::Var(v1), Term::Var(v2)) if v1 == v2 => Some(s),
        (Term::Var(v), t) | (t, Term::Var(v)) => {
            if occurs_check(*v, t) {
                None
            } else {
                s.push((*v, t.clone()));
                Some(s)
            }
        }
        (Term::Atom(a1), Term::Atom(a2)) if a1 == a2 => Some(s),
        (Term::Compound(f1, args1), Term::Compound(f2, args2)) if f1 == f2 => {
            unify_list(args1, args2, s)
        }
        _ => None,
    }
}

fn unify_list(ts1: &[Term], ts2: &[Term], mut s: Subst) -> Option<Subst> {
    if ts1.len() != ts2.len() {
        return None;
    }
    for (t1, t2) in ts1.iter().zip(ts2.iter()) {
        s = unify_terms(t1, t2, s)?;
    }
    Some(s)
}

// Prolog interpreter
pub fn eval_goal(fuel: u32, g: &Goal, e: &Env, s: Subst) -> Option<Subst> {
    if fuel == 0 {
        return None;
    }
    
    match g {
        Goal::True => Some(s),
        Goal::Unify(t1, t2) => unify_terms(t1, t2, s),
        Goal::Call(t) => {
            // Try each clause
            for (head, body) in e {
                if let Some(s2) = unify_terms(t, head, s.clone()) {
                    if let Some(s3) = eval_goal(fuel - 1, body, e, s2) {
                        return Some(s3);
                    }
                }
            }
            None
        }
        Goal::Conj(g1, g2) => {
            let s2 = eval_goal(fuel - 1, g1, e, s)?;
            eval_goal(fuel - 1, g2, e, s2)
        }
    }
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}

#[global_allocator]
static ALLOCATOR: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;
