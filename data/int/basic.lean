/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad

The integers, with addition, multiplication, and subtraction.
-/
import data.nat.sub
open nat

namespace int

instance : inhabited ℤ := ⟨0⟩
meta instance : has_to_format ℤ := ⟨λ z, int.rec_on z (λ k, ↑k) (λ k, "-("++↑k++"+1)")⟩

/- /  -/

theorem of_nat_div (m n : nat) : of_nat (m / n) = (of_nat m) / (of_nat n) := rfl

theorem neg_succ_of_nat_div (m : nat) {b : ℤ} (H : b > 0) :
  -[1+m] / b = -(m / b + 1) :=
match b, eq_succ_of_zero_lt H with ._, ⟨n, rfl⟩ := rfl end

@[simp] protected theorem div_neg : ∀ (a b : ℤ), a / -b = -(a / b)
| (m : ℕ) 0       := show of_nat (m / 0) = -(m / 0 : ℕ), by rw nat.div_zero; refl
| (m : ℕ) (n+1:ℕ) := rfl
| 0       -[1+ n] := rfl
| (m+1:ℕ) -[1+ n] := (neg_neg _).symm
| -[1+ m] 0       := rfl
| -[1+ m] (n+1:ℕ) := rfl
| -[1+ m] -[1+ n] := rfl


theorem div_of_neg_of_pos {a b : ℤ} (Ha : a < 0) (Hb : b > 0) : a / b = -((-a - 1) / b + 1) :=
match a, b, eq_neg_succ_of_lt_zero Ha, eq_succ_of_zero_lt Hb with
| ._, ._, ⟨m, rfl⟩, ⟨n, rfl⟩ :=
  by change (- -[1+ m] : ℤ) with (m+1 : ℤ); rw add_sub_cancel; refl
end

protected theorem div_nonneg {a b : ℤ} (Ha : a ≥ 0) (Hb : b ≥ 0) : a / b ≥ 0 :=
match a, b, eq_coe_of_zero_le Ha, eq_coe_of_zero_le Hb with
| ._, ._, ⟨m, rfl⟩, ⟨n, rfl⟩ := coe_zero_le _
end

protected theorem div_nonpos {a b : ℤ} (Ha : a ≥ 0) (Hb : b ≤ 0) : a / b ≤ 0 :=
nonpos_of_neg_nonneg $ by rw [← int.div_neg]; exact int.div_nonneg Ha (neg_nonneg_of_nonpos Hb)

theorem div_neg' {a b : ℤ} (Ha : a < 0) (Hb : b > 0) : a / b < 0 :=
match a, b, eq_neg_succ_of_lt_zero Ha, eq_succ_of_zero_lt Hb with
| ._, ._, ⟨m, rfl⟩, ⟨n, rfl⟩ := neg_succ_lt_zero _
end

@[simp] protected theorem zero_div : ∀ (b : ℤ), 0 / b = 0
| 0       := rfl
| (n+1:ℕ) := rfl
| -[1+ n] := rfl

@[simp] protected theorem div_zero : ∀ (a : ℤ), a / 0 = 0
| 0       := rfl
| (n+1:ℕ) := rfl
| -[1+ n] := rfl

@[simp] protected theorem div_one : ∀ (a : ℤ), a / 1 = a
| 0       := rfl
| (n+1:ℕ) := congr_arg of_nat (nat.div_one _)
| -[1+ n] := congr_arg neg_succ_of_nat (nat.div_one _)

theorem div_eq_zero_of_lt {a b : ℤ} (H1 : 0 ≤ a) (H2 : a < b) : a / b = 0 :=
match a, b, eq_coe_of_zero_le H1, eq_succ_of_zero_lt (lt_of_le_of_lt H1 H2), H2  with
| ._, ._, ⟨m, rfl⟩, ⟨n, rfl⟩, H2 :=
  congr_arg of_nat $ nat.div_eq_of_lt $ lt_of_coe_nat_lt_coe_nat H2
end

theorem div_eq_zero_of_lt_abs {a b : ℤ} (H1 : 0 ≤ a) (H2 : a < abs b) : a / b = 0 :=
match b, abs b, abs_eq_nat_abs b, H2 with
| (n : ℕ), ._, rfl, H2 := div_eq_zero_of_lt H1 H2
| -[1+ n], ._, rfl, H2 := neg_inj $ by rw [← int.div_neg]; exact div_eq_zero_of_lt H1 H2
end

protected theorem add_mul_div_right (a b : ℤ) {c : ℤ} (H : c ≠ 0) :
  (a + b * c) / c = a / c + b :=
have ∀ {k n : ℕ} {a : ℤ}, (a + n * k.succ) / k.succ = a / k.succ + n, from
λ k n a, match a with
| (m : ℕ) := congr_arg of_nat $ nat.add_mul_div_right _ _ k.succ_pos
| -[1+ m] := show ((n * k.succ:ℕ) - m.succ : ℤ) / k.succ =
                  n - (m / k.succ + 1 : ℕ), begin
  cases lt_or_ge m (n*k.succ) with h h,
  { rw [← int.coe_nat_sub h,
        ← int.coe_nat_sub ((nat.div_lt_iff_lt_mul _ _ k.succ_pos).2 h)],
    apply congr_arg of_nat,
    rw [mul_comm, nat.mul_sub_div], rwa mul_comm },
  { change (↑(n * nat.succ k) - (m + 1) : ℤ) / ↑(nat.succ k) =
           ↑n - ((m / nat.succ k : ℕ) + 1),
    rw [← sub_sub, ← sub_sub, ← neg_sub (m:ℤ), ← neg_sub _ (n:ℤ),
        ← int.coe_nat_sub h,
        ← int.coe_nat_sub ((nat.le_div_iff_mul_le _ _ k.succ_pos).2 h),
        ← neg_succ_of_nat_coe', ← neg_succ_of_nat_coe'],
    { apply congr_arg neg_succ_of_nat,
      rw [mul_comm, nat.sub_mul_div], rwa mul_comm } }
  end
end,
have ∀ {a b c : ℤ}, c > 0 → (a + b * c) / c = a / c + b, from
λ a b c H, match c, eq_succ_of_zero_lt H, b with
| ._, ⟨k, rfl⟩, (n : ℕ) := this
| ._, ⟨k, rfl⟩, -[1+ n] :=
  show (a - n.succ * k.succ) / k.succ = (a / k.succ) - n.succ, from
  eq_sub_of_add_eq $ by rw [← this, sub_add_cancel]
end,
match lt_trichotomy c 0 with
| or.inl hlt          := neg_inj $ by rw [← int.div_neg, neg_add, ← int.div_neg, ← neg_mul_neg];
                         apply this (neg_pos_of_neg hlt)
| or.inr (or.inl heq) := absurd heq H
| or.inr (or.inr hgt) := this hgt
end

protected theorem add_mul_div_left (a : ℤ) {b : ℤ} (c : ℤ) (H : b ≠ 0) :
    (a + b * c) / b = a / b + c :=
by rw [mul_comm, int.add_mul_div_right _ _ H]

@[simp] protected theorem mul_div_cancel (a : ℤ) {b : ℤ} (H : b ≠ 0) : a * b / b = a :=
by have := int.add_mul_div_right 0 a H;
   rwa [zero_add, int.zero_div, zero_add] at this

@[simp] protected theorem mul_div_cancel_left {a : ℤ} (b : ℤ) (H : a ≠ 0) : a * b / a = b :=
by rw [mul_comm, int.mul_div_cancel _ H]

@[simp] protected theorem div_self {a : ℤ} (H : a ≠ 0) : a / a = 1 :=
by have := int.mul_div_cancel 1 H; rwa one_mul at this

/- mod -/

theorem of_nat_mod (m n : nat) : (m % n : ℤ) = of_nat (m % n) := rfl

theorem neg_succ_of_nat_mod (m : ℕ) {b : ℤ} (bpos : b > 0) :
  -[1+m] % b = b - 1 - m % b :=
by rw [sub_sub, add_comm]; exact
match b, eq_succ_of_zero_lt bpos with ._, ⟨n, rfl⟩ := rfl end

@[simp] theorem mod_neg : ∀ (a b : ℤ), a % -b = a % b
| (m : ℕ) n := @congr_arg ℕ ℤ _ _ (λ i, ↑(m % i)) (nat_abs_neg _)
| -[1+ m] n := @congr_arg ℕ ℤ _ _ (λ i, sub_nat_nat i (nat.succ (m % i))) (nat_abs_neg _)

@[simp] theorem mod_abs (a b : ℤ) : a % (abs b) = a % b :=
abs_by_cases (λ i, a % i = a % b) rfl (mod_neg _ _)

@[simp] theorem zero_mod (b : ℤ) : 0 % b = 0 :=
congr_arg of_nat $ nat.zero_mod _

@[simp] theorem mod_zero : ∀ (a : ℤ), a % 0 = a
| (m : ℕ) := congr_arg of_nat $ nat.mod_zero _
| -[1+ m] := congr_arg neg_succ_of_nat $ nat.mod_zero _

@[simp] theorem mod_one : ∀ (a : ℤ), a % 1 = 0
| (m : ℕ) := congr_arg of_nat $ nat.mod_one _
| -[1+ m] := show (1 - (m % 1).succ : ℤ) = 0, by rw nat.mod_one; refl

theorem mod_eq_of_lt {a b : ℤ} (H1 : 0 ≤ a) (H2 : a < b) : a % b = a :=
match a, b, eq_coe_of_zero_le H1, eq_coe_of_zero_le (le_trans H1 (le_of_lt H2)), H2 with
| ._, ._, ⟨m, rfl⟩, ⟨n, rfl⟩, H2 :=
  congr_arg of_nat $ nat.mod_eq_of_lt (lt_of_coe_nat_lt_coe_nat H2)
end

theorem mod_nonneg : ∀ (a : ℤ) {b : ℤ}, b ≠ 0 → a % b ≥ 0
| (m : ℕ) n H := coe_zero_le _
| -[1+ m] n H :=
  sub_nonneg_of_le $ coe_nat_le_coe_nat_of_le $ nat.mod_lt _ (nat_abs_pos_of_ne_zero H)

theorem mod_lt_of_pos (a : ℤ) {b : ℤ} (H : b > 0) : a % b < b :=
match a, b, eq_succ_of_zero_lt H with
| (m : ℕ), ._, ⟨n, rfl⟩ := coe_nat_lt_coe_nat_of_lt (nat.mod_lt _ (nat.succ_pos _))
| -[1+ m], ._, ⟨n, rfl⟩ := sub_lt_self _ (coe_nat_lt_coe_nat_of_lt $ nat.succ_pos _)
end

theorem mod_lt (a : ℤ) {b : ℤ} (H : b ≠ 0) : a % b < abs b :=
by rw [← mod_abs]; exact mod_lt_of_pos _ (abs_pos_of_ne_zero H)

theorem mod_add_div_aux (m n : ℕ) : (n - (m % n + 1) - (n * (m / n) + n) : ℤ) = -[1+ m] :=
begin
  rw [← sub_sub, neg_succ_of_nat_coe, sub_sub (n:ℤ)],
  apply eq_neg_of_eq_neg,
  rw [neg_sub, sub_sub_self, add_right_comm],
  exact @congr_arg ℕ ℤ _ _ (λi, (i + 1 : ℤ)) (nat.mod_add_div _ _).symm
end

theorem mod_add_div : ∀ (a b : ℤ), a % b + b * (a / b) = a
| (m : ℕ) 0       := congr_arg of_nat (nat.mod_add_div _ _)
| (m : ℕ) (n+1:ℕ) := congr_arg of_nat (nat.mod_add_div _ _)
| 0       -[1+ n] := rfl
| (m+1:ℕ) -[1+ n] := show (_ + -(n+1) * -((m + 1) / (n + 1) : ℕ) : ℤ) = _,
  by rw [neg_mul_neg]; exact congr_arg of_nat (nat.mod_add_div _ _)
| -[1+ m] 0       := by rw [mod_zero, int.div_zero]; refl
| -[1+ m] (n+1:ℕ) := mod_add_div_aux m n.succ
| -[1+ m] -[1+ n] := mod_add_div_aux m n.succ

theorem mod_def (a b : ℤ) : a % b = a - b * (a / b) :=
eq_sub_of_add_eq (mod_add_div _ _)

@[simp] theorem add_mul_mod_self {a b c : ℤ} : (a + b * c) % c = a % c :=
if cz : c = 0 then by rw [cz, mul_zero, add_zero] else
by rw [mod_def, mod_def, int.add_mul_div_right _ _ cz,
       mul_add, mul_comm, add_sub_add_right_eq_sub]

@[simp] theorem add_mul_mod_self_left (a b c : ℤ) : (a + b * c) % b = a % b :=
by rw [mul_comm, add_mul_mod_self]

@[simp] theorem add_mod_self {a b : ℤ} : (a + b) % b = a % b :=
by have := add_mul_mod_self_left a b 1; rwa mul_one at this

@[simp] theorem add_mod_self_left {a b : ℤ} : (a + b) % a = b % a :=
by rw [add_comm, add_mod_self]

@[simp] theorem mod_add_mod (m n k : ℤ) : (m % n + k) % n = (m + k) % n :=
by have := (add_mul_mod_self_left (m % n + k) n (m / n)).symm;
   rwa [add_right_comm, mod_add_div] at this

@[simp] theorem add_mod_mod (m n k : ℤ) : (m + n % k) % k = (m + n) % k :=
by rw [add_comm, mod_add_mod, add_comm]

theorem add_mod_eq_add_mod_right {m n k : ℤ} (i : ℤ) (H : m % n = k % n) :
  (m + i) % n = (k + i) % n :=
by rw [← mod_add_mod, ← mod_add_mod k, H]

theorem add_mod_eq_add_mod_left {m n k : ℤ} (i : ℤ) (H : m % n = k % n) :
  (i + m) % n = (i + k) % n :=
by rw [add_comm, add_mod_eq_add_mod_right _ H, add_comm]

theorem mod_eq_mod_of_add_mod_eq_add_mod_right {m n k i : ℤ}
    (H : (m + i) % n = (k + i) % n) :
  m % n = k % n :=
by have := add_mod_eq_add_mod_right (-i) H;
   rwa [add_neg_cancel_right, add_neg_cancel_right] at this

theorem mod_eq_mod_of_add_mod_eq_add_mod_left {m n k i : ℤ} :
  (i + m) % n = (i + k) % n → m % n = k % n :=
by rw [add_comm, add_comm i]; apply mod_eq_mod_of_add_mod_eq_add_mod_right

@[simp] theorem mul_mod_left (a b : ℤ) : (a * b) % b = 0 :=
by rw [← zero_add (a * b), add_mul_mod_self, zero_mod]

@[simp] theorem mul_mod_right (a b : ℤ) : (a * b) % a = 0 :=
by rw [mul_comm, mul_mod_left]

@[simp] theorem mod_self {a : ℤ} : a % a = 0 :=
by have := mul_mod_left 1 a; rwa one_mul at this

/- properties of / and % -/

@[simp] theorem mul_div_mul_of_pos {a : ℤ} (b c : ℤ) (H : a > 0) : a * b / (a * c) = b / c :=
suffices ∀ (m k : ℕ) (b : ℤ), (m.succ * b / (m.succ * k) : ℤ) = b / k, from
match a, eq_succ_of_zero_lt H, c, eq_coe_or_neg c with
| ._, ⟨m, rfl⟩, ._, ⟨k, or.inl rfl⟩ := this _ _ _
| ._, ⟨m, rfl⟩, ._, ⟨k, or.inr rfl⟩ :=
  by rw [← neg_mul_eq_mul_neg, int.div_neg, int.div_neg];
     apply congr_arg has_neg.neg; apply this
end,
λ m k b, match b, k with
| (n : ℕ), k   := congr_arg of_nat (nat.mul_div_mul _ _ m.succ_pos)
| -[1+ n], 0   := by rw [int.coe_nat_zero, mul_zero, int.div_zero, int.div_zero]
| -[1+ n], k+1 := congr_arg neg_succ_of_nat $
  show (m.succ * n + m) / (m.succ * k.succ) = n / k.succ, begin
    apply nat.div_eq_of_lt_le,
    { refine le_trans _ (nat.le_add_right _ _),
      rw [← nat.mul_div_mul _ _ m.succ_pos],
      apply nat.div_mul_le_self },
    { change m.succ * n.succ ≤ _,
      rw [mul_left_comm],
      apply nat.mul_le_mul_left,
      apply (nat.div_lt_iff_lt_mul _ _ k.succ_pos).1,
      apply nat.lt_succ_self }
  end
end

@[simp] theorem mul_div_mul_of_pos_left (a : ℤ) {b : ℤ} (c : ℤ) (H : b > 0) :
  a * b / (c * b) = a / c :=
by rw [mul_comm, mul_comm c, mul_div_mul_of_pos _ _ H]

@[simp] theorem mul_mod_mul_of_pos {a : ℤ} (b c : ℤ) (H : a > 0) : a * b % (a * c) = a * (b % c) :=
by rw [mod_def, mod_def, mul_div_mul_of_pos _ _ H, mul_sub_left_distrib, mul_assoc]

theorem lt_div_add_one_mul_self (a : ℤ) {b : ℤ} (H : b > 0) : a < (a / b + 1) * b :=
by rw [add_mul, one_mul, mul_comm]; apply lt_add_of_sub_left_lt;
   rw [← mod_def]; apply mod_lt_of_pos _ H

theorem abs_div_le_abs : ∀ (a b : ℤ), abs (a / b) ≤ abs a :=
suffices ∀ (a : ℤ) (n : ℕ), abs (a / n) ≤ abs a, from
λ a b, match b, eq_coe_or_neg b with
| ._, ⟨n, or.inl rfl⟩ := this _ _
| ._, ⟨n, or.inr rfl⟩ := by rw [int.div_neg, abs_neg]; apply this
end,
λ a n, by rw [abs_eq_nat_abs, abs_eq_nat_abs]; exact
coe_nat_le_coe_nat_of_le (match a, n with
| (m : ℕ), n := nat.div_le_self _ _
| -[1+ m], 0 := nat.zero_le _
| -[1+ m], n+1 := nat.succ_le_succ (nat.div_le_self _ _)
end)

theorem div_le_self {a : ℤ} (b : ℤ) (Ha : a ≥ 0) : a / b ≤ a :=
by have := le_trans (le_abs_self _) (abs_div_le_abs a b);
   rwa [abs_of_nonneg Ha] at this

theorem mul_div_cancel_of_mod_eq_zero {a b : ℤ} (H : a % b = 0) : b * (a / b) = a :=
by have := mod_add_div a b; rwa [H, zero_add] at this

theorem div_mul_cancel_of_mod_eq_zero {a b : ℤ} (H : a % b = 0) : a / b * b = a :=
by rw [mul_comm, mul_div_cancel_of_mod_eq_zero H]

/- dvd -/

theorem coe_nat_dvd_coe_nat_of_dvd {m n : ℕ} (h : m ∣ n) : (↑m : ℤ) ∣ ↑n :=
dvd.elim h $ λk e, dvd.intro k $ by rw [e, int.coe_nat_mul]

theorem dvd_of_coe_nat_dvd_coe_nat {m n : ℕ} (h : (↑m : ℤ) ∣ ↑n) : m ∣ n :=
dvd.elim h $ λa ae,
  m.eq_zero_or_pos.elim
  (λm0, by rw[m0, int.coe_nat_zero, zero_mul] at ae;
           rw [int.coe_nat_inj ae]; apply dvd_zero)
  (λm0l, let ⟨k, ke⟩ := int.eq_coe_of_zero_le $ nonneg_of_mul_nonneg_left
      (by rw [← ae]; apply int.coe_zero_le : 0 ≤ (m:ℤ) * a)
      (int.coe_nat_le_coe_nat_of_le m0l) in
    by rw [ke, ← int.coe_nat_mul] at ae; exact dvd.intro _ (int.coe_nat_inj ae).symm)

theorem coe_nat_dvd_coe_nat_iff (m n : ℕ) : (↑m : ℤ) ∣ ↑n ↔ m ∣ n :=
⟨dvd_of_coe_nat_dvd_coe_nat, coe_nat_dvd_coe_nat_of_dvd⟩

theorem dvd_antisymm {a b : ℤ} (H1 : a ≥ 0) (H2 : b ≥ 0) : a ∣ b → b ∣ a → a = b :=
begin
  rw [← abs_of_nonneg H1, ← abs_of_nonneg H2, abs_eq_nat_abs, abs_eq_nat_abs],
  rw [coe_nat_dvd_coe_nat_iff, coe_nat_dvd_coe_nat_iff, int.coe_nat_eq_coe_nat_iff],
  apply nat.dvd_antisymm
end

theorem dvd_of_mod_eq_zero {a b : ℤ} (H : b % a = 0) : a ∣ b :=
⟨b / a, (mul_div_cancel_of_mod_eq_zero H).symm⟩

theorem mod_eq_zero_of_dvd : ∀ {a b : ℤ}, a ∣ b → b % a = 0
| a ._ ⟨c, rfl⟩ := mul_mod_right _ _

theorem dvd_iff_mod_eq_zero (a b : ℤ) : a ∣ b ↔ b % a = 0 :=
⟨mod_eq_zero_of_dvd, dvd_of_mod_eq_zero⟩

instance decidable_dvd : @decidable_rel ℤ (∣) :=
assume a n, decidable_of_decidable_of_iff (by apply_instance) (dvd_iff_mod_eq_zero _ _).symm

protected theorem div_mul_cancel {a b : ℤ} (H : b ∣ a) : a / b * b = a :=
div_mul_cancel_of_mod_eq_zero (mod_eq_zero_of_dvd H)

protected theorem mul_div_cancel' {a b : ℤ} (H : a ∣ b) : a * (b / a) = b :=
by rw [mul_comm, int.div_mul_cancel H]

protected theorem mul_div_assoc (a : ℤ) : ∀ {b c : ℤ}, c ∣ b → (a * b) / c = a * (b / c)
| ._ c ⟨d, rfl⟩ := if cz : c = 0 then by simp [cz] else
  by rw [mul_left_comm, int.mul_div_cancel_left _ cz, int.mul_div_cancel_left _ cz]

theorem div_dvd_div : ∀ {a b c : ℤ} (H1 : a ∣ b) (H2 : b ∣ c), b / a ∣ c / a
| a ._ ._ ⟨b, rfl⟩ ⟨c, rfl⟩ := if az : a = 0 then by simp [az] else
  by rw [int.mul_div_cancel_left _ az, mul_assoc, int.mul_div_cancel_left _ az];
     apply dvd_mul_right

protected theorem div_eq_iff_eq_mul_right {a b : ℤ} (c : ℤ) (H : b ≠ 0) (H' : b ∣ a) :
  a / b = c ↔ a = b * c :=
⟨λ H1, by rw [← H1, int.mul_div_cancel' H'],
 λ H1, by rw [H1, int.mul_div_cancel_left _ H]⟩

protected theorem div_eq_iff_eq_mul_left {a b : ℤ} (c : ℤ) (H : b ≠ 0) (H' : b ∣ a) :
  a / b = c ↔ a = c * b :=
by rw mul_comm; exact int.div_eq_iff_eq_mul_right _ H H'

protected theorem eq_mul_of_div_eq_right {a b c : ℤ} (H1 : b ∣ a) (H2 : a / b = c) :
  a = b * c :=
by rw [← H2, int.mul_div_cancel' H1]

protected theorem div_eq_of_eq_mul_right {a b c : ℤ} (H1 : b ≠ 0) (H2 : a = b * c) :
  a / b = c :=
by rw [H2, int.mul_div_cancel_left _ H1]

protected theorem eq_mul_of_div_eq_left {a b c : ℤ} (H1 : b ∣ a) (H2 : a / b = c) :
  a = c * b :=
by rw [mul_comm, int.eq_mul_of_div_eq_right H1 H2]

protected theorem div_eq_of_eq_mul_left {a b c : ℤ} (H1 : b ≠ 0) (H2 : a = c * b) :
  a / b = c :=
int.div_eq_of_eq_mul_right H1 (by rw [mul_comm, H2])

theorem neg_div_of_dvd : ∀ {a b : ℤ} (H : b ∣ a), -a / b = -(a / b)
| ._ b ⟨c, rfl⟩ := if bz : b = 0 then by simp [bz] else
  by rw [neg_mul_eq_mul_neg, int.mul_div_cancel_left _ bz, int.mul_div_cancel_left _ bz]

protected theorem sign_eq_div_abs (a : ℤ) : sign a = a / (abs a) :=
if az : a = 0 then by simp [az] else
(int.div_eq_of_eq_mul_left (mt eq_zero_of_abs_eq_zero az)
  (sign_mul_abs _).symm).symm

theorem le_of_dvd {a b : ℤ} (bpos : b > 0) (H : a ∣ b) : a ≤ b :=
match a, b, eq_succ_of_zero_lt bpos, H with
| (m : ℕ), ._, ⟨n, rfl⟩, H := coe_nat_le_coe_nat_of_le $
  nat.le_of_dvd n.succ_pos $ dvd_of_coe_nat_dvd_coe_nat H
| -[1+ m], ._, ⟨n, rfl⟩, _ :=
  le_trans (le_of_lt $ neg_succ_lt_zero _) (coe_zero_le _)
end

theorem eq_one_of_dvd_one {a : ℤ} (H : a ≥ 0) (H' : a ∣ 1) : a = 1 :=
match a, eq_coe_of_zero_le H, H' with
| ._, ⟨n, rfl⟩, H' := congr_arg coe $
  nat.eq_one_of_dvd_one $ dvd_of_coe_nat_dvd_coe_nat H'
end

theorem eq_one_of_mul_eq_one_right {a b : ℤ} (H : a ≥ 0) (H' : a * b = 1) : a = 1 :=
eq_one_of_dvd_one H ⟨b, H'.symm⟩

theorem eq_one_of_mul_eq_one_left {a b : ℤ} (H : b ≥ 0) (H' : a * b = 1) : b = 1 :=
eq_one_of_mul_eq_one_right H (by rw [mul_comm, H'])

/- / and ordering -/

protected theorem div_mul_le (a : ℤ) {b : ℤ} (H : b ≠ 0) : a / b * b ≤ a :=
le_of_sub_nonneg $ by rw [mul_comm, ← mod_def]; apply mod_nonneg _ H

protected theorem div_le_of_le_mul {a b c : ℤ} (H : c > 0) (H' : a ≤ b * c) : a / c ≤ b :=
le_of_mul_le_mul_right (le_trans (int.div_mul_le _ (ne_of_gt H)) H') H

protected theorem mul_lt_of_lt_div {a b c : ℤ} (H : c > 0) (H3 : a < b / c) : a * c < b :=
lt_of_not_ge $ mt (int.div_le_of_le_mul H) (not_le_of_gt H3)

protected theorem mul_le_of_le_div {a b c : ℤ} (H1 : c > 0) (H2 : a ≤ b / c) : a * c ≤ b :=
le_trans (mul_le_mul_of_nonneg_right H2 (le_of_lt H1)) (int.div_mul_le _ (ne_of_gt H1))

protected theorem le_div_of_mul_le {a b c : ℤ} (H1 : c > 0) (H2 : a * c ≤ b) : a ≤ b / c :=
le_of_lt_add_one $ lt_of_mul_lt_mul_right
  (lt_of_le_of_lt H2 (lt_div_add_one_mul_self _ H1)) (le_of_lt H1)

protected theorem le_div_iff_mul_le {a b c : ℤ} (H : c > 0) : a ≤ b / c ↔ a * c ≤ b :=
⟨int.mul_le_of_le_div H, int.le_div_of_mul_le H⟩

protected theorem div_le_div {a b c : ℤ} (H : c > 0) (H' : a ≤ b) : a / c ≤ b / c :=
int.le_div_of_mul_le H (le_trans (int.div_mul_le _ (ne_of_gt H)) H')

protected theorem div_lt_of_lt_mul {a b c : ℤ} (H : c > 0) (H' : a < b * c) : a / c < b :=
lt_of_not_ge $ mt (int.mul_le_of_le_div H) (not_le_of_gt H')

protected theorem lt_mul_of_div_lt {a b c : ℤ} (H1 : c > 0) (H2 : a / c < b) : a < b * c :=
lt_of_not_ge $ mt (int.le_div_of_mul_le H1) (not_le_of_gt H2)

protected theorem div_lt_iff_lt_mul {a b c : ℤ} (H : c > 0) : a / c < b ↔ a < b * c :=
⟨int.lt_mul_of_div_lt H, int.div_lt_of_lt_mul H⟩

protected theorem le_mul_of_div_le {a b c : ℤ} (H1 : b ≥ 0) (H2 : b ∣ a) (H3 : a / b ≤ c) :
  a ≤ c * b :=
by rw [← int.div_mul_cancel H2]; exact mul_le_mul_of_nonneg_right H3 H1

protected theorem lt_div_of_mul_lt {a b c : ℤ} (H1 : b ≥ 0) (H2 : b ∣ c) (H3 : a * b < c) :
  a < c / b :=
lt_of_not_ge $ mt (int.le_mul_of_div_le H1 H2) (not_le_of_gt H3)

protected theorem lt_div_iff_mul_lt {a b : ℤ} (c : ℤ) (H : c > 0) (H' : c ∣ b) :
  a < b / c ↔ a * c < b :=
⟨int.mul_lt_of_lt_div H, int.lt_div_of_mul_lt (le_of_lt H) H'⟩

theorem div_pos_of_pos_of_dvd {a b : ℤ} (H1 : a > 0) (H2 : b ≥ 0) (H3 : b ∣ a) : a / b > 0 :=
int.lt_div_of_mul_lt H2 H3 (by rwa zero_mul)

theorem div_eq_div_of_mul_eq_mul {a b c d : ℤ} (H1 : b ∣ a) (H2 : d ∣ c) (H3 : b ≠ 0)
    (H4 : d ≠ 0) (H5 : a * d = b * c) :
  a / b = c / d :=
int.div_eq_of_eq_mul_right H3 $
by rw [← int.mul_div_assoc _ H2]; exact
(int.div_eq_of_eq_mul_left H4 H5.symm).symm

end int

namespace int

theorem of_nat_add_neg_succ_of_nat_of_lt {m n : ℕ} (h : m < succ n) : of_nat m + -[1+n] = -[1+ n - m] := 
begin
 change sub_nat_nat _ _ = _, 
 have h' : succ n - m = succ (n - m), 
 apply succ_sub,
 apply le_of_lt_succ h,
 simp [*, sub_nat_nat]
end

theorem of_nat_add_neg_succ_of_nat_of_ge {m n : ℕ} (h : m ≥ succ n) : of_nat m + -[1+n] = of_nat (m - succ n) := 
begin
 change sub_nat_nat _ _ = _,
 have h' : succ n - m = 0,
 apply sub_eq_zero_of_le h,
 simp [*, sub_nat_nat]
end

@[simp] theorem neg_add_neg (m n : ℕ) : -[1+m] + -[1+n] = -[1+nat.succ(m+n)] := rfl

/- nat abs -/

attribute [simp] nat_abs

/-
theorem nat_abs_add_le (a b : ℤ) : nat_abs (a + b) ≤ nat_abs a + nat_abs b := sorry

theorem nat_abs_neg_of_nat (n : nat) : nat_abs (neg_of_nat n) = n :=
by cases n; refl

section
theorem nat_abs_mul : Π (a b : ℤ), nat_abs (a * b) = (nat_abs a) * (nat_abs b)
| (of_nat m) (of_nat n) := rfl
| (of_nat m) -[1+ n]    := by simp [mul, nat_abs_neg_of_nat]
| -[1+ m]    (of_nat n) := by simp [mul_neg_succ_of_nat_of_nat, nat_abs_neg_of_nat]
| -[1+ m]    -[1+ n]    := rfl
end

/- additional properties -/
theorem of_nat_sub {m n : ℕ} (H : m ≥ n) : of_nat (m - n) = of_nat m - of_nat n :=
have m - n + n = m,     from nat.sub_add_cancel H,
begin
  symmetry,
  apply sub_eq_of_eq_add,
  rewrite [←of_nat_add, this]
end

theorem neg_succ_of_nat_eq' (m : ℕ) : -[1+ m] = -m - 1 :=
by rewrite [neg_succ_of_nat_eq, neg_add]

def succ (a : ℤ) := a + (succ zero)
def pred (a : ℤ) := a - (succ zero)
def nat_succ_eq_int_succ (n : ℕ) : nat.succ n = int.succ n := rfl
theorem pred_succ (a : ℤ) : pred (succ a) = a := !sub_add_cancel
theorem succ_pred (a : ℤ) : succ (pred a) = a := !add_sub_cancel

theorem neg_succ (a : ℤ) : -succ a = pred (-a) :=
by rewrite [↑succ,neg_add]

theorem succ_neg_succ (a : ℤ) : succ (-succ a) = -a :=
by rewrite [neg_succ,succ_pred]

theorem neg_pred (a : ℤ) : -pred a = succ (-a) :=
by rewrite [↑pred,neg_sub,sub_eq_add_neg,add.comm]

theorem pred_neg_pred (a : ℤ) : pred (-pred a) = -a :=
by rewrite [neg_pred,pred_succ]

theorem pred_nat_succ (n : ℕ) : pred (nat.succ n) = n := pred_succ n
theorem neg_nat_succ (n : ℕ) : -nat.succ n = pred (-n) := !neg_succ
theorem succ_neg_nat_succ (n : ℕ) : succ (-nat.succ n) = -n := !succ_neg_succ

attribute [unfold 2]
def rec_nat_on {P : ℤ → Type} (z : ℤ) (H0 : P 0)
  (Hsucc : Π⦃n : ℕ⦄, P n → P (succ n)) (Hpred : Π⦃n : ℕ⦄, P (-n) → P (-nat.succ n)) : P z :=
int.rec (nat.rec H0 Hsucc) (λn, nat.rec H0 Hpred (nat.succ n)) z

--the only computation rule of rec_nat_on which is not defintional
theorem rec_nat_on_neg {P : ℤ → Type} (n : nat) (H0 : P zero)
  (Hsucc : Π⦃n : nat⦄, P n → P (succ n)) (Hpred : Π⦃n : nat⦄, P (-n) → P (-nat.succ n))
  : rec_nat_on (-nat.succ n) H0 Hsucc Hpred = Hpred (rec_nat_on (-n) H0 Hsucc Hpred) :=
nat.rec rfl (λn H, rfl) n
-/

/- bitwise ops -/

@[simp] lemma bodd_zero : bodd 0 = ff := rfl
@[simp] lemma bodd_one : bodd 1 = tt := rfl
@[simp] lemma bodd_two : bodd 2 = ff := rfl

@[simp] lemma bodd_sub_nat_nat (m n : ℕ) : bodd (sub_nat_nat m n) = bxor m.bodd n.bodd :=
by apply sub_nat_nat_elim m n (λ m n i, bodd i = bxor m.bodd n.bodd);
   intros i m; simp [bodd]; cases i.bodd; cases m.bodd; refl

@[simp] lemma bodd_neg_of_nat (n : ℕ) : bodd (neg_of_nat n) = n.bodd :=
by cases n; simp; refl

@[simp] lemma bodd_neg (n : ℤ) : bodd (-n) = bodd n :=
by cases n; unfold has_neg.neg; simp [int.coe_nat_eq, int.neg, bodd]

@[simp] lemma bodd_add (m n : ℤ) : bodd (m + n) = bxor (bodd m) (bodd n) :=
by cases m with m m; cases n with n n; unfold has_add.add; simp [int.add, bodd];
   cases m.bodd; cases n.bodd; refl

@[simp] lemma bodd_mul (m n : ℤ) : bodd (m * n) = bodd m && bodd n :=
by cases m with m m; cases n with n n; unfold has_mul.mul; simp [int.mul, bodd];
   cases m.bodd; cases n.bodd; refl

theorem bodd_add_div2 : ∀ n, cond (bodd n) 1 0 + 2 * div2 n = n
| (n : ℕ) :=
  by rw [show (cond (bodd n) 1 0 : ℤ) = (cond (bodd n) 1 0 : ℕ),
         by cases bodd n; refl]; exact congr_arg of_nat n.bodd_add_div2
| -[1+ n] := begin
    refine eq.trans _ (congr_arg neg_succ_of_nat n.bodd_add_div2),
    dsimp [bodd], cases nat.bodd n; dsimp [cond, bnot, div2, int.mul],
    { change -[1+ 2 * nat.div2 n] = _, rw zero_add },
    { rw [zero_add, add_comm], refl }
  end

theorem div2_val : ∀ n, div2 n = n / 2
| (n : ℕ) := congr_arg of_nat n.div2_val
| -[1+ n] := congr_arg neg_succ_of_nat n.div2_val

lemma bit0_val (n : ℤ) : bit0 n = 2 * n := (two_mul _).symm

lemma bit1_val (n : ℤ) : bit1 n = 2 * n + 1 := congr_arg (+(1:ℤ)) (bit0_val _)

lemma bit_val (b n) : bit b n = 2 * n + cond b 1 0 :=
by { cases b, apply (bit0_val n).trans (add_zero _).symm, apply bit1_val }

lemma bit_decomp (n : ℤ) : bit (bodd n) (div2 n) = n :=
(bit_val _ _).trans $ (add_comm _ _).trans $ bodd_add_div2 _

def {u} bit_cases_on {C : ℤ → Sort u} (n) (h : ∀ b n, C (bit b n)) : C n :=
by rw [← bit_decomp n]; apply h

@[simp] lemma bit_zero : bit ff 0 = 0 := rfl

@[simp] lemma bit_coe_nat (b) (n : ℕ) : bit b n = nat.bit b n :=
by rw [bit_val, nat.bit_val]; cases b; refl

@[simp] lemma bit_neg_succ (b) (n : ℕ) : bit b -[1+ n] = -[1+ nat.bit (bnot b) n] :=
by rw [bit_val, nat.bit_val]; cases b; refl

@[simp] lemma bodd_bit (b n) : bodd (bit b n) = b :=
by rw bit_val; simp; cases b; cases bodd n; refl

@[simp] lemma div2_bit (b n) : div2 (bit b n) = n :=
begin
  rw [bit_val, div2_val, add_comm, int.add_mul_div_left, (_ : (_/2:ℤ) = 0), zero_add],
  cases b, all_goals {exact dec_trivial}
end

@[simp] lemma test_bit_zero (b) : ∀ n, test_bit (bit b n) 0 = b
| (n : ℕ) := by rw [bit_coe_nat]; apply nat.test_bit_zero
| -[1+ n] := by rw [bit_neg_succ]; dsimp [test_bit]; rw [nat.test_bit_zero];
                clear test_bit_zero; cases b; refl

@[simp] lemma test_bit_succ (m b) : ∀ n, test_bit (bit b n) (nat.succ m) = test_bit n m
| (n : ℕ) := by rw [bit_coe_nat]; apply nat.test_bit_succ
| -[1+ n] := by rw [bit_neg_succ]; dsimp [test_bit]; rw [nat.test_bit_succ]

private meta def bitwise_tac : tactic unit := `[
  apply funext, intro m,
  apply funext, intro n,
  cases m with m m; cases n with n n; try {refl},
  all_goals {
    apply congr_arg of_nat <|> apply congr_arg neg_succ_of_nat,
    try {dsimp [nat.land, nat.ldiff, nat.lor]},
    try {rw [
      show nat.bitwise (λ a b, a && bnot b) n m =
           nat.bitwise (λ a b, b && bnot a) m n, from
      congr_fun (congr_fun (@nat.bitwise_swap (λ a b, b && bnot a) rfl) n) m]},
    apply congr_arg (λ f, nat.bitwise f m n),
    apply funext, intro a,
    apply funext, intro b,
    cases a; cases b; refl
  },
  all_goals {unfold nat.land nat.ldiff nat.lor}
]

theorem bitwise_or   : bitwise bor                  = lor   := by bitwise_tac
theorem bitwise_and  : bitwise band                 = land  := by bitwise_tac
theorem bitwise_diff : bitwise (λ a b, a && bnot b) = ldiff := by bitwise_tac
theorem bitwise_xor  : bitwise bxor                 = lxor  := by bitwise_tac

@[simp] lemma bitwise_bit (f : bool → bool → bool) (a m b n) :
  bitwise f (bit a m) (bit b n) = bit (f a b) (bitwise f m n) :=
begin
  cases m with m m; cases n with n n;
  repeat { rw [← int.coe_nat_eq] <|> rw bit_coe_nat <|> rw bit_neg_succ };
  unfold bitwise nat_bitwise bnot;
  [ ginduction f ff ff with h,
    ginduction f ff tt with h,
    ginduction f tt ff with h,
    ginduction f tt tt with h ],
  all_goals {
    unfold cond, rw nat.bitwise_bit,
    repeat { rw bit_coe_nat <|> rw bit_neg_succ <|> rw bnot_bnot } },
  all_goals { unfold bnot {fail_if_unchanged := ff}; rw h; refl }
end

@[simp] lemma lor_bit (a m b n) : lor (bit a m) (bit b n) = bit (a || b) (lor m n) :=
by rw [← bitwise_or, bitwise_bit]

@[simp] lemma land_bit (a m b n) : land (bit a m) (bit b n) = bit (a && b) (land m n) :=
by rw [← bitwise_and, bitwise_bit]

@[simp] lemma ldiff_bit (a m b n) : ldiff (bit a m) (bit b n) = bit (a && bnot b) (ldiff m n) :=
by rw [← bitwise_diff, bitwise_bit]

@[simp] lemma lxor_bit (a m b n) : lxor (bit a m) (bit b n) = bit (bxor a b) (lxor m n) :=
by rw [← bitwise_xor, bitwise_bit]

@[simp] lemma lnot_bit (b) : ∀ n, lnot (bit b n) = bit (bnot b) (lnot n)
| (n : ℕ) := by simp [lnot]
| -[1+ n] := by simp [lnot]

@[simp] lemma test_bit_bitwise (f : bool → bool → bool) (m n k) :
  test_bit (bitwise f m n) k = f (test_bit m k) (test_bit n k) :=
begin
  revert m n; induction k with k IH; intros m n;
  apply bit_cases_on m; intros a m';
  apply bit_cases_on n; intros b n';
  rw bitwise_bit,
  { simp [test_bit_zero] },
  { simp [test_bit_succ, IH] }
end

@[simp] lemma test_bit_lor (m n k) : test_bit (lor m n) k = test_bit m k || test_bit n k :=
by rw [← bitwise_or, test_bit_bitwise]

@[simp] lemma test_bit_land (m n k) : test_bit (land m n) k = test_bit m k && test_bit n k :=
by rw [← bitwise_and, test_bit_bitwise]

@[simp] lemma test_bit_ldiff (m n k) : test_bit (ldiff m n) k = test_bit m k && bnot (test_bit n k) :=
by rw [← bitwise_diff, test_bit_bitwise]

@[simp] lemma test_bit_lxor (m n k) : test_bit (lxor m n) k = bxor (test_bit m k) (test_bit n k) :=
by rw [← bitwise_xor, test_bit_bitwise]

@[simp] lemma test_bit_lnot : ∀ n k, test_bit (lnot n) k = bnot (test_bit n k)
| (n : ℕ) k := by simp [lnot, test_bit]
| -[1+ n] k := by simp [lnot, test_bit]

lemma shiftl_add : ∀ (m : ℤ) (n : ℕ) (k : ℤ), shiftl m (n + k) = shiftl (shiftl m n) k
| (m : ℕ) n (k:ℕ) := congr_arg of_nat (nat.shiftl_add _ _ _)
| -[1+ m] n (k:ℕ) := congr_arg neg_succ_of_nat (nat.shiftl'_add _ _ _ _)
| (m : ℕ) n -[1+k] := sub_nat_nat_elim n k.succ
    (λ n k i, shiftl ↑m i = nat.shiftr (nat.shiftl m n) k)
    (λ i n, congr_arg coe $
      by rw [← nat.shiftl_sub, nat.add_sub_cancel_left]; apply nat.le_add_right)
    (λ i n, congr_arg coe $
      by rw [add_assoc, nat.shiftr_add, ← nat.shiftl_sub, nat.sub_self]; refl)
| -[1+ m] n -[1+k] := sub_nat_nat_elim n k.succ
    (λ n k i, shiftl -[1+ m] i = -[1+ nat.shiftr (nat.shiftl' tt m n) k])
    (λ i n, congr_arg neg_succ_of_nat $
      by rw [← nat.shiftl'_sub, nat.add_sub_cancel_left]; apply nat.le_add_right)
    (λ i n, congr_arg neg_succ_of_nat $
      by rw [add_assoc, nat.shiftr_add, ← nat.shiftl'_sub, nat.sub_self]; refl)

lemma shiftl_sub (m : ℤ) (n : ℕ) (k : ℤ) : shiftl m (n - k) = shiftr (shiftl m n) k :=
shiftl_add _ _ _

@[simp] lemma shiftl_neg (m n : ℤ) : shiftl m (-n) = shiftr m n := rfl
@[simp] lemma shiftr_neg (m n : ℤ) : shiftr m (-n) = shiftl m n := by rw [← shiftl_neg, neg_neg]

@[simp] lemma shiftl_coe_nat (m n : ℕ) : shiftl m n = nat.shiftl m n := rfl
@[simp] lemma shiftr_coe_nat (m n : ℕ) : shiftr m n = nat.shiftr m n := by cases n; refl

@[simp] lemma shiftl_neg_succ (m n : ℕ) : shiftl -[1+ m] n = -[1+ nat.shiftl' tt m n] := rfl
@[simp] lemma shiftr_neg_succ (m n : ℕ) : shiftr -[1+ m] n = -[1+ nat.shiftr m n] := by cases n; refl

lemma shiftr_add : ∀ (m : ℤ) (n k : ℕ), shiftr m (n + k) = shiftr (shiftr m n) k
| (m : ℕ) n k := by rw [shiftr_coe_nat, shiftr_coe_nat,
                        ← int.coe_nat_add, shiftr_coe_nat, nat.shiftr_add]
| -[1+ m] n k := by rw [shiftr_neg_succ, shiftr_neg_succ,
                        ← int.coe_nat_add, shiftr_neg_succ, nat.shiftr_add]

lemma shiftl_eq_mul_pow : ∀ (m : ℤ) (n : ℕ), shiftl m n = m * 2 ^ n
| (m : ℕ) n := congr_arg coe (nat.shiftl_eq_mul_pow _ _)
| -[1+ m] n := @congr_arg ℕ ℤ _ _ (λi, -i) (nat.shiftl'_tt_eq_mul_pow _ _)

lemma shiftr_eq_div_pow : ∀ (m : ℤ) (n : ℕ), shiftr m n = m / 2 ^ n
| (m : ℕ) n := by rw shiftr_coe_nat; exact congr_arg coe (nat.shiftr_eq_div_pow _ _)
| -[1+ m] n := begin
  rw [shiftr_neg_succ, neg_succ_of_nat_div, nat.shiftr_eq_div_pow], refl,
  exact coe_nat_lt_coe_nat_of_lt (nat.pos_pow_of_pos _ dec_trivial)
end

lemma one_shiftl (n : ℕ) : shiftl 1 n = (2 ^ n : ℕ) :=
congr_arg coe (nat.one_shiftl _)

@[simp] lemma zero_shiftl : ∀ n : ℤ, shiftl 0 n = 0
| (n : ℕ) := congr_arg coe (nat.zero_shiftl _)
| -[1+ n] := congr_arg coe (nat.zero_shiftr _)

@[simp] lemma zero_shiftr (n) : shiftr 0 n = 0 := zero_shiftl _

end int